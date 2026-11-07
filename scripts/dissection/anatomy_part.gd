class_name AnatomyPart
extends Resource
## Parte anatômica coletável. Também funciona como "material" no inventário.

enum Region { HEAD, TORSO, LIMBS, FLUIDS }

const REGION_NAMES := {
	Region.HEAD: "Cabeça",
	Region.TORSO: "Tórax",
	Region.LIMBS: "Membros",
	Region.FLUIDS: "Fluidos",
}

@export var id: StringName
@export var display_name: String = ""
@export var family: Family.Id = Family.Id.NEUTRAL
@export var region: Region = Region.TORSO
@export var rarity: CardData.Rarity = CardData.Rarity.COMMON
## Chance base (0–1) de extrair a parte intacta.
@export_range(0.0, 1.0, 0.05) var preserve_chance: float = 0.8
## Carta desbloqueada na primeira extração bem-sucedida.
@export var unlocks_card: CardData
@export var icon: Texture2D
@export var art_motif: StringName = &"heart"
@export_multiline var description: String = ""


static func region_name(r: Region) -> String:
	return REGION_NAMES.get(r, "?")
