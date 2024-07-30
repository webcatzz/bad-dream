extends PanelContainer


func write(dict: Dictionary) -> void:
	$Items/Title.text = dict.get("title", "")
	$Items/Description.text = dict.get("description", "")
	$Items/Footer.text = dict.get("footer", "")
