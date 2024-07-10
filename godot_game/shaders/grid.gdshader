shader_type canvas_item;

uniform float rows = 10;
uniform float columns = 10;
uniform float lineSize = .1;
uniform float brightnessAddition = 0.0;
uniform vec4 color : source_color = vec4(1.0);

uniform bool offsetCentered = true;
uniform vec2 offsetOverride = vec2(0.0);

uniform bool bevel = true;
uniform vec4 bevelColor : source_color = vec4(1.0);

uniform bool outline = false;
uniform vec4 outlineColor : source_color = vec4(1.0);

bool shouldBevel(vec2 remainder) {
	if (bevel) {
		float mid = 1.0 - (lineSize / 2.0);
		bool xMid = remainder.x > mid;
		bool yMid = remainder.y > mid;
		if (xMid || yMid) {
			float invMid = 1.0 - mid;
			float avg = ((1.0 - remainder.y) + (1.0 - remainder.x)) / 2.0;  // omg so many inversions
			return 1.0 - avg < 1.0 - invMid || (xMid && yMid);
		}
	}
	return false;
}

bool shouldOutline(vec2 screenDim, vec2 scaledUV, vec2 offset) {
	if (outline) {
		bool shouldX = offset.x > scaledUV.x || scaledUV.x > screenDim.x - offset.x;
		if (shouldX) {return true;}  // cheeky early return
		return offset.y > scaledUV.y || scaledUV.y > screenDim.y - offset.y;
	}
	return false;
}

void fragment() {
	vec2 screenDim = 1.0 / SCREEN_PIXEL_SIZE;  // inverted to get dimensions
	vec2 scaledUV = UV * screenDim;
	
	float columnWidth = screenDim.x / columns;
	float rowHeight = screenDim.y / rows;
	vec2 offset = offsetCentered ? vec2((lineSize * columnWidth) * 0.5, (lineSize * rowHeight) * 0.5) : offsetOverride;
	
	// perform 'modulus' operation with floats
	vec2 remainder = vec2(scaledUV.x - offset.x, scaledUV.y - offset.y);
	remainder /= vec2(columnWidth, rowHeight);
	remainder -= floor(remainder);  // actually get the remainder (will be =< 0 and > 1 whithin each grid square)
	
	float maxRem = max(remainder.x, remainder.y);
	float full = 1.0 - lineSize;
	
	// apply colours
	if (maxRem > full) {
		COLOR = color;
		
		if (shouldOutline(screenDim, scaledUV, offset)) {
			COLOR = outlineColor;
		} else if (shouldBevel(remainder)) {
			COLOR = bevelColor;
		}
		COLOR += brightnessAddition;
	}
}
