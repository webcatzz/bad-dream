class_name Battle extends Node2D


# state
signal started
signal cycled
signal ended
# phase
signal phase_changed

enum Phase {
	ENEMY,
	PARTY,
}

@export var enemy_nodes: Array[ActorNode]

var cycle_idx: int = -1
var enemies: Array[Enemy]
var phase: Phase

var tile_highlight: TileHighlight

@onready var camera: Camera2D = $Camera
@onready var actor_info: PanelContainer = $ActorInfo
@onready var animator: AnimationPlayer = $UI/Animator
@onready var party_controller: Node2D = $PartyController



# cycling

func start() -> void:
	Game.battle = self
	
	Game.party_node.toggle(false)
	for actor: Actor in Save.party:
		actor.node.stop_walking()
		ready_actor(actor)
		party_controller.ready_actor(actor)
	
	for actor: Actor in enemies:
		ready_actor(actor)
	
	$UI.show()
	
	#var animation: Node = load("res://node/battle_intro.tscn").instantiate()
	#add_child(animation)
	#await animation.get_node("Root/Animator").animation_finished
	
	started.emit()
	
	cycle()


func cycle() -> void:
	cycle_idx += 1
	await do_party_phase()
	await do_enemy_phase()
	cycled.emit()
	cycle()


func do_enemy_phase() -> void:
	phase = Phase.ENEMY
	
	animator.play("start_enemy_phase")
	
	for enemy: Enemy in enemies:
		await enemy.act()
		enemy.stamina = enemy.max_stamina
	
	end_phase()


func do_party_phase() -> void:
	phase = Phase.PARTY
	
	animator.play("start_party_phase")
	
	for actor: Actor in Save.party:
		actor.stamina = actor.max_stamina
		actor.acted_this_phase = false
	
	party_controller.toggle(true)
	
	await phase_changed
	
	party_controller.toggle(false)
	
	if not enemies:
		end()


func end_phase() -> void:
	phase_changed.emit()


func end() -> void:
	Game.battle = null
	Game.party_node.toggle(true)
	$UI.hide()
	
	ended.emit()
	queue_free()



# actors

func ready_actor(actor: Actor) -> void:
	actor.set_position(Iso.to_grid(Iso.snap(actor.node.position)))
	actor.defeated.connect(free_actor.bind(actor))
	
	actor.node.input.mouse_entered.connect(actor_info.open.bind(actor))
	actor.node.input.mouse_exited.connect(actor_info.close)


func free_actor(actor: Actor) -> void:
	if actor is Enemy:
		enemies.erase(actor)
	else:
		Save.party.erase(actor)



# highlights

func highlight(shape: BitShape) -> void:
	clear_highlight()
	tile_highlight = TileHighlight.new()
	tile_highlight.shape = shape
	add_child(tile_highlight)


func clear_highlight() -> void:
	if tile_highlight:
		tile_highlight.queue_free()
		tile_highlight = null


func preview_action(action: Action, cause: Actor) -> void:
	var shape: BitShape = action.shape.rotated(cause.facing)
	shape.offset += cause.position
	highlight(shape)
	
	if action.knockback:
		for actor: Actor in Game.grid.collide_action(action, cause):
			var line: Line2D = preload("res://node/knockback_arrow.tscn").instantiate()
			line.position = Iso.from_grid(actor.position) - tile_highlight.position
			line.set_end(Iso.rotate_grid_vector(action.knockback, cause.facing))
			tile_highlight.add_child(line)



# camera

func watch(node: Node2D) -> void:
	camera.get_parent().remove_child(camera)
	node.add_child(camera)



# internal

func _ready() -> void:
	for node: ActorNode in enemy_nodes:
		enemies.append(node.resource)
