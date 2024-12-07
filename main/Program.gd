extends Node

var folders = {
	"blocks": [
					"blocks/",
					"blocks",
					[".json"],
					"res://BlockEditor/BlockEditor.tscn",
					"Block",
					false
				],
	"blockEvents": [
					"block_events/",
					"block-events",
					[".crbel", ".json"],
					"res://CRBELEditor/CRBELEditor.tscn",
					"Block Event",
					false
				],
	"items": [
					"items/",
					"items",
					[".json"],
					"res://ItemEditor/ItemEditor.tscn",
					"Item",
					false
				],
}

var commonDir
var dir

var userDefinedDefaultAssetsDir = "user://defaultAssets/"
var defaultAssetsDir = "res://defaultAssets/"

func getAssetPath(path: String, tryBase = true):
	path = path.replace(":", "/")
	if FileAccess.file_exists(commonDir + path):
		return commonDir + path
	if FileAccess.file_exists(userDefinedDefaultAssetsDir + path):
		return userDefinedDefaultAssetsDir + path
	if FileAccess.file_exists(defaultAssetsDir + path):
		return defaultAssetsDir + path
	if tryBase: return getAssetPath("base:" + path, false)
	else: return ""
	

func setDirs(commonDir: String, dir: String):
	self.commonDir = commonDir
	self.dir = dir
	ModelManager.dir = commonDir
	TextureManager.dir = commonDir
