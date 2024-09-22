extends InfoPanel


@onready var _title: Label = $Items/Title

@onready var _will: Slots = $Items/Controls/Stats/Key/WillSlots
@onready var _stamina: Slots = $Items/Controls/Stats/Key/StaminaSlots
@onready var _other: Label = $Items/Controls/Stats/Other

@onready var _traits: VBoxContainer = $Items/Controls/Traits
@onready var _conditions: VBoxContainer = $Items/Controls/Conditions


func write(actor: Actor) -> void:
	_title.text = actor.name
	
	_will.set_values(actor.will, actor.max_will)
	_stamina.set_values(actor.stamina, actor.max_stamina)
	_other.text = "ATK %s\nDEF %s\nEVA %s" % [actor.attack, actor.defense, actor.evasion]
	
	for i: int in range(1, _traits.get_child_count()):
		_traits.get_child(i).queue_free()
	for i: int in range(1, _conditions.get_child_count()):
		_conditions.get_child(i).queue_free()
	
	if actor.traits:
		for trait_type: Trait.Type in actor.traits:
			var label: Control = preload("res://node/ui/trait_label.tscn").instantiate()
			_traits.add_child(label)
			label.write(trait_type)
		_traits.show()
	else:
		_traits.hide()
	
	if actor.conditions:
		for condition: Condition in actor.conditions:
			var label: Control = preload("res://node/ui/condition_label.tscn").instantiate()
			_conditions.add_child(label)
			label.write(condition)
		_conditions.show()
	else:
		_conditions.hide()
