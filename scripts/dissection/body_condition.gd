class_name BodyCondition
extends RefCounted
## Estado do cadáver após o combate. A forma de vencer altera o que pode ser coletado.
##
## Regras (todas explicadas ao jogador — "regra de ouro da dissecação"):
##  * Golpe final com muito excesso de dano danifica/destrói a cabeça.
##  * Morte por sangramento/corrupção contamina os fluidos, mas preserva tecidos sólidos.
##  * Corrupção acumulada alta degenera os órgãos do tórax.
##  * Muitos golpes recebidos dilaceram os membros.

enum State { INTACT, DAMAGED, LOST }

const STATE_NAMES := {State.INTACT: "Intacta", State.DAMAGED: "Danificada", State.LOST: "Perdida"}

const OVERKILL_DAMAGE := 6
const OVERKILL_LOST := 12
const CORRUPTION_TORSO := 5
const HITS_LIMBS := 10
const STATUS_DEATH_BONUS := 0.1
const DEFAULT_DAMAGED_MULTIPLIER := 0.5

var region_states: Dictionary = {} # AnatomyPart.Region -> State
var region_reasons: Dictionary = {} # AnatomyPart.Region -> String
var notes: PackedStringArray = []
var solid_bonus: float = 0.0
## Bônus vindos do laboratório (definidos pela DissectionSession).
var preserve_bonus: float = 0.0
var damaged_multiplier: float = DEFAULT_DAMAGED_MULTIPLIER


static func from_combatant(m: Combatant) -> BodyCondition:
	var c := BodyCondition.new()
	for r in AnatomyPart.Region.values():
		c.region_states[r] = State.INTACT

	if m.death_cause == Combatant.DeathCause.ATTACK:
		if m.death_overkill >= OVERKILL_LOST:
			c._mark(AnatomyPart.Region.HEAD, State.LOST,
				"Golpe final com %d de excesso destruiu a cabeça." % m.death_overkill)
		elif m.death_overkill >= OVERKILL_DAMAGE:
			c._mark(AnatomyPart.Region.HEAD, State.DAMAGED,
				"Golpe final com %d de excesso danificou a cabeça." % m.death_overkill)
	elif m.death_cause == Combatant.DeathCause.STATUS:
		c._mark(AnatomyPart.Region.FLUIDS, State.DAMAGED,
			"Morreu por sangramento ou corrupção: fluidos contaminados.")
		c.solid_bonus = STATUS_DEATH_BONUS
		c.notes.append("Sem golpe final, os tecidos sólidos estão mais preservados (+10% de extração).")

	var corruption := m.get_status(&"corruption")
	if corruption >= CORRUPTION_TORSO:
		c._mark(AnatomyPart.Region.TORSO, State.DAMAGED,
			"Corrupção acumulada (%d) degenerou os órgãos do tórax." % corruption)

	if m.attack_hits_taken >= HITS_LIMBS:
		c._mark(AnatomyPart.Region.LIMBS, State.DAMAGED,
			"%d golpes recebidos dilaceraram os membros." % m.attack_hits_taken)

	if c.notes.is_empty():
		c.notes.append("Corpo bem preservado. Nenhuma região comprometida.")
	return c


func _mark(region: AnatomyPart.Region, state: State, reason: String) -> void:
	if state > region_states.get(region, State.INTACT):
		region_states[region] = state
		region_reasons[region] = reason
	notes.append(reason)


func get_state(region: AnatomyPart.Region) -> State:
	return region_states.get(region, State.INTACT)


func get_reason(region: AnatomyPart.Region) -> String:
	return region_reasons.get(region, "")


func chance_for(part: AnatomyPart) -> float:
	match get_state(part.region):
		State.LOST:
			return 0.0
		State.DAMAGED:
			return clampf((part.preserve_chance + preserve_bonus) * damaged_multiplier, 0.05, 0.95)
	var bonus := solid_bonus if part.region != AnatomyPart.Region.FLUIDS else 0.0
	return clampf(part.preserve_chance + bonus + preserve_bonus, 0.05, 0.95)


static func state_name(s: State) -> String:
	return STATE_NAMES.get(s, "?")
