@tool
class_name ResourcePreloaderPlus
extends ResourcePreloader

@export_dir var path: String
@export var load: bool:
	set(value): _add_dir_contents(path)


func get_resources() -> Array[Resource]:
	var array: Array[Resource]
	for key: String in get_resource_list():
		array.append(get_resource(key))
	return array


func _add_dir_contents(path: String) -> void:
	for dir: String in DirAccess.get_directories_at(path):
		_add_dir_contents(path.path_join(dir))
	
	for file: String in DirAccess.get_files_at(path):
		if file.ends_with(".tres"):
			var resource: Resource = load(path.path_join(file))
			var key: String = file.trim_suffix(".tres")
			if has_resource(key): remove_resource(key)
			add_resource(key, resource)
