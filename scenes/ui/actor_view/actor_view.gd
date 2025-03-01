extends PanelContainer
## Actor view.

@onready var title: Label = $VBox/Name
@onready var traits: HFlowContainer = $VBox/Traits



func write(data: ActorData) -> void:
	title.text = data.name
	
	for t: String in data.traits:
		var label: Control = ResLib.ui.get_resource("trait_label").instantiate()
		label.write(t)
		traits.add_child(label)
