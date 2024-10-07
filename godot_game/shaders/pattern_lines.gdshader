shader_type canvas_item;

uniform vec4 bg_col : source_color;

uniform vec4 one_col : source_color;
uniform float one_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float one_opacity : hint_range(0.0, 1.0, 0.1) = .2;

uniform vec4 two_col : source_color;
uniform float two_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float two_opacity : hint_range(0.0, 1.0, 0.1) = .2;

void fragment() {
	COLOR = bg_col;
	
	vec2 uv1 = UV + TIME * one_speed;
	vec2 uv2 = UV - TIME * two_speed;
	
	vec2 mod_1 = mod(floor(uv1 * 12.), 2.);
	vec2 mod_2 = mod(floor(uv2 * 12.), 2.);
	COLOR += one_col * (mod_1.x + mod_2.x) * one_opacity;
	COLOR += two_col * (mod_2.y + mod_1.y) * two_opacity;
}
