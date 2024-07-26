/*
HYPER UNOPTIMISED RAY CASTING (BEWARE: SHITTY CODE AHEAD)

Fade edge if heavy on performance atm :( 
as in 200-300 fps lost
*/

shader_type canvas_item;

const float EPSILON = .0001;

uniform bool debug_mode = false;

// depending upon the light map this could optimise ray casting
// if there is less red than black, toggle this on
// FYI: NOT IMPLEMENTED YET
uniform bool flip_ray_cast_strategy = false;
uniform bool fade_ray_edge = true;
uniform float ray_fade_margin : hint_range(.1, .5) = .25;  // .5 meets at middle (i think)
uniform int ray_fade_quality : hint_range(1, 10) = 5;

uniform float ray_length : hint_range(0.0, 1.0) = .15;
uniform float ray_direction : hint_range(0.0, 360.0) = 155.;
uniform float ray_strength : hint_range(0.0, 2.0) = 2.;
uniform int ray_quality : hint_range(1, 20) = 5;

uniform float bg_length : hint_range(0.0, 1.0) = .7;
uniform float bg_strength : hint_range(0.0, 2.0) = .8;
uniform float bg_falloff : hint_range(0.0, 1.0) = .8;

uniform vec4 colour : source_color = vec4(1.0, 0.9, 0.65, 1);
uniform sampler2D LIGHT_MAP;

vec2 rotate_point(float point, float deg) {
	float rad = deg * (PI / 180.);
	return vec2(
		point * cos(rad) - point * sin(rad),
		point * sin(rad) + point * cos(rad)
	);
}

// ray cast from red pixels
float raycast_other(vec2 uv, vec2 ray_step, float ray_len, vec2 offset_storage) {
	return .0;
}

// ray cast from from_pos until it hits red and returns length of ray & stores offset in offset_store.
// returns -1. if max_length or bounds have been reached instead of a red.
float raycast_to_red(vec2 from_pos, vec2 ray_step, float step_length, float max_length, vec2 offset_storage) {
	float len = 0.;
	while (true) {
		vec2 ray_cast = from_pos + offset_storage;
		if (texture(LIGHT_MAP, ray_cast).r > EPSILON) {   // found red
			return len;
		}
		bool out_of_bounds = min(ray_cast.x, ray_cast.y) < EPSILON || max(ray_cast.x, ray_cast.y) > 1.;
		if (len > max_length || out_of_bounds) {  // outside of bounds or too long, stop casting
			return -1.;
		}
		offset_storage += ray_step;
		len += step_length;
	}
}

void fragment() {
	float direction = ray_direction + 45.;  // add 45 so it points up a 0 deg
	
	// BACKGROUND
	float light_map_r = texture(LIGHT_MAP, UV).r;
	bool is_red = light_map_r > EPSILON;
	if (is_red) {
		float bg_rays = smoothstep(0.0, bg_falloff, (bg_length - UV.y));  // fade bottom
		float final_strength = bg_strength * light_map_r;
		vec3 bg_col = vec3(bg_rays) * colour.rgb;
		COLOR = vec4(bg_col * final_strength, bg_rays * final_strength);
	}
	
	// RAYS
	float step_length = SCREEN_PIXEL_SIZE.y * float(max(1, int(ray_quality)));  // DO NOT ALLOW LESS THAN 1
	vec2 ray_step = rotate_point(step_length, direction);  // 1 step in direction of ray
	
	vec2 final_offset = vec2(0.);
	float final_length = 0.;
	if (flip_ray_cast_strategy && is_red) {
		final_length = raycast_other(UV, ray_step, step_length, final_offset);
	} else if (!flip_ray_cast_strategy && !is_red) {
		final_length = raycast_to_red(UV, ray_step, step_length, ray_length, final_offset);
	}
	
	if (final_length > EPSILON) {  // is a ray
		float debug_on = 1. * float(debug_mode);
		COLOR = vec4(colour.rgb, (ray_length - final_length) * ray_strength + debug_on);  // debug sets alpha to 1
		
		// FADE EDGE
		if (fade_ray_edge) {
			bool searching = true;
			float max_dist_from_offset = ray_fade_margin * .5;
			float dist_from_offset = 0.;
			
			float fade_step_length = SCREEN_PIXEL_SIZE.y * float(max(1, int(ray_fade_quality)));
			vec2 fade_ray_step = rotate_point(fade_step_length, direction);
			
			vec2 closest_red = UV + final_offset;
			vec2 perp_norm = normalize(ray_step) * max_dist_from_offset;  // sets direction (idk it just works)
			perp_norm = vec2(-perp_norm.y, perp_norm.x);  // perpendicular to ray step
			
			// captured in raycast and re-used in next raycast (to check ("glide") along a red areas border (as perpenticular is raised with each check))
			vec2 prev_lhs = vec2(0.);
			vec2 prev_rhs = vec2(0.);
			
			int fail_safe = 0;
			while (searching) {
				float lhs_len = raycast_to_red(closest_red + (perp_norm * dist_from_offset), fade_ray_step, fade_step_length, ray_length, prev_lhs);
				float rhs_len = raycast_to_red(closest_red + (-perp_norm * dist_from_offset), fade_ray_step, fade_step_length, ray_length, prev_rhs);
				float len = min(lhs_len, rhs_len);
				searching = !(len < -EPSILON || dist_from_offset >= max_dist_from_offset);  // fyi, -1. is returned if max_length or bounds was reached
				dist_from_offset += step_length * float(searching);
				
				// oh god, the amount of times i crashed godot before adding this
				if (fail_safe++ > 50) break;
			}
			
			COLOR.a *= dist_from_offset / max_dist_from_offset;  // multiply alpha by percent
		}
	}
}
