extends Node


signal phase_changed


var active: bool = false

var enemies: Array[Enemy]
var current_actor: Actor
var party_phase: bool = false

var history: Array[Dictionary]
var history_idx: int

@onready var ui: CanvasLayer = $UI


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
	var state: Dictionary = history[history_idx]



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if not party_phase: return
	
	if event.is_action_pressed("move_up"):
		current_actor.move_by(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		current_actor.move_by(Vector2i.DOWN)
	elif event.is_action_pressed("move_left"):
		current_actor.move_by(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		current_actor.move_by(Vector2i.RIGHT)
	
	elif event.is_action_pressed("interact"):
		pass



# selector

func _on_selector_actor_entered(actor: Actor) -> void:
	$Selector/Info.write({
		"title": actor.name,
		"description": actor.description,
	})
	$Selector/Info.show()


func _on_selector_emptied() -> void:
	$Selector/Info.hide()
