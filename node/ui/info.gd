extends PanelContainer


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


func add_description(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.theme_type_variation = &"LabelMuted"
	add_control(label)


func add_list(title: String) -> VBoxContainer:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_control(vbox)
	
	var label: Label = Label.new()
	label.text = title
	label.theme_type_variation = &"SmallLabelMuted"
	vbox.add_child(label)
	
	return vbox



# internal

func _ready() -> void:
	set_footer(footer)
