shader_type canvas_item;

uniform vec4 color_behind: source_color = vec4(.7, 1, 1, 1);
uniform vec4 color: source_color = vec4(.6, .75, 1, 1);
uniform float fade_length: hint_range(0.0, 1.0, 0.05) = .8;
uniform float intensity: hint_range(0.0, 10.0, 0.1) = .4;

void fragment() {
	float y = (UV.y + (1.-fade_length));
	y += sin((TIME+UV.x)*2.) * .06;
	float col_mul = (abs(cos(TIME*.3)) + intensity) * .5;
	COLOR = color_behind * COLOR.a;
	COLOR += (color * col_mul) * (1. - y);
}