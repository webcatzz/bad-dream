extends CanvasLayer


func _ready() -> void:
	$Panel/VBox/OK.grab_focus()


func _on_ok_pressed():
	Data.load_file(-1)
