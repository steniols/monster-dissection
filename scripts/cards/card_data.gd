class_name CardData
extends Resource
## Definição imutável de uma carta. Instâncias em combate usam CardInstance.

enum CardType { ATTACK, DEFENSE, SKILL, MUTATION }
enum Rarity { STARTER, COMMON, UNCOMMON, RARE }
enum Category { NATURAL, HYBRID, MUTANT } ## origem conforme o GDD

const TYPE_NAMES := {
	CardType.ATTACK: "Ataque",
	CardType.DEFENSE: "Defesa",
	CardType.SKILL: "Habilidade",
	CardType.MUTATION: "Mutação",
}
const RARITY_NAMES := {
	Rarity.STARTER: "Básica",
	Rarity.COMMON: "Comum",
	Rarity.UNCOMMON: "Incomum",
	Rarity.RARE: "Rara",
}

@export var id: StringName
@export var display_name: String = ""
@export var cost: int = 1
@export var card_type: CardType = CardType.ATTACK
@export var rarity: Rarity = Rarity.COMMON
@export var category: Category = Category.NATURAL
@export var family: Family.Id = Family.Id.NEUTRAL
## Parte anatômica de origem, ex.: "Presas". Vazio para instrumentos.
@export var source_part: String = ""
@export var illustration: Texture2D
## Chave do desenho procedural usado enquanto não houver ilustração.
@export var art_motif: StringName = &"scalpel"
## Carta é banida (exaurida) até o fim do combate após ser jogada.
@export var exhaust: bool = false
@export var effects: Array[CardEffect] = []
## Se preenchido, substitui o texto gerado automaticamente a partir dos efeitos.
@export_multiline var description_override: String = ""
@export_multiline var flavor: String = ""


func needs_target() -> bool:
	for e in effects:
		if e.targets_enemy():
			return true
	return false


func get_description() -> String:
	var text := description_override
	if text.is_empty():
		var parts: PackedStringArray = []
		for e in effects:
			var d := e.describe()
			if not d.is_empty():
				parts.append(d)
		text = " ".join(parts)
	if card_type == CardType.MUTATION:
		text += " " + CardEffect.kw("Permanente no combate.", Palette.VIOLET_BRIGHT)
	if exhaust:
		text += " " + CardEffect.kw("Banir.", Palette.BONE_LIGHT)
	return text


func get_type_name() -> String:
	return TYPE_NAMES.get(card_type, "?")


func get_rarity_name() -> String:
	return RARITY_NAMES.get(rarity, "?")


func get_origin_label() -> String:
	if family == Family.Id.NEUTRAL:
		return "Instrumento"
	if source_part.is_empty():
		return Family.get_name_of(family)
	return "%s · %s" % [source_part, Family.get_name_of(family)]
