class_name Pickup
extends Trigger

@export var item: Item
@export var count: int = 12


func pick_up() -> void:
	Game.inventory.add(item, count)



# init

func _ready() -> void:
	super()
	triggered.connect(pick_up)
