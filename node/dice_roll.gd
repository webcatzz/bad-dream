extends Node2D


static var texture: Texture2D = load("res://asset/dice.png")

var dice_num: int
var rolls: PackedInt32Array


## Performs a dice-rolling animation, then populates [member rolls]
## with the values of [param num] rolled dice.
func roll(num: int, play_anim: bool = false) -> void:
	_prep(num)
	
	$Animator.play("RESET")
	
	if play_anim:
		$Animator.play("long_start")
		await $Animator.animation_finished
		await _randimate()
		
		_randomize()
		
		$Animator.play("long_end")
		await $Animator.animation_finished
	else:
		_randomize()
		$Animator.play("quick")


## Returns the sum of [param num] dice plus [param modifier].
func sum(num: int, modifier: int = 0, play_anim: bool = false) -> int:
	await roll(num, play_anim)
	
	var sum: int = 0
	for roll: int in rolls: sum += roll
	return sum + modifier



# internal

# Readies the node for a dice roll.
func _prep(num: int) -> void:
	dice_num = num
	rolls.resize(dice_num)
	
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
func _randimate() -> void:
	var steps: int = 32
	for i: int in steps:
		
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
