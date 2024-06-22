extends PanelContainer


func set_actor(actor: Actor) -> void:
	$HBox/Label.text = actor.name
	$HBox/VBox/Art.texture = actor.portrait
	$HBox/VBox/Health.max_value = actor.max_health
	$HBox/VBox/Health.value = actor.health
	
	actor.turn_started.connect($Selected.set_visible.bind(true))
	actor.turn_ended.connect($Selected.set_visible.bind(false))
	actor.health_changed.connect($HBox/VBox/Health.set_value)
	actor.defeated.connect($HBox/VBox/Art.set_modulate.bind(Color(1, 1, 1, 0.5)))
