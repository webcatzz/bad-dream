extends PanelContainer


func write(dict: Dictionary) -> void:
	$Items/Title.text = dict.get("title", "")
	$Items/Description.text = dict.get("description", "")
	$Items/Footer.text = dict.get("footer", "")
	
	for custom: Control in $Items/Custom.get_children():
		custom.queue_free()
	for custom: Control in dict.get("custom", []):
		$Items/Custom.add_child(custom)
