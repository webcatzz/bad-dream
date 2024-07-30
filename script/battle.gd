extends Node


signal phase_changed


var active: bool = false

var enemies: Array[Enemy]
var current_actor: Actor
var party_phase: bool = false

var history: Array[Dictionary]
var history_idx: int

@onready var ui: CanvasLayer = $UI
@onready var _selector: CharacterBody2D = $Selector
@onready var _selector_info: Control = $Selector/Info
@onready var _input_timer: Timer = $InputTimer


func start(enemies: Array[Enemy], region: Rect2i) -> void:
	self.enemies = enemies
	
	ui.show()
	
	cycle()


func cycle() -> void:
	# enemy phase
	party_phase = false
	for enemy: Enemy in enemies:
		pass
	
	# party phase
	party_phase = true
	current_actor = Data.party[0]
	await phase_changed
	
	cycle()


func end_party_phase() -> void:
	phase_changed.emit()


func end() -> void:
	history.clear()
	party_phase = false
	active = false



# history

func undo() -> void:
	history_idx = max(history_idx - 1, 0)
	recall_state()


func redo() -> void:
	history_idx = min(history_idx + 1, history.size() - 1)
	recall_state()


func record_state() -> void:
	if history_idx != history.size() - 1:
		history.resize(history_idx + 1)
	
	history.append({
		
	})
	
	history_idx += 1


func recall_state() -> void:
	if not history: return
	var state: Dictionary = history[history_idx]
	
	



# input

func _unhandled_key_input(_event: InputEvent) -> void:
	if party_phase and Input.is_action_pressed("interact"):
		if _selector.visible:
			current_actor = _selector.get_actor()
			_selector.hide()
			_input_timer.start()
		else:
			current_actor = null
			_selector.show()
			_input_timer.stop()


func _on_input_timer_timeout() -> void:
	if Input.is_action_pressed("backtrack"):
		undo()
		return
	
	var input: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)
	input[input.abs().min_axis_index()] = 0
	current_actor.move_by(input)



# selector

func _on_selector_actor_entered(actor: Actor) -> void:
	_selector_info.write({
		"title": actor.name,
		"description": actor.description,
	})
	_selector_info.show()


func _on_selector_emptied() -> void:
	_selector_info.hide()
