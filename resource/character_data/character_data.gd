class_name CharacterData
extends Resource

@export var name: String = "Character"
@export_color_no_alpha var color: Color = Palette.WHITE

@export var sprite: Texture2D = load("res://asset/character/default.png")
@export var sprite_offset := Vector2(0, -12)
