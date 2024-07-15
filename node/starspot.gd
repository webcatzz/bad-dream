extends Node2D



func reveal():
	$Animator.play("reveal")
	$Animator.queue("float")
