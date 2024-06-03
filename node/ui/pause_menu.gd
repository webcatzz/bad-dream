extends CanvasLayer


func _ready() -> void:
	$Centerer/Tabs/Settings/Volume/MasterVolumeSlider.value = Game.data.master_volume
	$Centerer/Tabs/Settings/Volume/MusicVolumeSlider.value = Game.data.music_volume
	$Centerer/Tabs/Settings/Volume/SfxVolumeSlider.value = Game.data.sfx_volume


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			Game.unpause()
			$Centerer/Tabs/Buttons/Continue.grab_focus()
		else:
			Game.pause()
		
		get_viewport().set_input_as_handled()


func _set_volume(value: float, type: String) -> void:
	Game.data[type + "_volume"] = value


func _exit() -> void:
	get_tree().quit()
