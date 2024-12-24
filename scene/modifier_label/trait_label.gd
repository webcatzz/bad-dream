extends HBoxContainer


func write(type: Trait.Type) -> void:
	$Icon.texture.region.position.x = type * 8
	$Name.text = Trait.type_name(type)
