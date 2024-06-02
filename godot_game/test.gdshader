shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec3 colour = texture(screen_texture, SCREEN_UV).rgb;
	colour.r = colour.r *1.0;
	colour.g = colour.g *1.0;
	colour.b = colour.b *0.6;
	COLOR.rgb = colour;
}

