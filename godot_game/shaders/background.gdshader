/*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/god-rays

Feel free to use, improve and change this shader according to your needs
and consider sharing the modified result on godotshaders.com.
*/

shader_type canvas_item;

uniform float angle = -0.1;
uniform vec2 position = vec2(0.2, 0.2);
uniform float v_length : hint_range(0.0, 1.0) = 0.5;
uniform float strength : hint_range(0.0, 1.0) = 0.3;
uniform float spread : hint_range(0.0, 1.0) = 0.5;
uniform float girth : hint_range(-1.0, 1.0) = 0.1;
uniform float falloff : hint_range(0.0, 1.0) = 0.8;
uniform float edge_fade : hint_range(0.0, 1.0) = 0.1;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.65, 1);

mat2 rotate(float _angle){
	vec2 a = vec2(cos(_angle), -sin(_angle));
	vec2 b = vec2(sin(_angle), cos(_angle));
    return mat2(a, b);
}

void fragment()
{
	// Rotate, skew and move the UVs
	vec2 transformed_uv = ( rotate(angle) * (UV - position) )  / ( (UV.y + spread) - (UV.y * spread) );
	vec2 ray = vec2(transformed_uv.x, 1.0);
	
	float cut = step(girth, transformed_uv.x) * step(girth, 1.0 - transformed_uv.x);
	ray *= cut;  // Cut off the ray's edges
	
	float rays = 1.0;
	// Fade out edges
	rays *= smoothstep(0.0, falloff, (v_length - UV.y)); // Bottom
	rays *= smoothstep(0.0 + girth, edge_fade + girth, transformed_uv.x); // Left
	rays *= smoothstep(0.0 + girth, edge_fade + girth, 1.0 - transformed_uv.x); // Right
	
	// Color to the rays
	vec3 shine_col = (vec3(rays) * color.rgb);
	COLOR += vec4(shine_col * strength, rays);
}
