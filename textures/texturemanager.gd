extends Node

var dir = null
var textures = {}
var empty = preload("res://icon/empty.svg")

func getTexture(path, fresh = false):
	if textures.has(path) and not fresh: return textures[path]
	var image = Image.new()
	var _path = Program.getAssetPath(path)
	var err = image.load(_path)
	if err != OK:
		prints("texture", path, "at", _path, "not found")
		return ImageTexture.create_from_image(empty.duplicate().get_image())
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	textures[path] = texture
	return texture
