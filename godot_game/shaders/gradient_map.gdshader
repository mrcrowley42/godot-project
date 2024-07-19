shader_type canvas_item;
uniform sampler2D gradient;

void fragment() {
	vec4 colour = texture(TEXTURE, UV);
	float brightness = (colour.r + colour.g + colour.b) / 3.0;
	vec4 outputColour = texture(gradient, vec2(brightness));
	COLOR = outputColour; 
}
