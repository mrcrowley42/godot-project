shader_type canvas_item;

uniform vec2 resolution = vec2(600.0, 400.0);
uniform vec4 bg_color: source_color;
uniform vec4 line_color: source_color = vec4(0.2, 0.3, 0.5, 1);
//uniform float zoom: hint_range(1.0, 50.0, 0.1) = 20.0;
uniform float thickness: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float brightness: hint_range(0.1, 4.0, 0.1) = 2.0;
uniform float scale: hint_range(0.01, 3.0, 0.01) = 0.5;

float draw_grid(vec2 uv) {
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

vec2 rotate(vec2 uv, float angle) {
	return uv * mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	uv += vec2(sin(TIME) * 0.4, cos(TIME) * 0.6);
	uv = rotate(uv, TIME * 0.1);
	uv = UV + TIME * 0.05;
	float zoom = abs(sin(0.6 * scale)) * 40.0;
	float line_thickness = zoom * thickness / resolution.y;
	vec4 color = smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv * zoom)) * line_color;
	COLOR = bg_color * (1.-color.a);
	COLOR += color;
}