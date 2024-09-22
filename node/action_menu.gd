extends TabContainer


enum Tab {
	MAIN,
	ACTIONS,
}

var actor: Actor
var action_highlight: TileHighlight
var buttons: Array[Button]

@onready var _action_list: ItemList = $Actions/List


func open(actor: Actor) -> void:
	self.actor = actor
	_open_main()
	show()


func close() -> void:
	hide()


func _open_main() -> void:
	current_tab = Tab.MAIN
	$Main/Attack.grab_focus()



# actions

func _open_actions() -> void:
	_action_list.clear()
	
	for action: Action in actor.actions:
		var idx: int = _action_list.add_item(action.name)
		_action_list.set_item_disabled(idx, not actor.can_send_action(action))
	
	current_tab = Tab.ACTIONS
	_action_list.grab_focus()
	_action_list.select(0)
	_action_list.item_selected.emit(0)


func set_highlight(action: Action) -> void:
	if action_highlight: clear_highlight()
	
	action_highlight = TileHighlight.new()
	action_highlight.from_bitshape(action.shape)
	action_highlight.position += Game.battle.selector.position
	Game.battle.add_child(action_highlight)


func clear_highlight() -> void:
	action_highlight.queue_free()
	action_highlight = null



# internal


func _on_action_selected(idx: int) -> void:
	set_highlight(actor.actions[idx])


func _on_action_activated(idx: int) -> void:
	clear_highlight()
	close()
	
	actor.send_action(actor.actions[idx])
	get_parent().on_action_taken()
