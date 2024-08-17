extends HBoxContainer


@export var label: String = "Action"
@export var action: String = "interact"
@export var time: float = 0.5

var held: bool

@onready var _progress: TextureProgressBar = $Progress


func _ready() -> void:
	$InputLabel.label = label
	$InputLabel.action = action
	_progress.max_value = time


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		held = true
	elif held and Input.is_action_just_released("interact"):
		held = false
		_progress.value = 0


func _process(delta: float) -> void:
	if held:
		_progress.value += delta


func _is_complete() -> bool:
	return _progress.value == time
