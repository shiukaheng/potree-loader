#ifdef new_format
	vec4 fromLinear(vec4 linearRGB) {
		bvec4 cutoff = lessThan(linearRGB, vec4(0.0031308));
		vec4 higher = vec4(1.055)*pow(linearRGB, vec4(1.0/2.4)) - vec4(0.055);
		vec4 lower = linearRGB * vec4(12.92);
		return mix(higher, lower, cutoff);
	} 
	vec4 toLinear(vec4 sRGB) {
		bvec4 cutoff = lessThan(sRGB, vec4(0.04045));
		vec4 higher = pow((sRGB + vec4(0.055))/vec4(1.055), vec4(2.4));
		vec4 lower = sRGB/vec4(12.92);
		return mix(higher, lower, cutoff);
	}
#else
	vec3 fromLinear(vec3 linearRGB) {
		bvec3 cutoff = lessThan(linearRGB, vec3(0.0031308));
		vec3 higher = vec3(1.055)*pow(linearRGB, vec3(1.0/2.4)) - vec3(0.055);
		vec3 lower = linearRGB * vec3(12.92);
		return mix(higher, lower, cutoff);
	}
	vec3 toLinear(vec3 sRGB) {
		bvec3 cutoff = lessThan(sRGB, vec3(0.04045));
		vec3 higher = pow((sRGB + vec3(0.055))/vec3(1.055), vec3(2.4));
		vec3 lower = sRGB/vec3(12.92);
		return mix(higher, lower, cutoff);
	}
#endif