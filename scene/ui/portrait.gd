extends PanelContainer

var data: Actor


func set_actor(actor: Actor) -> void:
	$VBox/Art.texture = actor.portrait
	$VBox/Health.max_value = actor.max_health
	$VBox/Health.value = actor.health
	
	actor.health_changed.connect($VBox/Health.set_value)
	actor.turn_started.connect($Selected.set_visible.bind(true))
	actor.turn_ended.connect($Selected.set_visible.bind(false))
	actor.defeated.connect(queue_free)
