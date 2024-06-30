shader_type canvas_item;
uniform float width: hint_range(0.0, 30.0);
uniform vec4 border_colour: source_color;


void fragment() {
	float size = width * 1.0 / float(textureSize(TEXTURE,0).x);
	vec4 source_colour = texture(TEXTURE, UV);
	float alpha = -8.0 * source_colour.a;
	alpha += texture(TEXTURE, UV + vec2(0, -size)).a;
	alpha += texture(TEXTURE, UV + vec2(size, -size)).a;
	alpha += texture(TEXTURE, UV + vec2(size, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(size, size)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size)).a;
	alpha += texture(TEXTURE, UV + vec2(-size, size)).a;
	alpha += texture(TEXTURE, UV + vec2(-size, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size, -size)).a;
	
	COLOR = vec4(border_colour.rgb, alpha);

}

