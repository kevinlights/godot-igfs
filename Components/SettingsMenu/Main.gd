extends PopupMenu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var config = ConfigFile.new()
var err = config.load("res://settings.cfg")

# Called when the node enters the scene tree for the first time.

func _process(delta):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	setNodes()
	addConnections()

func addConnections():
	get_node("VBoxContainer/Fullscreen").connect("toggled", self, "fullscreenPressed")
	get_node("VBoxContainer/V-sync").connect("toggled", self, "vsyncPressed")
	get_node("VBoxContainer/GlowHDR").connect("toggled", self, "glowHDRPressed")
	get_node("VBoxContainer/MotionBlur").connect("toggled", self, "motionBlurPressed")
	get_node("VBoxContainer/AntiAliasing").connect("item_selected", self, "antiAliasingChanged")
	get_node("VBoxContainer/FPS").connect("item_selected", self, "FPSChanged")

func setNodes():
	get_node("VBoxContainer/Fullscreen").pressed = OS.window_fullscreen
	get_node("VBoxContainer/V-sync").pressed = OS.vsync_enabled;
	get_node("VBoxContainer/GlowHDR").pressed = config.get_value("settings","GlowHDR",false);
	get_node("VBoxContainer/MotionBlur").pressed = config.get_value("settings","MotionBlur",false);
	get_node("VBoxContainer/AntiAliasing").add_item("Disabled",0)
	get_node("VBoxContainer/AntiAliasing").add_item("2x",2)
	get_node("VBoxContainer/AntiAliasing").add_item("4x",4)
	get_node("VBoxContainer/AntiAliasing").add_item("8x",8)
	get_node("VBoxContainer/AntiAliasing").add_item("16x",16)
	get_node("VBoxContainer/AntiAliasing").select(get_viewport().msaa)

	get_node("VBoxContainer/FPS").add_item("30",30)
	get_node("VBoxContainer/FPS").add_item("60",60)
	get_node("VBoxContainer/FPS").add_item("75",75)
	get_node("VBoxContainer/FPS").add_item("144",144)

	var fps = ProjectSettings.get_setting("debug/settings/fps/force_fps");
	var fps_index = 0
	if fps == 30:
		fps_index = 0
	elif fps == 60:
		fps_index = 1
	elif fps == 75:
		fps_index = 2
	elif fps == 144:
		fps_index = 3
	get_node("VBoxContainer/FPS").select(fps_index)
	

func resize(size):
	OS.window_resizable = true;
	OS.set_window_size(size)
	get_viewport().set_size_override(true, size)
	# Not setting viewport size with this has the Aliens scene still acting like it's 800x450
	#--> Player can move outside of window, can't move around fully in shown window
	#OS.center_window() #centers properly
	OS.window_borderless = false #doesn't go from borderless to bordered
	OS.window_fullscreen = true
	yield(get_tree().create_timer(0.1), "timeout")
	OS.window_fullscreen = false
	

func fullscreenPressed(state):
	print("fullscreenPressed: " + str(state))
	OS.window_fullscreen = state
	if not state:
		resize(Vector2(1280, 720))
	else:
		get_viewport().set_size_override(true, Vector2(1920, 1080))
		OS.set_window_size(Vector2(1920, 1080))
		OS.window_resizable = false
		OS.window_borderless = true 

func vsyncPressed(state):
	print("vsyncPressed: " + str(state))
	OS.vsync_enabled = state
	#persist
	ProjectSettings.set_setting("display/window/vsync/use_vsync",state)
	ProjectSettings.save()

func glowHDRPressed(state):
	print("glowHDRPressed: " + str(state))
	var enviroment;
	if state == true:
		enviroment = ResourceLoader.load("res://Scenes/Game/Environments/GlowAndAutoExposure.tres");
	else:
		enviroment = ResourceLoader.load("res://Scenes/Game/Environments/Performance.tres");
	
	config.set_value("settings","GlowHDR",state)
	config.save("res://settings.cfg")
	if get_tree().get_root().has_node("Game/WorldEnvironment"):
		get_tree().get_root().get_node("Game/WorldEnvironment").set_environment(enviroment)

func motionBlurPressed(state):
	print("motionBlurPressed: " + str(state))
	
	config.set_value("settings","MotionBlur",state)
	config.save("res://settings.cfg")
	get_node("RestartPopup").popup()

func antiAliasingChanged(id):
	print("antiAliasingChanged: " + str(id))
	get_viewport().msaa = id
	#persist
	ProjectSettings.set_setting("rendering/quality/filters/msaa",id)
	ProjectSettings.save()

func FPSChanged(id):
	var fps_options = [30,60,75,144]
	print("FPSChanged: " + str(fps_options[id]))
	ProjectSettings.set_setting("debug/settings/fps/force_fps",fps_options[id])
	ProjectSettings.save()
	get_node("RestartPopup").popup()
