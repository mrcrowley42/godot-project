/*
HYPER UNOPTIMISED RAY CASTING (BEWARE: SHITTY CODE AHEAD)

im actually not kidding this thing is slow as hell.
like from 700 fps to 330
i'll optimise later... when i feel like it
*/

shader_type canvas_item;

const float EPSILON = .0001;

// depending upon the light map this could optimise ray casting
// if there is less red than black toggle this on
// function: toggle ray to cast from either red pixels or clear pixels
uniform bool reverse_ray_cast = false;
uniform bool anti_alias_ray = false;

uniform float ray_length : hint_range(0.0, 1.0) = .15;
uniform float ray_rotation : hint_range(0.0, 360.0) = 155.;
uniform float ray_strength : hint_range(0.0, 2.0) = 2.;
uniform int ray_quality : hint_range(0, 20) = 5;  // do not mess too much with this

uniform float bg_length : hint_range(0.0, 1.0) = .7;
uniform float bg_strength : hint_range(0.0, 2.0) = .8;
uniform float bg_falloff : hint_range(0.0, 1.0) = .8;

uniform vec4 colour : source_color = vec4(1.0, 0.9, 0.65, 1);
uniform sampler2D light_map;

vec2 rotate_offset(vec2 centre, float offset) {
	vec2 point = centre + offset;
	vec2 vec_out = vec2(0., 0.);
	float rad = (ray_rotation + 45.) * (PI / 180.);  // add 45 so it points up at 0 degrees
	vec_out.x = centre.x + cos(rad) * (point.x - centre.x) - sin(rad) * (point.y - centre.y);
	vec_out.y = centre.y + sin(rad) * (point.x - centre.x) + cos(rad) * (point.y - centre.y);
	return vec_out;
}

void fragment() {
	// BACKGROUND
	float bg_rays = 1.0 * smoothstep(0.0, bg_falloff, (bg_length - UV.y));  // fade bottom
	vec3 bg_col = vec3(bg_rays) * colour.rgb;
	float light_map_r = texture(light_map, UV).r;
	
	// colour bg
	if (light_map_r > EPSILON){
		float final_strength = bg_strength * light_map_r;
		COLOR = vec4(bg_col * final_strength, bg_rays * final_strength);
	}
	
	// RAYS
	float offset = 0.;
	while (true) {
		vec2 ray_cast = rotate_offset(UV, offset);
		
		bool out_of_bounds = min(ray_cast.x, ray_cast.y) < .0 || max(ray_cast.x, ray_cast.y) > 1.;
		if (offset > ray_length || out_of_bounds) {  // outside of bounds or too long, stop casting
			offset = 0.;
			break;
		}
		
		if (texture(light_map, ray_cast).r > EPSILON) {
			break;  // found red, stop casting
		}
		
		offset += SCREEN_PIXEL_SIZE.y * float(ray_quality);  // x or y it doesnt really matter
	}
	
	// colour ray
	if (offset > 0.) {
		COLOR = vec4(colour.rgb, (ray_length - offset) * ray_strength);
	}
}
