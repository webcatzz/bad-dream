extends PanelContainer


func set_actor(actor: Actor) -> void:
	#$HBox/Art.texture = actor.portrait
	$HBox/VBox/Name.text = actor.name
	$HBox/VBox/Health.max_value = actor.max_health
	$HBox/VBox/Health.value = actor.health
	
	actor.turn_started.connect($HBox/ActiveIcon.set_visible.bind(true))
	actor.turn_ended.connect($HBox/ActiveIcon.set_visible.bind(false))
	actor.health_changed.connect($HBox/VBox/Health.set_value)
	actor.defeated.connect($HBox/Art.set_modulate.bind(Color(1, 1, 1, 0.5)))
