class_name ActorNode extends CharacterBody2D


@export var resource: Actor = Actor.new()

@onready var _will_slots: WillSlots = $WillSlots


func set_collision(value: bool) -> void:
	$Collision.disabled = value


func set_will_visible(value: bool) -> void:
	_will_slots.visible = value



#internal

func _ready() -> void:
	if resource not in Save.party:
		resource = resource.duplicate()
		resource.node = self
	
	resource.reoriented.connect(_on_reoriented)


func _on_reoriented() -> void:
	position = Iso.from_grid(resource.position)
