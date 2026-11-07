shader_type canvas_item;
// Contorno + brilho em volta de uma figura com fundo transparente (retratos de monstros).
// Os raios são em pixels da textura; MonsterArt converte de pixels de tela.

uniform vec4 outline_color : source_color = vec4(0.04, 0.035, 0.03, 0.95);
uniform float outline_px = 3.0;
uniform vec4 glow_color : source_color = vec4(0.8, 0.25, 0.25, 0.0);
uniform float glow_px = 12.0;

// cor do vértice (modulate) sem a textura; no fragment, COLOR já vem multiplicado pela textura
varying vec4 v_modulate;

void vertex() {
	v_modulate = COLOR;
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE;
	float a_out = 0.0;
	float a_glow = 0.0;
	for (int i = 0; i < 16; i++) {
		float ang = float(i) * 0.39269908;
		vec2 d = vec2(cos(ang), sin(ang)) * px;
		a_out = max(a_out, texture(TEXTURE, UV + d * outline_px).a);
		a_out = max(a_out, texture(TEXTURE, UV + d * outline_px * 0.5).a);
		a_glow += texture(TEXTURE, UV + d * glow_px).a;
		a_glow += texture(TEXTURE, UV + d * glow_px * 0.5).a;
	}
	a_glow /= 32.0;
	vec4 glow = vec4(glow_color.rgb, glow_color.a * clamp(a_glow * 2.2, 0.0, 1.0));
	vec4 outl = vec4(outline_color.rgb, outline_color.a * a_out);
	vec4 under = mix(glow, outl, outl.a);
	under.a = max(glow.a, outl.a);
	vec4 result = mix(under, base, base.a);
	result.a = max(under.a, base.a);
	COLOR = result * v_modulate;
}
