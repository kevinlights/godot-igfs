extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Texture) var star_texture setget set_star_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_star_texture(texture):
	var material = ResourceLoader.load("res://Components/Star/Material.tres");
	# print(material.emission_texture)
	material.emission_texture = texture
