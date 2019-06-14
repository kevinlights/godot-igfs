extends PopupMenu

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            print("esc")
            self.visible = !self.visible