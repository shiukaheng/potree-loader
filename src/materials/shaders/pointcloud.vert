#version 300 es

precision highp float;
precision highp int;

in vec3 position;
in vec3 normal;

uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat3 normalMatrix;

uniform float pcIndex;
uniform float screenWidth;
uniform float screenHeight;
uniform float fov;
uniform float spacing;

#if defined use_clip_box
	uniform mat4 clipBoxes[max_clip_boxes];
#endif

uniform float heightMin;
uniform float heightMax;
uniform float size; // pixel size factor
uniform float minSize; // minimum pixel size
uniform float maxSize; // maximum pixel size
uniform float octreeSize;
uniform vec3 bbSize; // bounding box size?
uniform vec3 uColor;
uniform float opacity;
uniform float level;

uniform float filterByNormalThreshold;
uniform float opacityAttenuation;

// LOD calculation
uniform float vnStart;
uniform bool isLeafNode;
uniform sampler2D visibleNodes;

// Passed to fragment shader
uniform sampler2D depthMap;

#ifdef new_format
	in vec4 rgba;
	out vec4 vColor;
#else
	in vec3 color;
	out vec3 vColor;
#endif

out float vOpacity;

#if defined(paraboloid_point_shape)
	out vec3 vViewPosition;
	out float vRadius;
#endif

// out vec3 vNormal;

#include lod.vert;
#include getRGB.vert;
#include colorConversion.vert;


void main() {
	/**

	Notes:
	- "position" is position of the point in model space
	- "modelViewMatrix" transforms from model to view space (position relative to camera), a.k.a. extrinsic matrix
	- "projectionMatrix" transforms from view to clip space (position relative to the screen), a.k.a. intrinsic matrix

	*/
	vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
	gl_Position = projectionMatrix * mvPosition;
	#if defined(paraboloid_point_shape)
		vViewPosition = mvPosition.xyz;
	#endif

	// vNormal = normalize(normalMatrix * normal);
	// vLogDepth = log2(-mvPosition.z);
	// float linearDepth = -mvPosition.z ;
	// float expDepth = (gl_Position.z / gl_Position.w) * 0.5 + 0.5;
	// vColor = vec3(linearDepth, expDepth, 0.0);

	// ---------------------
	// POINT SIZE
	// ---------------------

	float pointSize = 1.0;
	float slope = tan(fov / 2.0);
	float projFactor =  -0.5 * screenHeight / (slope * mvPosition.z);

	#if defined fixed_point_size
		pointSize = size;
	#elif defined attenuated_point_size
		pointSize = size * spacing * projFactor;
	#elif defined adaptive_point_size
		float worldSpaceSize = 2.0 * size * spacing / getPointSizeAttenuation();
		pointSize = worldSpaceSize * projFactor;
	#endif

	pointSize = max(minSize, pointSize);
	pointSize = min(maxSize, pointSize);

	#if defined(paraboloid_point_shape)
		vRadius = pointSize / projFactor;
	#endif

	gl_PointSize = pointSize;

	// ---------------------
	// OPACITY
	// ---------------------

	#ifdef attenuated_opacity
		vOpacity = opacity * exp(-length(-mvPosition.xyz) / opacityAttenuation);
	#else
		vOpacity = opacity;
	#endif

	// ---------------------
	// FILTERING
	// ---------------------

	#ifdef use_filter_by_normal
		if(abs((modelViewMatrix * vec4(normal, 0.0)).z) > filterByNormalThreshold) {
			// Move point outside clip space space to discard it.
			gl_Position = vec4(0.0, 0.0, 2.0, 1.0);
		}
	#endif

	// ---------------------
	// POINT COLOR
	// ---------------------	

	#ifdef new_format
		vColor = rgba;
	#elif defined color_type_rgb
		vColor = getRGB();
	#endif

	#if defined(output_color_encoding_sRGB) && defined(input_color_encoding_linear)
		vColor = toLinear(vColor);
	#endif

	#if defined(output_color_encoding_linear) && defined(input_color_encoding_sRGB)
		vColor = fromLinear(vColor);
	#endif
}
