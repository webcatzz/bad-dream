class_name CharacterNode extends Area2D


signal clicked(event: InputEventMouseButton)
signal right_clicked(event: InputEventMouseButton)

@export var resource := Character.new()

const SPEED: int = 128

@onready var sprite: Sprite2D = $Sprite
@onready var nav: NavigationAgent2D = $NavAgent


# navigation

func walk_to(point: Vector2) -> void:
	nav.target_position = point


func stop_walking() -> void:
	position = Iso.snap(position)
	nav.target_position = global_position


func _physics_process(delta: float):
	if not nav.is_navigation_finished():
		global_position = global_position.move_toward(nav.get_next_path_position(), SPEED * delta)


# resource mirroring

func _ready() -> void:
	resource.node = self
	sprite.texture = resource.sprite
	sprite.offset = resource.sprite_offset
