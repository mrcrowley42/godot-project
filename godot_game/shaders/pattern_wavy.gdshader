shader_type canvas_item;

uniform vec4 bg_col : source_color;
uniform bool double = true;
uniform float size : hint_range(1.0, 20.0, 0.5) = 12.;

uniform vec4 one_col : source_color;
uniform float one_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float one_opacity : hint_range(0.0, 1.0, 0.05) = .2;

float wave(float x) {
	return cos(PI * x);
}

void fragment() {
	COLOR = bg_col;
	
	vec2 uv1 = UV + TIME * one_speed;
	uv1.y += cos(uv1.x);
	vec2 mod_1 = mod(floor(uv1 * size), 2.);
	
	COLOR += one_col * mod_1.y * one_opacity;
}
