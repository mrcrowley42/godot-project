shader_type canvas_item;

uniform vec4 bg_col : source_color;
uniform bool shift_one_left = false;

uniform vec4 one_col : source_color = vec4(.03, .0, .03, 1.);
uniform float one_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float one_size : hint_range(5., 20., 1) = 10.;
uniform float one_opacity : hint_range(0.0, 1.0, 0.1) = .2;

uniform vec4 two_col : source_color = vec4(.01, .0, .06, 1.);
uniform float two_speed : hint_range(-.5, .5, 0.01) = -.02;
uniform float two_size : hint_range(5., 20., 1.) = 10.;
uniform float two_opacity : hint_range(0.0, 1.0, 0.1) = .2;

float grid(vec2 scaledUv) {
	vec2 fragmented = mod(floor(scaledUv), 2.);
	return mod(fragmented.x + fragmented.y, 2.);
}

void fragment() {
	COLOR = bg_col;
	
	vec2 uv1 = UV + TIME * one_speed;
	vec2 uv2 = UV + TIME * two_speed;
	if (shift_one_left) {
		uv1 = vec2(-uv1.y, uv1.x);
	}
	
	COLOR += vec4(one_col * grid(uv1 * one_size) * one_opacity);
	COLOR += vec4(two_col * grid(uv2 * two_size) * two_opacity);
}
