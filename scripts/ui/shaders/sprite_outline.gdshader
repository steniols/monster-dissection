shader_type canvas_item;
// Destaque em volta de uma figura com fundo transparente (retratos de monstros), em 3 camadas:
// contorno escuro colado na figura, linha clara na cor da família (luz de recorte) e aura difusa.
// Os raios são em pixels da textura; MonsterArt converte de pixels de tela.

uniform vec4 outline_color : source_color = vec4(0.03, 0.025, 0.02, 1.0);
uniform float outline_px = 3.0;
uniform vec4 rim_color : source_color = vec4(1.0, 0.6, 0.5, 1.0);
uniform float rim_px = 6.0;
uniform vec4 glow_color : source_color = vec4(0.8, 0.25, 0.25, 0.0);
uniform float glow_px = 16.0;

// cor do vértice (modulate) sem a textura; no fragment, COLOR já vem multiplicado pela textura
varying vec4 v_modulate;

void vertex() {
	v_modulate = COLOR;
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE;
	float a_out = 0.0;
	float a_rim = 0.0;
	float a_glow = 0.0;
	for (int i = 0; i < 24; i++) {
		float ang = float(i) * 0.26179939;
		vec2 d = vec2(cos(ang), sin(ang)) * px;
		a_out = max(a_out, texture(TEXTURE, UV + d * outline_px).a);
		a_out = max(a_out, texture(TEXTURE, UV + d * outline_px * 0.5).a);
		a_rim = max(a_rim, texture(TEXTURE, UV + d * rim_px).a);
		a_rim = max(a_rim, texture(TEXTURE, UV + d * mix(outline_px, rim_px, 0.5)).a);
		a_glow += texture(TEXTURE, UV + d * glow_px).a;
		a_glow += texture(TEXTURE, UV + d * glow_px * 0.6).a;
	}
	a_glow = clamp(a_glow / 48.0 * 2.5, 0.0, 1.0);

	vec4 col = vec4(glow_color.rgb, glow_color.a * a_glow);
	col = mix(col, vec4(rim_color.rgb, 1.0), rim_color.a * a_rim);
	col.a = max(col.a, rim_color.a * a_rim);
	col = mix(col, vec4(outline_color.rgb, 1.0), outline_color.a * a_out);
	col.a = max(col.a, outline_color.a * a_out);

	vec4 result = mix(col, base, base.a);
	result.a = max(col.a, base.a);
	COLOR = result * v_modulate;
}
