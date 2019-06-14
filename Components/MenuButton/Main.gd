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
		get_node("MenuButton").text = text

func addConnections():
	get_node("MenuButton").connect("pressed", self, "menuPressed")

func menuPressed():
	print("menuPressed")
	get_node("PopupMenu").visible = true
