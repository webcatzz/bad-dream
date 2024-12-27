class_name Dialogue
extends Trigger

signal prompted(choices: PackedStringArray)
signal chose(idx: int)
signal next_requested

@export var key: String

var active: bool
var strands: Dictionary # fix [Character, Node2D]
var current_strand: Node2D



# process

func run() -> void:
	active = true
	Game.player.listening = false
	await call(key)
	Game.player.listening = true
	active = false
	
	for strand in strands.values():
		strand.snip()
	strands.clear()


func set_speaker(speaker: Character) -> void:
	if speaker not in strands:
		var strand: Node2D = load("res://scene/dialogue/dialogue_strand.tscn").instantiate()
		strand.modulate = speaker.color
		speaker.add_child(strand)
		strands[speaker] = strand
	current_strand = strands[speaker]


func say(text: String) -> void:
	current_strand.add(text)
	await next_requested


func prompt(text: String, choices: PackedStringArray, decider: Character = Game.player) -> int:
	await say(text)
	return await strands[decider].prompt(choices)


func wait(time: float) -> void:
	await Game.get_tree().create_timer(time).timeout



# input

func next() -> void:
	next_requested.emit()


func choose(idx: int) -> void:
	chose.emit(idx)



# input eating

func _unhandled_input(event: InputEvent) -> void:
	if active and event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		next()



# init

func _ready() -> void:
	super()
	triggered.connect(run)
