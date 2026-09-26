extends Node

# Procedural Audio Synth & SFX Controller
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var combo_count: int = 0

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

func reset_combo() -> void:
	combo_count = 0

func play_tap() -> void:
	_trigger_haptic(8)
	_play_procedural_tone(520.0, 0.04, 0.25)

func play_escape(current_combo: int = -1) -> void:
	if current_combo >= 0:
		combo_count = current_combo
	else:
		combo_count += 1
		
	_trigger_haptic(15)
	# Ascending pentatonic pitch
	var base_freq: float = 440.0
	var semitones: Array[float] = [0.0, 2.0, 4.0, 7.0, 9.0, 12.0, 14.0, 16.0]
	var step_idx: int = combo_count % semitones.size()
	var freq: float = base_freq * pow(2.0, semitones[step_idx] / 12.0)
	_play_procedural_tone(freq, 0.18, 0.35)

func play_blocked() -> void:
	combo_count = 0
	_trigger_haptic(28)
	_play_procedural_tone(130.0, 0.12, 0.4)

func play_victory() -> void:
	_trigger_haptic(45)
	# Celebratory arpeggio
	_play_procedural_arpeggio([523.25, 659.25, 783.99, 1046.50])

func _trigger_haptic(duration_ms: int) -> void:
	if SaveManager.save_data.get("settings", {}).get("haptics_enabled", true):
		Input.vibrate_handheld(duration_ms)

func _play_procedural_tone(freq: float, duration: float, volume: float = 0.3) -> void:
	if not SaveManager.save_data.get("settings", {}).get("sound_enabled", true):
		return
		
	var sample_hz: float = 44100.0
	var total_samples: int = int(sample_hz * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = int(sample_hz)
	stream.stereo = false
	
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / sample_hz
		# Exponential decay envelope
		var env: float = exp(-4.0 * (float(i) / float(total_samples)))
		var val: float = sin(2.0 * PI * freq * t) * env * volume
		var sample_val: int = int(clamp(val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample_val)
		
	stream.data = data
	sfx_player.stream = stream
	sfx_player.play()

func _play_procedural_arpeggio(freqs: Array[float]) -> void:
	if not SaveManager.save_data.get("settings", {}).get("sound_enabled", true):
		return
		
	var sample_hz: float = 44100.0
	var note_duration: float = 0.10
	var total_samples: int = int(sample_hz * note_duration * freqs.size())
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = int(sample_hz)
	stream.stereo = false
	
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for f_idx in range(freqs.size()):
		var freq = freqs[f_idx]
		var start_sample: int = int(f_idx * note_duration * sample_hz)
		var note_samples: int = int(note_duration * sample_hz)
		
		for i in range(note_samples):
			var global_sample = start_sample + i
			var t: float = float(i) / sample_hz
			var env: float = exp(-3.0 * (float(i) / float(note_samples)))
			var val: float = sin(2.0 * PI * freq * t) * env * 0.35
			var sample_val: int = int(clamp(val, -1.0, 1.0) * 32767.0)
			data.encode_s16(global_sample * 2, sample_val)
			
	stream.data = data
	sfx_player.stream = stream
	sfx_player.play()
