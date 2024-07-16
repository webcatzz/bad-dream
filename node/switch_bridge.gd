extends Node2D


signal interacted_with


func on_interact() -> void:
	$Animator.play("open")
	await $Animator.animation_finished
	
	interacted_with.emit()
	
	if Battle.active:
		Battle.field.generate()
