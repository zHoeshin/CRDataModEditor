extends Node3D


func _ready():
	var model = ModelManager.getModelScene("eerie:models/blocks/wallpaper.json")
	
	add_child(model)
	return
