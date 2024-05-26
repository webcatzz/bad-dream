class_name TextParticles extends Node2D


var particles: Array[TextParticle] = []

class TextParticle:
	var text: String
	var position: Vector2 = Vector2.ZERO
	var start_angle: float = 0
	var existed_for: float = 0
	
	func _init(text: String): text = text


func emit(text: String) -> void:
	particles.append(TextParticle.new(text))


func _draw() -> void:
	for particle: TextParticle in particles:
		draw_string(
			ThemeDB.fallback_font,
			particle.position,
			particle.text,
			HORIZONTAL_ALIGNMENT_CENTER
		)


func _process(delta: float) -> void:
	for particle: TextParticle in particles:
		particle.existed_for += delta
	
	queue_redraw()
