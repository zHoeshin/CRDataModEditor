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
	"craftingRecipes": [
					"recipes/crafting/",
					"crafting-recipes",
					[".json"],
					"res://CraftingRecipeEditor/CraftingRecipeEditor.tscn",
					"Recipe",
					false
	]
}
var scanners: Dictionary = {
	"blocks": "res://BlockEditor/BlockScanner.gd",
	"items": "res://ItemEditor/ItemScanner.gd",
}
var commonDir: String = ""
var dir: String = ""

var userDefinedDefaultAssetsDir = "user://defaultAssets/"
var defaultAssetsDir = "res://defaultAssets/"
var userDefinedDefaultAssetsDirGlobal

var vars: Dictionary = {}

func _ready():
	userDefinedDefaultAssetsDirGlobal = ProjectSettings.globalize_path(userDefinedDefaultAssetsDir)
	
	#var contents = FileAccess.get_file_as_string("user://settings.json")
	#vars = JSON.parse_string(contents)


func getAssetPath(path: String, tryBase = true):
	path = path.replace(":", "/")
	if FileAccess.file_exists(commonDir + path):
		return commonDir + path
	if FileAccess.file_exists(userDefinedDefaultAssetsDir + path):
		return userDefinedDefaultAssetsDir + path
	if FileAccess.file_exists(defaultAssetsDir + path):
		return defaultAssetsDir + path
	if tryBase: return getAssetPath("base:" + path, false)
	else: return null

func filePathToAssetPath(path: String):
	path = path.replace("\\", "/")
	if path.begins_with(commonDir):
		return path.trim_prefix(commonDir)
	if path.begins_with(userDefinedDefaultAssetsDirGlobal):
		return path.trim_prefix(userDefinedDefaultAssetsDirGlobal)
	return ""

func setDirs(commonDir: String, dir: String):
	self.commonDir = commonDir
	self.dir = dir
	ModelManager.dir = commonDir
	TextureManager.dir = commonDir

func scan():
	ThingPreviewer.popup_window = true
	ThingPreviewer.borderless = true
	ThingPreviewer.size = Vector2.ZERO
	ThingPreviewer.visible = true
	for k in scanners.keys():
		var scannerscript = scanners[k]
		var n = Node.new()
		n.set_script(load(scannerscript))
		for folder in [defaultAssetsDir, userDefinedDefaultAssetsDir, commonDir]:
			var namespaces = DirAccess.get_directories_at(folder)
			for ns in namespaces:
				var thingsfolder = folder + ns + "/" + k
				n.scan(thingsfolder)
	await RenderingServer.frame_post_draw
	ThingPreviewer.visible = false
	ThingPreviewer.borderless = false
	ThingPreviewer.size = Vector2(512, 278)
	ThingPreviewer.popup_window = false

func cleanup():
	setDirs("", "")
	ThingPreviewer.cleanup()
