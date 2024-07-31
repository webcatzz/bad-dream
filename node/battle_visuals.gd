extends Node


@onready var _ui: CanvasLayer = $UI
@onready var _selector: CharacterBody2D = $Selector
@onready var _selector_info: Control = $Selector/Info
@onready var _path: Line2D = $Path


func _ready() -> void:
	for actor: Actor in Data.party:
		var control: Control = load("res://node/ui/party_member.tscn").instantiate()
		control.actor = actor
		_ui.get_node("Margins/Party").add_child(control)
	
	Battle.phase_changed.connect(_on_phase_changed)


func _on_phase_changed(is_party_phase: bool) -> void:
	_selector.controllable = is_party_phase



# selector

func _on_selector_body_entered(body: Node2D) -> void:
	var actor: Actor = body.data
	var controls: Array[Control] = []
	
	if actor.traits:
		var traits: VBoxContainer = VBoxContainer.new()
		traits.add_theme_constant_override("separation", 4)
		controls.append(traits)
		
		traits.add_child(Label.new())
		traits.get_child(0).text = "Traits"
		
		for trait_type: Trait.Type in actor.traits:
			traits.add_child(preload("res://node/ui/trait_label.tscn").instantiate())
			traits.get_child(-1).write(trait_type)
	
	_selector_info.write({
		"title": actor.name,
		"controls": controls
	})
	_selector_info.show()


func _on_selector_emptied() -> void:
	_selector_info.hide()


func _on_selector_squeezed() -> void:
	if not _selector.body: return
	
	Battle.current_actor = _selector.body.data
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
