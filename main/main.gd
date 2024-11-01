extends Control

var inEdit: Dictionary = {}
var dir = null

func loadFolder(a: Array):
	var folder = Folder.new(dir + a[0],
						a[0],
						a[1],
						a[2],
						a[3],
						a[4],
						a[5],
						
						$Contents/FilelistScroll/Filelist)
	folder.onFileClicked.connect(fileClicked)
	folder.onFileDeleted.connect(fileDeleted)
	folder.onFileRenamed.connect(fileRenamed)

func fileDeleted(file, filename, type, filetypes):
	var pathnoe: String = StringUtils.trimSuffixes(file, filetypes)
	if !inEdit.has(pathnoe): return
	var editor = inEdit.get(pathnoe)
	editor.queue_free()
	inEdit.erase(pathnoe)

func fileRenamed(file, filename, type, filetypes, newname, newpath):
	var pathnoe: String = StringUtils.trimSuffixes(file, filetypes)
	if !inEdit.has(pathnoe): return
	var editor = inEdit.get(pathnoe)
	editor.name = type + " " + newname
	inEdit.erase(pathnoe)
	var pathnoenew: String = StringUtils.trimSuffixes(newpath, filetypes)
	inEdit[pathnoenew] = editor

func cleanup():
	for file in $Contents/FilelistScroll/Filelist.get_children():
		file.queue_free()
	for file in $Contents/FilesInEdit.get_children():
		file.queue_free()
	inEdit = {}
	dir = null

func fileClicked(path: String, filename: String, editorScenePath, type: String, filetypes: Array):
	var pathnoe = StringUtils.trimSuffixes(path, filetypes)
	if inEdit.has(pathnoe):
		$Contents/FilesInEdit.current_tab = inEdit[pathnoe].get_index()
		return
	var editor = load(editorScenePath).instantiate()
	var opened = false
	for t in filetypes:
		if !FileAccess.file_exists(pathnoe + t):
			continue
		opened = true
		editor.setContents(FileAccess.get_file_as_string(pathnoe + t), t)
		break
	if !opened: return
	inEdit[pathnoe] = editor
	editor.name = type + " " + filename
	editor.file = path
	$Contents/FilesInEdit.add_child(editor)
	$Contents/FilesInEdit.current_tab = editor.get_index()
	$Contents/FilesInEdit.set_tab_icon(editor.get_index(), Icon.PENCIL)
	$Contents/FilesInEdit.set_tab_button_icon(editor.get_index(), Icon.CROSS)
	
	editor.changed.connect(fileChanged)
	editor.fileTypes = filetypes
	
func fileChanged(path, sender):
	$Contents/FilesInEdit.set_tab_icon(sender.get_index(), Icon.CIRCLE)

func fileClosed(tab):
	var editor = $Contents/FilesInEdit.get_tab_control(tab)
	var path = StringUtils.trimSuffixes(editor.file, editor.fileTypes, false)
	if inEdit.has(path) and editor.hasUnsavedChanges:
		$Popups/FileNotSaved.fileTab = editor.get_index()
		$Popups/FileNotSaved.visible = true
		return
	inEdit.erase(path)
	editor.queue_free()

func _process(delta):
	if Input.is_action_just_pressed("ui_save"):
		save_current()

func save_current():
	var editor = $Contents/FilesInEdit.get_current_tab_control()
	var filetypes = editor.fileTypes
	var file = StringUtils.trimSuffixes(editor.file, filetypes, false)
	#if !editor.hasUnsavedChanges: return
	editor.hasUnsavedChanges = false
	for t in filetypes:
		var fa = FileAccess.open(file + t, FileAccess.WRITE)
		fa.store_string(editor.getContents(t))
		fa.close()
	$Contents/FilesInEdit.set_tab_icon(editor.get_index(), Icon.PENCIL)

func saveAll():
	for editor in $Contents/FilesInEdit.get_children():
		var filetypes = editor.fileTypes
		var file = StringUtils.trimSuffixes(editor.file, filetypes, false)
		#if !editor.hasUnsavedChanges: return
		editor.hasUnsavedChanges = false
		for t in filetypes:
			var fa = FileAccess.open(file + t, FileAccess.WRITE)
			fa.store_string(editor.getContents(t))
			fa.close()
		$Contents/FilesInEdit.set_tab_icon(editor.get_index(), Icon.PENCIL)

func hasUnsavedFiles():
	for editor in $Contents/FilesInEdit.get_children():
		if editor.hasUnsavedChanges: return true
	return false
	
func openProject():
	if hasUnsavedFiles():
		$Popups/ProjectNotSaved.cleanupAction = openProject()
		$Popups/ProjectNotSaved.visible = true
		return
	cleanup()
	$Popups/OpenFileOrFolder.show()

func closeProject():
	if hasUnsavedFiles():
		$Popups/ProjectNotSaved.cleanupAction = closeProject()
		$Popups/ProjectNotSaved.visible = true
		return
	cleanup()
	
func tryExit():
	if hasUnsavedFiles():
		$Popups/ProjectNotSaved.cleanupAction = tryExit()
		$Popups/ProjectNotSaved.visible = true
		return
	get_tree().quit()

func openProjectFromFile(file: String):
	file = file.replace("\\", "/")
	var dir = file.get_base_dir().trim_suffix("/")
	var modsdir = dir.get_base_dir().trim_suffix("/") + "/"
	dir += "/"
	Program.setDirs(modsdir, dir)
	loadProject(dir)
	
func openProjectFromFolder(dir: String):
	dir = dir.replace("\\", "/").trim_suffix("/")
	var modsdir = dir.get_base_dir().trim_suffix("/") + "/"
	dir += "/"
	Program.setDirs(modsdir, dir)
	loadProject(dir)

func loadProject(dir: String):
	self.dir = dir
	for foldername in Program.folders.keys():
		var folder = Program.folders[foldername]
		loadFolder(folder)
