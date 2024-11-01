extends AcceptDialog

var cleanupAction

func _ready():
	add_button("Discard", true, "discard")
	add_cancel_button("Cancel")

func cancel():
	return

func discard(_unused):
	cleanupAction.call()

func confirm():
	$"../..".save_all()
	cleanupAction.call()

func close():
	return
