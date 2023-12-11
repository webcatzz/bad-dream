extends Node

var player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void: add_child(player)


func play(audio: Variant = null) -> void:
	if audio is String: player.stream = load("res://asset/music/" + audio + ".mp3")
	elif audio is AudioStreamMP3: player.stream = audio
	player.play()


func set_paused(value: bool = !player.stream_paused) -> void:
	player.stream_paused = value


func stop() -> void: player.stop()
