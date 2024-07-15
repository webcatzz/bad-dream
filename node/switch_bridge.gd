extends Node2D


signal interacted_with


func on_interact() -> void:
	$Animator.play("open")
	await $Animator.animation_finished
	$Collision.queue_free()
	
	interacted_with.emit()
	
	if Battle.active:
		await $Collision.tree_exited
		Battle.field.generate()
