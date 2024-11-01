extends VBoxContainer
class_name DictionaryInput

signal onChange()

func addPair():
	var wrapper = HBoxContainer.new()
	var name = LineEdit.new()
	name.name = "name"
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.text_changed.connect(changed)
	var value = LineEdit.new()
	value.name = "value"
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.text_changed.connect(changed)
	var label = Label.new()
	label.text = ":"
	var delete = Button.new()
	delete.flat = true
	delete.icon = Icon.BIN
	var deleteHandler = SimplePartialApplicator.new(onDelete, wrapper)
	delete.pressed.connect(deleteHandler.invoke)
	wrapper.set_meta("deleteHandler", deleteHandler)
	wrapper.add_child(name)
	wrapper.add_child(label)
	wrapper.add_child(value)
	wrapper.add_child(delete)
	$pairs.add_child(wrapper)
	return wrapper

func onDelete(node):
	node.get_meta("deleteHandler", null).queue_free()
	node.queue_free()
	changed()

func changed(_unusaed = null):
	onChange.emit()

func getRaw():
	var result = {}
	for pair in $pairs.get_children():
		var name = pair.get_node("name").text
		var value = pair.get_node("value").text
		result[name] = value
	return result

func setRaw(values: Dictionary):
	for key in values.keys():
		var value = values[key]
		var newpair = addPair()
		newpair.get_node("name").text = key
		newpair.get_node("value").text = value
