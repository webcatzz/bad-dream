extends Dialogue


func test() -> void:
	set_speaker(Game.player)
	await say("Text text?")
	await say("Text text text. Text text text text text.")
	
	set_speaker(get_parent())
	match await prompt("Pop quiz!!!!!", ["yes", "no"]):
		0:
			await say("fool")
			await say("ok")
		1:
			await say("foolish fool")
	
	set_speaker(Game.player)
	await say("Text!")
