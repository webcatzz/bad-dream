extends Node2D


@export var key: String
@export var dialogue_script: GDScript

var dialogue: Dialogue
var active: bool

@onready var _icon: TextureRect = $Panel/Main/Icon
@onready var _log: VBoxContainer = $Panel/Main/LogWrapper/Log
@onready var _choicer: ItemList = $Panel/Bottom/Choicer
@onready var _animator: AnimationPlayer = $Animator


func prod() -> void:
	if Game.battle: return
	if active: return dialogue.next()
	
	Game.party_node.toggle(false)
	await Save.leader.node.nav_agent.navigation_finished
	
	active = true
	_animator.play("open")
	
	await dialogue.call(key)
	
	for child: Node in _log.get_children():
		child.queue_free()
	
	_animator.play_backwards("open")
	active = false
	
	Game.party_node.toggle(true)



# signals

func _add_text(text: String) -> void:
	var label := TypedLabel.new()
	_log.add_child(label)
	
	label.modulate.a = 0
	get_tree().create_tween().tween_property(label, "modulate:a", 1, 0.2)
	
	if label.get_index():
		var prev_label: TypedLabel = _log.get_child(label.get_index() - 1) as TypedLabel
		prev_label.skip()
		prev_label.theme_type_variation = &"LabelSmall"
	
	label.type(text)


func _set_speaker(speaker: Character) -> void:
	_icon.texture = speaker.icon


func _prompt(choices: PackedStringArray) -> void:
	for choice: String in choices:
		_choicer.set_item_tooltip_enabled(_choicer.add_item(choice), false)
	_choicer.show()
	_choicer.select(0)
	
	dialogue.choose(await _choicer.item_selected)
	get_viewport().set_input_as_handled()
	
	_choicer.hide()
	_choicer.clear()



# internal

func _ready() -> void:
	dialogue = dialogue_script.new()
	dialogue.text_changed.connect(_add_text)
	dialogue.speaker_changed.connect(_set_speaker)
	dialogue.prompted.connect(_prompt)
