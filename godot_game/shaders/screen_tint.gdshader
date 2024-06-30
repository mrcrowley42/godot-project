shader_type canvas_item;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform float strength:hint_range(0.0,2.0) = 1.0;
void fragment() {
	vec3 colour = texture(screen_texture, SCREEN_UV).rgb;
	vec3 overlay_colour = COLOR.rgb;
	vec3 multiplied = colour * overlay_colour;
	vec3 blended = mix(colour, multiplied, strength);
	//colour.r = colour.r *COLOR.r;
	//colour.g = colour.g *COLOR.g;
	//colour.b = colour.b *COLOR.b;
	COLOR.rgb = blended;
}

