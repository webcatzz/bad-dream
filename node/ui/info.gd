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


func create_list(title: String = "") -> VBoxContainer:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	if title: vbox.add_child(create_label(title, &"SmallLabelMuted"))
	
	return vbox


func create_slice(title: String = "") -> HBoxContainer:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	if title: hbox.add_child(create_label(title, &"SmallLabelMuted"))
	
	return hbox


func create_label(text: String, type: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.theme_type_variation = type
	return label



# internal

func _ready() -> void:
	set_footer(footer)
