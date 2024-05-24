extends TabContainer


func _ready() -> void:
	$Settings/MasterVolumeSlider.value = Game.data.master_volume
	$Settings/MusicVolumeSlider.value = Game.data.music_volume
	$Settings/SfxVolumeSlider.value = Game.data.sfx_volume


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = !visible
		get_viewport().set_input_as_handled()


func _set_volume(value: float, type: String) -> void:
	Game.data[type + "_volume"] = value
