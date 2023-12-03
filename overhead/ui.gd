extends CanvasLayer

@onready var animator: AnimationPlayer = $Animator


func open(ui: String):
	animator.play(ui + "_open")


func close(ui: String):
	animator.play(ui + "_close")


func focus_next():
	get_viewport().gui_get_focus_owner().find_next_valid_focus().grab_focus()

func focus_prev():
	get_viewport().gui_get_focus_owner().find_prev_valid_focus().grab_focus()
