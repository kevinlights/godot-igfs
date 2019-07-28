extends StaticBody

export(Texture) var planet_texture setget set_planet_texture
# export(Number) var planet_radius setget set_planet_radius

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_planet_texture(texture):
	# var material = ResourceLoader.load("res://Components/Planet/materials/material.tres");
	var material = get_node("MeshInstance").get_surface_material(0).duplicate()
	# print(material.emission_texture)
	material.albedo_texture = texture

	get_node("MeshInstance").set_surface_material(0,material)
	

func set_planet_radius(radius):
	pass
