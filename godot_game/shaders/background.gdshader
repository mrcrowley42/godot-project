/*
HYPER UNOPTIMISED RAYCASTING AHEAD

RAY & FADE QUALITY IS CAPPED
(for performance reasons & negligible noticable differences at higher qualities)

Toggling on default fade reduces fps by ~100 atm

for moon noise: https://godotshaders.com/snippet/2d-noise/
*/

shader_type canvas_item;

const float EPSILON = .0001;
const int MIN_RAY_QUALITY = 5;
const int MIN_FADE_QUALITY = 5;

uniform bool debug_mode = false;

uniform vec4 upper_colour : source_color = vec4(1., .5, .4, 1);
uniform vec4 lower_colour : source_color = vec4(.0, .4, 1., 1);
uniform vec4 ray_colour : source_color = vec4(1, 1, 1, 1);
uniform sampler2D LIGHT_MAP;

uniform float bg_strength : hint_range(.0, 1.) = .5;
uniform float bg_fade : hint_range(.0, 1.) = 0.;

uniform bool fade_ray_edge = true;
uniform float ray_fade_margin : hint_range(.1, .5) = .25;
uniform int ray_fade_quality : hint_range(5, 15) = 6;

uniform float ray_length : hint_range(.0, 1.) = .12;
uniform float ray_direction : hint_range(.0, 360.) = 155.;
uniform float ray_strength : hint_range(.0, 2.) = 1.5;
uniform int ray_quality : hint_range(5, 15) = 10;

uniform vec4 sun_colour : source_color = vec4(.3, .3, .15, 1.);
uniform vec2 sun_pos = vec2(.9, .3);
uniform float sun_strength = 3.;
uniform float sun_radius = .08;
uniform float sun_fade : hint_range(0.0, .05) = .03;

const vec4 moon_colour = vec4(1, 1, 1, 1);
uniform vec2 moon_pos = vec2(.7, .3);
uniform float moon_strength = .6;
uniform float moon_radius = .06;
uniform float moon_fade : hint_range(0.001, 0.05) = .007;
uniform float m_shadow_dist : hint_range(0.0, 0.1) = .06;
uniform float m_shadow_rot : hint_range(0.0, 360.0) = 0.;

vec2 rotate_point(float point, float deg) {
	float rad = deg * (PI / 180.);
	return vec2(
		point * cos(rad) - point * sin(rad),
		point * sin(rad) + point * cos(rad)
	);
}

vec2 random(vec2 uv){
    uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

// perlin noise
float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

// fisheye
vec2 distort(vec2 p){
	float d = length(p);
	float z = sqrt(.0072 + d * d * -2.);
	float r = atan(d, z) / 3.1415926535;
	float phi = atan(p.y, p.x);
	return vec2(r * cos(phi) + 0.5, r * sin(phi) + 0.5);
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

// returns the percent alpha should be multiplied with
float perform_fade(vec2 uv, vec2 scrn_pixel_size, vec2 ray_step, vec2 final_offset, float step_length, float direction) {
	bool searching = true;
	float max_dist_from_offset = ray_fade_margin * .5;
	float dist_from_offset = 0.;
	
	float fade_step_length = scrn_pixel_size.y * float(max(MIN_FADE_QUALITY, int(ray_fade_quality)));
	vec2 fade_ray_step = rotate_point(fade_step_length, direction);
	
	vec2 closest_red = uv + final_offset;
	vec2 perp_norm = normalize(ray_step) * max_dist_from_offset;  // sets direction
	perp_norm = vec2(-perp_norm.y, perp_norm.x);  // perpendicular to ray step
	
	// captured in raycast and re-used in next raycast (to check ("glide") along a red areas border (as perpenticular is raised with each check))
	vec2 prev_lhs = vec2(0.);
	vec2 prev_rhs = vec2(0.);
	
	int fail_safe = 0;
	while (searching) {
		float lhs_len = raycast_to_red(closest_red + (perp_norm * dist_from_offset), fade_ray_step, fade_step_length, ray_length, prev_lhs);
		float rhs_len = raycast_to_red(closest_red + (-perp_norm * dist_from_offset), fade_ray_step, fade_step_length, ray_length, prev_rhs);
		float len = min(lhs_len, rhs_len);
		searching = !(len < -EPSILON || dist_from_offset >= max_dist_from_offset);  // fyi, len is -1 if max_length or bounds was reached in raycast
		dist_from_offset += step_length * float(searching);
		
		if (fail_safe++ > 20) break;  // oh god, the amount of times i crashed godot before adding this
	}
	return dist_from_offset / max_dist_from_offset;  // return percent
}

vec4 get_sun_col(float sun_dist) {
	float fade_amnt = sun_radius - sun_fade;
	float multiplier = min(1., 1. - ((sun_dist - fade_amnt) / (sun_radius - fade_amnt)));
	multiplier *= sun_strength;
	return sun_colour * multiplier;
}

vec4 get_moon_col(vec2 uv, float moon_dist, vec4 col_addition) {
	vec2 fisheye = distort(uv - moon_pos);
	vec4 noise_col = moon_colour * noise((fisheye + TIME * .02) * 5.);
	float fade_amnt = moon_radius - moon_fade;
	float multiplier = min(1., 1. - ((moon_dist - fade_amnt) / (moon_radius - fade_amnt)));
	col_addition *= 1. - multiplier;
	
	// shadow
	float shadow_dist = length(uv - (moon_pos + rotate_point(m_shadow_dist, m_shadow_rot)));
	float shadow_fade = min(1., (shadow_dist - fade_amnt) / (moon_radius - fade_amnt));
	float shadow_multiplier = float(shadow_dist >= moon_radius - moon_fade) * shadow_fade;
	
	multiplier *= moon_strength;
	return col_addition + (noise_col * multiplier * shadow_multiplier);
}

void fragment() {
	float light_map_r = texture(LIGHT_MAP, UV).r;
	bool is_red = light_map_r > EPSILON;
	
	if (is_red || debug_mode) {
		// BACKGROUND
		float fade_btm = smoothstep(.0, bg_fade, 1. - UV.y * float(!debug_mode));
		COLOR = mix(upper_colour, lower_colour, UV.y); 
		COLOR.a = fade_btm * (bg_strength * .5 + float(debug_mode));  // half the opacity by default
		
		// SUN & MOON
		float sun_dist = length(UV - sun_pos);
		float moon_dist = length(UV - moon_pos);
		vec4 col_addition = vec4(0.);
		if (sun_dist <= sun_radius) col_addition.rgb += get_sun_col(sun_dist).rgb;  // do sun first
		if (moon_dist <= moon_radius) col_addition.rgb = get_moon_col(UV, moon_dist, col_addition).rgb;
		COLOR += col_addition;
	}
	
	// RAYS
	if (!is_red || debug_mode) {
		float direction = ray_direction + 45.;  // add 45 so it points up a 0 deg
		float step_length = SCREEN_PIXEL_SIZE.y * float(max(MIN_RAY_QUALITY, int(ray_quality)));  // DO NOT ALLOW LESS THAN 1
		vec2 ray_step = rotate_point(step_length, direction);  // 1 step in direction of ray
		
		vec2 final_offset = vec2(0.);
		float final_length = 0.;
		final_length = raycast_to_red(UV, ray_step, step_length, ray_length, final_offset);
		
		if (final_length > EPSILON) {  // confirmed a ray
			float ray_debug_on = 1. * float(debug_mode);
			COLOR = vec4(ray_colour.rgb, (ray_length - final_length) * ray_strength + ray_debug_on);  // debug sets alpha to 1
			
			// FADE EDGE
			if (fade_ray_edge) {
				COLOR.a *= perform_fade(UV, SCREEN_PIXEL_SIZE, ray_step, final_offset, step_length, direction);
			}
		}
	}
}
