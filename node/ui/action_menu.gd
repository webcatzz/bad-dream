extends TabContainer


@onready var actor: Actor = owner.data

var splash: Splash ## Currently rendered [Splash].


## Adds a new [Splash] preview.
func set_splash(action: Action) -> void:
	free_splash()
	splash = action.splash
	actor.node.get_parent().add_child(splash)


## Frees the current [Splash] preview.
func free_splash() -> void:
	if splash:
		splash.get_parent().remove_child(splash)
		splash = null



# internal

func _ready() -> void:
	var actionlist: ItemList = $Actions/List
	if actor.actions:
		for action in actor.actions:
			actionlist.add_item(action.name)
	else:
		$TypeChooser/Attack.disabled = true


# Focuses the first available [Control].
func _focus_tab() -> void:
	if get_current_tab_control().find_next_valid_focus():
		get_current_tab_control().find_next_valid_focus().grab_focus()


# Focuses when becoming visible.
func _on_visibility_changed() -> void:
	if visible:
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		_focus_tab()


# Hides the spotlight when the action list is visible.
func _on_tab_changed(idx: int) -> void:
	_on_visibility_changed()
	actor.node.set_spotlight(idx == 1)


func _on_actionlist_item_selected(idx: int) -> void:
	set_splash(actor.actions[idx])
	$Actions/Label.text = actor.actions[idx].description


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
