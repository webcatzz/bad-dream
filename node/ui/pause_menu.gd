extends CanvasLayer


func _ready() -> void:
	$Centerer/Tabs/Settings/Volume/MasterVolumeSlider.value = Data.get_volume("master")
	$Centerer/Tabs/Settings/Volume/MusicVolumeSlider.value = Data.get_volume("music")
	$Centerer/Tabs/Settings/Volume/SfxVolumeSlider.value = Data.get_volume("sfx")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			Game.unpause()
		else:
			Game.pause()
			$Centerer/Tabs/Buttons/Continue.grab_focus()
		
		get_viewport().set_input_as_handled()


func _set_volume(value: float, type: String) -> void:
	Data.set_volume(type, value)


func _continue() -> void:
	hide()
	Game.unpause()


func _exit() -> void:
	get_tree().quit()
