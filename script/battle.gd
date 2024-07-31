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
@onready var _path: Line2D = $Path


func start(enemies: Array[Enemy], region: Rect2i) -> void:
	self.enemies = enemies
	for actor: Actor in Data.party + enemies:
		actor.position = Iso.to_grid(actor.node.position)
	
	for actor: Actor in Data.party:
		var control: Control = load("res://node/ui/party_member.tscn").instantiate()
		control.actor = actor
		$UI/Margins/Party.add_child(control)
	
	ui.show()
	
	cycle()


func cycle() -> void:
	# enemy phase
	party_phase = false
	for enemy: Enemy in enemies:
		current_actor = enemy
		await get_tree().create_timer(1).timeout
	
	# party phase
	party_phase = true
	current_actor = null
	#_selector.controllable = true
	await phase_changed
	
	_selector.controllable = false
	
	cycle()


func end_party_phase() -> void:
	phase_changed.emit()


func end() -> void:
	ui.hide()
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



# selector

func _on_selector_body_entered(body: Node2D) -> void:
	var actor: Actor = body.data
	_selector_info.write({
		"title": actor.name,
		"description": actor.description,
	})
	_selector_info.show()


func _on_selector_emptied() -> void:
	_selector_info.hide()


func _on_selector_squeezed() -> void:
	var body: Node2D = _selector.get_body()
	if not body: return
	
	current_actor = body.data
	_selector_info.hide()
	
	_path.points = current_actor.path.map(func(point: Dictionary) -> Vector2:
		return Iso.from_grid(point.position)
	)


func _on_selector_released() -> void:
	current_actor = null
	_selector_info.show()
	
	_path.clear_points()


func _on_selector_tile_changed() -> void:
	current_actor.extend_path()
	current_actor.move_to(_selector.tile)
	
	_path.points = current_actor.path.map(func(point: Dictionary) -> Vector2:
		return Iso.from_grid(point.position)
	)
