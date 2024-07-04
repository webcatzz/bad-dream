extends Node


const PALETTE: Dictionary = {
	"red": Color("#945b28"),
	"yellow": Color("#eadb74"),
	"light_green": Color("#a0b335"),
	"dark_green": Color("#537c44"),
	"blue": Color("#596faf"),
	
	"white": Color("#b8aab0"),
}

var _pause_menu: CanvasLayer = load("res://node/ui/pause_menu.tscn").instantiate()


# pausing


func pause() -> void:
	get_tree().paused = true
	_pause_menu.visible = true


func unpause() -> void:
	get_tree().paused = false
	_pause_menu.visible = false



# party

func spawn_party(position: Vector2) -> void:
	for actor: Actor in Data.party:
		if not actor.node:
			actor.node = load("res://node/actor/player_actor.tscn" if actor == Data.get_leader() else "res://node/actor/party_actor.tscn").instantiate()
			actor.node.data = actor
		
		actor.node.position = position
		get_tree().current_scene.add_child(actor.node)



# game over

func over() -> void:
	get_tree().change_scene_to_file("res://node/ui/game_over.tscn")



# internal

func _ready() -> void:
	add_child(_pause_menu)



# debug

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P and event.shift_pressed:
		var layer: CanvasLayer = CanvasLayer.new()
		var input: LineEdit = LineEdit.new()
		input.anchor_right = Control.ANCHOR_END
		layer.add_child(input)
		get_tree().current_scene.add_child(layer)
		input.grab_focus()
		
		await input.text_submitted
		
		var command: String = input.text
		layer.queue_free()
		
		if command:
			var script: GDScript = GDScript.new()
			script.source_code = "static func run():" + command
			script.reload()
			script.run()
