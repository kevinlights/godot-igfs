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
    get_node("ScannerArea").connect("body_entered", self, "scanner_body_enter")
    get_node("ScannerArea").connect("body_exited", self, "scanner_body_exit")

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
        if event.pressed and event.scancode == KEY_O:
            var speed_power;
            #1.07 is max exponent
            # 252.5/abs(speed) calculates exponent proportional to speed, so if speed is slower, then it will slow down faster
            if 252.5/abs(speed) < 1.07:
                speed_power = 252.5/abs(speed)
            else:
                speed_power = 1.07
            
            var speed_transition = transition(speed,0,100,speed_power)
            var speed_time = 0.01
            # print(speed_transition)
            for amount in speed_transition:
                if abs(amount) > 1.09:
                    speed = amount
                    yield( get_tree().create_timer(speed_time), "timeout" )
                else:
                    speed = 0
                    return
            

func _process(delta):
    var collisionInfo = move_and_slide(global_transform.basis.z * -1 * speed)
    
    # rpc_unreliable("update_position",get_tree().get_network_unique_id(),{"coords":translation,"rotation":get_rotation()})
    var emit_position;
    if get_node("LandingRay").is_colliding():
        var landing_distance = translation.y - get_node("LandingRay").get_collision_point().y;
        emit_position = {"coords":translation,"rotation":get_rotation(),"health":health,"speed":speed,"landing":{"possible":true,"distance":landing_distance,"doing":landing}}
    else:
        emit_position = {"coords":translation,"rotation":get_rotation(),"health":health,"speed":speed,"landing":{"possible":false}}

    emit_signal("position",emit_position) 

    send_scanner_bodies()

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
        # rotate_object_local(Vector3(1, 0, 0), TURN_SPEED)
        transition_rotate(TURN_SPEED,Vector3(1, 0, 0))
        _rot_x += TURN_SPEED
    if Input.is_key_pressed(KEY_W):
        # rotate_object_local(Vector3(1, 0, 0), -TURN_SPEED)
        transition_rotate(-TURN_SPEED,Vector3(1, 0, 0))
        _rot_x -= TURN_SPEED
    if Input.is_key_pressed(KEY_A):
        if !landing:
            # rotate_object_local(Vector3(0, 1, 0), TURN_SPEED)
            transition_rotate(TURN_SPEED,Vector3(0, 1, 0))
            _rot_y += TURN_SPEED
        else:
            rotate_object_local(Vector3(0, 1, 0), delta * (SHIP_TURN_RATE * 10))
            _rot_y += delta * (SHIP_TURN_RATE * 10)
    if Input.is_key_pressed(KEY_D):
        if !landing:
            # rotate_object_local(Vector3(0, 1, 0), -TURN_SPEED)
            transition_rotate(-TURN_SPEED,Vector3(0, 1, 0))
            _rot_y -= TURN_SPEED
        else:
            rotate_object_local(Vector3(0, 1, 0), -(delta * (SHIP_TURN_RATE * 10)))
            _rot_y -= delta * (SHIP_TURN_RATE * 10)
    if Input.is_key_pressed(KEY_Q):
        transition_rotate(TURN_SPEED,Vector3(0, 0, 1))
            
    if Input.is_key_pressed(KEY_E):
        transition_rotate(-TURN_SPEED,Vector3(0, 0, 1))

func reset_ship():
    set_translation(_initial_position)
    speed = 0
    set_rotation(Vector3(0, 0, 0))
    yield( get_tree().create_timer(0.05), "timeout" )
    health = 100

func crash():
    health = 0
    EventManager.emit("message",{"text":"Crashed!"})


func heat_body_enter(body):
    if body.get_groups().has("star"):
        _heat_interval = true
        while ( _heat_interval == true ):
            yield( get_tree().create_timer(0.05), "timeout" )
            health = health - 1
            # print(health)

func heat_body_exit(body):
    _heat_interval = false

func send_scanner_bodies():
    var overlapping_bodies = get_node("ScannerArea").get_overlapping_bodies()
    var processed_bodies = []


    for body in overlapping_bodies:
        var position = Vector2(body.get_global_transform().origin.x, body.get_global_transform().origin.z)
        var self_position2d = Vector2(get_global_transform().origin.x, get_global_transform().origin.z)
        var combined_position = Vector2(self_position2d.x - position.x, self_position2d.y - position.y)
        # print(position)
        var name = body.get_name()
        processed_bodies.append({
            "position": combined_position,
            "name":name
        })
        # print(name)

    # print(processed_bodies)
    EventManager.emit("scanner_bodies", processed_bodies)


func scanner_body_enter(body):
    # print("enter: " + str(body))
    pass

func scanner_body_exit(body):
    # print("exit: " + str(body))
    pass


func transition(start,end,amount,power):
    var res = []
    for i in range(amount - 1):
        res.append(0)

    res[0] = start

    if start > 0 && start > 1:
        for index in res.size():
            if index != 0:
                res[index] = pow(res[index - 1],1/power)
    elif start > 0 && start < 10:
        for index in res.size():
            if index != 0:
                res[index] = pow(res[index - 1],power)
    elif start < 0 && start < -1:
        for index in res.size():
            if index != 0:
                res[index] = pow(abs(res[index - 1]),1/power) * -1
    elif start < 0 && start > -1:
        for index in res.size():
            if index != 0:
                res[index] = pow(abs(res[index - 1]),power) * -1
    
    
        
    res.append(end)
    return res

func transition_rotate(speed,vector):
    var rotate_transiton = transition(speed,0,100,1.07)
    for amount in rotate_transiton:
        rotate_object_local(vector, amount)
        yield( get_tree().create_timer(0.05), "timeout" )