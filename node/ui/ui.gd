extends CanvasLayer


enum Menu {
	NONE = -1,
	INVENTORY,
	PAUSE,
}

var current_menu: Menu = Menu.NONE

@onready var _overlay: Control = $Overlay


func open(menu: Menu) -> void:
	close()
	current_menu = menu
	get_child(menu).show()
	_overlay.show()
	
	get_tree().paused = true


func close() -> void:
	get_child(current_menu).hide()
	_overlay.hide()
	current_menu = Menu.NONE
	
	get_tree().paused = false


func toggle(menu: Menu) -> void:
	if current_menu == menu:
		close()
	else:
		open(menu)



# internal

func _ready() -> void:
	for menu: Control in get_children():
		menu.hide()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle(Menu.INVENTORY)
	elif event.is_action_pressed("ui_cancel"):
		if current_menu == Menu.NONE:
			open(Menu.PAUSE)
		else:
			close()
