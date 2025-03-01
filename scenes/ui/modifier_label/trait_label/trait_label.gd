extends PanelContainer


func write(t: String) -> void:
	var data: ModifierData = ResLib.modifier_data.get_resource(t)
	$HBox/Name.text = data.name
	$HBox/Icon.texture = data.icon
