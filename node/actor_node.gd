class_name ActorNode extends CharacterBody2D


signal clicked(event: InputEventMouseButton)
signal right_clicked(event: InputEventMouseButton)

const SPEED: int = 128

@export var resource: Actor = Actor.new()

var walking: bool = false

@onready var sprite: Sprite2D = $Sprite
@onready var input: Interactable = $Input
@onready var nav_agent: NavigationAgent2D = $NavAgent


func emit_text(string: String, color: Color = Palette.WHITE) -> void:
	var text_particle: Label = preload("res://node/text_particle.tscn").instantiate()
	text_particle.text = string
	text_particle.add_theme_color_override("font_color", color)
	add_child(text_particle)


func set_collision(value: bool) -> void:
	$Collision.set_disabled.call_deferred(not value)



# navigation

func walk_to(point: Vector2) -> void:
	nav_agent.target_position = point


func stop_walking() -> void:
	position = Iso.snap(position)
	nav_agent.target_position = global_position


func _physics_process(delta: float):
	if not nav_agent.is_navigation_finished():
		global_position = global_position.move_toward(nav_agent.get_next_path_position(), SPEED * delta)



# resource mirroring

func _ready() -> void:
	if resource is Enemy:
		resource = resource.duplicate()
		resource.node = self
		resource.initialize_traits()
	
	sprite.texture = resource.sprite
	
	resource.will_changed.connect(_on_will_changed)
	resource.stamina_changed.connect(_on_stamina_changed)
	resource.defeated.connect(_on_defeated)
	# modifiers
	resource.condition_added.connect(_on_condition_added)
	resource.condition_removed.connect(_on_condition_removed)
	# actions
	resource.action_sent.connect(_on_action_sent)
	# orientation
	resource.reoriented.connect(_on_reoriented)
	
	_update_will_slots()


func _on_will_changed(by: int) -> void:
	if by < 0:
		$Animator.play("damaged")
		emit_text(str(by), Palette.RED)
	elif by > 0:
		$Animator.play("healed")
		emit_text("+" + str(by), Palette.GREEN)
	else:
		$Animator.play("will_unchanged")
		emit_text("0", Palette.WHITE)


func _update_will_slots() -> void:
	$WillSlots.set_values(resource.will, resource.max_will)


func _on_defeated() -> void:
	sprite.self_modulate.a = 0.5


func _on_stamina_changed() -> void:
	if not resource.stamina:
		$ExhaustParticles.restart()
	sprite.self_modulate.a = 1.0 if resource.stamina else 0.75


func _on_condition_added(condition: Condition) -> void:
	emit_text("+" + condition.name())
	add_child(condition.vfx())


func _on_condition_removed(condition: Condition) -> void:
	emit_text("-" + condition.name())
	get_node(condition.name()).queue_free()


func _blend_condition_colors() -> void:
	var color: Color = Color.WHITE
	
	for condition: Condition in resource.conditions:
		color = Color(condition.color(), 0.5).blend(color)
	
	sprite.self_modulate = color


func _on_action_sent() -> void:
	await get_tree().create_timer(1).timeout
	$ExhaustParticles.restart()


func _on_reoriented() -> void:
	var new_pos: Vector2 = Iso.from_grid(resource.position)
	var displacement: Vector2 = position - new_pos
	position = new_pos
	
	$MoveParticles.process_material.direction = Vector3(displacement.x, displacement.y, 0)
	$MoveParticles.restart()
