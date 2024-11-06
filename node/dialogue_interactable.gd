extends Interactable


@export var key: String
@export var dialogue_script: GDScript

var dialogue: Dialogue
var active: bool

@onready var _log: VBoxContainer = $Panel/VBox/HBox/Wrapper/Log
@onready var _icon: TextureRect = $Panel/VBox/HBox/Icon
@onready var _cont: Label = $Panel/VBox/Wrapper/Cont
@onready var _choicer: ItemList = $Panel/VBox/Wrapper/Choicer
@onready var _animator: AnimationPlayer = $Animator


func interact() -> void:
	super()
	if Game.battle: return
	if active: return dialogue.next()
	
	active = true
	_animator.play("open")
	
	await dialogue.call(key)
	
	for child: Node in _log.get_children():
		child.queue_free()
	
	_animator.play_backwards("open")
	active = false


func _add_text(text: String) -> void:
	var label := TypedLabel.new()
	_log.add_child(label)
	
	label.modulate.a = 0
	get_tree().create_tween().tween_property(label, "modulate:a", 1, 0.2)
	
	if label.get_index():
		_log.get_child(label.get_index() - 1).theme_type_variation = &"LabelSmall"
	
	label.type(text)


func _set_speaker(speaker: Character) -> void:
	_icon.texture = speaker.icon


func _prompt(choices: PackedStringArray) -> void:
	Game.party_node.toggle(false)
	
	for choice: String in choices:
		_choicer.set_item_tooltip_enabled(_choicer.add_item(choice), false)
	_choicer.show()
	_choicer.grab_focus()
	_choicer.select(0)
	
	dialogue.choose(await _choicer.item_activated)
	get_viewport().set_input_as_handled()
	
	_choicer.hide()
	_choicer.clear()
	
	Game.party_node.toggle(true)



# internal

func _ready() -> void:
	super()
	dialogue = dialogue_script.new()
	dialogue.text_changed.connect(_add_text)
	dialogue.speaker_changed.connect(_set_speaker)
	dialogue.prompted.connect(_prompt)


func _on_player_exited_area() -> void:
	if active:
		$Animator.play_backwards("open")


func _on_player_entered_area() -> void:
	if active:
		$Animator.play("open")
