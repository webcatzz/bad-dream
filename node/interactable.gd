class_name Interactable extends Control


signal click_started
signal clicked
signal right_click_started
signal right_clicked

@export var cursor_gesture: Cursor.Gesture
@export var move_leader: Vector2i


func interact() -> void:
	pass


func toggle(value: bool) -> void:
	print(value)
	visible = value



# internal

func _ready() -> void:
	clicked.connect(interact)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: click_started.emit()
			else: clicked.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed: right_click_started.emit()
			else: right_clicked.emit()


func _on_mouse_entered() -> void:
	Game.cursor.gesture(cursor_gesture)


func _on_mouse_exited() -> void:
	Game.cursor.gesture(Cursor.Gesture.NONE)
