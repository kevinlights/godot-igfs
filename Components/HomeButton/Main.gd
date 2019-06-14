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
		get_node("HomeButton").text = text

func addConnections():
	get_node("HomeButton").connect("pressed", self, "homePressed")
	
func homePressed():
	print("homePressed")
	get_tree().change_scene("res://Scenes/Home/Home.tscn")
