shader_type canvas_item;
uniform float outline_thickness: hint_range(0.0, 10.0, 0.01);
uniform vec4 outline_colour: source_color;
void fragment() {
	float thickness_x = outline_thickness*10.0/float(textureSize(TEXTURE, 0).x);
	float thickness_y = outline_thickness*10.0/float(textureSize(TEXTURE, 0).y);
	vec4 sprite_colour = texture(TEXTURE, UV);
	float alpha = -8.0 * sprite_colour.a;
	alpha += texture(TEXTURE, UV + vec2(thickness_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-thickness_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, thickness_y)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -thickness_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-thickness_x, thickness_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-thickness_x, -thickness_y)).a;
	alpha += texture(TEXTURE, UV + vec2(thickness_x, thickness_y)).a;
	alpha += texture(TEXTURE, UV + vec2(thickness_x, -thickness_y)).a;
	vec4 output_colour = mix(sprite_colour, outline_colour, clamp(alpha,0.0,1.0));
	COLOR = vec4(output_colour.rgb, clamp(abs(alpha) + sprite_colour.a, 0.0, 1.0) * output_colour.a);
}