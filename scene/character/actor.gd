class_name Actor
extends Character

signal attacked
signal turn_started
signal turn_ended

enum Trait {
	ANIMA,
	BURROWING,
	HEALER,
	BUCKSHOT,
}

static var types: Dictionary = {}

var type: String
var traits: Array[Trait]
var conditions: Array[Condition]

var turn_frequency: int = 4
var evasion: float

var ai: ActorAI
var friendly: bool
var can_react: bool = true

@onready var animator: AnimationPlayer = $Animator
@onready var info_name: Label = $Info/Label
@onready var info_slots: Slots = $Info/Traits



# battle

func take_turn() -> void:
	turn_started.emit()
	await _turn_logic()
	can_react = true


func _turn_logic() -> void:
	await ai.act()



# battle → movement

func move(point: Vector2) -> void:
	call_adjacency(false)
	
	if animator.is_playing():
		await get_tree().create_timer(0.1).timeout
	
	position = point
	
	await get_tree().create_timer(0.1).timeout
	
	call_adjacency(true)



# battle → attacks

func attack(target: Actor) -> void:
	target.recieve_attack(self)
	attacked.emit()


func recieve_attack(attacker: Actor, trait_idx: int = -1) -> void:
	if is_defeated(): return
	
	if can_evade(attacker):
		evade(attacker)
		return
	
	remove_trait(traits[trait_idx])
	can_react = false
	
	animator.play("hurt")
	
	if is_defeated():
		pass
	elif not friendly:
		change()



# battle → evasion

func evade(attacker: Actor) -> void:
	Game.battle.grid.set_point_solid(tile, false)
	position += position - attacker.position
	Game.battle.grid.set_point_solid(tile, true)
	can_react = false



# battle → adjacency

func call_adjacency(value: bool) -> void:
	for offset: Vector2 in [Grid.UP, Grid.DOWN, Grid.LEFT, Grid.RIGHT]:
		var obj: CollisionObject2D = Game.battle.grid.at(position + offset)
		if obj is Actor:
			obj.on_actor_adjacency_changed(self, value)


func on_actor_adjacency_changed(actor: Actor, adjacent: bool) -> void:
	ai.on_actor_adjacency_changed(actor, adjacent)



# traits

func add_trait(tr8: Trait) -> void:
	traits.append(tr8)
	match tr8:
		Trait.ANIMA: friendly = true
	
	info_slots.value += 1


func remove_trait(tr8: Trait) -> void:
	traits.erase(tr8)
	match tr8:
		Trait.ANIMA: friendly = false
	
	info_slots.value -= 1


static func get_type(trait_set: Array[Trait]) -> ActorType:
	return load("res://resource/actor_type/%s.tres" % types[trait_set]) if trait_set in types else null


static func get_trait_name(tr8: Trait) -> String:
	return Trait.keys()[tr8]


static func get_trait_icon(tr8: Trait) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = load("res://asset/ui/icon/trait.png")
	texture.region.size.x = 8
	texture.region.size.y = 8
	texture.region.position.x = tr8 * 8
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


func can_stand(point: Vector2) -> bool:
	return Game.battle.grid.is_point_open(Grid.point_to_tile(point)) or Game.battle.grid.at(point) == self


func can_attack(target: Node) -> bool:
	return target is Actor and target.friendly != friendly


func can_evade(attacker: Actor) -> bool:
	return can_react and Game.battle.grid.is_point_open(tile + tile - attacker.tile)


func calc_facing(motion: Vector2) -> Vector2:
	var angle: float = motion.angle()
	if angle > 0:
		return Grid.LEFT if angle > PI/2 else Grid.DOWN
	else:
		return Grid.UP if angle < -PI/2 else Grid.RIGHT



# data

func load_data(data: CharacterData) -> void:
	super(data)
	
	for tr8: Trait in data.traits:
		add_trait(tr8)
	
	info_slots.max_value = traits.size()
	
	read_data()


func read_data() -> void:
	type = data.name
	ai = data.ai.new(self)
	
	info_name.text = type
	info_slots.value = traits.size()


func change() -> void:
	data = get_type(traits)
	read_data()
	super.load_data(data)


static func _static_init() -> void:
	for actor_name: String in FileAccess.get_file_as_string("res://resource/actor_type/list.txt").split("\n", false):
		types[load("res://resource/actor_type/%s.tres" % actor_name).traits] = actor_name



# print

func _to_string() -> String:
	return "Actor(%s)" % type
