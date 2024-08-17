extends HBoxContainer


const DEADZONE: float = 0.1

@export var label: String = "Action"
@export var action: String = "interact"
@export var time: float = 0.5

var time_held: float

@onready var _progress: TextureProgressBar = $Progress


func _ready() -> void:
	$InputLabel.label = label
	$InputLabel.action = action
	_progress.max_value = time - DEADZONE


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_released("interact"):
		time_held = 0
		_progress.value = 0


func _process(delta: float) -> void:
	if Input.is_action_pressed("interact"):
		time_held += delta
		_progress.value = time_held
