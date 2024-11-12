shader_type canvas_item;

uniform vec4 bg_col : source_color;
uniform float rotation : hint_range(0.0, 359., .5) = 0.;
uniform bool double = true;
uniform float size : hint_range(1.0, 20.0, 0.5) = 12.;

uniform vec4 one_col : source_color;
uniform float one_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float one_opacity : hint_range(0.0, 1.0, 0.05) = .2;

uniform vec4 two_col : source_color;
uniform float two_speed : hint_range(-.5, .5, 0.01) = .02;
uniform float two_opacity : hint_range(0.0, 1.0, 0.05) = .2;

vec2 rotate_point(vec2 pos, float angle){
     return vec2(cos(angle) * pos.x - sin(angle) * pos.y + pos.x,
                 sin(angle) * pos.x + cos(angle) * pos.y + pos.y);
}

void fragment() {
	COLOR = bg_col;

	vec2 rotated = rotate_point(UV, rotation * PI / 180.);
	vec2 uv1 = rotated + TIME * one_speed;
	vec2 uv2 = rotated - TIME * two_speed;

	vec2 mod_1 = mod(floor(uv1 * size), 2.);
	vec2 mod_2 = mod(floor(uv2 * size), 2.);

	COLOR += one_col * (mod_1.x + (mod_2.x * float(double))) * one_opacity;
	COLOR += two_col * (mod_2.y + (mod_1.y * float(double))) * two_opacity;
}
