extends TabContainer


@onready var actor: Actor = get_parent().get_parent().data

var splash: Splash


## Adds a new [Splash] preview.
func set_splash(action: Action) -> void:
	free_splash()
	splash = Splash.new(action)
	splash.action.cause = actor
	actor.node.add_child(splash)


## Frees the current [Splash] preview.
func free_splash() -> void:
	if splash:
		splash.queue_free()
		splash = null



# internal

func _ready() -> void:
	var actionlist: ItemList = $ActionList
	for action in actor.actions: actionlist.add_item(action.name)


func _focus_tab() -> void:
	if get_current_tab_control().find_next_valid_focus():
		get_current_tab_control().find_next_valid_focus().grab_focus()


func _on_visibility_changed() -> void:
	if visible:
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		_focus_tab()


func _on_tab_changed(idx: int) -> void:
	_on_visibility_changed()
	
	if idx == 1:
		actor.node.set_spotlight(false)


# Previews the currently selected [Action]'s [Splash].
func _on_actionlist_item_selected(idx: int) -> void:
	set_splash(actor.actions[idx])


# Starts the currently selected [Action] and closes the menu.
func _on_actionlist_item_activated(_idx: int) -> void:
	actor.node.listening = false
	
	var action: Action = splash.action
	splash = null
	visible = false
	await actor.take_action(action)
	
	actor.node.listening = true


func _end_turn() -> void:
	actor.end_turn()
	visible = false
