extends TabContainer


@onready var actor: Actor = get_parent().get_parent().data

var splash: Splash


## Focuses the first valid [Control] in the current tab.
func focus_tab() -> void:
	get_current_tab_control().find_next_valid_focus().grab_focus()

## Previews the currently selected [Action]'s [Splash].
func on_action_selected(idx: int) -> void:
	free_splash()
	splash = Splash.new(actor.actions[idx])
	splash.action.cause = actor
	actor.node.add_child(splash)

## Starts the currently selected [Action] and closes the menu.
func take_action(idx: int) -> void:
	splash.action.start()
	splash = null
	visible = false

## Frees the current [Splash] preview.
func free_splash() -> void:
	if splash:
		splash.queue_free()
		splash = null

func end_turn():
	actor.end_turn()
