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
uniform bool anti_alias_ray = false;

uniform float ray_length : hint_range(0.0, 1.0) = .15;
uniform float ray_rotation : hint_range(0.0, 360.0) = 155.;
uniform float ray_strength : hint_range(0.0, 2.0) = 2.;
uniform int ray_quality : hint_range(0, 20) = 5;  // do not mess too much with this

uniform float bg_length : hint_range(0.0, 1.0) = .7;
uniform float bg_strength : hint_range(0.0, 2.0) = .8;
uniform float bg_falloff : hint_range(0.0, 1.0) = .8;

uniform vec4 colour : source_color = vec4(1.0, 0.9, 0.65, 1);
uniform sampler2D LIGHT_MAP;

vec2 rotate_offset(vec2 centre, float offset) {
	vec2 point = centre + offset;
	vec2 vec_out = vec2(0., 0.);
	float rad = (ray_rotation + 45.) * (PI / 180.);  // add 45 so it points up at 0 degrees
	vec_out.x = centre.x + cos(rad) * (point.x - centre.x) - sin(rad) * (point.y - centre.y);
	vec_out.y = centre.y + sin(rad) * (point.x - centre.x) + cos(rad) * (point.y - centre.y);
	return vec_out;
}

// ray cast from red pixels
float ray_cast_reds(vec2 uv, vec2 pixel_size) {
	return .0;
}

// ray cast from clear pixels
float ray_cast_clears(vec2 uv, vec2 pixel_size) {
	float offset = .0;
	while (true) {
		vec2 ray_cast = rotate_offset(uv, offset);
		bool out_of_bounds = min(ray_cast.x, ray_cast.y) < EPSILON || max(ray_cast.x, ray_cast.y) > 1.;
		if (offset > ray_length || out_of_bounds) {  // outside of bounds or too long, stop casting
			return 0.;
		}
		if (texture(LIGHT_MAP, ray_cast).r > EPSILON) {   // found red
			return offset;
		}
		offset += pixel_size.y * float(ray_quality);  // x or y it doesnt really matter
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
	float offset = .0;
	if (flip_ray_cast_strategy && is_red) {
		offset = ray_cast_reds(UV, SCREEN_PIXEL_SIZE);
	} else if (!flip_ray_cast_strategy && !is_red) {
		offset = ray_cast_clears(UV, SCREEN_PIXEL_SIZE);
	}
	
	if (offset > EPSILON) {
		COLOR = vec4(colour.rgb, (ray_length - offset) * ray_strength);
	}
}
