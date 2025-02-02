extends Window

var things: Dictionary = {}
var thingsqueue: Array = []

var thingInFocus = null

var ThingPreview3D = preload("res://TringPreviewer/ThingPreview3D.tscn")
var ThingPreview2D = preload("res://TringPreviewer/ThingPreview2D.tscn")
var controllerScript: Script = preload("res://TringPreviewer/thing.gd")

signal selected(id)
var callOnSelect = []

const thingsize = Vector2(48, 48)

#func _ready():
#	for i in 15:
#		addThing("blah:test", "{i}".format({"i": i}), "t", i % 2 == 0)

func cleanup():
	for k in things.keys():
		removeGroup(k)

func _on_close_requested():
	callOnSelect.clear()
	visible = false

func _on_visibility_changed():
	pass

func addThing(id: String, params: String, preview: String, is3d: bool = true, isItem: bool = false, queue: bool = false):
	if id == "" or id == null: return false
	if not things.has(id):
		things[id] = {}
	var previewer: Control
	#if is3d:
	#	previewer = ThingPreview3D.instantiate()
	#else: previewer = ThingPreview2D.instantiate()
	var controller: Button = Button.new()
	previewer = ThingPreview2D.instantiate()
	var t
	if is3d:
		t = ModelManager.setRenderTo2D(preview, previewer, thingsize)
		controller.add_child(t)
	else:
		previewer.setThing(preview)
	previewer.setSize(thingsize)
	if previewer.has_method("setShift"):
		previewer.setShift(Vector2(0, 0))
	#controller.flat = true
	previewer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controller.custom_minimum_size = thingsize
	controller.set_script(controllerScript)
	var fullid = id
	if params != null and !isItem:
		fullid += "[" + params + "]"
	controller.id = fullid
	controller.tooltip_text = fullid
	#controller.pressed.connect(controller._pressed)
	controller.clicked.connect(_selected)
	controller.add_child(previewer)
	previewer.name = "_"
	things[id][normalizeParams(params)] = controller
	things[id][0] = isItem
	$ScrollContainer/things.add_child(controller)
	if t != null:
		await RenderingServer.frame_post_draw
		if t != null:
			t.queue_free()
	
func removeGroup(id):
	if !things.has(id): return
	for k in things[id].keys():
		if typeof(k) == TYPE_INT: continue
		things[id][k].queue_free()
	things.erase(id)

func removeThing(id, params):
	if !things.has(id): return
	if !things[id].has(params): return
	things[id][params].queue_free()

func _selected(id):
	#visible = false
	for c in callOnSelect:
		c.call(id)
	callOnSelect.clear()
	selected.emit(id)

func normalizeParams(params: String):
	var parr: Array = params.split(",", false)
	parr.sort()
	var pnorm = ",".join(parr)
	return pnorm
	
func getPreviewTexture(id, params):
	if id == "#TAG":
		return Icon.TAG
	params = normalizeParams(params) if params != null else ""
	var c = things.get(id)
	if c == null: return
	return c[params].get_node("_").getTexture()

func connectSelected(callable: Callable):
	callOnSelect.push_back(callable)
