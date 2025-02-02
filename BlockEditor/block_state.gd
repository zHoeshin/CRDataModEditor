extends VBoxContainer

const defaults = {
	"langKey" = "",
	"modelName" = "",
	"swapGroupId" = "",
	"blockEventsId" = "",
	"dropId" = "",
	"allowSwapping" = true,
	"isOpaque" = true,
	"canRaycastForBreak" = true,
	"canRaycastForPlaceOn" = true,
	"canRaycastForReplace" = false,
	"catalogHidden" = false,
	"walkthrough" = false,
	"isFluid" = false,
	"lightAttenuation" = 15,
	"lightLevelRed" = 0,
	"lightLevelGreen" = 0,
	"lightLevelBlue" = 0,
	"rotXZ" = 0,
	"hardness" = 1.5,
	"blastResistance" = 100,
	"friction" = 1,
	"dropParams" = {},
}
var unusedProperties = {}

var _model

signal onChange()

func setProperty(property, value):
	if property == "lightLevelRed":
		$wrapper/properties/light/color.color.r8 = value * 17
		return
	if property == "lightLevelGreen":
		$wrapper/properties/light/color.color.g8 = value * 17
		return
	if property == "lightLevelBlue":
		$wrapper/properties/light/color.color.b8 = value * 17
		return
	var propnode = $wrapper/properties.get_node(property)
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

func getProperties():
	var result = {}
	for node in $wrapper/properties.get_children():
		var property = node.name
		var type = node.get_meta("type")
		if type == null: continue
		var propval = getProperty(property)
		if property == "light":
			if propval.r != defaults["lightLevelRed"]:
				result["lightLevelRed"] = propval.r8 / 17
			if propval.g != defaults["lightLevelGreen"]:
				result["lightLevelGreen"] = propval.g8 / 17
			if propval.b != defaults["lightLevelBlue"]:
				result["lightLevelBlue"] = propval.b8 / 17
			continue
		elif propval == defaults[property]: continue
		elif typeof(propval) == TYPE_DICTIONARY:
			if len(propval.keys()) == 0: continue
		if property != "light":
			result[property] = propval
	#result["tags"] = $wrapper/other/tags.text.split("\n")
	#result["stateGenerators"] = $wrapper/other/stateGenerators.text.split("\n")
	return result

func setProperties(properties):
	for property in properties.keys():
		var value = properties[property]
		if property == "lightLevelRed":
			$wrapper/properties/light/color.color.r8 = value * 17
			continue
		if property == "lightLevelGreen":
			$wrapper/properties/light/color.color.g8 = value * 17
			continue
		if property == "lightLevelBlue":
			$wrapper/properties/light/color.color.b8 = value * 17
			continue
		var node = $wrapper/properties.get_node_or_null(property)
		if node == null and not node in ["tags", "stateGenerators"]:
			unusedProperties[property] = value
		else:
			setProperty(property, value)
	#for node in $wrapper/properties.get_children():
		#var property = String(node.name)
		#if !defaults.has(property): continue
		#setProperty(property, properties.get(property, defaults[property]))
		

func getProperty(property):
	var propnode = $wrapper/properties.get_node(NodePath(property))
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
	return null

func getParams():
	return $name/params.text

func setParams(params):
	if typeof(params) == TYPE_DICTIONARY:
		var o: String = ""
		for key in params.keys():
			o += "{key}={param},".format({key = key, param = params[key]})
		$name/params.text = o.substr(0, len(o) - 2)	
	elif typeof(params) == TYPE_STRING:
		$name/params.text = params

func changed(_unused = null):
	onChange.emit()

func setName(blockId):
	$name/name.text = blockId

func getWhole():
	var properties = getProperties().merged(unusedProperties)
	var tags = Array($wrapper/other/tags.text.split("\n", false)).filter(func(e): return len(e) > 0)
	if len(tags) > 0:
		properties.merge({"tags": tags}, true)
	var stateGenerators = Array($wrapper/other/stateGenerators.text.split("\n", false)).filter(func(e): return len(e) > 0)
	if len(stateGenerators) > 0:
		properties.merge({"stateGenerators": stateGenerators}, true)
	return [getParams(), properties]

func setWhole(params: String, properties: Dictionary):
	setParams(params)
	setProperties(properties)
	$wrapper/other/tags.text = "\n".join(properties.get("tags", []))
	$wrapper/other/stateGenerators.text = "\n".join(properties.get("stateGenerators", []))
	#var modelLoadThread = Thread.new()
	#modelLoadThread.start(loadModel.bind(properties.get("modelName")))
	loadModel(properties["modelName"])

func loadModel(path):
	#_model = ModelManager.getModelScene(path)
	#$wrapper/icon/SubViewportContainer/SubViewport.add_child(_model)
	"""var meshes = ModelManager.getModelMeshes(path)
	if meshes == null or not len(meshes):
		$wrapper/icon/SubViewportContainer/SubViewport/Unknown.visible = true
		$wrapper/icon/SubViewportContainer/SubViewport/Empty.visible = false
		return
	$wrapper/icon/SubViewportContainer/SubViewport/Unknown.visible = false
	$wrapper/icon/SubViewportContainer/SubViewport/Empty.visible = true
	for m in meshes:
		$wrapper/icon/SubViewportContainer/SubViewport/Empty/container.add_child(m.duplicate())
	"""
	$wrapper/icon/ThingPreview3d.setThing(path)
	
func _on_dropparamslabel_pressed():
	toggleDictFold($wrapper/properties/dropParams)

func toggleDictFold(wrapper):
	var s = wrapper.get_node("dict").visible
	wrapper.get_node("dict").visible = !s
	wrapper.get_node("labelwrapper/ellipsis").text = ["{", "{ ... }"][int(s)]
	wrapper.get_node("labelwrapper/name").icon = [
		Icon.DOWN, Icon.RIGHT
	][int(s)]


func model_changed(model = null):
	"""if model == null:
		model = $wrapper/properties/modelName/string.text
	if $wrapper/icon/SubViewportContainer/SubViewport/Empty/container != null:
		$wrapper/icon/SubViewportContainer/SubViewport/Empty/container.queue_free()
		await $wrapper/icon/SubViewportContainer/SubViewport/Empty/container.tree_exited
	var c = Node3D.new()
	$wrapper/icon/SubViewportContainer/SubViewport/Empty.add_child(c)
	c.name = "container"
	c.rotation_degrees.y = $wrapper/properties/rotXZ/int.value * 90
	loadModel(model)"""
	if model == null: return
	$wrapper/icon/ThingPreview3d.setThing(model, $wrapper/properties/rotXZ/int.value)


func _on_rotxz_value_changed(value):
	$wrapper/icon/ThingPreview3d.setRotation(value)

func selectModel():
	var picker: FileDialog = $wrapper/properties/modelName/selectModel
	picker.current_dir = Program.commonDir + "models/blocks/"
	picker.visible = true

func modelSelected(path: String):
	var model = Program.filePathToAssetPath(path)
	$wrapper/properties/modelName/string.text = model
	loadModel(model)
	changed()
