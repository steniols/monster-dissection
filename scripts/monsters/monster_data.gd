class_name MonsterData
extends Resource
## Definição de uma espécie de monstro.

enum Tier { NORMAL, ELITE, BOSS }
enum Pattern { CYCLE, RANDOM_NO_REPEAT }

@export var id: StringName
@export var display_name: String = ""
@export var family: Family.Id = Family.Id.BLOODFANG
@export var tier: Tier = Tier.NORMAL
@export var max_hp: int = 40
@export var pattern: Pattern = Pattern.CYCLE
@export var intents: Array[MonsterIntent] = []
## Efeitos aplicados ao monstro no início do combate (ex.: Espinhos).
@export var combat_start_effects: Array[CardEffect] = []
@export var parts: Array[AnatomyPart] = []
@export var portrait: Texture2D
## Posição (0–1 no retrato) de Cabeça, Tórax, Membros e Fluidos na dissecação.
## Vazio = posições do desenho procedural. Ajuste ao trocar pela arte final.
@export var region_anchors: Array[Vector2] = []
## Chave do desenho procedural enquanto não houver arte final.
@export var visual: StringName = &"bloodfang"
@export var scale: float = 1.0
## Tingimento aplicado ao desenho (variações de espécie, ex.: elite/chefe).
@export var tint: Color = Color.WHITE
@export_multiline var lore: String = ""
@export_multiline var weakness_note: String = ""
