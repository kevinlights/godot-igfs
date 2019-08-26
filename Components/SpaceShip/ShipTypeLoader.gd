extends Node

var load_ship_type_ref;
########################
var settings_location = "res://settings.cfg"
var config = ConfigFile.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	initConfig()
	setFuncrefs()
	addListeners()
	# print(config.get_value("ship_info","ship",0))
	load_ship_type(config.get_value("ship_info","ship",0))

func _exit_tree():
	removeListeners();

func initConfig():
	config.load(settings_location)#returns error, is there is one

func setFuncrefs():
	load_ship_type_ref = funcref(self, "load_ship_type")

func addListeners():
	EventManager.listen("ship_type_change",load_ship_type_ref)

func removeListeners():
	EventManager.ignore("ship_type_change",load_ship_type_ref)
	
func load_ship_type(type):
	config.set_value("ship_info","ship",type)
	config.save(settings_location)
	ShipInfo.ship = type
	print("ship type is: " + str(type))
	var shipImport = load("res://Components/SpaceShip/S"+str(type)+".tscn").instance()
	for child in get_owner().get_children():
		if child.is_in_group("ShipPart"):
			get_owner().remove_child(child)
			child.queue_free()
	
	get_owner().call_deferred("add_child",shipImport)
	for child in shipImport.get_children():
		shipImport.remove_child(child)
		get_owner().call_deferred("add_child",child)
		# child.set_name("ShipPart" + child.get_name())
		child.add_to_group("ShipPart")
	shipImport.queue_free()
