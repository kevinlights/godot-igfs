extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _process(delta):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	addConnections()

func addConnections():
	get_node("StartButton").connect("pressed", self, "startPressed")
	

func startPressed():
	print("startPressed")
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
