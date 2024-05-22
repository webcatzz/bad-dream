extends PanelContainer


func set_actor(actor: Actor) -> void:
	$HBox/Label.text = actor.name
	$HBox/VBox/Art.texture = actor.portrait
	$HBox/VBox/Health.max_value = actor.max_health
	$HBox/VBox/Health.value = actor.health
	
	actor.health_changed.connect($HBox/VBox/Health.set_value)
	actor.turn_started.connect($Selected.set_visible.bind(true))
	actor.turn_ended.connect($Selected.set_visible.bind(false))
	actor.defeated.connect(queue_free)
