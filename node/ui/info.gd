extends PanelContainer


func write(dict: Dictionary) -> void:
	$Items/Title.text = dict.get("title", "")
	$Items/Footer.text = dict.get("footer", "")
	
	for control: Control in $Items/Controls.get_children():
		control.queue_free()
	for control: Control in dict.get("controls", []):
		$Items/Controls.add_child(control)
