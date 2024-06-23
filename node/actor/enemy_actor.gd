extends ActorNode


func take_turn() -> void:
	if data.turn_logic: data.turn_logic.start()



# internal

func _ready() -> void:
	super()
	if data.turn_logic: data.turn_logic.owner = data
