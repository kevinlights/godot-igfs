extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
# func _process():
# 	get_node("Position").text = 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Member variables
var viewport = null
var sprite = null
var viewport_sprite = null

# variables for the sprite animation
const MAX_FRAME_FOR_SPRITE = 4
const FRAME_SWITCH_TIME = 0.2
var frame_switch_timer = 0

func _ready():
	addConnections()
	# EventManager.listen("ship_position",funcref(self, "_update_coords"))
	startCubeView()

func addConnections():
	get_node("../SpaceShip").connect("position", self, "_update_coords")

func _update_coords(pos):
	var coords = pos.coords
	var rotation = pos.rotation
	var health = pos.health
	get_node("Coords").text = "x:" + str(round(coords.x)) + " y:" + str(round(coords.y)) + " z:" + str(round(coords.z))
	get_node("Rotation").text = "x:" + str(round(rad2deg(rotation.x))) + " y:" + str(round(rad2deg(rotation.y))) + " z:" + str(round(rad2deg(rotation.z)))
	get_node("Viewport/viewCube").set_rotation(rotation);
	get_node("Health").text = "Health:" + str(health)
	pass

func startCubeView():
	viewport = get_node("Viewport")
	sprite = get_node("Sprite")
	viewport_sprite = get_node("Viewport_Sprite")

	# Assign the sprite's texture to the viewport texture
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	viewport_sprite.texture = viewport.get_texture()
	set_process(true)

func _process(delta):
	frame_switch_timer += delta
	if frame_switch_timer >= FRAME_SWITCH_TIME:
		frame_switch_timer -= FRAME_SWITCH_TIME
		sprite.frame += 1
	if sprite.frame > MAX_FRAME_FOR_SPRITE:
		sprite.frame = 0
