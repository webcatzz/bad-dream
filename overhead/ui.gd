extends CanvasLayer

@onready var animator: AnimationPlayer = $Animator


func open(ui: String):
	animator.play(ui + "_open")


func close(ui: String):
	animator.play(ui + "_close")
