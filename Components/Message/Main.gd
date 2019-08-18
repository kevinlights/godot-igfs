extends Node

# export (String) var text;

# const messages = preload("res://Scripts/messages.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
# func _process(delta):
	# _on_message("test")
	# setParameters()
	# pass
	# EventManager.listen("message",funcref(self, "_on_message"))
	# _on_message("started")
	# var notifier = messages.new()
	# var handler = your_handler.new()

	# notifier.connect("message", self, "_on_message")
	# global_event_bus.subscribe("message",self,"_on_message")
	
# func setParameters():
# 	if not text == "":
# 		get_node("Message").text = text

var _on_message_ref = funcref(self, "_on_message")


func _ready():
	# addConnections()
	addListeners()
	

func _exit_tree():
	removeListeners()

func addListeners():
	EventManager.listen("message",_on_message_ref)

func removeListeners():
	EventManager.ignore("message",_on_message_ref)
# func addConnections():
# 	get_node("../SpaceShip").connect("message", self, "_on_message")

func _on_message(message):
	print("message: " + message.text)
	get_node("Message").text = message.text
	yield(get_tree().create_timer(2.0), "timeout")
	get_node("Message").text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
