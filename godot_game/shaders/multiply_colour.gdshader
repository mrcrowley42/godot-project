shader_type canvas_item;
uniform vec4 tint_colour: source_color;
uniform float tint_strength: hint_range(0.0, 2.0, 0.1) = 1;
void fragment() {
	vec4 colour = texture(TEXTURE,UV);
	vec4 tinted_image = colour * tint_colour;
	vec4 final = mix(colour, tinted_image,tint_strength);
	COLOR = final;
}