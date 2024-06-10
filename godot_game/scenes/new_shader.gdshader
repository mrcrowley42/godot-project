shader_type canvas_item;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec3 colour = texture(screen_texture, SCREEN_UV).rgb;
	colour.r = colour.r *COLOR.r;
	colour.g = colour.g *COLOR.g;
	colour.b = colour.b *COLOR.b;
	COLOR.rgb = colour;
}

