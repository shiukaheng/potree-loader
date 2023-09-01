// ---------------------
// OCTREE
// ---------------------

#if (defined(adaptive_point_size) || defined(color_type_lod)) && defined(tree_type_octree)

/**
 * Gets the number of 1-bits up to inclusive index position.
 * 
 * number is treated as if it were an integer in the range 0-255
 */
int numberOfOnes(int number, int index) {
	int numOnes = 0;
	int tmp = 128;
	for (int i = 7; i >= 0; i--) {

		if (number >= tmp) {
			number = number - tmp;

			if (i <= index) {
				numOnes++;
			}
		}

		tmp = tmp / 2;
	}

	return numOnes;
}

/**
 * Checks whether the bit at index is 1.0
 *
 * number is treated as if it were an integer in the range 0-255
 */
bool isBitSet(int number, int index){

	// weird multi else if due to lack of proper array, int and bitwise support in WebGL 1.0
	int powi = 1;
	if (index == 0) {
		powi = 1;
	} else if (index == 1) {
		powi = 2;
	} else if (index == 2) {
		powi = 4;
	} else if (index == 3) {
		powi = 8;
	} else if (index == 4) {
		powi = 16;
	} else if (index == 5) {
		powi = 32;
	} else if (index == 6) {
		powi = 64;
	} else if (index == 7) {
		powi = 128;
	}

	int ndp = number / powi;

	return mod(float(ndp), 2.0) != 0.0;
}

/**
 * Gets the the LOD at the point position.
 */
float getLOD() {
	vec3 offset = vec3(0.0, 0.0, 0.0);
	int iOffset = int(vnStart);
	float depth = level;

	for (float i = 0.0; i <= 30.0; i++) {
		float nodeSizeAtLevel = octreeSize  / pow(2.0, i + level + 0.0);
		
		vec3 index3d = (position-offset) / nodeSizeAtLevel;
		index3d = floor(index3d + 0.5);
		int index = int(round(4.0 * index3d.x + 2.0 * index3d.y + index3d.z));
		
		vec4 value = texture(visibleNodes, vec2(float(iOffset) / 2048.0, 0.0));
		int mask = int(round(value.r * 255.0));

		if (isBitSet(mask, index)) {
			// there are more visible child nodes at this position
			int advanceG = int(round(value.g * 255.0)) * 256;
			int advanceB = int(round(value.b * 255.0));
			int advanceChild = numberOfOnes(mask, index - 1);
			int advance = advanceG + advanceB + advanceChild;

			iOffset = iOffset + advance;

			depth++;
		} else {
			return value.a * 255.0; // no more visible child nodes at this position
		}
		
		offset = offset + (vec3(1.0, 1.0, 1.0) * nodeSizeAtLevel * 0.5) * index3d;  
	}
		
	return depth;
}

float getPointSizeAttenuation() {
	return 0.5 * pow(2.0, getLOD());
}

#endif

// ---------------------
// KD-TREE
// ---------------------

#if (defined(adaptive_point_size) || defined(color_type_lod)) && defined(tree_type_kdtree)

float getLOD() {
	vec3 offset = vec3(0.0, 0.0, 0.0);
	float intOffset = 0.0;
	float depth = 0.0;
			
	vec3 size = bbSize;	
	vec3 pos = position;
		
	for (float i = 0.0; i <= 1000.0; i++) {
		
		vec4 value = texture(visibleNodes, vec2(intOffset / 2048.0, 0.0));
		
		int children = int(value.r * 255.0);
		float next = value.g * 255.0;
		int split = int(value.b * 255.0);
		
		if (next == 0.0) {
		 	return depth;
		}
		
		vec3 splitv = vec3(0.0, 0.0, 0.0);
		if (split == 1) {
			splitv.x = 1.0;
		} else if (split == 2) {
		 	splitv.y = 1.0;
		} else if (split == 4) {
		 	splitv.z = 1.0;
		}
		
		intOffset = intOffset + next;
		
		float factor = length(pos * splitv / size);
		if (factor < 0.5) {
		 	// left
			if (children == 0 || children == 2) {
				return depth;
			}
		} else {
			// right
			pos = pos - size * splitv * 0.5;
			if (children == 0 || children == 1) {
				return depth;
			}
			if (children == 3) {
				intOffset = intOffset + 1.0;
			}
		}
		size = size * ((1.0 - (splitv + 1.0) / 2.0) + 0.5);
		
		depth++;
	}
		
		
	return depth;	
}

float getPointSizeAttenuation() {
	return 0.5 * pow(1.3, getLOD());
}

#endif