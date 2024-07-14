extends Node2D


signal interacted_with


@onready var flag: String = Game.get_world_name() + "_bridges"


func _ready() -> void:
	if name in Data.get_flag(flag, []):
		open()


func on_interact() -> void:
	Data.get_leader().node.listening = false
	open()
	await $Animator.animation_finished
	Data.get_leader().node.listening = true


func open() -> void:
	$Animator.play("open")
	await $Animator.animation_finished
	$Collision.queue_free()
	
	var bridges: Array = Data.get_flag(flag, [])
	bridges.append(name)
	Data.set_flag(flag, bridges)
	
	interacted_with.emit()
