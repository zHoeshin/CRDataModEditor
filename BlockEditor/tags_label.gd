extends Button

func _on_pressed():
	$"../tags".visible = !$"../tags".visible
	icon = [Icon.RIGHT, Icon.DOWN][int($"../tags".visible)]
