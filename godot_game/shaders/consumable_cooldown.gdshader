shader_type canvas_item;

uniform float percent = 1;

void fragment() {
	COLOR.a -= step(percent, UV.x) * .6;
}
