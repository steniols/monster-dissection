class_name StatusLibrary
extends RefCounted
## Definições de efeitos de status, orientadas a dados.
##
## Para criar um novo status basta adicionar uma entrada aqui:
##   name, description (use {x} para a quantidade), color, debuff,
##   tick: o que acontece no início do turno do portador
##        { "kind": "lose_hp" | "heal" | "block" | "apply_self" | "apply_opponents", "status": id }
##   decay: quanto diminui e quando ("turn_start" | "turn_end"); 0 = permanente no combate.
## O processamento fica em CombatManager._tick_statuses().

const DEFS := {
	&"spores": {
		"name": "Germinação",
		"description": "Bomba-relógio: no início do turno, a Germinação cresce 1. Ao chegar a 8, explode causando 15 de dano e some. Aplicar mais adianta a explosão. Se um inimigo morrer com Germinação, ela passa para os outros inimigos.",
		"color": Color("#5FBFA8"),
		"debuff": true,
		"tick": {"kind": "germinate"},
		"decay": 0,
	},
	&"ember": {
		"name": "Brasa",
		"description": "Ao receber um ataque, perde {x} de vida, ignorando a Armadura. Diminui 1 a cada golpe.",
		"color": Color("#E0803A"),
		"debuff": true,
		"decay": 0,
	},
	&"spore_crown": {
		"name": "Coroa Micélica",
		"description": "No início do turno, aplica {x} de Germinação a todos os oponentes.",
		"color": Color("#5FBFA8"),
		"debuff": false,
		"tick": {"kind": "apply_opponents", "status": &"spores"},
		"decay": 0,
	},
	&"molten_heart": {
		"name": "Coração Fundido",
		"description": "No início do turno, aplica {x} de Brasa a todos os oponentes.",
		"color": Color("#E0803A"),
		"debuff": false,
		"tick": {"kind": "apply_opponents", "status": &"ember"},
		"decay": 0,
	},
	&"bleed": {
		"name": "Sangramento",
		"description": "No início do turno, perde {x} de vida. Diminui 1 por turno.",
		"color": Color("#C2474D"),
		"debuff": true,
		"tick": {"kind": "lose_hp"},
		"decay": 1, "decay_on": "turn_start",
	},
	&"corruption": {
		"name": "Corrupção",
		"description": "No início do turno, perde {x} de vida. Não diminui.",
		"color": Color("#A27BBB"),
		"debuff": true,
		"tick": {"kind": "lose_hp"},
		"decay": 0,
	},
	&"strength": {
		"name": "Força",
		"description": "Ataques causam {x} de dano adicional.",
		"color": Color("#D9C29A"),
		"debuff": false,
		"decay": 0,
	},
	&"weak": {
		"name": "Fraqueza",
		"description": "Ataques causam 25% menos dano. Dura {x} turno(s).",
		"color": Color("#8E877A"),
		"debuff": true,
		"decay": 1, "decay_on": "turn_end",
	},
	&"vulnerable": {
		"name": "Vulnerável",
		"description": "Recebe 50% mais dano de ataques. Dura {x} turno(s).",
		"color": Color("#B5776B"),
		"debuff": true,
		"decay": 1, "decay_on": "turn_end",
	},
	&"thorns": {
		"name": "Espinhos",
		"description": "Ao receber um ataque, causa {x} de dano ao atacante.",
		"color": Color("#8FA97E"),
		"debuff": false,
		"decay": 0,
	},
	&"regen": {
		"name": "Regeneração",
		"description": "No início do turno, recupera {x} de vida. Diminui 1 por turno.",
		"color": Color("#8C9A5B"),
		"debuff": false,
		"tick": {"kind": "heal"},
		"decay": 1, "decay_on": "turn_start",
	},
	&"endoskeleton": {
		"name": "Endoesqueleto",
		"description": "No início do turno, ganha {x} de Armadura.",
		"color": Color("#8FA97E"),
		"debuff": false,
		"tick": {"kind": "block"},
		"decay": 0,
	},
	&"bloodthirst": {
		"name": "Sede de Sangue",
		"description": "No início do turno, ganha {x} de Força.",
		"color": Color("#C2474D"),
		"debuff": false,
		"tick": {"kind": "apply_self", "status": &"strength"},
		"decay": 0,
	},
	&"immune": {
		"name": "Imune",
		"description": "Não recebe efeitos negativos (Sangramento, Germinação, Corrupção, Fraqueza, Vulnerável, Brasa).",
		"color": Color("#D8D2B8"),
		"debuff": false,
		"decay": 0,
	},
	&"undying": {
		"name": "Imortalidade Pútrida",
		"description": "Sobrevive a um golpe fatal com 1 de vida ({x} vez/vezes). Monstros voltam com 20 de Armadura, sem efeitos negativos e imunes a eles.",
		"color": Color("#8C9A5B"),
		"debuff": false,
		"decay": 0,
	},
	&"rot_pulse": {
		"name": "Pulso Pútrido",
		"description": "No início do turno, recupera {x} de vida.",
		"color": Color("#8C9A5B"),
		"debuff": false,
		"tick": {"kind": "heal"},
		"decay": 0,
	},
	&"abyss": {
		"name": "Abismo",
		"description": "No início do turno, aplica {x} de Corrupção a todos os oponentes.",
		"color": Color("#A27BBB"),
		"debuff": false,
		"tick": {"kind": "apply_opponents", "status": &"corruption"},
		"decay": 0,
	},
}


static func has(id: StringName) -> bool:
	return DEFS.has(id)


static func get_def(id: StringName) -> Dictionary:
	return DEFS.get(id, {"name": String(id), "description": "", "color": Color.WHITE, "debuff": false, "decay": 0})


static func get_display_name(id: StringName) -> String:
	return get_def(id)["name"]


static func get_color(id: StringName) -> Color:
	return get_def(id)["color"]


static func describe(id: StringName, stacks: int) -> String:
	var d := get_def(id)
	return "%s %d: %s" % [d["name"], stacks, String(d["description"]).replace("{x}", str(stacks))]


## Retorna o nome do status formatado como palavra-chave BBCode.
static func keyword(id: StringName) -> String:
	return "[color=#%s]%s[/color]" % [get_color(id).to_html(false), get_display_name(id)]
