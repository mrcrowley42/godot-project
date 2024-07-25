/*
HYPER UNOPTIMISED RAY CASTING (BEWARE: SHITTY CODE AHEAD)

im actually not kidding this thing is slow as hell.
like from 700 fps to 330
i'll optimise later... when i feel like it

anti-aliasing:
https://gist.github.com/cart/7d2da58eb28c75c0952787f29f3e562f
https://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf
only need a low pass through, im sure...
*/

shader_type canvas_item;

const float EPSILON = .0001;

// depending upon the light map this could optimise ray casting
// if there is less red than black, toggle this on
uniform bool flip_ray_cast_strategy = false;
uniform bool fade_ray_edge = false;
uniform float ray_fade_margin: hint_range(.1, .5) = .3;

uniform float ray_length : hint_range(0.0, 1.0) = .15;
uniform float ray_rotation : hint_range(0.0, 360.0) = 155.;
uniform float ray_strength : hint_range(0.0, 2.0) = 2.;
uniform int ray_quality : hint_range(0, 20) = 5;  // INT ONLY. do not mess too quickly (the graphics driver hates it)

uniform float bg_length : hint_range(0.0, 1.0) = .7;
uniform float bg_strength : hint_range(0.0, 2.0) = .8;
uniform float bg_falloff : hint_range(0.0, 1.0) = .8;

uniform vec4 colour : source_color = vec4(1.0, 0.9, 0.65, 1);
uniform sampler2D LIGHT_MAP;

vec2 rotate_point(float point) {
	float rad = (ray_rotation + 45.) * (PI / 180.);  // add 45 so it points up at 0 degrees
	return vec2(
		point * cos(rad) - point * sin(rad),
		point * sin(rad) + point * cos(rad)
	);
}

// ray cast from red pixels
float ray_cast_reds(vec2 uv, vec2 ray_step, float ray_len, vec2 offset_storage) {
	return .0;
}

// ray cast from clear pixels
float ray_cast_clears(vec2 uv, vec2 ray_step, float ray_len, vec2 offset_storage) {
	float len = 0.;
	while (true) {
		vec2 ray_cast = uv + offset_storage;
		if (texture(LIGHT_MAP, ray_cast).r > EPSILON) {   // found red
			return len;
		}
		bool out_of_bounds = min(ray_cast.x, ray_cast.y) < EPSILON || max(ray_cast.x, ray_cast.y) > 1.;
		if (len > ray_length || out_of_bounds) {  // outside of bounds or too long, stop casting
			return 0.;
		}
		offset_storage += ray_step;
		len += ray_len;
	}
}

void fragment() {
	// BACKGROUND
	float light_map_r = texture(LIGHT_MAP, UV).r;
	bool is_red = light_map_r > EPSILON;
	if (is_red) {
		float bg_rays = smoothstep(0.0, bg_falloff, (bg_length - UV.y));  // fade bottom
		float final_strength = bg_strength * light_map_r;
		vec3 bg_col = vec3(bg_rays) * colour.rgb;
		COLOR = vec4(bg_col * final_strength, bg_rays * final_strength);
	}
	
	// RAYS (only ray cast if necessary)
	float step_length = SCREEN_PIXEL_SIZE.y * float(ray_quality);
	vec2 ray_step = rotate_point(step_length);  // 1 step in direction of ray
	
	vec2 final_offset = vec2(0.);
	float final_length = 0.;
	if (flip_ray_cast_strategy && is_red) {
		final_length = ray_cast_reds(UV, ray_step, step_length, final_offset);
	} else if (!flip_ray_cast_strategy && !is_red) {
		final_length = ray_cast_clears(UV, ray_step, step_length, final_offset);
	}
	
	if (final_length > EPSILON) {
		COLOR = vec4(colour.rgb, (ray_length - final_length) * ray_strength);
		
		// fade edge calculations using final offset & remainder of ray length from final_length here
	}
}
