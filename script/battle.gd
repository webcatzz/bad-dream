extends Node


signal phase_changed(is_party_phase: bool)


var active: bool = false

var enemies: Array[Enemy]
var current_actor: Actor
var party_phase: bool = false

var history: Array[Dictionary]
var history_idx: int

var _visuals: Node


func start(enemies: Array[Enemy], region: Rect2i) -> void:
	self.enemies = enemies
	for actor: Actor in Data.party + enemies:
		actor.position = Iso.to_grid(actor.node.position)
	
	_visuals = preload("res://node/battle_visuals.tscn").instantiate()
	add_child(_visuals)
	
	cycle()


func cycle() -> void:
	# enemy phase
	party_phase = false
	phase_changed.emit(false)
	
	for enemy: Enemy in enemies:
		current_actor = enemy
		await get_tree().create_timer(1).timeout
	
	
	# party phase
	party_phase = true
	current_actor = null
	phase_changed.emit(true)
	await phase_changed
	
	cycle()


func end_party_phase() -> void:
	phase_changed.emit()


func end() -> void:
	remove_child(_visuals)
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
		"enemies": enemies.map(func(enemy: Enemy) -> Enemy: return enemy.duplicate()),
		"party": Data.party.map(func(actor: Actor) -> Actor: return actor.duplicate()),
	})
	
	history_idx += 1


func recall_state() -> void:
	if not history: return
	var state: Dictionary = history[history_idx]



# input

func _unhandled_key_input(_event: InputEvent) -> void:
	if party_phase:
		
		if Input.is_action_pressed("backtrack"):
			undo()
		
		elif Input.is_action_pressed("ui_cancel"):
			$EndPhaseConfirm.popup_centered()
