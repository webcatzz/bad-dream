extends PanelContainer
## Actor view.

@onready var title: Label = $VBox/Name
@onready var traits: VBoxContainer = $VBox/Traits



func write(actor: Actor) -> void:
	title.text = actor.data.name
	
	for t: Control in traits.get_children():
		t.queue_free()
	for t: String in actor.traits:
		var label: Control = ResLib.ui.get_resource("trait_label").instantiate()
		label.write(t)
		traits.add_child(label)
