extends TabContainer


@onready var actor: Actor = owner.data

var splash: Splash


## Adds a new [Splash] preview.
func set_splash(splash: Splash) -> void:
	free_splash()
	self.splash = splash
	actor.node.get_parent().add_child(splash)


## Frees the current [Splash] preview.
func free_splash() -> void:
	if splash:
		splash.queue_free()
		splash = null



# internal

func _ready() -> void:
	var actionlist: ItemList = $Actions.list
	actionlist.item_activated.connect(_on_actionlist_item_activated)
	actionlist.item_selected.connect(_on_actionlist_item_selected)
	actionlist.focus_entered.connect(_on_actionlist_item_selected.bind(0))
	actionlist.focus_entered.connect(actionlist.select.bind(0))
	actionlist.hidden.connect(free_splash)
	if actor.actions:
		for action: Action in actor.actions:
			actionlist.add_item(action.name)
	else:
		$TypeChooser/Attack.disabled = true
	
	var inventory: ItemList = $Inventory.list
	inventory.item_activated.connect(_on_inventory_item_activated)
	inventory.item_selected.connect(_on_inventory_item_selected)
	inventory.focus_entered.connect(_on_inventory_item_selected.bind(0))
	inventory.focus_entered.connect(inventory.select.bind(0))
	inventory.hidden.connect(free_splash)


# Focuses the first available [Control].
func _focus_tab() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if get_current_tab_control().find_next_valid_focus():
		get_current_tab_control().find_next_valid_focus().grab_focus()


# Focuses when becoming visible.
func _on_visibility_changed() -> void:
	if visible: _focus_tab()


# Hides the spotlight when the action list is visible.
func _on_tab_changed(idx: int) -> void:
	if visible: _focus_tab()
	actor.node.set_spotlight(idx == 0)
	
	if idx == 2:
		var inventory: ItemList = $Inventory.list
		inventory.clear()
		if Data.inventory:
			for item: Item in Data.inventory:
				inventory.add_item(item.name)
		else:
			$TypeChooser/Item.disabled = true



# actions

func _on_actionlist_item_selected(idx: int) -> void:
	var action: Action = actor.actions[idx]
	set_splash(Splash.new(action, actor))
	$Actions.display(action.name, action.description)


func _on_actionlist_item_activated(idx: int) -> void:
	actor.current_splash = splash
	splash = null
	visible = false
	get_viewport().set_input_as_handled()
	
	actor.take_action(actor.actions[idx])



# inventory

func _on_inventory_item_selected(idx: int) -> void:
	$Inventory.display(Data.inventory[idx].name, Data.inventory[idx].description)
	if Data.inventory[idx] is Consumable and Data.inventory[idx].action:
		set_splash(Splash.new(Data.inventory[idx].action, actor))


func _on_inventory_item_activated(idx: int) -> void:
	actor.current_splash = splash
	splash = null
	visible = false
	get_viewport().set_input_as_handled()
	
	actor.use_item(Data.inventory[idx])



# guarding

func _guard() -> void:
	actor.guard()
	visible = false
