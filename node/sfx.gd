class_name SFX extends Node2D
## Comic-book SFX animation.


signal finished

var text: String

var upright: bool = true
var is_x_axis: bool
var align_right: bool

var rot_val: float = 26.6 ## Letter nodes' rotation.
var skew_val: float ## Letter nodes' skew.



# internal

func _init(text: String, pos: Vector2, facing: Vector2i) -> void:
	self.text = text
	position = pos
	y_sort_enabled = true
	
	# text orientation
	if upright:
		skew_val = -26.7
		if facing > Vector2i.ZERO:
			position.x += 16 * signi(facing.x)
			position.y -= 8
	else:
		skew_val = 36.8
	
	# transform axis
	if facing % 2:
		is_x_axis = true
		rot_val = -rot_val
		skew_val = -skew_val
	
	# text align
	align_right = facing < Vector2i.ZERO
	
	rot_val = deg_to_rad(rot_val)
	skew_val = deg_to_rad(skew_val)


func _ready() -> void:
	# tween
	var tween: Tween = get_tree().create_tween().set_parallel()
	
	# letters
	var letter_x: int = 0
	for i: int in text.length():
		# wrapper (carries transform, simplifies animating letters)
		var wrapper: Node2D = Node2D.new()
		wrapper.position = Vector2(letter_x, letter_x/2)
		if is_x_axis: wrapper.position.y *= -1
		wrapper.rotation = rot_val
		wrapper.skew = skew_val
		
		# label
		var label: Label = Label.new()
		label.theme_type_variation = &"SFXLabel"
		label.text = text[i]
		
		label.reset_size()
		var label_offset: float = -label.size.y if upright else 8
		label.position.y = label_offset - 16
		label.modulate.a = 0
		
		# adding to tree
		wrapper.add_child(label)
		add_child(wrapper)
		
		# animation
		var delay: float = i * 0.05
		tween.tween_property(label, "modulate:a", 1, 0.125).set_delay(delay)
		tween.tween_property(label, "position:y", label_offset, 0.125).set_delay(delay)
		tween.tween_property(label, "modulate:a", 0, 0.125).set_delay(delay + 1)
		tween.tween_property(label, "position:y", label_offset + 4, 0.125).set_delay(delay + 1)
		
		letter_x += label.size.x - 2
	
	# positioning from right instead
	if align_right:
		for letter: Node2D in get_children():
			letter.position = Vector2(-letter_x, letter_x/2)
			if not is_x_axis: letter.position.y *= -1
			letter_x -= letter.get_child(0).size.x - 2
	
	tween.finished.connect(on_finished)


func on_finished() -> void:
	finished.emit()
	queue_free()
