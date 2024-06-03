class_name ActorNode extends CharacterBody2D
## Node representation of an [Actor].


@export var data: Actor = Actor.new()

@onready var dice: Node2D = $DiceRoll


func _ready() -> void:
	data.node = self
	data.position = Iso.to_grid(position)
	# orientation
	data.position_changed.connect(_on_position_changed)
	data.position_changed.connect($SFX/Move.play.unbind(1))
	data.facing_changed.connect(_on_facing_changed)
	# turns
	data.turn_started.connect($DuringTurn.set_visible.bind(true))
	data.turn_started.connect(set_spotlight.bind(true))
	data.turn_ended.connect($DuringTurn.set_visible.bind(false))
	data.turn_ended.connect(set_spotlight.bind(false))
	# health
	data.health_changed_by.connect(_on_health_changed_by)
	data.defeated.connect(_on_defeated)


func take_turn() -> void:
	await Game.get_tree().create_timer(0.5).timeout
	data.turn_ended.emit()


## Smoothly moves the node to a new position.
func tween_position(pos: Vector2) -> void:
	create_tween().tween_property(self, "position", pos, 0.05)


func set_spotlight(value: bool) -> void:
	$DuringTurn/Spotlight.visible = value
	if value: $SFX/SpotlightOn.play()
	else: $SFX/SpotlightOff.play()



# listeners

func _on_position_changed(pos: Vector2i) -> void:
	tween_position(Iso.from_grid(pos))


func _on_facing_changed(facing: Vector2i) -> void:
	match facing:
		Vector2i.DOWN: $Sprite.frame_coords.x = 0
		Vector2i.UP: $Sprite.frame_coords.x = 1
		Vector2i.LEFT: $Sprite.frame_coords.x = 2
		Vector2i.RIGHT: $Sprite.frame_coords.x = 3


func _on_health_changed_by(value: int) -> void:
	if value < 0: $Animator.play("damaged")


func _on_defeated() -> void:
	$Collision.disabled = true
	await $Animator.animation_finished
	await Game.tween_opacity($Sprite, 1, 0, 0.5)
	queue_free()
