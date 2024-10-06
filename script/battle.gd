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
var history: PhaseHistory

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
	await announce("Enemy Phase", Palette.RED)
	
	for enemy: Enemy in enemies:
		await enemy.act()
	
	end_phase()


func do_party_phase() -> void:
	phase = Phase.PARTY
	$UI/Phase.current_tab = phase
	history = PhaseHistory.new(self)
	
	for actor: Actor in Save.party:
		actor.stamina = actor.max_stamina
	
	party_phase_started.emit()
	await announce("Party Phase", Palette.BLUE)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(selector, "position", Iso.from_grid(Save.player.position), 0.1)
	await tween.finished
	selector.set_enabled(true)
	
	await phase_changed
	
	selector.set_enabled(false)
	history = null


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
	await get_tree().create_timer(0.8).timeout



# internal

func _ready() -> void:
	for node: ActorNode in enemy_nodes:
		enemies.append(node.resource)
