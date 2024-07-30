extends VBoxContainer


func write(dict: Dictionary) -> void:
	$Title.text = dict.get("title", "")
	$Panel/Items/Description.text = dict.get("description", "")
	$Panel/Items/Tags.text = dict.get("tags", "")
