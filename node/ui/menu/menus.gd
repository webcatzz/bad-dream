extends CanvasLayer


enum Menu {
	PAUSE,
	SETTINGS,
	CONTROLS,
	INVENTORY,
	CONSOLE,
}

var last_focus: Control

@onready var _menus: TabContainer = $Overlay/Tabs


func open(menu: Menu) -> void:
	if visible:
		close()
	else:
		last_focus = get_viewport().gui_get_focus_owner()
	
	get_tree().paused = true
	_menus.current_tab = menu
	show()
	
	await get_tree().process_frame
	if _menus.find_next_valid_focus():
		_menus.find_next_valid_focus().grab_focus()


func close() -> void:
	get_tree().paused = false
	hide()
	
	if last_focus:
		last_focus.grab_focus()


func toggle(menu: Menu) -> void:
	if _menus.current_tab == menu:
		close()
	else:
		open(menu)



# internal

func _ready() -> void:
	hide()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()
		else:
			open(Menu.PAUSE)
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("inventory"):
		if not visible or _menus.current_tab == Menu.INVENTORY: toggle(Menu.INVENTORY)
		get_viewport().set_input_as_handled()


func _exit() -> void:
	get_tree().quit()
