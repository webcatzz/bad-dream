extends TabContainer


enum Tab {
	MAIN,
	ACTION,
	MOVEMENT,
}

var actor: Actor
var action_highlight: TileHighlight
var buttons: Array[Button]

@onready var _selector: Selector = get_parent()
@onready var _action_list: ItemList = $Action/List


func open(actor: Actor) -> void:
	self.actor = actor
	_open_main()
	show()


func close() -> void:
	hide()



# openers

func _open_main() -> void:
	current_tab = Tab.MAIN
	$Main/Attack.grab_focus()


func _open_action() -> void:
	_action_list.clear()
	
	for action: Action in actor.actions:
		var idx: int = _action_list.add_item(action.name)
		_action_list.set_item_disabled(idx, not actor.can_send_action(action))
	
	current_tab = Tab.ACTION
	_action_list.grab_focus()
	_action_list.select(0)
	_action_list.item_selected.emit(0)


func _open_movement() -> void:
	_selector.mode = Selector.Mode.MOVE
	
	current_tab = Tab.MOVEMENT
	$Movement/Stop.grab_focus()


func _close_movement() -> void:
	_selector.mode = Selector.Mode.ACT
	_open_main()



# highlights

func set_highlight(action: Action) -> void:
	clear_highlight()
	
	action_highlight = TileHighlight.new()
	action_highlight.from_bitshape(action.shape)
	action_highlight.position += Game.battle.selector.position
	Game.battle.add_child(action_highlight)


func clear_highlight() -> void:
	if action_highlight:
		action_highlight.queue_free()
		action_highlight = null


func _on_action_selected(idx: int) -> void:
	set_highlight(actor.actions[idx])


func _on_action_activated(idx: int) -> void:
	clear_highlight()
	close()
	actor.send_action(actor.actions[idx])
	_selector.deselect_delayed()



# guarding

func _on_guard_pressed() -> void:
	close()
	actor.guard()
	_selector.deselect_delayed()
