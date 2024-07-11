extends HBoxContainer


@onready var list: ItemList = $Selector/PanelContainer/LoopingItemList


func display(title: String, description: String) -> void:
	$Item/Title.text = title
	$Item/Description.text = description



# internal

func _ready() -> void:
	$Selector/Title.text = name
