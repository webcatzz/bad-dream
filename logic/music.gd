extends Node


var player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	add_child(player)
	player.bus = "Music"
	
	process_mode = Node.PROCESS_MODE_ALWAYS


## Loads an audio file from /asset/music/ and plays it.
func play(audio_name: String) -> void:
	player.stream = load("res://asset/music/" + audio_name + ".mp3")
	player.play()


## Sets whether the player is paused. If no argument is passed, toggles playback.
func set_paused(value: bool = !player.stream_paused) -> void:
	player.stream_paused = value


## Stops the player.
func stop() -> void:
	player.stop()
