class_name Actor
extends Character

signal hurt
signal healed
signal exhausted
signal defeated

enum Trait {
	ANIMA,
	BURROWING,
	HEALER,
	BUCKSHOT,
}

static var types: Dictionary = {}

var type: String
var traits: Array[Trait]

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
	remove_trait(traits[-1]) # fix customize idx
	hurt.emit()
	
	if is_defeated():
		defeated.emit()
		get_parent().remove_child(self)
	else:
		change()



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

func add_trait(tr8: Trait) -> void:
	traits.append(tr8)
	match tr8:
		Trait.ANIMA: friendly = true


func remove_trait(tr8: Trait) -> void:
	traits.erase(tr8)
	match tr8:
		Trait.ANIMA: friendly = false



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
	for tr8: Trait in data.traits:
		add_trait(tr8)
	
	if not friendly:
		hurt.connect(change)


func change() -> void:
	data = types[traits]
	type = data.name
	super.load_data(data)


static func _static_init() -> void:
	for actor_name: String in FileAccess.get_file_as_string("res://resource/actor_type/list.txt").split("\n", false):
		types[load("res://resource/actor_type/%s.tres" % actor_name).traits] = actor_name


static func get_data(trait_set: Array[Trait]) -> ActorType:
	return load("res://resource/actor_type/%s.tres" % types[trait_set]) if trait_set in types else null



# traits

static func get_trait_name(tr8: Trait) -> String:
	return Trait.keys()[tr8]


static func get_trait_icon(tr8: Trait) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = load("res://asset/ui/icon/trait.png")
	texture.region.size.x = 8
	texture.region.size.y = 8
	texture.region.position.x = tr8 * 8
	return texture



# print

func _to_string() -> String:
	return "Actor(%s)" % type
