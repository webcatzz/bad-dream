extends AudioStreamPlayer2D
## Actor SFX player.


var move: AudioStream = load("res://asset/sfx/move.mp3")
var spotlight_on: AudioStream = load("res://asset/sfx/spotlight_on.mp3")
var spotlight_off: AudioStream = load("res://asset/sfx/spotlight_off.mp3")


func plays(string: String) -> void:
	stream = self[string]
	play()
