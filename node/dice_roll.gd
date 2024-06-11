extends Node2D


static var texture: Texture2D = load("res://asset/dice.png")

var dice_num: int = 1
var rolls: PackedInt32Array
var skipped: bool


## Performs a dice-rolling animation, then populates [member rolls]
## with the values of [param num] rolled dice.
func roll(num: int) -> void:
	_prep(num)
	
	await Game.tween_opacity(self, 0, 1, 0.5)
	await _animate()
	
	_randomize()
	
	await get_tree().create_timer(1 if skipped else 2).timeout
	Game.tween_opacity(self, 1, 0, 0.5)


## Returns the sum of [param num] dice plus [param modifier].
func sum(num: int, modifier: int = 0) -> int:
	await roll(num)
	
	var sum: int = 0
	for roll: int in rolls: sum += roll
	return sum + modifier



# internal

# Readies the node for a dice roll.
func _prep(num: int) -> void:
	dice_num = num
	rolls.resize(dice_num)
	skipped = false
	
	# grid columns
	if dice_num == 2: $Grid.columns = 2
	else: $Grid.columns = ceili(dice_num / 2.0)
	
	# adding/removing dice
	while dice_num < $Grid.get_child_count():
		$Grid.remove_child($Grid.get_child(-1))
	while dice_num > $Grid.get_child_count():
		$Grid.add_child(_create_dice())


# Returns a new dice node.
func _create_dice() -> TextureRect:
	var dice: TextureRect = TextureRect.new()
	
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2.ZERO, Vector2(16, 16))
	dice.texture = atlas
	
	dice.use_parent_material = true
	
	return dice


# Animates dice nodes to flicker through random faces.
func _animate() -> void:
	var steps: int = 32
	for i: int in steps: if not skipped:
		
		for die: TextureRect in $Grid.get_children():
			var face: int = randi() % 5 * 16
			if face == die.texture.region.position.x: face += 16
			die.texture.region.position.x = face
		
		await get_tree().create_timer(0.05 + (i/steps)).timeout


# Randomizes the values of [member rolls]. Also updates the textures of dice nodes.
func _randomize() -> void:
	for i: int in dice_num:
		rolls[i] = randi_range(1, 6)
		$Grid.get_child(i).texture.region.position.x = (rolls[i] - 1) * 16


func _unhandled_key_input(event: InputEvent) -> void:
	pass
	#if not skipped and event.is_action_pressed("ui_accept"):
		#skipped = true
		#get_viewport().set_input_as_handled()
