extends CodeEdit

var file
var hasUnsavedChanges = false
var fileTypes
var shscript = preload("res://CRBELEditor/crbel_syntax.gd")
signal changed(file, sender)

func _ready():
	syntax_highlighter = SyntaxHighlighter.new()
	syntax_highlighter.set_script(shscript)

func getContents(filetype: String):
	#CRBEL.parse(text)
	if filetype == ".json": return JSON.stringify(CRBEL.parse(text), "    ", false)
	return text

func setContents(content: String, filetype: String):
	if filetype == ".json": text = JSONtoCRBEL.convert(content)
	else: text = content

func onChange():
	hasUnsavedChanges = true
	changed.emit(file, self)
