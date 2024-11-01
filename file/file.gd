extends HBoxContainer

var path: String
var dirpath: String
var _name: String

signal clicked(file, name)
signal deleted(file, name)
signal renameD(file, name, newname)

func _init_(path: String, name: String, dirpath: String, icon):
	_name = name
	$name.text = _name
	$editname.text = _name
	self.path = path
	self.dirpath = dirpath

func _on_delete_pressed():
	$delete.visible = false
	$rename.visible = false
	$deleteconfirm.visible = true
	$deletecancel.visible = true
	
func _on_delete_cleanup():
	$delete.visible = true
	$rename.visible = true
	$deleteconfirm.visible = false
	$deletecancel.visible = false

func _on_deleteconfirm_pressed():
	_on_delete_cleanup()
	deleted.emit(dirpath + _name, _name)

func _on_deletecancel_pressed():
	_on_delete_cleanup()


func onPressed():
	clicked.emit(dirpath + _name, _name)

func _on_rename_pressed():
	$name.visible = false
	$editname.visible = true
	$editname.grab_focus()

func _on_editname_text_change_rejected(_unused = null):
	$name.visible = true
	$editname.visible = false
	$editname.text = _name

func _on_editname_text_submitted(newname):
	$name.visible = true
	$editname.visible = false
	renameD.emit(dirpath + _name, _name, newname, dirpath + newname)
