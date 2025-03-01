extends PanelContainer


func write(t: String) -> void:
	$HBox/Name.text = t
	#var data: ModifierData = ResLib.modifier_data.get_resource(t)
	#$HBox/Icon.texture = data.icon
