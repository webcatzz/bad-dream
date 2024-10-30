extends InfoPanel


@onready var _will: Slots = $Items/Controls/Stats/Key/WillSlots
@onready var _stamina: Slots = $Items/Controls/Stats/Key/StaminaSlots
@onready var _other: Label = $Items/Controls/Stats/Other

@onready var _traits: GridContainer = $Items/Controls/Traits/Grid
@onready var _conditions: GridContainer = $Items/Controls/Conditions/Grid


func write(actor: Actor) -> void:
	_title.text = actor.name
	
	_will.set_values(actor.will, actor.max_will)
	_stamina.set_values(actor.stamina, actor.max_stamina)
	#_other.text = "ATK %s\nDEF %s\nEVA %s" % [actor.attack, actor.defense, actor.evasion]
	
	for child: Control in _traits.get_children() + _conditions.get_children():
		child.queue_free()
	
	if actor.traits:
		for trait_type: Trait.Type in actor.traits:
			var name_label: Label = Label.new()
			name_label.text = Trait.name(trait_type)
			_traits.add_child(name_label)
			var desc_label: Label = Label.new()
			desc_label.text = Trait.describe(trait_type)
			desc_label.theme_type_variation = &"LabelSmall"
			desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_traits.add_child(desc_label)
		_traits.get_parent().show()
	else:
		_traits.get_parent().hide()
	
	if actor.conditions:
		for condition: Condition in actor.conditions:
			var name_label: Label = Label.new()
			name_label.text = condition.name()
			_conditions.add_child(name_label)
			var slots: Slots = Slots.new()
			slots.set_values(condition.duration_left, condition.duration)
			slots.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_conditions.add_child(slots)
		_conditions.get_parent().show()
	else:
		_conditions.get_parent().hide()
	
	size = Vector2.ZERO
