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
## Segunda família (cartas híbridas). Conta para o Instinto de ambas.
@export var secondary_family: Family.Id = Family.Id.NEUTRAL
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

## Verdadeiro na versão aprimorada (gerada em tempo de execução, id terminado em "+").
var upgraded: bool = false

const UPGRADE_SUFFIX := "+"


func is_hybrid() -> bool:
	return secondary_family != Family.Id.NEUTRAL


func belongs_to(f: Family.Id) -> bool:
	return family == f or secondary_family == f


func can_upgrade() -> bool:
	return not upgraded and not effects.is_empty()


## Cria a versão aprimorada: cada efeito melhora a si mesmo; se nenhum puder, o custo cai em 1.
func make_upgraded() -> CardData:
	var c := duplicate() as CardData
	var list: Array[CardEffect] = []
	var improved := false
	for e in effects:
		var copy := e.clone()
		improved = copy.upgrade() or improved
		list.append(copy)
	c.effects = list
	if not improved or cost >= 3:
		c.cost = maxi(0, cost - 1)
	c.id = StringName(String(id) + UPGRADE_SUFFIX)
	c.display_name = display_name + UPGRADE_SUFFIX
	c.upgraded = true
	return c


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
	if is_hybrid():
		return "Híbrida · %s + %s" % [Family.get_name_of(family), Family.get_name_of(secondary_family)]
	if source_part.is_empty():
		return Family.get_name_of(family)
	return "%s · %s" % [source_part, Family.get_name_of(family)]
