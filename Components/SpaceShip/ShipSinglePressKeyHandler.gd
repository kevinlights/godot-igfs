extends Node

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
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_R:
            get_owner().reset_ship()
        if event.pressed and event.scancode == KEY_L:
            var body_in_landing = $"../LandingRay".is_colliding()
            # print(body_in_landing)
            if body_in_landing:
                get_owner().stop_ship()
                # landing = !landing
                get_owner().set("landing",!get_owner().get("landing"))
            else:
                get_owner().set("landing",false)
        if event.pressed and event.scancode == KEY_O:
            get_owner(). stop_ship()
