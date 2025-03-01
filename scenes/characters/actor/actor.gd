class_name Actor
extends Character

signal attacked
signal turn_started
signal turn_ended

const MAX_STOPS: int = 3
const MAX_STOP_LENGTH: float = 80.0

@export var is_friendly: bool

var traits: PackedStringArray
var conditions: Array[Condition]

var can_react: bool = true
var is_defeated: bool

@onready var actor_view: PanelContainer = $ActorView
@onready var animator: AnimationPlayer = $Animator



# traits

func add_trait(t: String) -> void:
	traits.insert(traits.bsearch(t), t)


func remove_trait(t: String) -> void:
	traits.remove_at(traits.find(t))
	
	if traits:
		actor_view.write(self)
		if not has_trait("obstinate"):
			change_type()
	else:
		is_defeated = true


func has_trait(t: String) -> bool:
	var idx: int = traits.bsearch(t)
	return idx < traits.size() and traits[idx] == t



# conditions

func add_condition(c: Condition) -> void:
	conditions.append(c)
	c.apply(self)


func remove_condition(c: Condition) -> void:
	conditions.erase(c)
	c.unapply(self)



# battle → crossing

func cross(point: Vector2) -> void:
	if point != position:
		call_adjacency(false)
	
	if animator.is_playing():
		await get_tree().create_timer(0.1).timeout
	
	position = point
	
	await get_tree().create_timer(0.1).timeout



# battle → striking

func strike(target: Actor, trait_idx: int = -1) -> void:
	target.recieve_strike(self, trait_idx)
	attacked.emit()


func recieve_strike(attacker: Actor, trait_idx: int = -1) -> void:
	if is_defeated: return
	
	if has_trait("dexterous") and can_evade(attacker):
		evade(attacker)
		return
	
	remove_trait(traits[trait_idx])
	can_react = false
	
	animator.play("hurt")
	
	if is_defeated: pass



# battle → reacting

func evade(attacker: Actor) -> void:
	Game.battle.grid.set_point_enabled(position, false)
	position += position - attacker.position
	Game.battle.grid.set_point_enabled(position, true)
	can_react = false


func call_adjacency(value: bool) -> void:
	for offset: Vector2 in [Grid.UP, Grid.DOWN, Grid.LEFT, Grid.RIGHT]:
		var obj: CollisionObject2D = Game.battle.grid.at(position + offset)
		if obj is Actor:
			obj.on_actor_adjacency_changed(self, value)


func on_actor_adjacency_changed(actor: Actor, adjacent: bool) -> void:
	if can_react and not adjacent and can_strike(actor):
		strike(actor)



# battle → turns

func take_turn() -> void:
	turn_started.emit()
	await _turn_logic()
	can_react = true


func _turn_logic() -> void:
	var target: Actor = Game.player
	
	if has_trait("irate"):
		var path: PackedVector2Array = Game.battle.grid.get_point_path(position, target.position - calc_unit(target.position - position), true)
		for point: Vector2 in path:
			await cross(point)
		if position - target.position == calc_unit(position - target.position):
			await strike(target)



# checks & calcs

func can_stand(point: Vector2) -> bool:
	return Game.battle.grid.is_point_enabled(point) or Game.battle.grid.at(point) == self


func can_strike(target: Node) -> bool:
	return target is Actor and target.is_friendly != is_friendly


func can_evade(attacker: Actor) -> bool:
	return can_react and Game.battle.grid.is_point_enabled(position + position - attacker.position)


func calc_unit(motion: Vector2) -> Vector2:
	var angle: float = motion.angle()
	if angle > 0:
		return Grid.LEFT if angle > PI/2 else Grid.DOWN
	else:
		return Grid.UP if angle < -PI/2 else Grid.RIGHT



# input

func _on_mouse_entered() -> void:
	if Game.battle:
		pass


func _on_mouse_exited() -> void:
	pass



# data

func _ready() -> void:
	super()
	for t: String in data.traits:
		add_trait(t)
	actor_view.write(self)


func load_data(data: CharacterData) -> void:
	super(data)


func change_type() -> void:
	data = ResLib.actor_data.get_resource_by_traits(traits)
	load_data(data)



# print

func _to_string() -> String:
	return "Actor(%s)" % data.name
