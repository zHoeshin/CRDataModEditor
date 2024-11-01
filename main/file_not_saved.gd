extends AcceptDialog

var fileTab: int = -1

func _ready():
	add_button("Discard", true, "discard")
	add_cancel_button("Cancel")

func cancel():
	return

func discard(_unused):
	if fileTab == -1: return
	var editor = $"../../Contents/FilesInEdit".get_tab_control(fileTab)
	if editor == null: return
	$"../..".inEdit.erase(StringUtils.trimSuffixes(editor.file, editor.fileTypes, false))
	editor.queue_free()
	visible = false
	fileTab = -1

func confirm():
	$"../..".save_current()
	if fileTab == -1: return
	var editor = $"../../Contents/FilesInEdit".get_tab_control(fileTab)
	if editor == null: return
	$"../..".inEdit.erase(StringUtils.trimSuffixes(editor.file, editor.fileTypes, false))
	editor.queue_free()

func close():
	return
