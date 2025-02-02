extends Control

var file
var hasUnsavedChanges = false
var fileTypes
var blockstatescene = preload("res://BlockEditor/blockState.tscn")
signal changed(file, sender)

var unusedFields = {}

func getContents(filetype: String):
	var blockstates = getBlockstates()
	var id = $propertiesWrapper/properties/commonInfo/name/value.text
	
	ThingPreviewer.removeGroup(id)
	for blockstate in blockstates.keys():
		var model = blockstates[blockstate].get("modelName", "")
		if !blockstates[blockstate].get("catalogHidden", false):
			ThingPreviewer.addThing(id, blockstate, model, true, false)
	
	return JSON.stringify({
		"stringId": id,
		"blockStates": blockstates
	}.merged(unusedFields), "    ", false)
	
func getBlockstates():
	var blockstates = {}
	for blockstate in $propertiesWrapper/properties/blockStates.get_children():
		var data = blockstate.getWhole()
		var paramsarr = data[0].replace(" ", "").split(",")
		paramsarr.sort()
		var params = ",".join(paramsarr)
		var properties = data[1]
		blockstates[params] = properties
	return blockstates

func setContents(content: String, filetype: String):
	if filetype != ".json": return
	var c = JSON.parse_string(content)
	if c == null: return
	if !c.has("stringId"): return
	$propertiesWrapper/properties/commonInfo/name/value.text = c["stringId"]
	for field in c.keys():
		if field in ["blockStates", "stringId"]: continue
		unusedFields[field] = c[field]
	if !c.has("blockStates"): return
	for blockstate in c["blockStates"].keys():
		var stateid = blockstate
		var state = c["blockStates"][blockstate]
		var statenode = blockstatescene.instantiate()
		$propertiesWrapper/properties/blockStates.add_child(statenode)
		statenode.setName(c["stringId"])
		statenode.setWhole(stateid, state)
		statenode.onChange.connect(onChange)
	pass

func onChange(_unused = null):
	hasUnsavedChanges = true
	changed.emit(file, self)

func addEmptyBlockState():
	var statenode = blockstatescene.instantiate()
	$propertiesWrapper/properties/blockStates.add_child(statenode)
