extends Node

const Bullet = preload("res://Components/Bullet/Bullet.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if is_network_master():
		if event is InputEventKey:
			if event.pressed and event.scancode == KEY_SPACE:
				print_debug("shoot pressed")
				shoot()

func shoot():
	var bullet = Bullet.instance()
	bullet.set_network_master(get_tree().get_network_unique_id())
	get_node("/root/Game").add_child(bullet)
	# var speed = 50
	
	bullet.set_global_transform(get_owner().get_global_transform())

	bullet.translate(Vector3(0,0,-10))
		
	# bullet.translate(bullet.global_transform.basis.z * -1 * speed)
	# print_debug(collision)
	# if collision:
	# 	bullet.queue_free()
