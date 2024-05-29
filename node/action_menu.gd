extends TabContainer


@onready var actor: Actor = get_parent().get_parent().data

var splash: Splash


func _ready():
	var actionlist: ItemList = get_child(1)
	for action in actor.actions: actionlist.add_item(action.name)


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


## Focuses the first valid [Control] in the current tab.
func focus_tab():
	if get_current_tab_control().find_next_valid_focus():
		get_current_tab_control().find_next_valid_focus().grab_focus()


## Ends the [member actor]'s turn.
func end_turn():
	actor.end_turn()
	visible = false



# signal connections


func _on_visibility_changed():
	if visible:
		await get_tree().process_frame
		focus_tab()


func _on_tab_changed(idx: int) -> void:
	actor.node.set_spotlight(idx != 1)
	if visible:
		await get_tree().process_frame
		focus_tab()


# Previews the currently selected [Action]'s [Splash].
func _on_actionlist_item_selected(idx: int) -> void:
	set_splash(actor.actions[idx])


# Starts the currently selected [Action] and closes the menu.
func _on_actionlist_item_activated(idx: int) -> void:
	var action: Action = splash.action
	splash = null
	visible = false
	action.start()
