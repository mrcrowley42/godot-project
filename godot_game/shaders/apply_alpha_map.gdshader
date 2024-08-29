shader_type canvas_item;

const float EPSILON = 0.0001;
uniform sampler2D alpha_map;
uniform vec2 normal = vec2(1, 0);

void fragment() {
	vec4 map_col = texture(alpha_map, UV);
	vec2 col = vec2(map_col.r, map_col.g) * normal;
	float threshold = 1. - EPSILON;
	// this SUCKS IDK WHY IF CANT GET IT TO DO WHAT I WANT IT TO
	// OH MY GOD WHAT >:(
	if (col.r - (map_col.g - threshold) > threshold) {
		COLOR.a = 0.;
	}
	if (col.g - (map_col.r - threshold) > threshold) {
		COLOR.a = 0.;
	}
}
