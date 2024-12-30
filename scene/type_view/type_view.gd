extends PanelContainer

@export var selector: OptionButton
@export var view_name: Label
@export var view_sprite: TextureRect
@export var view_traits: VBoxContainer
@export var view_parents: VBoxContainer
@export var view_children: Label

var list: Array[ActorType]
var data: ActorType


func _ready() -> void:
	for trait_set: Array[Actor.Trait] in Actor.types:
		var data: ActorType = Actor.get_data(trait_set)
		selector.add_item(data.name)
		list.append(data)
	view(0)


func view(idx: int) -> void:
	data = list[idx]
	selector.select(idx)
	
	view_name.text = data.name
	view_sprite.texture = data.sprite
	
	# clearing
	for child: Node in view_traits.get_children(): child.queue_free()
	for child: Node in view_parents.get_children(): child.queue_free()
	
	# traits
	for tr8: Actor.Trait in data.traits:
		var data_without: ActorType = get_data_without(tr8)
		if data_without:
			view_traits.add_child(get_trait_control(tr8, "↓ " + data_without.name, data_without))
		else:
			view_traits.add_child(get_trait_control(tr8, "↓ x"))
	
	# parents
	var parents: Array[Dictionary] = get_type_parents()
	if parents:
		for parent: Dictionary in get_type_parents():
			view_parents.add_child(get_trait_control(parent.trait, "↑ " + parent.data.name, parent.data))
	else:
		var label := Label.new()
		label.text = "-"
		label.modulate.a = 0.5
		label.theme_type_variation = &"LabelSmall"
		view_parents.add_child(label)
	
	# children
	view_children.text = ", ".join(get_type_children_names())


func get_trait_control(tr8: Actor.Trait, text: String, view_data: ActorType = null) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	
	var trait_label: Control = load("res://scene/modifier_label/trait_label.tscn").instantiate()
	trait_label.write(tr8)
	trait_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(trait_label)
	
	if view_data:
		var button := Button.new()
		button.text = text
		button.pressed.connect(view.bind(list.find(view_data)))
		hbox.add_child(button)
	else:
		var label := Label.new()
		label.text = text
		label.modulate.a = 0.5
		hbox.add_child(label)
	
	return hbox



# getters

func get_type_parents() -> Array[Dictionary]:
	var parents: Array[Dictionary]
	for tr8: Actor.Trait in Actor.Trait.values():
		var data: ActorType = get_data_with(tr8)
		if data: parents.append({"data": data, "trait": tr8})
	return parents


func get_type_children_names() -> Array[String]:
	var children: Array[String]
	for trait_set: Array[Actor.Trait] in Actor.types:
		var child: bool = true
		for tr8: Actor.Trait in trait_set:
			if tr8 not in data.traits:
				child = false
				break
		if child:
			children.append(Actor.get_data(trait_set).name)
	return children


func get_data_with(tr8: Actor.Trait) -> ActorType:
	var traits: Array[Actor.Trait] = data.traits.duplicate()
	traits.append(tr8)
	traits.sort()
	return Actor.get_data(traits)


func get_data_without(tr8: Actor.Trait) -> ActorType:
	var traits: Array[Actor.Trait] = data.traits.duplicate()
	traits.erase(tr8)
	return Actor.get_data(traits)
