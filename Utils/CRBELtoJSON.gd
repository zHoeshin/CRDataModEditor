extends Node

const TType = {
	Symbol = 1,
	Int = 2,
	ID = 3,
	Keyword = 4,
	ERROR = -1,
	Name = 5,
	Action = 6,
	ActionSubType = 7,
	Sep = 8,
	NO = 9,
	NewLine = 10,
	Comment = 11,
	Dict = 12,
}

const colors = {
	TType.ERROR: {"color": Color(1, 0, 0)},
	TType.Symbol: {"color": Color(0.252, 0.252, 0.252)},
	TType.Int: {"color": Color(1, 0.337, 0.157)},
	TType.ID: {"color": Color(0.892, 0.9, 0.765)},
	TType.Keyword: {"color": Color(0.76, 0.312, 0.76)},
	TType.Name: {"color": Color(0.464, 0.95, 0.555)},
	TType.Action: {"color": Color(0.1, 0.338, 1)},
	TType.ActionSubType: {"color": Color(0.741, 0.22, 0.964)},
	TType.Sep: {"color": Color(0.84, 0.151, 0.289)},
	TType.NO: {"color": Color.WHITE},
	TType.Comment: {"color": Color(0.32, 0.32, 0.32)},
	TType.Dict: {"color": Color(0.902, 0.677, 0)}
}

var keywords: Array = ["name", "inherit", "trigger"]
var actions: Array = ["explode", "drop", "place", "set", "grow", "leaf_decay", "run_trigger", "increment_param", "play"]
var actionSubType = [false, true, false, true, true, false, false, false, false]
var sep = ["to", "with", "from", "by", "at", "normals"]

const strtoactid = {
  "explode": "base:explode",
  "grow base:tree_coconut": "base:grow_tree_coconut",
  "grow base:tree_poplar": "base:grow_tree_poplar",
  "drop item": "base:item_drop",
  "leaf_decay": "base:leaf_decay",
  "drop loot": "base:loot_drop",
  "play": "base:play_sound_3d",
  "set block": "base:replace_block_state",
  "run_trigger": "base:run_trigger",
  "set cube": "base:set_cuboid",
  "set cuboid": "base:set_cuboid",
  "set sphere": "base:set_sphere",
  "sphere segment": "base:set_spherical_segment",
  "increment_param": "base:increment_param",
  "set params": "base:set_block_state_params"
}


var whitespaceA: RegEx = RegEx.new()
var whitespaceP: RegEx = RegEx.new()
var digits: String = "0123456789"
var whitespace: String = " \t"
var comments: String = "#;"
const symbols = "{},"

func tokenize(r: String, removeComments = true, _singleunitdict = false):
	if len(r) <= 0: return []
	var tokens: Array = []
	# token = {value: String, pos: int, type: int}
	var i: int = 0
	var c: String = ""
	while i < len(r):
		if r[i] in whitespace:
			i += 1; continue
		if r[i] == "\n":
			tokens.append({value = "", pos = i, type = TType.NewLine})
		elif r[i] in symbols:
			tokens.append({value = r[i], pos = i, type = TType.Symbol})
			i += 1; continue
		elif r[i] in digits or r[i] in "+-":
			var s = i
			var v = r[i]
			i += 1
			while i < len(r) and ((r[i] in digits) or (r[i] == ".")):
				v += r[i]
				i += 1
			i -= 1
			tokens.append({value = v, pos = s, type = TType.Int})
		elif r[i] in comments:
			var s = i
			var v = ""
			while i < len(r):
				if r[i] == "\n": break
				v += r[i]
				i += 1
			i -= 1
			if !removeComments:
				tokens.append({value = v, pos = s, type = TType.Comment})
		else:
			var s = i
			var v = ""
			var bc = 0
			var cbc = 0
			while i < len(r):
				if r[i] in whitespace:
					i += 1
					break
				if r[i] == "\n":
					i += 1
					break
				if r[i] in symbols:
					if (r[i] == ",") and (bc <= 0) and (cbc <= 0):
						i += 1
						break
					elif not r[i] in ",":
						i += 1
						break
				if r[i] == "[": bc += 1
				if r[i] == "]": bc -= 1
				if r[i] == "{": cbc += 1
				if r[i] == "}": cbc -= 1
				v += r[i]
				i += 1
			i -= 1
			tokens.append({value = v, pos = s, type = TType.ID})
		i += 1
	return tokens

func convert(raw):
	var value = {"triggers": {}}
	
	var tokens = tokenize(raw, true, true)
	
	var i: int = 0
	var t: Dictionary = {}
	while i < len(tokens):
		t = tokens[i]
		if t.type != TType.ID:
			#return "Error parsing file {i}: {t} expected to be an identifier".format({t = t, i = i})
			i += 1; continue
			
		if t.value.strip_edges() == "name":
			if i + 1 >= len(tokens):
				return "Error parsing file: expected name"
			value["stringId"] = tokens[i + 1].value.strip_edges()
			i += 2; continue
		if t.value.strip_edges() == "inherit":
			if i + 1 >= len(tokens):
				return "Error parsing file: expected parent"
			value["parent"] = tokens[i + 1].value.strip_edges()
			i += 2; continue
		
		if t.value.strip_edges() == "trigger":
			if i + 3 >= len(tokens):
				return "Error parsing file: expected trigger name and body"
			var tname = tokens[i + 1].value.strip_edges()
			value["triggers"][tname] = []
			if (tokens[i + 2].type != TType.Symbol) or\
				(tokens[i + 2].value.strip_edges() != "{"):
				return "Error parsing file: expected trigger body"
			i += 4
			var s = i - 2
			var b = 1
			while i < len(tokens):
				t = tokens[i]
				if (tokens[i].type == TType.Symbol):
					if (tokens[i].value.strip_edges() == "{"):
						b += 1
					if (tokens[i].value.strip_edges() == "}"):
						b -= 1
				if b == 0:
					break
				i += 1
			var tbody = tokens.slice(s + 1, i - 1)
			var actionstokens = []
			var a = []
			for T in tbody:
				if (T.type == TType.NewLine) and len(a) > 0:
					actionstokens.append(a)
					a = []
				else: a.append(T)
			if len(a): actionstokens.append(a)
			actions = []
			for alist in actionstokens:
				var action = {}
				var ai = 0
				if alist[ai].type == TType.NewLine:
					ai += 1
				if ai >= len(alist):
					continue
				if alist[ai].type == TType.Symbol:
					continue
				var id = ""
				if(strtoactid.has(alist[ai]["value"].strip_edges())):
					id = strtoactid[alist[ai]["value"].strip_edges()]
				else:
					id = strtoactid[alist[ai]["value"].strip_edges()\
					+ " " + alist[ai + 1]["value"].strip_edges()]
					ai += 1
				
				action["actionId"] = id
				action["parameters"] = {}
				ai += 1
				if !JSONtoCRBEL.actionVars.has(id):
					return -1
				elif JSONtoCRBEL.actionVars[id] != "":
					var _t = alist[ai]
					var v = null
					var j = ""
					if (_t.type == TType.Symbol) and (_t.value.strip_edges() == "{"):
						var bc = 1
						ai += 1
						j += "{"
						while ai < len(alist):
							var nt = alist[ai]
							var _value = nt["value"].strip_edges()
							#var needq = _value[0] != '"' or _value[-1] != '"'
							#if (nt["type"] in [TType.ID, TType.NO]) and needq: j += '"'
							j += _value
							#if (nt["type"] in [TType.ID, TType.NO]) and needq: j += '"'
							if nt["type"] == TType.Symbol:
								if nt["value"].strip_edges() == "{":
									bc += 1
								if nt["value"].strip_edges() == "}":
									bc -= 1
								if bc == 0:
									break
							ai += 1
						v = JSON.parse_string(j)
					elif (_t.type == TType.ID) and not (_t.value.strip_edges() in sep):
						v = alist[ai]["value"].strip_edges()
					if v != null:
						action["parameters"][JSONtoCRBEL.actionVars[id]] = v
						ai += 1
					
				while ai < len(alist):
					var sv = alist[ai].value.strip_edges()
					if sv in sep:
						if sv == "with":
							ai += 1
							var with = {}
							while ai + 1 < len(alist):
								with[alist[ai]["value"].strip_edges()] = alist[ai + 1]["value"].strip_edges()
								ai += 2
								if ai >= len(alist): break
								if (alist[ai]["value"].strip_edges() == ",") and (alist[ai]["type"] == TType.Symbol):
									ai += 1
							action["parameters"].merge(with)
						elif sv == "by":
							ai += 1
							action["parameters"]["step"] = alist[ai]["value"].strip_edges()
						else:
							var vals = []
							ai += 1
							if ai + 3 >= len(tokens):
								return null
							for vi in 3:
								vals.push_back(int(alist[ai + vi]["value"].strip_edges()))
							if sv == "at":
								if id not in ["base:play_sound_3d","base:loot_drop","base:item_drop"]:
									action["parameters"]["xOff"] = vals[0]
									action["parameters"]["yOff"] = vals[1]
									action["parameters"]["zOff"] = vals[2]
								else:
									action["parameters"]["position"] = vals
							else:
								match sv:
									"to":
										action["parameters"]["x2Off"] = vals[0]
										action["parameters"]["y2Off"] = vals[1]
										action["parameters"]["z2Off"] = vals[2]
									"from":
										action["parameters"]["x1Off"] = vals[0]
										action["parameters"]["y1Off"] = vals[1]
										action["parameters"]["z1Off"] = vals[2]
									"normals":
										action["parameters"]["xNormal"] = vals[0]
										action["parameters"]["yNormal"] = vals[1]
										action["parameters"]["zNormal"] = vals[2]
										
							ai += 3
						ai -= 1
					ai += 1
				if id == "base:play_sound_3d":
					if !action["parameters"].has("position"):
						action["actionId"] = "base:play_sound_2d"
				actions.push_back(action)
			value["triggers"][tname] = actions
			i += 1
		i += 1
	return JSON.stringify(value, "    ")
