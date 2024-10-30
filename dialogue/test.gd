extends Dialogue


func test() -> void:
	set_speaker(Save.leader)
	await say("Text text?")
	await say("Text text text. Text text text text text.")
	
	match await prompt("Pop quiz!!!!!", ["yes", "no"]):
		0:
			await say("fool")
			await say("ok")
		1:
			await say("foolish fool")
	
	await say("Text!")
