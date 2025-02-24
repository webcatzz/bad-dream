class_name Actor
extends Character

signal attacked
signal turn_started
signal turn_ended

enum Trait {
	ANIMA,
	PITEOUS,
	BURROWER,
	BUCKSHOT,
}

var type: String
var traits: Array[Trait]
var conditions: Array[Condition]

var turn_frequency: int = 4
var evasion: float

var behavior: ActorBehavior
var friendly: bool
var can_react: bool = true



# battle

func take_turn() -> void:
	turn_started.emit()
	await _turn_logic()
	can_react = true


func _turn_logic() -> void:
	await behavior.act()



# battle → movement

func move(point: Vector3) -> void:
	call_adjacency(false)
	
	#if animator.is_playing():
		#await get_tree().create_timer(0.1).timeout
	
	position = point
	
	await get_tree().create_timer(0.1).timeout
	
	call_adjacency(true)



# battle → attacks

func attack(target: Actor) -> void:
	target.recieve_attack(self)
	attacked.emit()


func recieve_attack(attacker: Actor, trait_idx: int = -1) -> void:
	if is_defeated(): return
	
	#if can_evade(attacker):
		#evade(attacker)
		#return
	
	remove_trait(traits[trait_idx])
	can_react = false
	
	#animator.play("hurt")
	
	if is_defeated():
		pass
	elif not friendly:
		change()



# battle → evasion

func evade(attacker: Actor) -> void:
	#Game.battle.grid.set_point_solid(coords, false)
	position += position - attacker.position
	#Game.battle.grid.set_point_solid(coords, true)
	can_react = false



# battle → adjacency

func call_adjacency(value: bool) -> void:
	pass
	#for offset: Vector2 in [Grid.UP, Grid.DOWN, Grid.LEFT, Grid.RIGHT]:
		#var obj: CollisionObject2D = Game.battle.grid.at(position + offset)
		#if obj is Actor:
			#obj.on_actor_adjacency_changed(self, value)


func on_actor_adjacency_changed(actor: Actor, adjacent: bool) -> void:
	behavior.on_actor_adjacency_changed(actor, adjacent)



# traits

func add_trait(t: Trait) -> void:
	traits.append(t)
	match t:
		Trait.ANIMA: friendly = true


func remove_trait(t: Trait) -> void:
	traits.erase(t)
	match t:
		Trait.ANIMA: friendly = false


static func get_trait_name(t: Trait) -> String:
	return Trait.keys()[t]


static func get_trait_icon(t: Trait) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = load("res://assets/ui/icon/trait.png")
	texture.region.size.x = 8
	texture.region.size.y = 8
	texture.region.position.x = t * 8
	return texture



# conditions

func add_condition(condition: Condition) -> void:
	conditions.append(condition)
	condition.apply(self)


func remove_condition(condition: Condition) -> void:
	conditions.erase(condition)
	condition.unapply(self)



# checks & calcs

func is_defeated() -> bool:
	return traits.is_empty()


func can_stand(point: Vector3) -> bool:
	return true


func can_attack(target: Node) -> bool:
	return target is Actor and target.friendly != friendly


func can_evade(attacker: Actor) -> bool:
	return false


func calc_facing(motion: Vector2) -> Vector2:
	return Vector2()



# data

func load_data(data: CharacterData) -> void:
	super(data)
	
	for t: Trait in data.traits:
		add_trait(t)
	
	read_data()


func read_data() -> void:
	type = data.name
	behavior = data.behavior.new(self)


func change() -> void:
	data = ResourceLibrary.get_actor_type(traits)
	read_data()
	super.load_data(data)



# print

func _to_string() -> String:
	return "Actor(%s)" % type
