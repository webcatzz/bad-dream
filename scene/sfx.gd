class_name SFX extends Node2D

signal finished

var text: String

var vertical: bool = true#randf() > 0.5
var anchor_right: bool
var is_x_axis: bool

var rot_val: float = 26.6
var skew_val: float = 36.8


func _init(text: String, direction: Vector2i, pos: Vector2i) -> void:
	self.text = text
	position = pos
	y_sort_enabled = true
	
	if vertical:
		skew_val = -26.7
		if direction.y > 0: position.y += 8
		else: position.x += 16 * signi(direction.x)
	if direction in [Iso.LEFT, Iso.RIGHT]:
		is_x_axis = true
		rot_val = -rot_val
		skew_val = -skew_val
	if direction.x < 0:
		anchor_right = true
	
	rot_val = deg_to_rad(rot_val)
	skew_val = deg_to_rad(skew_val)
	
	print("---")
	print("vertical: ", vertical)
	for property in ["anchor_right", "is_x_axis", "reverse_skew"]:
		print(property, ": ", get(property))
	print("---")


func _ready() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel()
	var settings: LabelSettings = LabelSettings.new()
	settings.font = load("res://asset/ui/crang.ttf")
	settings.outline_color = Color.BLACK
	settings.outline_size = 4
	
	var x_offset: int = 0
	for i: int in text.length():
		var label_wrapper: Node2D = Node2D.new()
		label_wrapper.position = Vector2(x_offset, x_offset/2 if not is_x_axis else -x_offset/2)
		label_wrapper.rotation = rot_val
		label_wrapper.skew = skew_val
		
		var label: Label = Label.new()
		label.text = text[i]
		label.label_settings = settings
		label.reset_size()
		var label_offset = -label.size.y if vertical else 8
		label.position.y = label_offset - 16
		label.modulate.a = 0
		
		label_wrapper.add_child(label)
		add_child(label_wrapper)
		
		var delay: float = i * 0.05
		tween.tween_property(label, "modulate:a", 1, 0.125).set_delay(delay)
		tween.tween_property(label, "position:y", label_offset, 0.125).set_delay(delay)
		tween.tween_property(label, "modulate:a", 0, 0.125).set_delay(delay + 1)
		tween.tween_property(label, "position:y", label_offset + 4, 0.125).set_delay(delay + 1)
		
		x_offset += label.size.x - 2
	
	if anchor_right: for letter in get_children():
		letter.position = Vector2(-x_offset, x_offset/2 if is_x_axis else -x_offset/2)
		x_offset -= letter.get_child(0).size.x - 2
	
	tween.finished.connect(on_finished)



func on_finished() -> void:
	finished.emit()
	queue_free()
