extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var settings_location = "res://settings.cfg"
var config = ConfigFile.new()

var SHIP_TURN_RATE = 0.1
var SHIP_MAX_SPEED = 250

var load_ship_type_ref;
# Called when the node enters the scene tree for the first time.
func _ready():
	#    set_physics_process(true)
	#    set_gravity_scale(1)
	initConfig()
	setFuncrefs()
	addListeners()
	load_ship_type(config.get_value("ship_info","ship",0))


func _exit_tree():
	removeListeners()

func initConfig():
	config.load(settings_location)#returns error, is there is one

func setFuncrefs():
	load_ship_type_ref = funcref(self, "load_ship_type")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_ship_type(type):
	var ship_config = ConfigFile.new()
	var err = ship_config.load("res://Components/SpaceShip/S"+str(type)+".cfg")
	SHIP_TURN_RATE = ship_config.get_value("ship_info","turn_rate",0.1)
	SHIP_MAX_SPEED = ship_config.get_value("ship_info","max_speed",250) 


func addListeners():
	EventManager.listen("ship_type_change",load_ship_type_ref)

func removeListeners():
	EventManager.ignore("ship_type_change",load_ship_type_ref)

func _process(delta):

	var TURN_SPEED = get_turn_speed(delta,get_owner().speed,get_owner().SHIP_TURN_RATE)

	if Input.is_key_pressed(KEY_UP):
		if get_owner().speed + 1 <= SHIP_MAX_SPEED && !get_owner().landing:
			get_owner().speed = get_owner().speed+1
		elif get_owner().landing:
			var body_in_landing = $"../LandingRay".is_colliding()
			if body_in_landing:
				get_owner().move_and_collide(get_owner().global_transform.basis.y * 1 * 0.1)
	if Input.is_key_pressed(KEY_DOWN):
		if abs(get_owner().speed - 1) <= SHIP_MAX_SPEED && !get_owner().landing:
			get_owner().speed = get_owner().speed-1
		elif get_owner().landing:
			var body_in_landing = $"../LandingRay".is_colliding()
			if body_in_landing:
				get_owner().move_and_collide(get_owner().global_transform.basis.y * -1 * 0.1)
	if Input.is_key_pressed(KEY_S):
		# rotate_object_local(Vector3(1, 0, 0), TURN_SPEED)
		if !get_owner().landing:
			get_owner().transition_rotate(TURN_SPEED,Vector3(1, 0, 0))
		else:
			get_owner().transition_rotate(delta * (SHIP_TURN_RATE * 10),Vector3(1, 0, 0))
	if Input.is_key_pressed(KEY_W):
		if !get_owner().landing:
			get_owner().transition_rotate(-TURN_SPEED,Vector3(1, 0, 0))
		else:
			get_owner().transition_rotate(-(delta * (SHIP_TURN_RATE * 10)),Vector3(1, 0, 0))
	if Input.is_key_pressed(KEY_A):
		if !get_owner().landing:
			get_owner().transition_rotate(TURN_SPEED,Vector3(0, 1, 0))
		else:
			get_owner().transition_rotate(delta * (SHIP_TURN_RATE * 10),Vector3(0, 1, 0))
	if Input.is_key_pressed(KEY_D):
		if !get_owner().landing:
			get_owner().transition_rotate(-TURN_SPEED,Vector3(0, 1, 0))
		else:
			get_owner().transition_rotate(-(delta * (SHIP_TURN_RATE * 10)),Vector3(0, 1, 0))
	if Input.is_key_pressed(KEY_Q):
		if !get_owner().landing:
			get_owner().transition_rotate(TURN_SPEED,Vector3(0, 0, 1))
		else:
			get_owner().transition_rotate(delta * (SHIP_TURN_RATE * 10),Vector3(0, 0, 1))
			
	if Input.is_key_pressed(KEY_E):
		if !get_owner().landing:
			get_owner().transition_rotate(-TURN_SPEED,Vector3(0, 0, 1))
		else:
			get_owner().transition_rotate(-(delta * (SHIP_TURN_RATE * 10)),Vector3(0, 0, 1))


func get_turn_speed(delta,speed,SHIP_TURN_RATE):
	var TURN_SPEED = 0;
	if abs(speed * SHIP_TURN_RATE) <= SHIP_TURN_RATE * 10:
		TURN_SPEED = delta * abs(speed * SHIP_TURN_RATE)
	else:
		TURN_SPEED = delta * (SHIP_TURN_RATE * 10)

	return TURN_SPEED
				
