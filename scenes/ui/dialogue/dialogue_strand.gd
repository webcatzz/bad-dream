extends Node2D

var speaker: Character
var log: Array[Label]

@onready var _label: TypedLabel = $Bubble/Label
@onready var _animator: AnimationPlayer = $Animator
@onready var _choicer: ItemList = $Choices


func add(text: String) -> void:
	if _label.text:
		add_to_log(_label.text)
	
	_label.type(text)


func add_to_log(text: String) -> void:
	var bubble: Label = load("res://scenes/ui/dialogue/dialogue_bubble_small.tscn").instantiate()
	bubble.text = text
	log.append(bubble)
	add_child(bubble)
	
	if log.size() > 4:
		log.pop_front().queue_free()
	
	var tween: Tween = get_tree().create_tween().set_parallel()
	_animator.play("bob")
	
	var i: int = log.size()
	for logged: Label in log:
		i -= 1
		tween.tween_property(logged, "position:y", -35 - 14 * i, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(logged, "modulate:a", 1.0 / pow(2, i + 1), 0.75).set_trans(Tween.TRANS_CUBIC)


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
	for i: int in range(log.size() - 1, -1, -1):
		var to: Vector2 = log[i].position + Vector2(log[i].size.x / 2, 0)
		draw_line(from, to + Vector2(0, log[i].size.y), log[i].modulate, 1)
		from = to


func _process(_delta: float) -> void:
	queue_redraw()



# init & deinit

func _ready() -> void:
	_label.text = ""
	_label.size.x = 0
	_label.position.x = _label.size.x / -2
	_animator.play("appear")


func snip() -> void:
	_animator.play("disappear")
