extends Control

onready var ScannerSprite = preload("res://Components/ScannerSprite/ScannerSprite.tscn")

var config = ConfigFile.new()
var err = config.load("res://settings.cfg")

var SHIP_MAX_SPEED = config.get_value("ship_info","max_speed",250)


var update_scanner_bodies_ref = funcref(self, "update_scanner_bodies")


func _ready():
	addConnections()
	addListeners()
	# EventManager.listen("ship_position",funcref(self, "_update_coords"))
	# startCubeView()
	get_node("SpeedProgress").max_value = SHIP_MAX_SPEED

func _exit_tree():
	removeListeners()

func addConnections():
	get_node("../SpaceShip").connect("position", self, "_update_coords")

func addListeners():
	EventManager.listen("scanner_bodies",update_scanner_bodies_ref)

func removeListeners():
	EventManager.ignore("scanner_bodies",update_scanner_bodies_ref)

func _update_coords(pos):
	var coords = pos.coords
	var rotation = pos.rotation
	var health = pos.health
	var speed = pos.speed
	var landing = pos.landing
	get_node("PositionBG/Coords").text = "x:" + str(round(coords.x)) + " y:" + str(round(coords.y)) + " z:" + str(round(coords.z))
	get_node("PositionBG/Rotation").text = "x:" + str(round(rad2deg(rotation.x))) + " y:" + str(round(rad2deg(rotation.y))) + " z:" + str(round(rad2deg(rotation.z)))
	get_node("ScannerBG/ScannerViewer").rotation = rotation.y
	get_node("Viewport/viewCube").set_rotation(rotation);
	get_node("PositionBG/HealthProgress").value = health
	get_node("Speed").text = str(round(speed)) + " um/s"
	get_node("SpeedProgress").value = abs(speed)
	if landing.possible:
		get_node("LandingIcon").icon = "chevron-down-circle-outline"
		get_node("LandingIcon").add_color_override("font_color", Color("#4caf50"))
		get_node("LandingIcon/Label").visible = true
		get_node("LandingIcon/Label").text = str(round(landing.distance));
		if landing.doing:
			get_node("LandingIcon").icon = "chevron-down-circle"
	else:
		get_node("LandingIcon").icon = "chevron-down-circle-outline"
		get_node("LandingIcon").add_color_override("font_color", Color("#ffffff"))
		get_node("LandingIcon/Label").visible = false
	pass

func update_scanner_bodies(bodies):
	for child in get_node("ScannerViewport").get_children():
		child.queue_free()
	
	for body in bodies:
		# print(body)
		var sprite = ScannerSprite.instance()
		get_node("ScannerViewport").add_child(sprite)
		sprite.position.x = (body.position.x / 40.96) + 100
		sprite.position.y = (body.position.y / 40.96) + 100
		sprite.name = body.name
		# print(sprite.position)
