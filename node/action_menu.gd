extends PanelContainer


signal selected(action: Action)
signal activated(action: Action)

var actor: Actor
var action_highlight: TileHighlight
var buttons: Array[Button]


func open(actor: Actor) -> void:
	self.actor = actor
	
	for action: Action in actor.actions:
		add(action)
	
	show()
	$VBox/Cancel.grab_focus()


func close() -> void:
	hide()
	clear()



# items

func add(action: Action) -> void:
	var button: Button = Button.new()
	
	button.text = action.name
	button.disabled = not actor.can_send_action(action)
	
	button.theme_type_variation = &"ActionButton"
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	button.focus_entered.connect(_on_selected.bind(action))
	button.pressed.connect(_on_activated.bind(action))
	
	buttons.append(button)
	$VBox.add_child(button)


func clear() -> void:
	for button: Button in buttons:
		button.queue_free()
	buttons.clear()


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

func _on_selected(action: Action = null) -> void:
	if action: set_highlight(action)
	selected.emit(action)


func _on_activated(action: Action = null) -> void:
	if action_highlight: clear_highlight()
	close()
	activated.emit(action)
