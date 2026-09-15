shader_type canvas_item;

// License: CC0
// Author: Ultipuk, https://ultipuk.xyz
// Link: https://godotshaders.com/shader/desaturated-and-darkened-texture-progress

#define USE_TERMINATOR
 //#define USE_UV_BASED_TERMINATOR_SIZE
 //#define USE_SAMPLER_TEXTURE

/** Use this from the editor for interpolation. */
uniform float progress: hint_range(-1.0, 1.0) = 0.5;
uniform float progress2: hint_range(-1.0, 1.0) = 0.5;
#ifdef USE_SAMPLER_TEXTURE
/** Just a texture. */
uniform sampler2D albedo_texture : source_color;
#endif

#ifdef USE_TERMINATOR
group_uniforms terminator;
/** Terminator color. */
uniform vec4 terminator_color: source_color = vec4(1.0);
	#ifdef USE_UV_BASED_TERMINATOR_SIZE
	/** Terminator size in UV coords. */
	uniform float terminator_size: hint_range(0.0, 1.0) = 0.012;
	#else
	/** Terminator size in pixels. */
	uniform float terminator_size_px: hint_range(0.0, 64.0, 1.0) = 4.0;
	#endif
#endif

void fragment() {
	#ifdef USE_SAMPLER_TEXTURE
	vec4 color = texture(albedo_texture, UV);
	#else
	vec4 color = COLOR;
	#endif
	
	float cutoff = 1.0 - UV.x;
	float cutoff2 = UV.x;
	
	#ifdef USE_TERMINATOR
	
	float terminator_size_uv;
	

	

	#endif
	if (progress < cutoff) {
		color.a = 0.0; // Hide outside the progress limit
	}
	// Right-to-left progressive cutoff
	else if (progress2 < cutoff2) {
		color.a = 0.0; // Hide outside the second progress limit
	}
	
	COLOR = color;
}