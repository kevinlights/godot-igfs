extends Node2D
export (String) var text;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	setParameters()
	addConnections()

func setParameters():
	if not text == "":
		get_node("QuitButton").text = text

func addConnections():
	get_node("QuitButton").connect("pressed", self, "quitPressed")
	
func quitPressed():
	print("quitPressed")
	get_tree().quit()
