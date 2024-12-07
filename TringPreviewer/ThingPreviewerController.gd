extends Window

func _on_close_requested():
	print("closed")
	visible = false


func _on_visibility_changed():
	print(visible)
