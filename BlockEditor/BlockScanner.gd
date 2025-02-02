extends Node

func scan(folder: String):
	folder = folder.replace("\\", "/").trim_suffix("/") + "/"
	var files = DirAccess.get_files_at(folder)
	for file in files:
		var contents = FileAccess.get_file_as_string(folder + file)
		var data = JSON.parse_string(contents)
		if data == null:
			printerr("Failed parsing " + folder + file)
			continue
		var id = data.get("stringId", "")
		ThingPreviewer.removeGroup(id)
		for blockstate in data.get("blockStates", []):
			var model = data["blockStates"][blockstate].get("modelName", "")
			if !data["blockStates"][blockstate].get("catalogHidden", false):
				ThingPreviewer.addThing(id, blockstate, model, true, false)
