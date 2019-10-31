extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(5.0), "timeout")
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var speed = -0.1
	var collision = move_and_collide(global_transform.basis.z * -1 * speed)

	if collision:
		print_debug(collision)
		collision.collider.rpc("bullet_hit")
		queue_free()
