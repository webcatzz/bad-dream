extends TabContainer


enum Tab {
	MAIN,
	ACTION,
	MOVEMENT,
	POCKET,
}

var actor: Actor
var action_highlight: TileHighlight
var buttons: Array[Button]

@onready var _selector: Selector = get_parent()
@onready var _action_list: ItemList = $Action/List


func open(actor: Actor) -> void:
	self.actor = actor
	_open_main(Tab.ACTION)
	show()


func close() -> void:
	hide()



# openers

func _open_main(from: Tab = current_tab) -> void:
	current_tab = Tab.MAIN
	$Main.get_child(from - 1).grab_focus()
	$Main/Pocket.disabled = actor.pocket == null


func _open_action() -> void:
	_action_list.clear()
	
	for action: Action in actor.actions:
		var idx: int = _action_list.add_item(action.name + " " + "*".repeat(action.cost))
		_action_list.set_item_disabled(idx, not actor.can_send_action(action))
	
	current_tab = Tab.ACTION
	_action_list.grab_focus()
	_action_list.select(0)
	_action_list.item_selected.emit(0)


func _open_movement() -> void:
	current_tab = Tab.MOVEMENT
	$Movement/Stop.grab_focus()
	update_stamina()


func _open_pocket() -> void:
	current_tab = Tab.POCKET
	$Pocket/Item/Name.text = actor.pocket.name



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



# movement

func _on_movement_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("undo"):
		Game.battle.history.undo()
	else:
		var input: Vector2i
		if Input.is_action_just_pressed("move_up"): input = Vector2i.UP
		elif Input.is_action_just_pressed("move_down"): input = Vector2i.DOWN
		elif Input.is_action_just_pressed("move_left"): input = Vector2i.LEFT
		elif Input.is_action_just_pressed("move_right"): input = Vector2i.RIGHT
		else: return
		
		if _selector.selected.resource.can_move() and not _selector.selected.test_move(_selector.selected.transform, Iso.from_grid(input)):
			Game.battle.history.add_motion(_selector.selected.resource, input)
	
	update_stamina()
	accept_event()


func update_stamina() -> void:
	$Movement/Stamina/Slots.set_values(actor.stamina, actor.max_stamina)
