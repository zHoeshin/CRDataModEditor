extends Node

func scan(folder: String):
	folder = folder.replace("\\", "/").trim_suffix("/") + "/"
	var files = DirAccess.get_files_at(folder)
	for file in files:
		var contents = FileAccess.get_file_as_string(folder + file)
		var data = JSON.parse_string(contents)
		if data == null: continue
		if !data.has("itemProperties"):
			continue
		var texture = data["itemProperties"].get("texture", "")
		var id = data.get("id", "")
		ThingPreviewer.removeGroup(id)
		ThingPreviewer.addThing(id, "", texture, false, true)
