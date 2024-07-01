shader_type canvas_item;

uniform float rows = 20;
uniform float columns = 10;
uniform float lineSize = .1;
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
	vec2 sdim = (vec2(1, 1) / SCREEN_PIXEL_SIZE);  // inverted
	vec2 grid_uv = UV * sdim;
	float lSize = (lineSize / 1.0);
	
	float columnWidth = (sdim.x / columns);
	float xMod = (grid_uv.x - (lSize * columnWidth) * 0.5) / columnWidth;
	xMod -= floor(xMod);
	if (xMod > 1.0 - lSize && xMod < 1.0) {
		COLOR = color;
	}
	
}
