extends Resource


@export var party: PackedStringArray = ["woodcarver"]


@export_range(0, 1) var master_volume: float = 1
@export_range(0, 1) var music_volume: float = 1
@export_range(0, 1) var sfx_volume: float = 1

@export_group("Keybinds")
@export var move_up: InputEvent
@export var move_down: InputEvent
@export var move_left: InputEvent
@export var move_right: InputEvent
