extends Panel

var recipescene = preload("res://CraftingRecipeEditor/CraftingRecipe.tscn")
var hasUnsavedChanges = false
var file
var fileTypes

signal changed(file, sender)
func onChange(_unused = null):
	hasUnsavedChanges = true
	changed.emit(file, self)

func setContents(contents, filetype: String):
	var data = JSON.parse_string(contents)
	if data == null: return
	for recipe in data.get("recipes", []):
		var rscene = recipescene.instantiate()
		rscene.setRecipe(recipe)
		rscene.changed.connect(onChange)
		$ScrollContainer/wrapper/recipes.add_child(rscene)

func getContents(filetype: String):
	var data = {"recipes": []}
	for recipe in $ScrollContainer/wrapper/recipes.get_children():
		data["recipes"].append(recipe.getRecipe())
	#return null
	return JSON.stringify(data, "    ", false)


func newrecipe():
	var rscene = recipescene.instantiate()
	rscene.changed.connect(onChange)
	$ScrollContainer/wrapper/recipes.add_child(rscene)
	return rscene
