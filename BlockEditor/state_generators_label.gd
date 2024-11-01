extends Button

func _on_pressed():
	$"../stateGenerators".visible = !$"../stateGenerators".visible
	icon = [Icon.RIGHT, Icon.DOWN][int($"../stateGenerators".visible)]
