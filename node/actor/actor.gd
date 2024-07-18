class_name ActorNode extends CharacterBody2D
## Node representation of an [Actor].


@export var data: Actor = Actor.new()

var text_particle_scene: PackedScene = preload("res://node/text_particle.tscn")
var status_effect_animations: SpriteFrames = preload("res://asset/actor/status_effect_animation.tres")

@onready var dice: Node2D = $DiceRoll
@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _animator: AnimationPlayer = $Animator
@onready var _path: Line2D = $DuringTurn/Path


func take_turn() -> void:
	await Game.get_tree().create_timer(0.5).timeout
	data.end_turn()


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
	if data not in Data.party:
		data = data.duplicate()
	
	# updating variables
	data.node = self
	data.position = Iso.to_grid(position)
	# sprite
	_sprite.sprite_frames = data.sprite
	_sprite.offset = data.sprite_offset
	set_animation("idle")
	
	# orientation
	data.position_changed.connect(_on_position_changed)
	data.position_changed.connect($SFX/Move.play.unbind(1))
	# turns
	data.turn_started.connect(_on_turn_started)
	data.turn_ended.connect(_on_turn_ended)
	# path
	data.path_extended.connect(_on_path_extended)
	data.path_backtracked.connect(_on_path_backtracked)
	# status
	data.health_changed_by.connect(_on_health_changed_by)
	data.status_effect_added.connect(_on_status_effect_added)
	data.status_effect_removed.connect(_on_status_effect_removed)
	data.evaded.connect(_on_evaded)
	data.defeated.connect(_on_defeated)


func _on_position_changed(pos: Vector2i) -> void:
	create_tween().tween_property(self, "position", Iso.from_grid(pos), 0.05)


func _on_health_changed_by(value: int) -> void:
	if value < 0:
		_animator.play(&"damaged")
		#play_animation("hurt")
		emit_text(str(value), Color.RED)
	elif value > 0:
		emit_text("+" + str(value), Color.GREEN)
	else:
		emit_text("-0", Color.WHITE)


func _on_evaded(successful: bool) -> void:
	emit_text("evaded!" if successful else "can't evade!")


func _on_defeated() -> void:
	$Collision.disabled = true
	_animator.queue(&"defeated")



# status effects

func _on_status_effect_added(status_effect: StatusEffect) -> void:
	var effect_name: String = status_effect.get_type_string()
	
	if status_effect_animations.has_animation(effect_name):
		var sprite: AnimatedSprite2D = AnimatedSprite2D.new()
		sprite.name = effect_name
		sprite.sprite_frames = status_effect_animations
		sprite.offset.y = -24
		_sprite.add_child(sprite)
		sprite.play(effect_name)
	
	emit_text("+ " + effect_name)


func _on_status_effect_removed(status_effect: StatusEffect) -> void:
	var effect_name: String = status_effect.get_type_string()
	
	if status_effect_animations.has_animation(effect_name):
		_sprite.get_node(effect_name).queue_free()
	
	emit_text("- " + effect_name)



# turns

func _on_turn_started() -> void:
	$DuringTurn.show()
	set_spotlight(true)


func _on_turn_ended() -> void:
	$DuringTurn.hide()
	set_spotlight(false)
	_path.clear_points()
	set_animation("idle")



# path

func _on_path_extended() -> void:
	_path.add_point(Iso.from_grid(data.path[-1].position))


func _on_path_backtracked() -> void:
	_path.remove_point(data.path.size())



# animation

func set_animation(key: String) -> void:
	match data.facing:
		Vector2i.DOWN: _sprite.animation = key + "_down"
		Vector2i.UP: _sprite.animation = key + "_up"
		Vector2i.LEFT: _sprite.animation = key + "_left"
		Vector2i.RIGHT: _sprite.animation = key + "_right"


func play_animation(key: String) -> void:
	set_animation(key)
	_sprite.play()


func advance_animation(by: int = 1) -> void:
	_sprite.frame = posmod(_sprite.frame + by, _sprite.sprite_frames.get_frame_count(_sprite.animation))
