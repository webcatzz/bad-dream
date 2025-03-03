class_name TypeGraphNode
extends MarginContainer

const LINE_CENTER := Vector2(0, 10)

@export var data: ActorData

@onready var actor_view: PanelContainer = $VBox/ActorView
@onready var child_list: HBoxContainer = $VBox/ChildList


func _ready() -> void:
	actor_view.write_data(data)


func child(node: TypeGraphNode) -> void:
	child_list.add_child(node)
	queue_redraw.call_deferred()



# lines

func _draw() -> void:
	if not child_list.get_child_count(): return
	var points: PackedVector2Array
	
	var rect: Rect2 = actor_view.get_global_rect()
	var connector := Vector2(rect.get_center().x, rect.position.y)
	points.append(connector)
	points.append(connector - LINE_CENTER)
	
	for child: TypeGraphNode in child_list.get_children():
		var child_rect: Rect2 = child.actor_view.get_global_rect()
		var child_connector := Vector2(child_rect.get_center().x, child_rect.end.y)
		points.append(child_connector)
		points.append(child_connector + LINE_CENTER)
		points.append(child_connector + LINE_CENTER)
		points.append(connector - LINE_CENTER)
	
	draw_set_transform(-global_position)
	draw_multiline(points, Palette.WHITE.lerp(Color("#1b1b1b"), 0.5), 1)
