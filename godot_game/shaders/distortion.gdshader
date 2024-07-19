shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DISPLACEMENT_MAP: repeat_enable;
uniform float strength: hint_range(0.0, 100.0, 0.01);
void fragment() {
	vec4 noise_colour = texture(DISPLACEMENT_MAP, UV + vec2(0.02,0) * TIME);
	//vec2 displacedUV = SCREEN_UV - texture(DISPLACEMENT_MAP, UV).g * strength / 1000.0;
	//vec4 screen_colour = texture(SCREEN_TEXTURE, displacedUV);
	//COLOR = screen_colour;
	vec4 displaced_colour = texture(SCREEN_TEXTURE, SCREEN_UV + strength/100.0 * noise_colour.rr);
	COLOR = displaced_colour;
}

