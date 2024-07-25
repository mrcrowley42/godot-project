/*
HYPER UNOPTIMISED RAY CASTING (BEWARE: SHITTY CODE AHEAD)

im actually not kidding this thing is slow as hell.
like from 700 fps to 330
i'll optimise later... when i feel like it

also the ray length is super scuffed
*/

shader_type canvas_item;

// depending upon the light map this could optimise ray casting
// if there is less red than black toggle this on
// function: toggle ray cast from red pixels or clear pixels
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

vec2 get_ray_cast(vec2 centre, float offset) {
	// rotate points around centre
	vec2 point = centre + offset;
	vec2 v_out = vec2(0., 0.);
	float rad = (ray_rotation + 45.) * (PI / 180.);  // add 45 so it points up at 0 degrees
	v_out.x = centre.x + cos(rad) * (point.x - centre.x) - sin(rad) * (point.y - centre.y);
	v_out.y = centre.y + sin(rad) * (point.x - centre.x) + cos(rad) * (point.y - centre.y);
	return v_out;
}

void fragment() {
	// BACKGROUND
	float bg_rays = 1.0 * smoothstep(0.0, bg_falloff, (bg_length - UV.y));  // fade bottom
	vec3 bg_col = (vec3(bg_rays) * colour.rgb);
	float light_map_r = texture(light_map, UV).r;
	bool in_red = light_map_r != 0.;
	
	// colour bg
	if (in_red){
		float final_strength = bg_strength * light_map_r;
		COLOR = vec4(bg_col * final_strength, bg_rays * final_strength);
	}
	
	// RAYS
	float offset = 0.;
	while (true) {
		vec2 ray_cast = get_ray_cast(UV, offset);
		
		// outside of bounds, stop casting
		vec2 leng = ray_cast - UV;
		if (ray_cast.x < 0. || ray_cast.y < 0. || ray_cast.x > UV.x + ray_length || ray_cast.y > UV.y + ray_length) {
			offset = 0.;
			break;
		}
		
		// found red, stop casting
		if (texture(light_map, ray_cast).r != 0.) {
			break;
		}
		
		// progress ray
		offset += SCREEN_PIXEL_SIZE.y * float(ray_quality);  // x or y it doesnt really matter
	}
	
	// colour ray
	if (offset > 0.) {
		COLOR = vec4(colour.rgb, (ray_length - offset) * ray_strength);
	}
}
