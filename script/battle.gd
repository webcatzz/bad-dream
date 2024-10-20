class_name Battle extends Node2D


# state
signal started
signal cycled
signal ended
# phase
signal phase_changed
signal enemy_phase_started
signal party_phase_started

enum Phase {ENEMY, PARTY}

@export var enemy_nodes: Array[ActorNode]

var cycle_idx: int = -1
var enemies: Array[Enemy]
var phase: Phase
# helpers
var field: BattleField
var tile_highlight: TileHighlight

@onready var selector: CharacterBody2D = $Selector



# cycling

func start() -> void:
	Game.battle = self
	Game.party_node.set_enabled(false)
	field = BattleField.new()
	$UI.show()
	
	for actor: Actor in Save.party + enemies:
		ready_actor(actor)
	
	var animation: Node = load("res://node/battle_intro.tscn").instantiate()
	add_child(animation)
	await animation.get_node("Root/Animator").animation_finished
	
	#for actor: Actor in Save.party:
		#var figure: Control = load("res://node/ui/party_member.tscn").instantiate()
		#figure.actor = actor
		#_party.add_child(figure)
	
	#announce("Battle start!", Palette.RED)
	started.emit()
	
	cycle()


func cycle() -> void:
	cycle_idx += 1
	await do_enemy_phase()
	await do_party_phase()
	cycled.emit()
	cycle()


func do_enemy_phase() -> void:
	phase = Phase.ENEMY
	$UI/Phase.current_tab = phase
	
	enemy_phase_started.emit()
	announce("Enemy Phase", Palette.RED)
	await get_tree().create_timer(1).timeout
	
	for enemy: Enemy in enemies:
		field.update_region()
		await selector.move_to(enemy.position)
		await enemy.act()
		enemy.stamina = enemy.max_stamina
	
	end_phase()


func do_party_phase() -> void:
	phase = Phase.PARTY
	$UI/Phase.current_tab = phase
	
	party_phase_started.emit()
	announce("Party Phase", Palette.BLUE)
	await get_tree().create_timer(0.8).timeout
	
	await selector.move_to(Save.player.position)
	selector.set_enabled(true)
	await phase_changed
	selector.set_enabled(false)
	
	for actor: Actor in Save.party:
		actor.stamina = actor.max_stamina
		actor.acted_this_phase = false
	
	if not enemies:
		end()


func end_phase() -> void:
	phase_changed.emit()


func end() -> void:
	Game.battle = null
	Game.party_node.set_enabled(true)
	$UI.hide()
	
	for actor: Actor in Save.party + enemies:
		actor.defeated.disconnect(free_actor)
	
	ended.emit()
	queue_free()



# actors

func ready_actor(actor: Actor) -> void:
	actor.set_position(Iso.to_grid(actor.node.position))
	actor.defeated.connect(free_actor.bind(actor))


func free_actor(actor: Actor) -> void:
	if actor is Enemy:
		enemies.erase(actor)
	else:
		Save.party.erase(actor)



# announcements

func announce(text: String, color: Color) -> void:
	$UI/Announcement/Label.text = text
	$UI/Announcement/Color.color = color
	$UI/Announcement/Squiggles.modulate = Palette.light(color)
	$UI/Announcement/Animator.play("announce")



# highlights

func set_highlight(bitshape: BitShape) -> void:
	clear_highlight()
	tile_highlight = TileHighlight.new()
	tile_highlight.from_bitshape(bitshape)
	add_child(tile_highlight)


func clear_highlight() -> void:
	if tile_highlight:
		tile_highlight.queue_free()
		tile_highlight = null


func preview_action(action: Action, cause: Actor) -> void:
	var shape: BitShape = action.shape.rotated(cause.facing)
	shape.offset += cause.position
	set_highlight(shape)
	
	if action.knockback:
		for actor: Actor in field.collide_action(action, cause):
			var line: Line2D = preload("res://node/knockback_arrow.tscn").instantiate()
			line.position = Iso.from_grid(actor.position) - tile_highlight.position
			line.set_end(action.knockback)
			tile_highlight.add_child(line)



# internal

func _ready() -> void:
	for node: ActorNode in enemy_nodes:
		enemies.append(node.resource)
