extends KinematicBody

#Declarations
var _initial_position;
var load_ship_type_ref;
var _heat_interval;
var health;
var landing;
var speed;

export(int) var ship = 0

puppet var slave_position = Transform(Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0))

########################
var settings_location = "res://settings.cfg"
var config = ConfigFile.new()

onready var TransitionHandler = get_node("/root/Game/TransitionHandler")
#signals
signal position(content) 

#exports
# export(int) var ship;

func _ready():

	# print(get_node("/root/Game"))
#    set_physics_process(true)
#    set_gravity_scale(1)
	_initial_position = get_global_transform().origin
	setFuncrefs()
	setDefaultValues()
	initConfig()
	addConnections()
	addListeners()
	load_ship_type(config.get_value("ship_info","ship",0))
	yield( get_tree().create_timer(0.5), "timeout" )
	if is_network_master():
		get_node("Camera").set_current(true)
	else:
		print("is not network master")
		load_ship_type(ship)
	

func setFuncrefs():
	load_ship_type_ref = funcref(self, "load_ship_type")

func setDefaultValues():
	_heat_interval = false
	health = 100
	landing = false
	speed = 0

func initConfig():
	config.load(settings_location)#returns error, is there is one

func addListeners():
	EventManager.listen("ship_type_change",load_ship_type_ref)

func removeListeners():
	EventManager.ignore("ship_type_change",load_ship_type_ref)

func addConnections():
	get_node("HeatArea").connect("body_entered", self, "heat_body_enter")
	get_node("HeatArea").connect("body_exited", self, "heat_body_exit")

func load_ship_type(type):
	# var ship_config = ConfigFile.new()
	# var err = ship_config.load("res://Components/SpaceShip/S"+str(type)+".cfg")
	# SHIP_TURN_RATE = ship_config.get_value("ship_info","turn_rate",0.1)
	# SHIP_MAX_SPEED = ship_config.get_value("ship_info","max_speed",250) 
	# SHIP_TURN_RATE = 
	var shipImport = load("res://Components/SpaceShip/S"+str(type)+".tscn").instance()
	for child in get_children():
		if child.is_in_group("ShipPart"):
			remove_child(child)
			child.queue_free()
	
	call_deferred("add_child",shipImport)
	for child in shipImport.get_children():
		shipImport.remove_child(child)
		call_deferred("add_child",child)
		# child.set_name("ShipPart" + child.get_name())
		child.add_to_group("ShipPart")
	shipImport.queue_free()

func _enter_tree():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	pass

func _exit_tree():
	removeListeners()

func _process(delta):
	if is_network_master():
		var SHIP_TURN_RATE = ShipInfo.ships[ShipInfo.ship].turn_rate
		var SHIP_MAX_SPEED = ShipInfo.ships[ShipInfo.ship].max_speed

		var collisionInfo = move_and_slide(global_transform.basis.z * -1 * speed)
		
		# rpc_unreliable("update_position",get_tree().get_network_unique_id(),{"coords":translation,"rotation":get_rotation()})
		var emit_position;
		if get_node("LandingRay").is_colliding():
			var landing_distance = translation.y - get_node("LandingRay").get_collision_point().y;
			emit_position = {"coords":translation,"rotation":get_rotation(),"health":health,"speed":speed,"landing":{"possible":true,"distance":landing_distance,"doing":landing}}
		else:
			emit_position = {"coords":translation,"rotation":get_rotation(),"health":health,"speed":speed,"landing":{"possible":false}}

		emit_signal("position",emit_position)

		if (health <= 0):
			reset_ship()

		if get_slide_count():
			if abs(speed) > 30:
				crash()
		
		var TURN_SPEED = get_turn_speed(delta,speed,SHIP_TURN_RATE)
		# var SHIP_TURN_RATE_RECIP = 1/SHIP_TURN_RATE
		
		if speed > SHIP_MAX_SPEED:
			speed = SHIP_MAX_SPEED

		# print("self position:")
		# print(get_global_transform())
		rset_unreliable('slave_position', get_global_transform())
	else:
		# print("slave position:")
		# print(slave_position)
		set_global_transform(slave_position)
			

master func reset_ship():
	set_translation(_initial_position)
	speed = 0
	landing = false
	set_rotation(Vector3(0, 0, 0))
	yield( get_tree().create_timer(0.05), "timeout" )
	health = 100

master func crash():
	health = 0
	EventManager.emit("message",{"text":"Crashed!"})


master func heat_body_enter(body):
	if body.get_groups().has("star"):
		_heat_interval = true
		while ( _heat_interval == true ):
			yield( get_tree().create_timer(0.05), "timeout" )
			health = health - 1
			# print(health)

master func heat_body_exit(body):
	_heat_interval = false

master func transition_rotate(speed,vector):
	var rotate_transiton = TransitionHandler.transition(speed,0,100,1.07)
	for amount in rotate_transiton:
		rotate_object_local(vector, amount)
		yield( get_tree().create_timer(0.05), "timeout" )

master func stop_ship():
	if speed != 0:
		var speed_power;
		#1.07 is max exponent
		# 252.5/abs(speed) calculates exponent proportional to speed, so if speed is slower, then it will slow down faster
		speed_power = 252/abs(speed)
		if speed_power > 1.07:
			speed_power = 1.07
		elif speed_power < 1.006:
			speed_power = 1.006
			
		print_debug(speed)
		print_debug(speed_power)
		var speed_transition = TransitionHandler.transition(speed,0,100,speed_power)
		var speed_time = 0.01
		# print(speed_transition)
		for amount in speed_transition:
			if abs(amount) > 1.09:
				speed = amount
				yield( get_tree().create_timer(speed_time), "timeout" )
			else:
				speed = 0
				return

master func get_turn_speed(delta,speed,SHIP_TURN_RATE):
	var TURN_SPEED = 0;
	if abs(speed * SHIP_TURN_RATE) <= SHIP_TURN_RATE * 10:
		TURN_SPEED = delta * abs(speed * SHIP_TURN_RATE)
	else:
		TURN_SPEED = delta * (SHIP_TURN_RATE * 10)

	return TURN_SPEED
	

master func bullet_hit():
	print_debug("bullet detected")
