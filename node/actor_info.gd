extends PanelContainer


@export var icon: TextureRect
@export var will: ProgressBar
@export var traits: VBoxContainer
@export var conditions: VBoxContainer


func open(actor: Actor) -> void:
	icon.texture = actor.icon
	will.max_value = actor.max_will
	will.value = actor.will
	
	for trait_type: Trait.Type in actor.traits:
		var label: HBoxContainer = preload("res://node/ui/trait_label.tscn").instantiate()
		label.write(trait_type)
		conditions.add_child(label)
	
	for condition: Condition in actor.conditions:
		var label: HBoxContainer = preload("res://node/ui/condition_label.tscn").instantiate()
		label.write(condition)
		conditions.add_child(label)
	
	position = actor.node.position + Vector2(16, -48)
	show()
	$Animator.play("open")


func close() -> void:
	hide()
	
	for child: Node in traits.get_children() + conditions.get_children():
		child.queue_free()
