extends Node2D


# ring
const RING_WIDTH: float = 32
const RING_RADIUS: float = 48
const CURSOR_RANGE: float = pow(RING_RADIUS + RING_WIDTH / 2 + ITEM_OFFSET, 2)
# item
const ITEM_ARC: float = TAU * 0.1
const ITEM_ARC_HALF: float = ITEM_ARC / 2
const ITEM_OFFSET: float = 4

var start_angle: float
var end_angle: float

var items: Array[MenuItem]
var hovered: MenuItem


func _ready() -> void:
	add_item("1")
	add_item("2", load("res://asset/ui/icon/commit.png"))
	add_item("3")
	add_item("4")
	add_item("5")


func add_item(text: String, icon: Texture2D = null, enabled: bool = true) -> void:
	var item := MenuItem.new()
	item.text = text
	item.icon = icon
	item.enabled = enabled
	items.append(item)
	queue_redraw()



# drawing

func _draw() -> void:
	start_angle = (items.size() * ITEM_ARC + PI) / -2
	var angle: float = start_angle
	for item: MenuItem in items:
		item.angle = angle
		draw_item(item)
		angle += ITEM_ARC
	end_angle = angle


func draw_item(item: MenuItem) -> void:
	var vector: Vector2 = Vector2.from_angle(item.angle + ITEM_ARC_HALF)
	
	draw_arc(
		vector * ITEM_OFFSET,
		RING_RADIUS,
		item.angle,
		item.angle + ITEM_ARC,
		8,
		Color.BLUE if item == hovered else Palette.BLACK,
		RING_WIDTH, true
	)
	
	if item.icon:
		draw_texture(
			item.icon,
			vector * (RING_RADIUS + ITEM_OFFSET) - item.icon.get_size() / 2,
		)



# draw calculators

func arc_to_length(arc: float, radius: float) -> float:
	return arc * radius


func length_to_arc(length: float, radius: float) -> float:
	return length / radius



# internal

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var angle: float = get_local_mouse_position().angle()
		
		if angle < start_angle or angle > end_angle or Vector2.ZERO.distance_squared_to(get_local_mouse_position()) > CURSOR_RANGE:
			hovered = null
		else:
			for item: MenuItem in items:
				if item.angle < angle:
					hovered = item
				else:
					break
		
		queue_redraw()
	
	elif event.is_action("click") and hovered:
		pass



# menu item

class MenuItem:
	var text: String
	var icon: Texture2D
	var enabled: bool
	
	var angle: float
