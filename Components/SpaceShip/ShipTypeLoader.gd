extends Node

var load_ship_type_ref;
var SHIP_TURN_RATE;
var SHIP_MAX_SPEED;
########################
var settings_location = "res://settings.cfg"
var config = ConfigFile.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	setFuncrefs()
	addListeners()
	load_ship_type(config.get_value("ship_info","ship",0))

func _exit_tree():
	removeListeners();

func setFuncrefs():
	load_ship_type_ref = funcref(self, "load_ship_type")

func addListeners():
	EventManager.listen("ship_type_change",load_ship_type_ref)

func removeListeners():
	EventManager.ignore("ship_type_change",load_ship_type_ref)
	
func load_ship_type(type):
	config.set_value("ship_info","ship",type)
	config.save(settings_location)
	print("ship type is: " + str(type))
	var shipImport = load("res://Components/SpaceShip/S"+str(type)+".tscn").instance()
	var ship_config = ConfigFile.new()
	var err = ship_config.load("res://Components/SpaceShip/S"+str(type)+".cfg")
	SHIP_TURN_RATE = ship_config.get_value("ship_info","turn_rate",0.1)
	SHIP_MAX_SPEED = ship_config.get_value("ship_info","max_speed",250) 
	for child in get_owner().get_children():
		if "ShipPart" in child.get_name():
			get_owner().remove_child(child)
			child.queue_free()
	
	get_owner().call_deferred("add_child",shipImport)
	for child in shipImport.get_children():
		shipImport.remove_child(child)
		get_owner().call_deferred("add_child",child)
		child.set_name("ShipPart" + child.get_name())
	shipImport.queue_free()
