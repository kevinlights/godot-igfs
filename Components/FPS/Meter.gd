extends CenterContainer

func _ready():
	pass

func _process(delta):
	if delta > 0:
		get_node("Meter").text = str(round(1 / delta)) + " FPS"