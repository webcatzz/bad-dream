class_name Character extends Resource


@export var name: String
@export var sprite: Texture2D = load("res://asset/sprite/default.png")
@export var sprite_offset: Vector2 = Vector2(0, -24)

@export_color_no_alpha var color: Color

var node: CharacterNode
