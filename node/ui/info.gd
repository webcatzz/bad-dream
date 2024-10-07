class_name InfoPanel extends PanelContainer


@onready var _title: Label = $Items/Header/Title
@onready var _subtitle: Label = $Items/Header/HBox/Subtitle


func set_title(title: String) -> void: # also clears everything else
	_title.text = title
	clear_controls()
	set_subtitle("")


func set_subtitle(subtitle: String) -> void:
	_subtitle.text = subtitle



# controls

func add_control(control: Control) -> void:
	$Items/Controls.add_child(control)


func clear_controls() -> void:
	for control: Control in $Items/Controls.get_children():
		control.queue_free()


func focus_controls() -> void:
	find_next_valid_focus().grab_focus()


func add_slice() -> HBoxContainer:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	add_control(hbox)
	
	return hbox


func add_label(text: String, type: StringName) -> Label:
	var label: Label = create_label(text, type)
	add_control(label)
	return label


func add_spacer(expand: bool = false) -> void:
	var control: Control = Control.new()
	if expand: control.size_flags_vertical = SIZE_EXPAND_FILL
	add_control(control)


func create_label(text: String, type: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.theme_type_variation = type
	return label
