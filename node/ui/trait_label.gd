extends PanelContainer


@onready var _name: Label = $Margins/HBox/Name
@onready var _description: Label = $Margins/HBox/Description
@onready var _color: ColorRect = $Color


func write(trait_type: Trait.Type) -> void:
	_name.text = Trait.name(trait_type)
	_description.text = Trait.describe(trait_type)
	_color.color = Trait.color(trait_type)
	
	#$HBox/Frame/Icon.region_rect.position = Vector2(
		#trait_type % $HBox/Frame/Icon.texture.get_width(),
		#trait_type / $HBox/Frame/Icon.texture.get_width()
	#) * 8 
