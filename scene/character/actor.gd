class_name Actor
extends Character

signal hurt
signal healed
signal exhausted
signal defeated

var type: String
var traits: Array[Trait.Type]

var friendly: bool

var turn_frequency: int = 4
var stamina: int = 32
var max_stamina: int = 32

@onready var animator: AnimationPlayer = $Animator



# attacking

func attack() -> void:
	var target: Actor = Game.grid.get_actor_at(tile + facing)
	if target:
		target.recieve_attack()
	exhausted.emit()


func recieve_attack() -> void:
	remove_trait(traits[-1])
	hurt.emit()
	if is_defeated():
		defeated.emit()
		get_parent().remove_child(self)



# movement

func replenish() -> void:
	stamina = max_stamina


func step(point: Vector2) -> void:
	facing = calc_facing(Game.grid.point_to_tile(point - position))
	position = point


func follow_path(path: PackedVector2Array) -> void:
	for point: Vector2 in path:
		step(point)
		stamina -= 1
		await get_tree().create_timer(0.1).timeout



# modifiers

func add_trait(type: Trait.Type) -> void:
	traits.append(type)
	Trait.add(type, self)


func remove_trait(type: Trait.Type) -> void:
	traits.erase(type)
	Trait.remove(type, self)



# checks/calcs

func is_defeated() -> bool:
	return traits.is_empty()

func calc_facing(motion: Vector2i) -> Vector2i:
	var axis: int = motion.abs().max_axis_index()
	return (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(motion[axis])



# data

func load_data(data: CharacterData) -> void:
	super(data)
	type = data.name
	for type: Trait.Type in data.traits: add_trait(type)



# print

func _to_string() -> String:
	return "Actor(%s)" % type
