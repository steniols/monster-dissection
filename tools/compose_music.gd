extends SceneTree
## Compõe a trilha ambiente do jogo e salva em assets/audio/music/main.wav (loop perfeito).
## Ré menor, 8 acordes de 8 s (64 s): pads lentos + caixinha de música esparsa + eco suave.
## Uso: Godot_console.exe --headless --path . -s res://tools/compose_music.gd

const RATE := 22050
const CHORD_SEC := 8.0
const OUT := "res://assets/audio/music/main.wav"

## Cada acorde: [baixo, notas do pad...] em Hz.
const CHORDS := [
	[73.42, 146.83, 174.61, 220.00],   # Dm
	[58.27, 116.54, 146.83, 174.61],   # Bb
	[87.31, 174.61, 220.00, 261.63],   # F
	[65.41, 130.81, 164.81, 196.00],   # C
	[73.42, 146.83, 174.61, 220.00],   # Dm
	[49.00, 98.00, 116.54, 146.83],    # Gm
	[58.27, 116.54, 146.83, 174.61],   # Bb
	[55.00, 110.00, 138.59, 164.81],   # A
]

var _n := 0
var _l := PackedFloat32Array()
var _r := PackedFloat32Array()


func _initialize() -> void:
	var length := CHORDS.size() * CHORD_SEC
	_n = int(length * RATE)
	_l.resize(_n)
	_r.resize(_n)
	_pads()
	_music_box()
	_echo(0.43, 0.32)
	_echo(0.61, 0.24)
	_save()
	quit()


## Acordes com janela cosseno² sobreposta: a soma das janelas é constante, então o loop não tem emenda.
func _pads() -> void:
	var d := CHORD_SEC
	for k in CHORDS.size():
		var chord: Array = CHORDS[k]
		var center := k * d + d * 0.5
		var start := int((center - d) * RATE)
		for s in range(start, start + int(2.0 * d * RATE)):
			var t := float(s) / RATE
			var w := cos(PI * (t - center) / (2.0 * d))
			w *= w
			var i := posmod(s, _n)
			var l := 0.0
			var r := 0.0
			# baixo bem suave
			var fb: float = chord[0]
			l += sin(TAU * fb * t) * 0.22
			r += sin(TAU * fb * 1.002 * t) * 0.22
			for j in range(1, chord.size()):
				var f: float = chord[j]
				var lfo := 0.85 + 0.15 * sin(TAU * t / (11.0 + j * 3.0) + j)
				l += (sin(TAU * f * 0.997 * t) + 0.18 * sin(TAU * f * 2.0 * t)) * 0.13 * lfo
				r += (sin(TAU * f * 1.003 * t) + 0.18 * sin(TAU * f * 2.0 * 1.001 * t)) * 0.13 * lfo
			_l[i] += l * w
			_r[i] += r * w


## Notas de caixinha de música: tons do acorde, duas oitavas acima, em ritmo lento e com pausas.
func _music_box() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var beats := [0.0, 1.5, 3.0, 4.0, 5.5, 6.5]
	for k in CHORDS.size():
		var chord: Array = CHORDS[k]
		for b in beats:
			if rng.randf() < 0.35:
				continue
			var f: float = chord[rng.randi_range(1, chord.size() - 1)] * 4.0
			if rng.randf() < 0.25:
				f *= 0.5
			var start: float = k * CHORD_SEC + float(b) + rng.randf_range(-0.04, 0.04)
			var pan := rng.randf_range(-0.6, 0.6)
			_note(start, f, 0.16 * rng.randf_range(0.7, 1.0), pan)


func _note(start: float, f: float, gain: float, pan: float) -> void:
	var dur := 4.0
	var s0 := int(start * RATE)
	var gl := gain * (1.0 - maxf(0.0, pan))
	var gr := gain * (1.0 + minf(0.0, pan))
	for s in range(int(dur * RATE)):
		var t := float(s) / RATE
		var env := minf(1.0, t * 200.0) * exp(-t * 1.9)
		var v := (sin(TAU * f * t) + 0.28 * sin(TAU * f * 2.0 * t) * exp(-t * 3.0) + 0.08 * sin(TAU * f * 3.01 * t) * exp(-t * 5.0)) * env
		var i := posmod(s0 + s, _n)
		_l[i] += v * gl
		_r[i] += v * gr


## Eco circular (o fim do loop alimenta o começo), duas passadas para estabilizar a cauda.
func _echo(sec: float, g: float) -> void:
	var d := int(sec * RATE)
	for _pass in 2:
		for i in _n:
			var j := posmod(i - d, _n)
			var nl := _l[i] + _r[j] * g
			var nr := _r[i] + _l[j] * g
			_l[i] = nl
			_r[i] = nr


func _save() -> void:
	var peak := 0.0001
	for i in _n:
		peak = maxf(peak, maxf(absf(_l[i]), absf(_r[i])))
	var gain := 0.8 / peak
	var data := PackedByteArray()
	data.resize(_n * 4)
	for i in _n:
		data.encode_s16(i * 4, int(clampf(_l[i] * gain, -1.0, 1.0) * 32000.0))
		data.encode_s16(i * 4 + 2, int(clampf(_r[i] * gain, -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = true
	w.data = data
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT.get_base_dir()))
	var err := w.save_to_wav(ProjectSettings.globalize_path(OUT))
	print("salvo %s (%d s, erro %d)" % [OUT, _n / RATE, err])
