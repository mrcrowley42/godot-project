shader_type canvas_item;

uniform float rows = 20;
uniform float columns = 10;
uniform float lineSize = .1;
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
	vec2 sdim = (vec2(1, 1) / SCREEN_PIXEL_SIZE);  // inverted
	vec2 grid_uv = UV * sdim;
	float lSize = (lineSize / 1.0);
	
	float columnWidth = sdim.x / columns;
	float rowHeight = sdim.y / rows;
	vec2 offset = vec2((lSize * columnWidth) * 0.5, (lSize * rowHeight) * 0.5);
	
	vec2 modu = vec2(grid_uv.x - offset.x, grid_uv.y - offset.y);
	modu /= vec2(columnWidth, rowHeight);
	modu -= floor(modu);
	
	// idk why i dont need to max the rhs of the && lmao perplexing
	if (max(modu.x, modu.y) > 1.0 - lSize && modu.x < 1.0) {
		COLOR = color;
	}
}
