extends Node


signal phase_changed(is_party_phase: bool)


var active: bool = false

var enemies: Array[Enemy]
var current_actor: Actor
var party_phase: bool = false

var history: BattleHistory

var _visuals: Node


func start(enemies: Array[Enemy], region: Rect2i) -> void:
	self.enemies = enemies
	for actor: Actor in Data.party + enemies:
		actor.position = Iso.to_grid(actor.node.position)
	
	_visuals = preload("res://node/battle_visuals.tscn").instantiate()
	add_child.call_deferred(_visuals)
	
	history = BattleHistory.new()
	
	active = true
	cycle()


func cycle() -> void:
	# enemy phase
	party_phase = false
	phase_changed.emit(false)
	
	for enemy: Enemy in enemies:
		current_actor = enemy
		#await get_tree().create_timer(1).timeout
	
	# party phase
	party_phase = true
	current_actor = null
	
	for actor: Actor in Data.party:
		actor.stamina = actor.max_stamina
	
	phase_changed.emit(true)
	await phase_changed
	
	cycle()


func end_party_phase() -> void:
	history = null
	phase_changed.emit()


func end() -> void:
	remove_child(_visuals)
	if party_phase: end_party_phase()
	active = false



# input

func _unhandled_key_input(_event: InputEvent) -> void:
	if history and history.has_undo() and Input.is_action_pressed("backtrack"):
		history.undo()
