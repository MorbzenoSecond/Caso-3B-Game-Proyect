shader_type canvas_item;
render_mode blend_premul_alpha;

// ¡AQUÍ ESTÁ EL TRUCO! Declaramos la textura de la pantalla con hint_screen_texture
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform sampler2D noise_tex_normal;
uniform sampler2D noise_tex;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float strength = 1.0;
uniform float pixel_count : hint_range(1.0, 512.0) = 64.0;
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    // Pixelation
    float pixel_size = 1.0 / pixel_count;
    vec2 pixel_uv = floor(UV / pixel_size) * pixel_size;

    // Distortion
    vec2 direction = texture(noise_tex_normal, pixel_uv).xy;
    direction = (direction - 0.5) * 2.0;
    direction *= strength * progress;

    // Usamos SCREEN_UV para mapear la posición exacta de la pantalla
    vec2 distorted_uv = SCREEN_UV - direction;

    // Base texture: ¡Ahora lee de screen_texture en lugar de TEXTURE!
    vec4 tex = texture(screen_texture, distorted_uv);

    // Discard casi transparente (opcional para pantalla completa, puedes comentarlo)
    if (tex.a < alpha_threshold) {
        discard;
    }

    // Dissolve
    float dissolve = texture(noise_tex, pixel_uv).x;
    dissolve = step(progress, dissolve);
    tex.a *= dissolve;

    // Aplicar modulación
    COLOR = tex * COLOR;
}