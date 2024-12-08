extends Control

const defaults = {
	"texture": "",
	"modelType": "",
	"stackLimit": 1000,
	"toolSpeed": 1,
	"durability": 0,
	"fuelTicks": 0,
	"effectiveBreakingTags": []
}
var unusedProperties = {}

var file
var hasUnsavedChanges = false
var fileTypes
signal changed(file, sender)

func _ready():
	$wrapper/wrapper/ThingPreview2D.setSize(
		$wrapper/wrapper/ThingPreview2D.custom_minimum_size - Vector2(32, 32)
	)

func setProperty(property, value):
	var propnode = $wrapper/wrapper/properties.get_node(property)
	if propnode == null: return
	var type = propnode.get_meta("type")
	if type == null: return
	var valnode = propnode.get_node(type)
	match type:
		"int":
			valnode.value = value
		"float":
			valnode.value = value
		"color":
			valnode.color = value
		"boolean":
			valnode.button_pressed = value
		"string":
			valnode.text = value
		"dict":
			valnode.setRaw(value)
		"str[]":
			valnode.text = "\n".join(value)

func getProperties():
	var result = {}
	for node in $wrapper/wrapper/properties.get_children():
		var property = node.name
		var type = node.get_meta("type")
		if type == null: continue
		var propval = getProperty(property)
		if propval == defaults[property]: continue
		result[property] = propval
	return result

func setProperties(properties):
	for property in properties.keys():
		var value = properties[property]
		var node = $wrapper/wrapper/properties.get_node_or_null(property)
		if node == null and not node in ["tags", "stateGenerators"]:
			unusedProperties[property] = value
		else:
			setProperty(property, value)

func getProperty(property):
	var propnode = $wrapper/wrapper/properties.get_node(NodePath(property))
	if propnode == null: return
	var type = propnode.get_meta("type")
	if type == null: return
	var valnode = propnode.get_node(type)
	match type:
		"int":
			return valnode.value
		"float":
			return valnode.value
		"color":
			return valnode.color
		"boolean":
			return valnode.button_pressed
		"string":
			return valnode.text
		"dict":
			return valnode.getRaw()
		"str[]":
			return Array(valnode.text.split("\n", false)).filter(func(e): return len(e) > 0)
	return null

func getContents(filetype: String):
	return JSON.stringify({
		"id": $wrapper/id/id.text,
		"itemProperties": getProperties(),
	}, "    ", false)
	
func setContents(content: String, filetype: String):
	if filetype != ".json": return
	var c = JSON.parse_string(content)
	if c == null: return
	if !c.has("id"): return
	$wrapper/id/id.text = c["id"]
	setProperties(c.get("itemProperties", {}))
	setTexture(c.get("itemProperties", {}).get("texture", ""))

func modelTypeChanged(index):
	$wrapper/properties/modelType/string.text = ["base:item3D", "base:item2D"][index]
	onChange()

func onChange(_unused = null):
	hasUnsavedChanges = true
	changed.emit(file, self)

func setTexture(newtexture):
	$wrapper/wrapper/ThingPreview2D.setThing(newtexture)
