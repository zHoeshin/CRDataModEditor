extends VBoxContainer

var infocus = null

signal changed()

func getRecipe():
	var shapeless = $wrapper/properties/shapeless/bool.button_pressed
	if shapeless: return getShapeless()
	return getShaped()

func getShapeless():
	var ingredients = {"tag": {}, "lit": {}}
	for c in 9:
		var p = "recipe/{c}".format({"c": c+1})
		var thing = $wrapper.get_node(p).id
		if thing == null or thing == "":
			continue
		var istag = $wrapper.get_node(p).istag
		ingredients["tag" if istag else "lit"][thing] =\
		ingredients["tag" if istag else "lit"].get(thing, 0) + 1
	#prints("iii", ingredients)
	var recipe = {
		"inputs": [],
		"output": {
			"item": $wrapper/r/r.id,
			"amount": $wrapper/properties/HBoxContainer/int.value
		}
	}
	for t in ingredients["tag"]:
		var c: Dictionary = PredicateProcesser.compile(t, func(s): return {"has_tag": s})
		recipe["inputs"].push_back(c.merged({
			"amount": ingredients["tag"][t]
		}))
	for t in ingredients["lit"]:
		recipe["inputs"].push_back({
			t: ingredients["lit"][t]
		})
	#print(recipe)
	return recipe
	
func getShaped():
	var ingredients = {"tag": {}, "lit": {}}
	for c in 9:
		var p = "recipe/{c}".format({"c": c+1})
		var thing = $wrapper.get_node(p).id
		if thing == null or thing == "":
			continue
		var istag = $wrapper.get_node(p).istag
		if !ingredients["tag" if istag else "lit"].has(thing):
			ingredients["tag" if istag else "lit"][thing] = []
		ingredients["tag" if istag else "lit"][thing].append(c)
	
	var s = ["   ", "   ", "   "]
	var i = 0
	var a = "abcdefghi"
	var inputs = {}
	for id in ingredients["lit"]:
		var cells = ingredients["lit"][id]
		inputs[a[i]] = id
		for cell in cells:
			s[cell / 3][cell % 3] = a[i]
		i += 1
	for id in ingredients["tag"]:
		var cells = ingredients["tag"][id]
		var c: Dictionary = PredicateProcesser.compile(id, func(s): return {"has_tag": s})
		inputs[a[i]] = c
		for cell in cells:
			s[cell / 3][cell % 3] = a[i]
		i += 1
	if $wrapper/properties/crop/bool.button_pressed:
		s = crop(s)
	var recipe = {
		"pattern": s,
		"inputs": inputs,
		"output": {
			"item": $wrapper/r/r.id,
			"amount": $wrapper/properties/HBoxContainer/int.value
		}
	}
	#print(recipe)
	return recipe

func crop(pattern:):
	pattern = pattern.duplicate()
	var top = len(pattern) - 1
	var bottom = 0
	while len(pattern) and bottom < len(pattern) and Array(pattern[bottom].split("")).all(func(e): return e == " "):
		bottom += 1
	while len(pattern) and top > 0 and Array(pattern[top].split("")).all(func(e): return e == " "):
		top -= 1
	var leftl = []
	var rightl = []
	for line in pattern:
		leftl.push_back(line.length() - line.lstrip(" ").length())
		rightl.push_back(line.length() - line.rstrip(" ").length())
	var left = leftl.min()
	var right = rightl.min()
	for i in len(pattern):
		pattern[i] = pattern[i].substr(left, len(pattern[i])-left-right)
	return pattern.slice(bottom, top + 1)

func setRecipe(recipe):
	#print(recipe)
	match typeof(recipe.get("inputs", {})):
		TYPE_ARRAY:
			setShapeless(recipe)
		_:
			setShaped(recipe)

func setShapeless(recipe):
	$wrapper/properties/crop.visible = false
	var ingredients = []
	var inputs = recipe.get("inputs", [])
	for input in inputs:
		if input.has("and")||input.has("not")||\
		input.has("or")||input.has("has_tag"):
			var t = stringifyCondition(input, true)
			for c in t[1]:
				ingredients.append([1, t[0]])
		else:
			for c in input[input.keys()[0]]:
				ingredients.append([0, input.keys()[0]])
	
	for c in min(9, len(ingredients)):
		var cell = c + 1
		var p = "recipe/{c}".format({"c": cell})
		var t = ingredients[c]
		if t[0] == 0:
			setItem(p, t[1])
		else:
			$wrapper.get_node(p + "/_").setTexture(Icon.TAG)
			$wrapper.get_node(p).id = t[1]
			$wrapper.get_node(p).istag = true
			$wrapper.get_node(p).tooltip_text = t[1]
		
	setItem("r/r", recipe["output"]["item"])
	$wrapper/properties/HBoxContainer/int.value = recipe["output"]["amount"]
	$wrapper/properties/shapeless/bool.button_pressed = true

	getShapeless()
	

func setShaped(recipe):
	#print("shaped")
	if !recipe.has("pattern"): return
	for r in len(recipe["pattern"]):
		var row = recipe["pattern"][r]
		for c in len(row):
			var itemchar = row[c]
			if itemchar == " ": continue
			var cell = r * 3 + c + 1
			var item = recipe.get("inputs", {}).get(itemchar, null)
			if typeof(item) == TYPE_STRING:
				setItem("recipe/{c}".format({"c": cell}), item)
			else:
				var p = "recipe/{c}".format({"c": cell})
				var cond = stringifyCondition(item)
				$wrapper.get_node(p + "/_").setTexture(Icon.TAG)
				$wrapper.get_node(p).id = cond
				$wrapper.get_node(p).istag = true
				$wrapper.get_node(p).tooltip_text = cond
			
	setItem("r/r", recipe["output"]["item"])
	$wrapper/properties/HBoxContainer/int.value = recipe["output"]["amount"]
	$wrapper/properties/shapeless/bool.button_pressed = false

func setItem(path, itemid):
	var spl = itemid.split("[", true, 1)
	var id = spl[0]
	var params = null
	if len(spl) > 1:
		params = spl[1].substr(0, len(spl[1]) - 1)
	var texture = ThingPreviewer.getPreviewTexture(id, params)
	$wrapper.get_node(path + "/_").setTexture(texture)
	$wrapper.get_node(path).id = itemid
	$wrapper.get_node(path).tooltip_text = itemid

func stringifyCondition(condition, returnamount = false):
	var amount = condition.get("amount", 1)
	condition.erase("amount")
	var c = condition.keys()[0]
	var r = PredicateProcesser.parse(condition, {
		"has_tag": func(tag): return tag
	})
	#print(c, r)
	if returnamount:
		return [r, amount]
	return r

func conditionChanged(newcond):
	if infocus == null: return
	infocus.id = newcond
	infocus.istag = true
	infocus.tooltip_text = newcond
	changed.emit()


func delete():
	changed.emit()
	queue_free()


func shapeless_toggled(shapeless):
	changed.emit()
	$wrapper/properties/crop.visible = !shapeless
