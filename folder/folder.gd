extends VBoxContainer

var path: String
var lpath: String

var fileTypes: Array

var watchFolders = false

var watcher: DirectoryWatcher

var filesList: Dictionary = {}
var namesList: Dictionary

var editor: String
var type: String

@onready var files = $fileswrapper/files
@onready var namenode = $control/name

signal onFileClicked(file, filename, editor, type, filetypes)
signal onFileDeleted(file, filename, type, filetypes)
signal onFileRenamed(file, filename, type, filetypes, newname, newpath)

func _init_(globalPath: String,
			localPath: String,
			translationCode: String,
			fileTypes: Array,
			editorScenePath: String,
			type: String,
			watchFolders = false):
	
	if !DirAccess.dir_exists_absolute(globalPath):
		DirAccess.make_dir_absolute(globalPath)
	
	self.type = type
	editor = editorScenePath
	
	path = globalPath
	lpath = localPath
	self.fileTypes = fileTypes
	
	namenode.text = lpath
	
	watcher = DirectoryWatcher.new()
	watcher.add_scan_directory(globalPath)
	self.watchFolders = watchFolders
	
	watcher.files_created.connect(filesAdded)
	watcher.files_deleted.connect(filesDeleted)
	
	add_child(watcher)
	
	loadDir()

func loadDir():
	var d = DirAccess.open(path)
	if d != null: filesAdded(d.get_files())

func filesAdded(files: Array[String]):
	for f in files:
		var fname = f.get_file()
		var n; var t
		var temp = StringUtils.trimSuffixes(fname, fileTypes, true)
		n = temp[0]; t = temp[1]
		if t == null: continue
		if n in namesList: continue
		namesList[n] = f
		var fnode = File.new(f, n, path, Icon.CIRCLE)
		filesList[f] = fnode
		self.files.add_child(fnode)
		fnode.clicked.connect(fileClicked)
		fnode.deleted.connect(fileDeleted)
		fnode.renameD.connect(fileRenamed)
	sortChildren()

func filesDeleted(files: Array):
	for f in files:
		var fname = f.get_file()
		var n; var t
		var temp = StringUtils.trimSuffixes(fname, fileTypes, true)
		n = temp[0]; t = temp[1]
		if t == null: continue
		if not n in namesList: continue
		var p = namesList[n]
		if fileTypes.find(t) < fileTypes.find(StringUtils.trimSuffixes(p, fileTypes, true)[1]):
			continue
		filesList[p].queue_free()
		namesList.erase(n)
		filesList.erase(p)
		onFileDeleted.emit(fname, StringUtils.trimSuffixes(fname.get_file(), fileTypes), t, fileTypes)
	sortChildren()
	
	
func fileClicked(file, filename):
	onFileClicked.emit(file, filename, editor, type, fileTypes)

func fileDeleted(file, filename):
	onFileDeleted.emit(file, filename, type, fileTypes)
	for type in fileTypes:
		DirAccess.remove_absolute(file + type)

func fileRenamed(file, filename, newname, newpath):
	onFileRenamed.emit(file, filename, type, fileTypes, newname, newpath)
	for type in fileTypes:
		DirAccess.rename_absolute(file + type, newpath + type)

func _on_expand_pressed():
	files.visible = !files.visible
	namenode.icon = [Icon.RIGHT, Icon.DOWN][int(files.visible)]

func _exit_tree():
	if watcher != null:
		watcher.queue_free()

func sortChildren(_unused: Node = null):
	var nodes = $fileswrapper/files.get_children()
	nodes.sort_custom(
		func(a: Node, b: Node): return a._name.naturalnocasecmp_to(b._name) < 0
	)
	for node in nodes:
		$fileswrapper/files.remove_child(node)
	for node in nodes:
		$fileswrapper/files.add_child(node)


func addFilePressed():
	$newfile.visible = true
	$newfile/name.grab_focus()

func addFileCleanup():
	$newfile.visible = false

func addFileConfirm(filename):
	for type in fileTypes:
		if FileAccess.file_exists(path + filename + type):
			return
	for type in fileTypes:
		DirAccess.make_dir_recursive_absolute(path)
		var dummy = FileAccess.open(path + filename + type, FileAccess.WRITE)
		if dummy != null:
			dummy.close()
	addFileCleanup()
	sortChildren()

func addFileCancel(_unused = null):
	addFileCleanup()
