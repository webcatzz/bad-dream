class_name Battle extends Node2D


signal phase_changed

enum Phase {PARTY, ENEMY}

@export var enemy_nodes: Array[ActorNode]

var enemies: Array[Enemy]
var field: BattleField
var phase: Phase
# party phase
var current_actor: Actor
var history: PhaseHistory

@export_group("Scene")
@export var _party: HBoxContainer
@export var _selector_mode_label: Label
@onready var selector: CharacterBody2D = $Selector
@export var _action_menu: Control
@export var _animator: AnimationPlayer


func start() -> void:
	Game.current_battle = self
	Game.party_node.set_enabled(false)
	$UI.show()
	
	for actor: Actor in Save.party + enemies:
		ready_actor(actor)
	
	for actor: Actor in Save.party:
		var figure: Control = load("res://node/ui/party_member.tscn").instantiate()
		figure.actor = actor
		_party.add_child(figure)
	
	cycle()


func cycle() -> void:
	await do_enemy_phase()
	await do_party_phase()
	cycle()


func do_enemy_phase() -> void:
	phase = Phase.ENEMY
	#await _announce("Enemy Phase")
	
	end_phase()


func do_party_phase() -> void:
	phase = Phase.PARTY
	history = PhaseHistory.new(self)
	await _announce("Party Phase")
	
	selector.set_enabled(true)
	selector.position = Save.player.node.position
	
	await phase_changed
	
	selector.set_enabled(false)
	history = null


func end_phase() -> void:
	phase_changed.emit()


func end() -> void:
	Game.current_battle = null
	Game.party_node.set_enabled(true)
	$UI.hide()



# actors

func ready_actor(actor: Actor) -> void:
	actor.set_position(Iso.to_grid(actor.node.position))


func free_actor(actor: Actor) -> void:
	pass



# party phase

func open_action_menu(actor: Actor) -> void:
	_action_menu.clear()
	for action: Action in actor.actions:
		_action_menu.add_item(action)
	
	_action_menu.show()
	_action_menu.focus_list()


func close_action_menu() -> void:
	_action_menu.hide()



# internal

func _ready() -> void:
	for node: ActorNode in enemy_nodes:
		enemies.append(node.resource)


func _announce(text: String) -> void:
	$UI/Phase/Label.text = text
	_animator.play("announce")
	await get_tree().create_timer(0.8).timeout


func _on_selector_mode_changed(mode: Selector.Mode) -> void:
	_selector_mode_label.text = Selector.Mode.keys()[mode]
