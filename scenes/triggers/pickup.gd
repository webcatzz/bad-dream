#class_name Pickup
#extends Trigger
#
#@export var items: Array[Item]
#
#
#func pick_up() -> void:
	#for item: Item in items:
		#Game.inventory.add(item)
#
#
#
## init
#
#func _ready() -> void:
	#super()
	#triggered.connect(pick_up)
