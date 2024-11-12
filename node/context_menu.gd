extends PanelContainer


signal chosen(idx: int)

@onready var _label: Label = $VBox/Label
@onready var _options: ItemList = $VBox/Options


func open(title: String) -> void:
	position = Game.cursor.position
	_label.text = title
	show()
	$Animator.play("open")


func close() -> void:
	hide()
	_options.clear()


func add_option(text: String, icon: Texture2D, disabled: bool = false) -> void:
	var option: int = _options.add_item(text, icon, false)
	_options.set_item_tooltip_enabled(option, false)
	_options.set_item_disabled(option, disabled)



# internal

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _on_option_clicked(idx: int) -> void:
	chosen.emit(idx)
	get_viewport().set_input_as_handled()
