extends CanvasLayer

@onready var animator: AnimationPlayer = $Animator


func open(ui: String) -> void: animator.play(ui + "_open")

func close(ui: String) -> void: animator.play(ui + "_close")
