class_name InfoPanel extends PanelContainer


@export var footer: String


func set_title(title: String) -> void: # also clears everything else
	$Items/Title.text = title
	clear_controls()
	set_footer("")


func set_footer(footer: String) -> void:
	$Items/Footer.text = footer



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


func add_label(text: String, type: StringName) -> void:
	add_control(create_label(text, type))


func add_spacer() -> void:
	add_control(Control.new())


func create_label(text: String, type: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.theme_type_variation = type
	return label



# internal

func _ready() -> void:
	set_footer(footer)
