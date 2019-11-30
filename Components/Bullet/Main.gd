extends KinematicBody

puppet var slave_position = Transform(Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0))
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_network_master():
		EventManager.emit("register_bullet",{id=self.name,owner=get_tree().get_network_unique_id()})
		yield(get_tree().create_timer(5.0), "timeout")
		queue_free()
		EventManager.emit("unregister_bullet",{id=self.name})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_network_master():
		var speed = 5
		var collision = move_and_collide(global_transform.basis.z * -1 * speed)

		if collision:
			print_debug(collision)
			collision.collider.rpc("bullet_hit")
			queue_free()
			EventManager.emit("unregister_bullet",{id=self.name})
		
		rset_unreliable('slave_position', get_global_transform())
	else:
		set_global_transform(slave_position)
		# print("slave bullet position:" + str(slave_position))
