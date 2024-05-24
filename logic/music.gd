extends Node


var player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	add_child(player)
	player.bus = "Music"


func play(audio_name: String) -> void:
	player.stream = load("res://asset/music/" + audio_name + ".mp3")
	player.play()


func set_paused(value: bool = !player.stream_paused) -> void:
	player.stream_paused = value


func stop() -> void:
	player.stop()
