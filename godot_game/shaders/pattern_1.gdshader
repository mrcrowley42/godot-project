shader_type canvas_item;

uniform vec4 bg_col : source_color;

uniform vec4 one_col : source_color = vec4(.03, .0, .03, 1.);
uniform float one_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float one_size : hint_range(5., 20., 1) = 10.;
uniform vec4 two_col : source_color = vec4(.01, .0, .06, 1.);
uniform float two_speed : hint_range(-.5, .5, 0.01) = -.02;
uniform float two_size : hint_range(5., 20., 1.) = 10.;

float grid(vec2 uv, float size) {
	vec2 fragmented = mod(floor((uv * size)), 2.);
	return mod(fragmented.x + fragmented.y, 2.);
}

void fragment() {
	vec2 uv1 = UV + TIME * one_speed;
	vec2 uv2 = UV + TIME * two_speed;
	
	COLOR = bg_col;
	COLOR += vec4(one_col * grid(uv1, one_size));
	COLOR += vec4(two_col * grid(uv2, two_size));
}
