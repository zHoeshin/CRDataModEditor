extends Control

func setThing(texture: String, rotation: int = 0):
	if texture == null: return
	var i = TextureManager.getTexture(texture)
	$TextureRect.texture = i

func setTexture(texture):
	$TextureRect.texture = texture

func getTexture():
	return $TextureRect.texture

func clearThing():
	$TextureRect.texture = null

func setRotation(rotation: int):
	$TextureRect.rotation_degrees = rotation

func setSize(size: Vector2):
	$TextureRect.size = size

func setShift(shift: Vector2):
	$TextureRect.position = shift
