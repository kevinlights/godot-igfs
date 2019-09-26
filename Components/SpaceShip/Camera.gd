extends Camera

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var config = ConfigFile.new()
var err = config.load("res://settings.cfg")

var motion_blur_resource = preload("res://motion_blur/motion_blur.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	if config.get_value("settings","MotionBlur",false) == true:
		var motion_blur = motion_blur_resource.instance()
		add_child(motion_blur)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
