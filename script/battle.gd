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

@export_group("Node")
@export var selector: CharacterBody2D
@export var _party: Control



# cycling

func start() -> void:
	Game.battle = self
	Game.party_node.set_enabled(false)
	field = BattleField.new()
	$UI.show()
	
	for actor: Actor in Save.party + enemies:
		ready_actor(actor)
	
	#for actor: Actor in Save.party:
		#var figure: Control = load("res://node/ui/party_member.tscn").instantiate()
		#figure.actor = actor
		#_party.add_child(figure)
	
	#announce("Battle start!", Palette.RED)
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
		await enemy.act()
	
	end_phase()


func do_party_phase() -> void:
	phase = Phase.PARTY
	$UI/Phase.current_tab = phase
	
	for actor: Actor in Save.party:
		actor.stamina = actor.max_stamina
	
	party_phase_started.emit()
	announce("Party Phase", Palette.BLUE)
	await get_tree().create_timer(0.8).timeout
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(selector, "position", Iso.from_grid(Save.player.position), 0.1)
	await tween.finished
	selector.set_enabled(true)
	
	await phase_changed
	
	selector.set_enabled(false)


func end_phase() -> void:
	phase_changed.emit()


func end() -> void:
	Game.battle = null
	Game.party_node.set_enabled(true)
	$UI.hide()



# actors

func ready_actor(actor: Actor) -> void:
	actor.set_position(Iso.to_grid(actor.node.position))


func free_actor(actor: Actor) -> void:
	pass



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



# internal

func _ready() -> void:
	for node: ActorNode in enemy_nodes:
		enemies.append(node.resource)
