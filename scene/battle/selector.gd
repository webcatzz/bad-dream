extends CharacterBody2D

enum Mode {
	DISABLED,
	SKIMMING,
	LOCKED,
}

enum Tab {
	INFO,
	MAIN,
	ATTACK,
	MOVE,
	ITEM,
	CONFIRM,
}

var mode: Mode : set = set_mode
var input: Vector2
var actor: Actor
var history := UndoRedo.new()

@onready var camera: Camera2D = $Camera
@onready var area: Area2D = $Area
@onready var menu: TabContainer = $Menu


func set_mode(value: Mode) -> void:
	mode = value
	match mode:
		Mode.DISABLED:
			set_process_unhandled_key_input(false)
			area.monitoring = false
			hide_menu()
			visible = false
		
		Mode.SKIMMING:
			set_process_unhandled_key_input(true)
			area.monitoring = true
			visible = true
		
		Mode.LOCKED:
			set_process_unhandled_key_input(false)
			area.monitoring = false
			menu_main()



# movement

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and actor:
		if actor.friendly:
			mode = Mode.LOCKED
		else:
			actor.animator.play("err")
		get_viewport().set_input_as_handled()
	else:
		input = Game.grid.tile_to_point(Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")) * 8


func _physics_process(delta: float) -> void:
	if input:
		velocity = velocity.lerp(input, 0.5)
		move_and_slide()
	else:
		position = position.lerp(Game.grid.snap(position), 0.25)



# area

func _on_area_entered(area: Area2D) -> void:
	assert(area is Actor)
	show_menu(area)


func _on_area_exited(area: Area2D) -> void:
	if mode == Mode.SKIMMING:
		hide_menu()



# menu

func show_menu(actor: Actor) -> void:
	self.actor = actor
	menu_info()
	menu.show()


func hide_menu() -> void:
	menu.hide()
	menu.current_tab = Tab.INFO
	actor = null


func menu_info() -> void:
	menu.current_tab = Tab.INFO
	$Menu/Info/Type.text = actor.type
	
	for child: Node in $Menu/Info/Traits.get_children():
		child.queue_free()
	for type: Trait.Type in actor.traits:
		var label: HBoxContainer = preload("res://scene/modifier_label/trait_label.tscn").instantiate()
		label.write(type)
		$Menu/Info/Traits.add_child(label)


func menu_main() -> void:
	var last_tab: Tab = menu.current_tab
	menu.current_tab = Tab.MAIN
	if last_tab > Tab.MAIN:
		await get_tree().process_frame
		await get_tree().process_frame
		menu.get_current_tab_control().get_child(last_tab - Tab.ATTACK).grab_focus()
	else:
		menu_focus()


func menu_attack() -> void:
	menu.current_tab = Tab.ATTACK
	menu_focus()
	
	var highlight := TileHighlight.new()
	highlight.add_tiles([actor.facing])
	add_child(highlight)
	await menu.tab_changed
	highlight.queue_free()


func menu_move() -> void:
	menu.current_tab = Tab.MOVE
	menu_focus()


func menu_item() -> void:
	menu.current_tab = Tab.ITEM
	menu_focus()


func menu_confirm() -> void:
	menu.current_tab = Tab.CONFIRM
	menu_focus()


func menu_focus() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if menu.find_next_valid_focus():
		menu.find_next_valid_focus().grab_focus()



# actor

func _on_attack_confirmed() -> void:
	actor.attack()


func _on_move_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"): step(Vector2i(0, -1))
	elif event.is_action_pressed("ui_down"): step(Vector2i(0, 1))
	elif event.is_action_pressed("ui_left"): step(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"): step(Vector2i(1, 0))
	elif event.is_action_pressed("backtrack") and history.has_undo(): history.undo()
	else: return
	menu.accept_event()


func step(motion: Vector2i) -> void:
	var tile: Vector2i = actor.tile + motion
	var point: Vector2 = Game.grid.tile_to_point(tile)
	
	if not Game.grid.is_point_open(tile): return
	
	history.create_action("move")
	history.add_undo_property(actor, "position", actor.position)
	history.add_undo_property(actor, "facing", actor.facing)
	history.add_undo_property(self, "position", position)
	history.add_do_method(actor.step.bind(point))
	history.add_do_property(self, "position", point)
	history.commit_action()





# init

func _ready() -> void:
	mode = Mode.DISABLED
