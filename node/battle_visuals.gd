extends Node


@onready var _ui: CanvasLayer = $UI
@onready var _selector: CharacterBody2D = $Selector


func _ready() -> void:
	for actor: Actor in Data.party:
		var control: Control = load("res://node/ui/party_member.tscn").instantiate()
		control.actor = actor
		_ui.get_node("Margins/Party").add_child(control)
	
	Battle.phase_changed.connect(_on_phase_changed)


func _on_phase_changed(is_party_phase: bool) -> void:
	_selector.controllable = is_party_phase
