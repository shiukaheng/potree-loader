precision highp float;
precision highp int;

uniform mat4 viewMatrix;
uniform vec3 cameraPosition;
uniform mat4 projectionMatrix;
uniform float opacity;
uniform float blendHardness;
uniform float blendDepthSupplement;
uniform float fov;
uniform float spacing;
uniform float pcIndex;
uniform float screenWidth;
uniform float screenHeight;
uniform sampler2D depthMap;

out vec4 fragColor;
in float vOpacity;

#ifdef new_format
	in vec4 vColor;
#else
	in vec3 vColor;
#endif

#if defined(paraboloid_point_shape)
	in vec3 vViewPosition;
#endif

#if defined(paraboloid_point_shape)
	in float vRadius;
#endif

void main() {

	#ifdef new_format
		// set actualColor vec3 from vec4 vColor
		vec3 actualColor = vColor.xyz;
	#else
		// set actualColor RGB from the XYZ of vColor
		vec3 actualColor = vColor;
	#endif
	
	vec3 color = actualColor;
	float depth = gl_FragCoord.z;

	#if defined(circle_point_shape) || defined(paraboloid_point_shape) || defined (weighted_splats)

		float u = 2.0 * gl_PointCoord.x - 1.0;
		float v = 2.0 * gl_PointCoord.y - 1.0;

	#endif
		
	fragColor = vec4(color, vOpacity);
	
	#if defined paraboloid_point_shape

		float wi = 0.0 - ( u*u + v*v);
		vec4 pos = vec4(vViewPosition, 1.0);
		pos.z += wi * vRadius;
		float linearDepth = -pos.z;
		pos = projectionMatrix * pos;
		pos = pos / pos.w;
		float expDepth = pos.z;
		depth = (pos.z + 1.0) / 2.0;
		gl_FragDepth = depth;

		#if defined(color_type_depth)
			gl_FragColor.r = linearDepth;
			gl_FragColor.g = expDepth;
		#endif

		#if defined(use_edl)
			gl_FragColor.a = log2(linearDepth);
		#endif

	#endif
}