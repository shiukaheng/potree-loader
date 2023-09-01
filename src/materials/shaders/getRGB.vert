// formula adapted from: http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/image-processing-algorithms-part-5-contrast-adjustment/
float getContrastFactor(float contrast) {
	return (1.0158730158730156 * (contrast + 1.0)) / (1.0158730158730156 - contrast);
}

#ifndef new_format

vec3 getRGB() {
	#if defined(use_rgb_gamma_contrast_brightness)
	  vec3 rgb = color;
		rgb = pow(rgb, vec3(rgbGamma));
		rgb = rgb + rgbBrightness;
		rgb = (rgb - 0.5) * getContrastFactor(rgbContrast) + 0.5;
		rgb = clamp(rgb, 0.0, 1.0);
		return rgb;
	#else
		return color;
	#endif
}

#endif