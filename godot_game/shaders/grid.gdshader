shader_type canvas_item;

uniform float rows = 10;
uniform float columns = 10;
uniform float lineSize = .1;
uniform vec4 color : source_color = vec4(1.0);
uniform bool bevel = true;
uniform vec4 bevelColor : source_color = vec4(1.0);

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
	
	float maxRem = max(remainder.x, remainder.y);  // btw will never be > 1
	if (maxRem > 1.0 - lSize) {
		if (bevel && maxRem > 1.0 - lSize / 2.0) {
			COLOR = bevelColor;  // add bevel
		} else {
			COLOR = color;
		}
	}
}
