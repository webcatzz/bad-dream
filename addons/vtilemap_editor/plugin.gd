@tool
extends EditorPlugin

var editor: Control = load("res://addons/vtilemap_editor/editor.tscn").instantiate()
var tab: Button = add_control_to_bottom_panel(editor, "VTileMap")



# handling

func _handles(object: Object) -> bool:
	return object is VTileMap



# editor

func _enter_tree() -> void:
	editor.history = get_undo_redo()
	editor.canvas_redraw_requested.connect(update_overlays)


func _edit(object: Object) -> void:
	editor.map = object
	tab.hide()
	hide_bottom_panel()
	if object:
		tab.show()
		make_bottom_panel_item_visible(editor)


func _disable_plugin() -> void:
	remove_control_from_bottom_panel(editor)
	editor.queue_free()
	editor = null



# forwarding

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if editor.visible and event is InputEventMouse:
		editor.handle_input(event)
		return true
	return false


func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if editor.visible:
		editor.handle_draw(overlay)
