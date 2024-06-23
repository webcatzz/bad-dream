class_name ActorNode extends CharacterBody2D
## Node representation of an [Actor].


@export var data: Actor = Actor.new()

var text_particle_scene: PackedScene = preload("res://node/text_particle.tscn")
var status_effect_animations: SpriteFrames = preload("res://asset/actor/status_effect_animation.tres")

@onready var dice: Node2D = $DiceRoll


func take_turn() -> void:
	await Game.get_tree().create_timer(0.5).timeout
	data.end_turn()


## Smoothly moves the node to a new position.
func tween_position(pos: Vector2) -> void:
	create_tween().tween_property(self, "position", pos, 0.05)


## Toggles the spotlight and plays sfx.
func set_spotlight(value: bool) -> void:
	if value != $DuringTurn/Spotlight.visible:
		$DuringTurn/Spotlight.visible = value
		if value: $SFX/SpotlightOn.play()
		else: $SFX/SpotlightOff.play()


## Emits a text particle.
func emit_text(string: String, color: Color = Color.WHITE) -> void:
	var text_particle: Label = text_particle_scene.instantiate()
	text_particle.text = string
	text_particle.add_theme_color_override("font_color", color)
	add_child(text_particle)



# internal

func _ready() -> void:
	data = data.duplicate()
	_on_data_set()


func _on_data_set() -> void:
	data.position = Iso.to_grid(position)
	data.node = self
	
	$Sprite.texture = data.sprite
	
	# orientation
	data.position_changed.connect(_on_position_changed)
	data.position_changed.connect($SFX/Move.play.unbind(1))
	data.facing_changed.connect(_on_facing_changed)
	# turns
	data.turn_started.connect($DuringTurn.set_visible.bind(true))
	data.turn_started.connect(set_spotlight.bind(true))
	data.turn_ended.connect($DuringTurn.set_visible.bind(false))
	data.turn_ended.connect(set_spotlight.bind(false))
	# stats
	data.health_changed_by.connect(_on_health_changed_by)
	data.status_effect_added.connect(_on_status_effect_added)
	data.status_effect_removed.connect(_on_status_effect_removed)
	data.evaded.connect(_on_evaded)
	data.defeated.connect(_on_defeated)


func _on_position_changed(pos: Vector2i) -> void:
	tween_position(Iso.from_grid(pos))


func _on_facing_changed(facing: Vector2i) -> void:
	match facing:
		Vector2i.DOWN: $Sprite.frame_coords.x = 0
		Vector2i.UP: $Sprite.frame_coords.x = 1
		Vector2i.LEFT: $Sprite.frame_coords.x = 2
		Vector2i.RIGHT: $Sprite.frame_coords.x = 3


func _on_health_changed_by(value: int) -> void:
	if value < 0:
		$Animator.play("damaged")
		emit_text(str(value), Color.RED)
	else:
		emit_text("+" + str(value), Color.GREEN)


func _on_status_effect_added(status_effect: StatusEffect) -> void:
	var effect_name: String = StatusEffect.Type.keys()[status_effect.type].to_lower()
	
	if status_effect_animations.has_animation(effect_name):
		var sprite: AnimatedSprite2D = AnimatedSprite2D.new()
		sprite.name = effect_name
		sprite.sprite_frames = status_effect_animations
		sprite.offset.y = -24
		$Sprite.add_child(sprite)
		sprite.play(effect_name)
	
	emit_text("+ " + effect_name)


func _on_status_effect_removed(status_effect: StatusEffect) -> void:
	var effect_name: String = StatusEffect.Type.keys()[status_effect.type].to_lower()
	
	if status_effect_animations.has_animation(effect_name):
		$Sprite.get_node(effect_name).queue_free()
	
	emit_text("- " + effect_name)


func _on_evaded(successful: bool) -> void:
	emit_text("evaded!" if successful else "can't evade!")


func _on_defeated() -> void:
	$Collision.disabled = true
	$Animator.queue("defeated")
	await $Animator.animation_finished
	await $Animator.animation_finished
