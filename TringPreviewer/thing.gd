extends Button

var id = "#TAG"

var inFocus = false

signal clicked(id)
signal clickedOnce(id)

func _ready():
	var focusstylebox = StyleBoxFlat.new()
	focusstylebox.content_margin_bottom = -1
	focusstylebox.content_margin_top = -1
	focusstylebox.content_margin_left = 4
	focusstylebox.content_margin_right = 4
	focusstylebox.bg_color = Color(0.451, 0.451, 0.596, 0.4)
	
	add_theme_stylebox_override("focus", focusstylebox)

func _pressed():
	if inFocus:
		inFocus = false
		clicked.emit(id)
		return
	else:
		inFocus = true
		grab_focus()
		clickedOnce.emit(id)
		return
