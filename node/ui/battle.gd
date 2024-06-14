extends Node
## Battle UI manager.


@onready var _animator: AnimationPlayer = $Animator
@onready var _modulator: CanvasModulate = $Modulator

@onready var _order: HBoxContainer = $Top/VBox/BarTop/Order


func _ready() -> void:
	Battle.started.connect(_on_battle_started)
	Battle.ended.connect(_on_battle_ended)
	Battle.actor_added.connect(_on_actor_added)
	Battle.actor_removed.connect(_on_actor_removed)



# showing & hiding

func _on_battle_started() -> void:
	_animator.play("open")
	
	_modulator.visible = true
	get_tree().create_tween().tween_property(_modulator, "color:v", 0.8, 2)


func _on_battle_ended() -> void:
	_animator.play("close")
	
	await get_tree().create_tween().tween_property(_modulator, "color:v", 1, 2).finished
	_modulator.visible = false



# portraits

func _on_actor_added(actor: Actor, idx: int) -> void:
	var portrait: Control = preload("res://node/ui/portrait.tscn").instantiate()
	portrait.set_actor(actor)
	
	_order.add_child(portrait)
	_order.move_child(portrait, idx)


func _on_actor_removed(idx: int) -> void:
	_order.get_child(idx).queue_free()
