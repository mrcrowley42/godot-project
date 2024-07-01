shader_type canvas_item;

uniform float rows = 10;
uniform float columns = 10;
uniform float lineSize = .1;
uniform vec4 color : source_color = vec4(1.0);
uniform bool bevel = true;
uniform vec4 bevelColor : source_color = vec4(1.0);

bool shouldBevel(vec2 remainder, float lSize) {
	float mid = 1.0 - (lSize / 2.0);
	
	bool xMid = remainder.x > mid;
	bool yMid = remainder.y > mid;
	if (bevel && (xMid || yMid)) {
		float invMid = 1.0 - mid;
		float avg = ((1.0 - remainder.y) + (1.0 - remainder.x)) / 2.0;  // omg so many inversions
		return 1.0 - avg < 1.0 - invMid || (xMid && yMid);
	}
	return false;
}

void fragment() {
	vec2 screenDim = vec2(1, 1) / SCREEN_PIXEL_SIZE;  // inverted to get dimensions
	vec2 scaledUv = UV * screenDim;
	float lSize = lineSize / 1.0;
	
	float columnWidth = screenDim.x / columns;
	float rowHeight = screenDim.y / rows;
	vec2 offset = vec2((lSize * columnWidth) * 0.5, (lSize * rowHeight) * 0.5);
	
	// perform 'modulus' operation
	vec2 remainder = vec2(scaledUv.x - offset.x, scaledUv.y - offset.y);
	remainder /= vec2(columnWidth, rowHeight);
	remainder -= floor(remainder);  // actually get the remainder
	
	float maxRem = max(remainder.x, remainder.y);  // will never be > 1
	float full = 1.0 - lSize;
	
	if (maxRem > full) {
		COLOR = color;
		if (shouldBevel(remainder, lSize)) {
			COLOR = bevelColor;
		}
	}
}
