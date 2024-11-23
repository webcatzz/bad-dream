extends Dialogue


func test() -> void:
	var rock: Character = load_character("rock")
	
	set_speaker(rock)
	await say("Text text?")
	set_speaker(Save.leader)
	await say("What?")
	await say("What's wrong witb you?")
	set_speaker(rock)
	await say("Text text text. Text text text text text.")
	set_speaker(Save.leader)
	await say("Huh")
	
	set_speaker(rock)
	match await prompt("Pop quiz!!!!!", ["yes", "no"]):
		0:
			await say("fool")
			await say("ok")
		1:
			await say("foolish fool")
	
	await say("Text!")
