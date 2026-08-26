shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

// Godot asigna automáticamente el frame actual del AnimatedSprite3D a esta variable
uniform sampler2D texture_albedo : source_color, filter_nearest;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;
uniform bool enable_outline = true;

void fragment() {
	vec4 col = texture(texture_albedo, UV);

	if (enable_outline && outline_width > 0.0) {
		vec2 size = vec2(textureSize(texture_albedo, 0));
		vec2 px = vec2(outline_width) / size;

		// Muestreo de los píxeles adyacentes
		float a1 = texture(texture_albedo, UV + vec2(px.x, 0.0)).a;
		float a2 = texture(texture_albedo, UV + vec2(-px.x, 0.0)).a;
		float a3 = texture(texture_albedo, UV + vec2(0.0, px.y)).a;
		float a4 = texture(texture_albedo, UV + vec2(0.0, -px.y)).a;

		float max_alpha = max(max(a1, a2), max(a3, a4));

		if (col.a < 0.1 && max_alpha > 0.1) {
			ALBEDO = outline_color.rgb;
			ALPHA = outline_color.a;
		} else {
			ALBEDO = col.rgb;
			ALPHA = col.a;
		}
	} else {
		ALBEDO = col.rgb;
		ALPHA = col.a;
	}
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}