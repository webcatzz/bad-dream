extends CanvasLayer


enum Menu {
	NONE = -1,
	PAUSE,
	INVENTORY,
	CONSOLE,
}

var current_menu: Menu = Menu.NONE
var last_focus: Control

@onready var _overlay: Control = $Overlay


func open(menu: Menu) -> void:
	close()
	last_focus = get_viewport().gui_get_focus_owner()
	
	current_menu = menu
	_overlay.get_child(menu).show()
	
	_overlay.show()
	get_tree().paused = true
	
	await get_tree().process_frame
	if _overlay.find_next_valid_focus():
		_overlay.find_next_valid_focus().grab_focus()


func close() -> void:
	if current_menu == Menu.NONE: return
	
	_overlay.get_child(current_menu).hide()
	current_menu = Menu.NONE
	
	_overlay.hide()
	get_tree().paused = false
	if last_focus: last_focus.grab_focus()


func toggle(menu: Menu) -> void:
	if current_menu == menu:
		close()
	else:
		open(menu)



# internal

func _ready() -> void:
	_overlay.hide()
	
	for i: int in _overlay.get_child_count() - 1:
		_overlay.get_child(i).hide()


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle(Menu.INVENTORY)
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("ui_cancel"):
		if current_menu == Menu.NONE: open(Menu.PAUSE)
		else: close()
		get_viewport().set_input_as_handled()
