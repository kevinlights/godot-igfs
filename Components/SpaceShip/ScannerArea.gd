extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	send_scanner_bodies()

func send_scanner_bodies():
	var overlapping_bodies = get_overlapping_bodies()
	var processed_bodies = []


	for body in overlapping_bodies:
		var position = Vector2(body.get_global_transform().origin.x, body.get_global_transform().origin.z)
		var self_position2d = Vector2(get_global_transform().origin.x, get_global_transform().origin.z)
		var combined_position = Vector2(self_position2d.x - position.x, self_position2d.y - position.y)
		# print(position)
		var name = body.get_name()
		var groups = body.get_groups() 
		# DEFAULT
		var type = "star"

		for group in groups:
			if group.find("scanner_") > -1:
				type = group.replace("scanner_","")

		var size = 1
		# (scanner viewer width / scanner area width) / texture image size
		var constant_of_sprite_scale = (200/10000)/20
		if body.get_node("CollisionShape"):
			var shape = body.get_node("CollisionShape").shape
			if shape is SphereShape:
				size = (shape.radius)*0.001
				print_debug(size)
		
		processed_bodies.append({
			"position": combined_position,
			"name":name,
			"type":type,
			"size":size
		})
		# print(name)

	# print(processed_bodies)
	EventManager.emit("scanner_bodies", processed_bodies)
