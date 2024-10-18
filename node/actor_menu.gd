extends TabContainer


enum Tab {
	MAIN,
	ACTION,
	MOVEMENT,
	POCKET,
}

var actor: Actor
var buttons: Array[Button]

var history: UndoRedo = UndoRedo.new()

@onready var _selector: Selector = get_parent()
@onready var _action_list: ItemList = $Action/List


func open(actor: Actor) -> void:
	self.actor = actor
	_open_main(Tab.ACTION)
	show()


func close() -> void:
	hide()
	history.clear_history()
	_selector.deselect()


func cancel() -> void:
	hide()
	while history.has_undo():
		await get_tree().create_timer(0.05).timeout
		history.undo()
	await get_tree().create_timer(0.25).timeout
	close()



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
	if actor.actions:
		_action_list.focus_mode = Control.FOCUS_ALL
		_action_list.grab_focus()
		_action_list.select(0)
		if _action_list.is_anything_selected():
			_action_list.item_selected.emit(_action_list.get_selected_items()[0])
			return
	else:
		_action_list.focus_mode = Control.FOCUS_NONE
	$Action/Cancel.grab_focus()


func _open_movement() -> void:
	current_tab = Tab.MOVEMENT
	$Movement/Stop.grab_focus()
	_update_stamina_slots()


func _open_pocket() -> void:
	current_tab = Tab.POCKET
	$Pocket/Item/Name.text = actor.pocket.name



# highlights

func _on_action_selected(idx: int) -> void:
	Game.battle.preview_action(actor.actions[idx], actor)


func _on_action_activated(idx: int) -> void:
	Game.battle.clear_highlight()
	close()
	actor.send_action(actor.actions[idx])
	_selector.deselect_delayed()


func _on_action_list_focus_entered() -> void:
	if _action_list.is_anything_selected():
		_action_list.item_selected.emit(_action_list.get_selected_items()[0])


func _on_action_list_focus_exited() -> void:
	Game.battle.clear_highlight()



# movement

func _on_movement_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("undo"):
		history.undo()
	else:
		var input: Vector2i
		if Input.is_action_just_pressed("move_up"): input = Vector2i.UP
		elif Input.is_action_just_pressed("move_down"): input = Vector2i.DOWN
		elif Input.is_action_just_pressed("move_left"): input = Vector2i.LEFT
		elif Input.is_action_just_pressed("move_right"): input = Vector2i.RIGHT
		else: return
		
		if actor.can_move() and not actor.node.test_move(actor.node.transform, Iso.from_grid(input)):
			_commit_motion(input)
	
	_update_stamina_slots()
	accept_event()


func _commit_motion(motion: Vector2i) -> void:
	history.create_action("motion")
	
	history.add_do_method(actor.add_to_path)
	history.add_do_method(actor.move_by.bind(motion))
	history.add_do_method(Game.battle.selector.match_position.bind(actor.node))
	
	history.add_undo_method(actor.unpath)
	history.add_undo_method(Game.battle.selector.match_position.bind(actor.node))
	
	history.commit_action()


func _update_stamina_slots() -> void:
	$Movement/Stamina/Slots.set_values(actor.stamina, actor.max_stamina)
