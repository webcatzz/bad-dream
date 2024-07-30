extends CanvasLayer


enum Menu {
	NONE = -1,
	PAUSE,
	KEYBINDS,
	INVENTORY,
}

var current_menu: Menu = Menu.NONE

@onready var _overlay: Control = $Overlay


func open(menu: Menu) -> void:
	close()
	
	current_menu = menu
	_overlay.get_child(menu).show()
	_overlay.show()
	
	get_tree().paused = true


func close() -> void:
	current_menu = Menu.NONE
	_overlay.get_child(current_menu).hide()
	_overlay.hide()
	
	get_tree().paused = false


func toggle(menu: Menu) -> void:
	if current_menu == menu:
		close()
	else:
		open(menu)



# internal

func _ready() -> void:
	_overlay.hide()
	for menu: Control in _overlay.get_children():
		menu.hide()


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("inventory"):
		toggle(Menu.INVENTORY)
	elif Input.is_action_pressed("ui_cancel"):
		if current_menu == Menu.NONE:
			open(Menu.PAUSE)
		else:
			close()
