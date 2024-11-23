extends Node2D


var speaker: Character

@onready var _label: TypedLabel = $Bubble/Label
@onready var _log: Node2D = $Log
@onready var _animator: AnimationPlayer = $Animator
@onready var _choicer: ItemList = $Choices


func add(text: String) -> void:
	if _label.text:
		add_to_log(_label.text)
	
	_label.type(text)


func add_to_log(text: String) -> void:
	var bubble := Label.new()
	bubble.text = text
	bubble.theme_type_variation = &"DialogueBubbleSmall"
	bubble.use_parent_material = true
	bubble.modulate.a = 0
	_log.add_child(bubble)
	bubble.position = Vector2(bubble.size.x / -2, -8)
	
	if _log.get_child_count() > 4: _log.get_child(0).queue_free()
	
	var tween: Tween = get_tree().create_tween().set_parallel()
	_animator.play("bob")
	
	var i: int = _log.get_child_count()
	for child: Node in _log.get_children():
		i -= 1
		tween.tween_property(child, "position:y", -35 - 14 * i, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(child, "modulate:a", 1.0 / pow(2, i + 1), 0.75).set_trans(Tween.TRANS_CUBIC)


func prompt(choices: PackedStringArray) -> int:
	for choice: String in choices:
		_choicer.add_item(choice, null, false)
	_choicer.show()
	
	var choice: int = await _choicer.item_activated
	
	_choicer.hide()
	_choicer.clear()
	
	return choice



# connecting line

func _draw() -> void:
	var from := Vector2(0, _label.position.y)
	for i: int in range(_log.get_child_count() - 1, -1, -1):
		var child: Label = _log.get_child(i)
		var to: Vector2 = child.position + Vector2(child.size.x / 2, 0)
		draw_line(from, to + Vector2(0, child.size.y), child.modulate, 1)
		from = to


func _process(_delta: float) -> void:
	queue_redraw()



# init + deinit

func _ready() -> void:
	_label.text = ""
	_label.size.x = 0
	_label.position.x = _label.size.x / -2
	_animator.play("appear")


func snip() -> void:
	_animator.play("disappear")
