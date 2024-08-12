class_name Battle extends Node2D


signal phase_changed

enum Phase {PARTY, ENEMY}

@export var enemy_nodes: Array[ActorNode]

var enemies: Array[Enemy]
var phase: Phase
# party phase
var current_actor: Actor
var history: PhaseHistory

@onready var _party: HBoxContainer = $UI/Margins/Party
@onready var selector: CharacterBody2D = $Selector


func start() -> void:
	Game.current_battle = self
	Game.party_node.set_enabled(false)
	
	for actor: Actor in Save.party + enemies:
		ready_actor(actor)
	
	for actor: Actor in Save.party:
		var figure: Control = load("res://node/ui/party_member.tscn").instantiate()
		figure.actor = actor
		_party.add_child(figure)
	
	cycle()


func cycle() -> void:
	# enemy phase
	phase = Phase.ENEMY
	await get_tree().process_frame
	end_phase()
	
	# party phase
	phase = Phase.PARTY
	
	history = PhaseHistory.new()
	history.battle = self
	
	selector.set_enabled(true)
	selector.position = Save.player.node.position
	
	await phase_changed
	
	selector.set_enabled(false)
	history = null
	
	cycle()


func end_phase() -> void:
	phase_changed.emit()


func end() -> void:
	Game.current_battle = null
	Game.party_node.set_enabled(true)



# actors

func ready_actor(actor: Actor) -> void:
	actor.set_position(Iso.to_grid(actor.node.position))


func free_actor(actor: Actor) -> void:
	pass



# internal

func _ready() -> void:
	for node: ActorNode in enemy_nodes:
		enemies.append(node.resource)
