extends Node
## Autoload "Sfx": efeitos sonoros sintetizados em código e a trilha de fundo (assets/audio/music).
## Para trocar por áudio gravado: coloque um AudioStream em CUSTOM com a mesma chave.

const RATE := 22050
const MUSIC_RATE := 16000
const POOL_SIZE := 8

## Sons gravados que substituem os sintetizados (chave -> AudioStream).
var CUSTOM: Dictionary = {}

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _music: AudioStreamPlayer
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)
	_build_all()
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	_music.volume_db = -40.0
	add_child(_music)
	_music.stream = _load_music()
	_music.play()
	# entra devagar
	create_tween().tween_property(_music, "volume_db", MUSIC_DB, 4.0)


## Volume base da música (o controle de Música nas Opções ajusta por cima disso).
const MUSIC_DB := -6.0
## Trilha de fundo: um arquivo seu (main.ogg/main.mp3) tem prioridade sobre a trilha composta (main.wav).
const MUSIC_FILES := ["res://assets/audio/music/main.ogg", "res://assets/audio/music/main.mp3", "res://assets/audio/music/main.wav"]


func _load_music() -> AudioStream:
	for path in MUSIC_FILES:
		if not ResourceLoader.exists(path):
			continue
		var s := load(path) as AudioStream
		if s is AudioStreamWAV:
			var w := s as AudioStreamWAV
			w.loop_mode = AudioStreamWAV.LOOP_FORWARD
			w.loop_begin = 0
			w.loop_end = w.data.size() / (4 if w.stereo else 2)
		elif "loop" in s:
			s.set("loop", true)
		if s != null:
			return s
	return _ambient()


func play(key: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.06) -> void:
	var stream: AudioStream = CUSTOM.get(key, _streams.get(key))
	if stream == null:
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + _rng.randf_range(-pitch_jitter, pitch_jitter)
	p.play()


# --- Síntese ----------------------------------------------------------------

func _build_all() -> void:
	_streams[&"click"] = _make(0.05, func(t: float, _i: int): return sin(TAU * 1300.0 * t) * exp(-t * 90.0) * 0.5)
	_streams[&"card"] = _make(0.2, _swish)
	_streams[&"hit"] = _make(0.28, func(t: float, i: int): return _thump(t, i, 150.0, 45.0, 0.9))
	_streams[&"hit_big"] = _make(0.45, func(t: float, i: int): return _thump(t, i, 120.0, 32.0, 1.0))
	_streams[&"block"] = _make(0.3, func(t: float, _i: int):
		var env := exp(-t * 14.0)
		return (sin(TAU * 880.0 * t) * 0.5 + sin(TAU * 1310.0 * t) * 0.3 + sin(TAU * 2090.0 * t) * 0.2) * env * 0.55)
	_streams[&"heal"] = _make(0.6, func(t: float, _i: int):
		var notes := [523.0, 659.0, 784.0]
		var k := mini(int(t / 0.14), 2)
		var lt := t - k * 0.14
		return sin(TAU * notes[k] * t) * exp(-lt * 6.0) * 0.35)
	_streams[&"cut"] = _make(0.35, _squelch)
	_streams[&"fail"] = _make(0.45, func(t: float, _i: int):
		var f := lerpf(300.0, 110.0, t / 0.45)
		return signf(sin(TAU * f * t)) * 0.18 * exp(-t * 4.0))
	_streams[&"unlock"] = _make(0.7, func(t: float, _i: int):
		var f := 660.0 if t < 0.16 else 990.0
		var lt := t if t < 0.16 else t - 0.16
		return (sin(TAU * f * t) + 0.3 * sin(TAU * f * 2.0 * t)) * exp(-lt * 5.0) * 0.3)
	_streams[&"turn"] = _make(0.7, func(t: float, _i: int):
		return (sin(TAU * 220.0 * t) * 0.6 + sin(TAU * 330.0 * t) * 0.3 + sin(TAU * 441.0 * t) * 0.1) * exp(-t * 5.0) * 0.35)
	_streams[&"death"] = _make(0.9, _rumble)
	_streams[&"instinct"] = _make(0.55, func(t: float, _i: int):
		var f := lerpf(200.0, 820.0, t / 0.55)
		return sin(TAU * f * t) * (0.6 + 0.4 * sin(TAU * 18.0 * t)) * sin(PI * t / 0.55) * 0.3)


func _make(duration: float, gen: Callable, rate: int = RATE, loop: bool = false) -> AudioStreamWAV:
	var n := int(duration * rate)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var v: float = clampf(gen.call(t, i), -1.0, 1.0)
		data.encode_s16(i * 2, int(v * 32000.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo = false
	s.data = data
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = n
	return s


var _lp := 0.0


func _noise_lp(k: float) -> float:
	_lp = lerpf(_lp, _rng.randf_range(-1.0, 1.0), k)
	return _lp


func _swish(t: float, _i: int) -> float:
	var env := sin(PI * clampf(t / 0.2, 0.0, 1.0))
	return _noise_lp(0.25 + t * 2.0) * env * 0.5


func _thump(t: float, _i: int, f0: float, f1: float, gain: float) -> float:
	var f := lerpf(f0, f1, minf(1.0, t * 6.0))
	var body := sin(TAU * f * t) * exp(-t * 9.0)
	var crack := _noise_lp(0.6) * exp(-t * 45.0)
	return (body * 0.8 + crack * 0.6) * gain


func _squelch(t: float, _i: int) -> float:
	var wobble := 0.5 + 0.5 * sin(TAU * 28.0 * t)
	return _noise_lp(0.12) * wobble * exp(-t * 7.0) * 0.9


func _rumble(t: float, _i: int) -> float:
	return (_noise_lp(0.04) * 1.5 + sin(TAU * 55.0 * t) * 0.4) * exp(-t * 3.0) * 0.6


## Drone ambiente em loop: quintas graves com respiração lenta e vento filtrado.
func _ambient() -> AudioStreamWAV:
	var dur := 16.0
	return _make(dur, func(t: float, _i: int):
		var breath := 0.5 + 0.5 * sin(TAU * t / dur)
		var breath2 := 0.5 + 0.5 * sin(TAU * t / dur * 2.0 + 1.3)
		var drone := sin(TAU * 55.0 * t) * 0.35 + sin(TAU * 82.5 * t) * 0.2 * breath + sin(TAU * 110.0 * t) * 0.08 * breath2
		var wind := _noise_lp(0.02) * 0.6 * breath2
		return (drone + wind) * 0.35, MUSIC_RATE, true)
