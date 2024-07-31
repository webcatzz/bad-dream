extends Node


@onready var _ui: CanvasLayer = $UI
@onready var _selector: CharacterBody2D = $SVisual/elector
@onready var _selector_info: Control = $Visual/Selector/Info
@onready var _path: Line2D = $Visual/Path


func _ready() -> void:
	for actor: Actor in Data.party:
		var control: Control = load("res://node/ui/party_member.tscn").instantiate()
		control.actor = actor
		_ui.get_node("Margins/Party").add_child(control)



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
	
	Battle.current_actor = body.data
	_selector_info.hide()
	
	_path.points = Battle.current_actor.path.map(func(point: Dictionary) -> Vector2:
		return Iso.from_grid(point.position)
	)


func _on_selector_released() -> void:
	Battle.current_actor = null
	_selector_info.show()
	
	_path.clear_points()


func _on_selector_tile_changed() -> void:
	Battle.current_actor.extend_path()
	Battle.current_actor.move_to(_selector.tile)
	
	_path.points = Battle.current_actor.path.map(func(point: Dictionary) -> Vector2:
		return Iso.from_grid(point.position)
	)
