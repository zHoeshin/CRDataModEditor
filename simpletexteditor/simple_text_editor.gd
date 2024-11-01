extends TextEdit

var file
var hasUnsavedChanges = false
var fileTypes

signal changed(file, sender)

func getContents(filetype):
	return text

func setContents(content: String):
	text = content

func onChange():
	hasUnsavedChanges = true
	changed.emit(file, self)
