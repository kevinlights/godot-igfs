extends KinematicBody

var _initial_position
var _initial_rotation
var _rot_x = 0
var _rot_y = 0
var _rot_z = 0
var _heat_interval = false
var health = 100
var landing = false
# change to ship in storage
# var SHIP_TURN_RATE = 0.1

var config = ConfigFile.new()
var err = config.load("res://settings.cfg")

var SHIP_TURN_RATE = config.get_value("ship_info","turn_rate",0.1)
var SHIP_MAX_SPEED = config.get_value("ship_info","max_speed",250)

signal position(content) 

var speed = 0

func _ready():
#    set_physics_process(true)
#    set_gravity_scale(1)
    _initial_position = get_global_transform().origin
    _initial_rotation = get_global_transform().basis
    addConnections()

func addConnections():
    get_node("HeatArea").connect("body_entered", self, "heat_body_enter")
    get_node("HeatArea").connect("body_exited", self, "heat_body_exit")

func _enter_tree():
    # Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
    pass

func _exit_tree():
    # Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
    pass

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_R:
            reset_ship()
        if event.pressed and event.scancode == KEY_L:
            var body_in_landing = get_node("LandingRay").is_colliding()
            # print(body_in_landing)
            if body_in_landing:
                speed = 0
                landing = !landing
            else:
                landing = false
            

func _process(delta):
    var collisionInfo = move_and_slide(global_transform.basis.z * -1 * speed)
    emit_signal("position",{"coords":translation,"rotation":get_rotation(),"health":health,"speed":speed}) 
    # rpc_unreliable("update_position",get_tree().get_network_unique_id(),{"coords":translation,"rotation":get_rotation()})

    if (health <= 0):
        reset_ship()

    if get_slide_count():
        if abs(speed) > 30 && !landing:
            crash()

    var TURN_SPEED = 0
    # var SHIP_TURN_RATE_RECIP = 1/SHIP_TURN_RATE
    if abs(speed * SHIP_TURN_RATE) <= SHIP_TURN_RATE * 10:
        TURN_SPEED = delta * abs(speed * SHIP_TURN_RATE)
    else:
        TURN_SPEED = delta * (SHIP_TURN_RATE * 10)

    if Input.is_key_pressed(KEY_UP):
        if speed + 1 <= SHIP_MAX_SPEED && !landing:
            speed = speed + 1
        elif landing:
            var body_in_landing = get_node("LandingRay").is_colliding()
            if body_in_landing:
                move_and_collide(global_transform.basis.y * 1 * 0.1)
    if Input.is_key_pressed(KEY_DOWN):
        if abs(speed - 1) <= SHIP_MAX_SPEED && !landing:
            speed = speed - 1
        elif landing:
            var body_in_landing = get_node("LandingRay").is_colliding()
            if body_in_landing:
                move_and_collide(global_transform.basis.y * -1 * 0.1)
    if Input.is_key_pressed(KEY_S):
        rotate_object_local(Vector3(1, 0, 0), TURN_SPEED)
        _rot_x += TURN_SPEED
    if Input.is_key_pressed(KEY_W):
        rotate_object_local(Vector3(1, 0, 0), -TURN_SPEED)
        _rot_x -= TURN_SPEED
    if Input.is_key_pressed(KEY_A):
        if !landing:
            rotate_object_local(Vector3(0, 1, 0), TURN_SPEED)
            _rot_y += TURN_SPEED
        else:
            rotate_object_local(Vector3(0, 1, 0), delta * (SHIP_TURN_RATE * 10))
            _rot_y += delta * (SHIP_TURN_RATE * 10)
    if Input.is_key_pressed(KEY_D):
        if !landing:
            rotate_object_local(Vector3(0, 1, 0), -TURN_SPEED)
            _rot_y -= TURN_SPEED
        else:
            rotate_object_local(Vector3(0, 1, 0), -(delta * (SHIP_TURN_RATE * 10)))
            _rot_y -= delta * (SHIP_TURN_RATE * 10)
    if Input.is_key_pressed(KEY_Q):
        rotate_object_local(Vector3(0, 0, 1), TURN_SPEED)
        _rot_z += TURN_SPEED
    if Input.is_key_pressed(KEY_E):
        rotate_object_local(Vector3(0, 0, 1), -TURN_SPEED)
        _rot_z -= TURN_SPEED
    if Input.is_key_pressed(KEY_O):
        speed = 0

func reset_ship():
    set_translation(_initial_position)
    speed = 0
    set_rotation(Vector3(0, 0, 0))
    yield( get_tree().create_timer(0.05), "timeout" )
    health = 100
# func _integrate_forces(state):
    # var a = state.get_transform().basis
    # set_linear_velocity(Vector3(a.x.z, a.y.z, -a.z.z) * speed)
    # if Input.is_key_pressed(KEY_Z):
    #     set_linear_velocity(Vector3(1,1,1) * 0.00001)
    #     set_angular_velocity(Vector3(1,1,1) * 0.00001)

    # move_and_slide(Vector3(a.x.z, a.y.z, -a.z.z) * speed)

func crash():
    # print("crashed")
    # global_event_bus.publish("message",{"text":"Crashed!"})
    # emit_signal("message","crashed")
    health = 0
    EventManager.emit("message",{"text":"Crashed!"})
    # get_node("../Message/Message").set_text("Crashed")
    # emit_signal("message","Crashed")
    # print(get_node("../Message/Message"))
    # emit_signal("message","Crashed")
    
    # THIS WAS THE PROBLEM
    # get_tree().reload_current_scene()


func heat_body_enter(body):
    if body.get_groups().has("star"):
        _heat_interval = true
        while ( _heat_interval == true ):
            yield( get_tree().create_timer(0.05), "timeout" )
            health = health - 1
            # print(health)

func heat_body_exit(body):
    _heat_interval = false
