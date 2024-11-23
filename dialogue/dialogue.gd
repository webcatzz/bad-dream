class_name Dialogue


signal prompted(choices: PackedStringArray)
signal chose(idx: int)
signal next_requested

var active: bool
var current_strand: Node2D
var strands: Dictionary # fix [Character, Node2D]


func run(key: String) -> void:
	active = true
	await call(key)
	active = false
	
	for strand in strands.values():
		strand.snip()
	strands.clear()


func set_speaker(speaker: Character) -> void:
	if speaker not in strands:
		var strand: Node2D = preload("res://node/dialogue/dialogue_strand.tscn").instantiate()
		strand.position.y = -64
		strand.modulate = speaker.color
		speaker.node.add_child(strand)
		strands[speaker] = strand
	current_strand = strands[speaker]


func say(text: String) -> void:
	current_strand.add(text)
	await next_requested


func prompt(text: String, choices: PackedStringArray, decider: Character = Save.leader) -> int:
	await say(text)
	return await strands[decider].prompt(choices)


func wait(time: float) -> void:
	await Game.get_tree().create_timer(time).timeout



# internal

func load_character(path: String) -> Character:
	return load("res://resource/character/%s.tres" % path)



# response

func next() -> void:
	next_requested.emit()


func choose(idx: int) -> void:
	chose.emit(idx)
