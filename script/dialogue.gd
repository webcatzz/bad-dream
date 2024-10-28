extends Node


enum LineType {
	TEXT,
	CHOICE,
	START,
	STOP,
	GOTO,
}


var stored: Dictionary = {} # fix [String, Array]


func _ready() -> void:
	var file: String = FileAccess.open("res://dialogue.txt", FileAccess.READ).get_as_text()
	
	for section: String in file.split("#"):
		var split: int = section.find("\n")
		var key: String = section.substr(1, split - 1)
		var raw_lines: PackedStringArray = section.substr(split).split("\n", false)
		var body: Array[Dictionary] = []
		
		for i: int in raw_lines.size():
			var line: Dictionary = {}
			
			if raw_lines[i].begins_with("PROMPT"):
				line.type = LineType.CHOICE
				line.text = raw_lines[i].substr(7)
				line.choices = {}
				i += 1
				
				while raw_lines[i].begins_with("CHOICE"):
					var choice_key: String = raw_lines[i].substr(7)
					var choice_body: Array[Dictionary] = []
					i += 1
					
					while raw_lines[i].begins_with("\t"):
						choice_body.append(_parse_line(raw_lines[i].substr(1)))
						i += 1
					
					line.choices[choice_key] = choice_body
			
			else:
				line = _parse_line(raw_lines[i])
			
			body.append(line)
		
		stored[key] = body
	
	print(stored)



func _parse_line(raw: String) -> Dictionary:
	var line: Dictionary = {}
	
	if raw.begins_with("START"):
		line.type = LineType.START
		line.key = raw.substr(6)
	
	elif raw == "STOP":
		line.type = LineType.STOP
	
	elif raw.begins_with("GOTO"):
		line.type = LineType.GOTO
		line.idx = int(raw.substr(5))
	
	else:
		line.type = LineType.TEXT
		line.text = raw
	
	return line
