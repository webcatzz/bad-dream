@tool
extends Node
# Resource library.

@export var load: bool = true

@onready var actor_data: ResourcePreloader = $ActorData
@onready var character_data: ResourcePreloader = $CharacterData
@onready var modifier_data: ResourcePreloader = $ModifierData
@onready var ui: ResourcePreloader = $UI


func _ready() -> void:
	if load:
		load_resources("res://resources/actor_data/", actor_data)
		load_resources("res://resources/character_data/", character_data)
		load_resources("res://resources/modifier_data/", modifier_data)


# Loads all resources in a folder and stores them in a preloader. Includes subfolders.
# Any resources previously stored in the preloader are cleared.
func load_resources(path: String, storage: ResourcePreloader) -> void:
	for key: String in storage.get_resource_list():
		storage.remove_resource(key)
	_add_dir_contents(path, storage)


# Loads all resources in a folder and stores them in a preloader. Includes subfolders.
func _add_dir_contents(path: String, storage: ResourcePreloader) -> void:
	for dir: String in DirAccess.get_directories_at(path):
		_add_dir_contents(path.path_join(dir), storage)
	
	for file: String in DirAccess.get_files_at(path):
		if file.ends_with(".tres"):
			var resource: Resource = load(path.path_join(file))
			var key: String = file.trim_suffix(".tres")
			storage.add_resource(key, resource)
