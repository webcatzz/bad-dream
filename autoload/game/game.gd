extends Node

var player: Player
var battle: Battle

var grid := IsoGrid.new()

@onready var menu: ItemList = $ContextMenu
