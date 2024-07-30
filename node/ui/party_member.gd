extends PanelContainer


var actor: Actor


func select() -> void:
	modulate.v = 1


func deselect() -> void:
	modulate.v = 0.5
