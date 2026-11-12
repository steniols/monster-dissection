class_name Family
extends RefCounted
## Famílias biológicas. Cada uma tem cor de identidade e um efeito de Instinto.

enum Id { NEUTRAL, BLOODFANG, IRONBACK, VOIDSPAWN, ROTWALKER, SPOREMAW, ASHWING }

const NAMES := {
	Id.NEUTRAL: "Pesquisador",
	Id.BLOODFANG: "Bloodfang",
	Id.IRONBACK: "Ironback",
	Id.VOIDSPAWN: "Voidspawn",
	Id.ROTWALKER: "Rotwalker",
	Id.SPOREMAW: "Sporemaw",
	Id.ASHWING: "Ashwing",
}

const EPITHETS := {
	Id.NEUTRAL: "Instrumentos",
	Id.BLOODFANG: "Predador",
	Id.IRONBACK: "Inseto blindado",
	Id.VOIDSPAWN: "Aberração",
	Id.ROTWALKER: "Morto-vivo",
	Id.SPOREMAW: "Fungo",
	Id.ASHWING: "Ave de brasa",
}

## Nome do efeito de conjunto ativado pelo Instinto.
const INSTINCT_NAMES := {
	Id.BLOODFANG: "Frenesi",
	Id.IRONBACK: "Fortificação",
	Id.VOIDSPAWN: "Corrupção",
	Id.ROTWALKER: "Persistência",
	Id.SPOREMAW: "Proliferação",
	Id.ASHWING: "Incandescência",
}

const INSTINCT_DESCRIPTIONS := {
	Id.BLOODFANG: "Ganhe 2 de Força.",
	Id.IRONBACK: "Ganhe 8 de Armadura e 2 de Espinhos.",
	Id.VOIDSPAWN: "Aplique 3 de Corrupção a todos os inimigos.",
	Id.ROTWALKER: "Recupere 5 de vida.",
	Id.SPOREMAW: "Aplique 3 de Germinação a todos os inimigos e recupere 3 de vida.",
	Id.ASHWING: "Aplique 3 de Brasa a todos os inimigos e compre 1 carta.",
}


static func get_name_of(id: Id) -> String:
	return NAMES.get(id, "?")


static func get_color(id: Id) -> Color:
	match id:
		Id.BLOODFANG:
			return Palette.BLOOD_BRIGHT
		Id.IRONBACK:
			return Palette.MOSS_BRIGHT
		Id.VOIDSPAWN:
			return Palette.VIOLET_BRIGHT
		Id.ROTWALKER:
			return Palette.SICK_GREEN
		Id.SPOREMAW:
			return Color("#5FBFA8")
		Id.ASHWING:
			return Color("#E0803A")
		_:
			return Palette.BONE


static func get_dark_color(id: Id) -> Color:
	match id:
		Id.BLOODFANG:
			return Palette.BLOOD
		Id.IRONBACK:
			return Palette.MOSS
		Id.VOIDSPAWN:
			return Palette.VIOLET
		Id.ROTWALKER:
			return Color("#5E6A3E")
		Id.SPOREMAW:
			return Color("#2F6B5E")
		Id.ASHWING:
			return Color("#8A4A22")
		_:
			return Palette.INK_SOFT
