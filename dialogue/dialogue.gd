class_name Dialogue


signal text_changed(text: String)
signal speaker_changed(speaker: Character)
signal prompted(choices: PackedStringArray)
signal chose(idx: int)
signal next_requested


func say(text: String) -> void:
	text_changed.emit(text)
	await next_requested


func set_speaker(speaker: Character) -> void:
	speaker_changed.emit(speaker)


func prompt(text: String, choices: PackedStringArray) -> int:
	await say(text)
	prompted.emit(choices)
	return await chose


func wait(time: float) -> void:
	await Game.get_tree().create_timer(time).timeout


func next() -> void:
	next_requested.emit()


func choose(idx: int) -> void:
	chose.emit(idx)
