extends Node

var scene = preload("res://file/file.tscn")

func new(path: String, name: String, dirpath: String, icon):
	var i = scene.instantiate()
	i._init_(path, name, dirpath, icon)
	return i
