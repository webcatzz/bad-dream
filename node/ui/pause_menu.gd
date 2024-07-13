extends CanvasLayer


func _ready() -> void:
	$Overlay/Tabs/Settings/Volume/MasterVolumeSlider.value = Data.get_volume("master")
	$Overlay/Tabs/Settings/Volume/MusicVolumeSlider.value = Data.get_volume("music")
	$Overlay/Tabs/Settings/Volume/SfxVolumeSlider.value = Data.get_volume("sfx")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			if $Overlay/Tabs.current_tab != 0: $Overlay/Tabs.current_tab = 0
			else: Game.unpause()
		else:
			Game.pause()
			_on_tab_changed()
		get_viewport().set_input_as_handled()


func _on_tab_changed() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	$Overlay.find_next_valid_focus().grab_focus()


func _set_volume(value: float, type: String) -> void:
	Data.set_volume(type, value)


func _continue() -> void:
	hide()
	Game.unpause()


func _exit() -> void:
	get_tree().quit()
