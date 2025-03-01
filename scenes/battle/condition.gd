class_name Condition

var data: ModifierData
var target: Actor
var duration: int


func tick() -> void:
	duration -= 1


func kill() -> void:
	data.unapply(target)



# virtual

func _init(name: String, target: Actor, duration: int) -> void:
	data = ResLib.modifier_data.get_resource(name)
	self.target = target
	self.duration = duration
	data.apply(target)
