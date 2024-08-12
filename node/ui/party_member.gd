extends PanelContainer


var actor: Actor


func select() -> void:
	modulate.v = 1


func deselect() -> void:
	modulate.v = 0.5



# internal

func _ready() -> void:
	$Panel/VBox/WillSlots.slots = actor.max_will
	$Panel/VBox/WillSlots.value = actor.will
	actor.will_changed.connect(_on_will_changed.unbind(1))


func _on_will_changed() -> void:
	$Panel/VBox/WillSlots.value = actor.will
