extends PanelContainer

@export var selector: OptionButton
@export var view_name: Label
@export var view_sprite: TextureRect
@export var view_traits: VBoxContainer
@export var view_children: Label

var list: Array[ActorType]
var current_type: ActorType


func _ready() -> void:
	for tset: Array[Actor.Trait] in Actor.types:
		var type: ActorType = Actor.get_type(tset)
		list.append(type)
		selector.add_item(type.name)
	
	view_idx(0)


func view_idx(idx: int) -> void:
	view(list[idx])


func view(type: ActorType) -> void:
	current_type = type
	selector.select(list.find(type))
	
	view_name.text = type.name
	view_sprite.texture = type.sprite
	
	# clearing
	for i: int in range(1, view_traits.get_child_count()): view_traits.get_child(i).queue_free()
	
	# traits
	for tr8: Actor.Trait in type.traits:
		var hbox := HBoxContainer.new()
		hbox.add_child(get_trait_control(tr8))
		
		var child: ActorType = get_type_without(tr8)
		if child:
			hbox.add_child(get_trait_button(child, false))
		
		view_traits.add_child(hbox)
	
	# parents
	for tr8: Actor.Trait in Actor.Trait.size():
		var parent: ActorType = get_type_with(tr8)
		if parent:
			var hbox := HBoxContainer.new()
			hbox.add_child(get_trait_control(tr8))
			hbox.add_child(get_trait_button(parent, true))
			hbox.modulate.a = 0.5
			view_traits.add_child(hbox)
	
	# children
	view_children.text = "Children\n" + ", ".join(get_type_children_names())



# controls

func get_trait_control(tr8: Actor.Trait) -> HBoxContainer:
	var trait_label: Control = load("res://scene/ui/modifier_label/trait_label.tscn").instantiate()
	trait_label.write(tr8)
	trait_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return trait_label


func get_trait_button(type: ActorType, parent: bool) -> Button:
	var button := Button.new()
	button.text = ("↑ " if parent else "↓ ") + type.name
	button.theme_type_variation = &"ButtonSmall"
	button.pressed.connect(view.bind(type))
	return button



# getters

func get_type_children_names() -> Array[String]:
	var children: Array[String]
	for tr8: Actor.Trait in current_type.traits:
		var child: ActorType = get_type_without(tr8)
		if child:
			children.append(child.name)
	return children


func get_type_with(tr8: Actor.Trait) -> ActorType:
	var traits: Array[Actor.Trait] = current_type.traits.duplicate()
	traits.insert(traits.bsearch(tr8), tr8)
	return Actor.get_type(traits)


func get_type_without(tr8: Actor.Trait) -> ActorType:
	var traits: Array[Actor.Trait] = current_type.traits.duplicate()
	traits.erase(tr8)
	return Actor.get_type(traits)
