class_name DialogueTrigger extends Node2D


@export var dialogue_script: GDScript
@export var key: String

var dialogue: Dialogue


func trigger() -> void:
	if dialogue.active:
		dialogue.next()
	else:
		Game.party_node.toggle(false)
		await Save.leader.node.nav.navigation_finished
		await dialogue.run(key)
		Game.party_node.toggle(true)



# internal

func _ready() -> void:
	dialogue = dialogue_script.new()
