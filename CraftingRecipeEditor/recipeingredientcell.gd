extends Button

var id = ""
var istag = false

var inFocus = false

func setItem(id):
	self.id = id

func  _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
				clearThing()
			if event.button_index == MOUSE_BUTTON_MASK_LEFT:
				pressed()

func pressed():
	if inFocus:
		ThingPreviewer.show()
		ThingPreviewer.position = global_position + Vector2(0, 64)
		ThingPreviewer.connectSelected(changeThing)
		return
	else:
		inFocus = true
		if $"../../..".infocus != null:
			$"../../..".infocus.inFocus = false
		$"../../..".infocus = self
		grab_focus()
		if istag:
			$"../../properties/condition".visible = true
			$"../../properties/condition/expr".text = id
		else:
			$"../../properties/condition".visible = false
		return

func changeThing(newthing):
	ThingPreviewer.visible = false
	istag = false
	$"../../..".setItem(("recipe/{c}" if name != "r" else "r/r").format({"c": name}), newthing)
	if newthing == "#TAG":
		id = ""
		istag = true
		tooltip_text = ""
		if $"../../..".infocus == self:
			$"../../properties/condition".visible = true
	else:
		if $"../../..".infocus == self:
			$"../../properties/condition".visible = false
	$"../../..".changed.emit()

func clearThing():
	id = ""
	istag = false
	tooltip_text = ""
	if $"../../..".infocus == self:
		$"../../properties/condition".visible = false
	$"../../..".changed.emit()
	$_.clearThing()

func _on_focus_exited():
	if $"../../..".infocus == self:
		$"../../..".infocus = null
	inFocus = false
