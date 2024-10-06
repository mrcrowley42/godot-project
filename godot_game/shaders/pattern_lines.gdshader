shader_type canvas_item;

uniform vec4 bg_col : source_color;

void fragment() {
	COLOR = bg_col;
}
