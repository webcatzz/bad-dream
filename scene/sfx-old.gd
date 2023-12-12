class_name SFX extends Node2D

signal finished

var text: String
var anchor_right: bool


func _init(text: String, direction: Vector2i, pos: Vector2i, vertical: bool = true) -> void:
	self.text = text
	position = pos
	var hbox: HBoxContainer = HBoxContainer.new()
	if vertical:
		if direction.y > 0: position.y += 8
		else: position.x += 16 * signi(direction.x)
	if direction in [Iso.UP, Iso.DOWN]:
		rotation_degrees = 26.6
		skew = deg_to_rad(36.8 if not vertical else -26.7)
	else:
		rotation_degrees = -26.6
		skew = deg_to_rad(-36.8 if not vertical else 26.7)
	if direction.x < 0: anchor_right = true
	add_child(hbox)


func _ready() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel()
	var settings: LabelSettings = LabelSettings.new()
	settings.font = load("res://asset/ui/crang.ttf")
	settings.outline_color = Color.BLACK
	settings.outline_size = 4
	for i: int in text.length():
		var label: Label = Label.new()
		label.text = text[i]
		label.label_settings = settings
		get_child(0).add_child(label)
		label.modulate.a = 0
		tween.tween_property(label, "position:y", -16, 0) # godot is a flawless engine
		tween.tween_property(label, "modulate:a", 1, 0.125).set_delay(i * 0.05)
		tween.tween_property(label, "position:y", 0, 0.125).set_delay(i * 0.05)
		tween.tween_property(label, "modulate:a", 0, 0.125).set_delay(i * 0.05 + 1)
		tween.tween_property(label, "position:y", 4, 0.125).set_delay(i * 0.05 + 1)
	get_child(0).reset_size()
	get_child(0).position.y = -get_child(0).size.y
	if anchor_right: get_child(0).position.x = -get_child(0).size.x
	tween.finished.connect(on_finished)


func on_finished() -> void:
	finished.emit()
	queue_free()
