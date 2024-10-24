extends TabContainer


enum Tab {
	MAIN,
}

var item: Item

@export var _selector: Selector = get_parent()


func open(item: Item) -> void:
	self.item = item
	_open_main()
	show()


func close() -> void:
	hide()
	_selector.deselect()



# openers

func _open_main(from: Tab = current_tab as Tab) -> void:
	current_tab = Tab.MAIN
	$Main.get_child(from - 1).grab_focus()
