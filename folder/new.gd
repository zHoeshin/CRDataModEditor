extends Node

var scene = preload("res://folder/folder.tscn")

func new(globalPath: String,
			localPath: String,
			translationCode: String,
			fileTypes: Array,
			editorScenePath: String,
			type: String,
			watchFolders = false,
			
			nodeParent = null):
	var s = scene.instantiate()
	if nodeParent != null:
		nodeParent.add_child(s)
	s._init_(globalPath, localPath, translationCode, fileTypes, editorScenePath, type, watchFolders)
	return s
