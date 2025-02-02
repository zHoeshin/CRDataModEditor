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
	String = 13,
	Range = 14,
	Number = 15,
}

const colors = {
	TType.ERROR: {"color": Color(1, 0, 0)},
	TType.Symbol: {"color": Color(0.252, 0.252, 0.252)},
	TType.Int: {"color": Color(1, 0.337, 0.157)},
	TType.Number: {"color": Color(1, 0.337, 0.157)},
	TType.Range: {"color": Color(1, 0.337, 0.157)},
	TType.ID: {"color": Color(0.892, 0.9, 0.765)},
	TType.Keyword: {"color": Color(0.76, 0.312, 0.76)},
	TType.Name: {"color": Color(0.464, 0.95, 0.555)},
	TType.Action: {"color": Color(0.1, 0.338, 1)},
	TType.ActionSubType: {"color": Color(0.741, 0.22, 0.964)},
	TType.Sep: {"color": Color(0.84, 0.151, 0.289)},
	TType.NO: {"color": Color.WHITE},
	TType.Comment: {"color": Color(0.32, 0.32, 0.32)},
	TType.Dict: {"color": Color(0.902, 0.677, 0)},
	TType.String: {"color": Color(0.855, 0.98, 0.38)},
	TType.NewLine: {"color": Color.WHITE},
}

var keywords: Array = ["name", "inherit", "trigger"]
var actions: Array = ["explode", "drop", "place", "set", "grow", "leaf_decay", "run_trigger", "increment_param", "play"]
var actionSubType = [false, true, false, true, true, false, false, false, false]
const sep = ["to", "with", "from", "by", "at", "normals"]

const strtoactid = {
	"explode": {0: {"id": "base:explode", "paramnames": []},},
	"grow base:tree_coconut": {0: {"id": "base:grow_tree_coconut", "paramnames": []},},
	"grow base:tree_poplar": {0: {"id": "base:grow_tree_poplar", "paramnames": []},},
	"drop item": {
		0: {"id": "base:item_drop", "paramnames": []},
		1: {"id": "base:item_drop", "paramnames": ["dropId"]},
	},
	"leaf_decay": {0: {"id": "base:leaf_decay", "paramnames": []},},
	"drop loot": {1: {"id": "base:loot_drop", "paramnames": ["lootId"]},},
	"play": {1: {"id": "base:play_sound_3d", "paramnames": ["sound"]},},
	"set block": {1: {"id": "base:replace_block_state", "paramnames": ["blockStateId"]},},
	"run_trigger": {1: {"id": "base:run_trigger", "paramnames": ["triggerId"]},},
	"run trigger": {1: {"id": "base:run_trigger", "paramnames": ["triggerId"]},},
	"set cube": {1: {"id": "base:set_cuboid", "paramnames": ["blockStateId"]},},
	"set cuboid": {1: {"id": "base:set_cuboid", "paramnames": ["blockStateId"]},},
	"set sphere": {1: {"id": "base:set_sphere", "paramnames": ["blockStateId"]},},
	"sphere segment": {1: {"id": "base:set_spherical_segment", "paramnames": ["blockStateId"]},},
	"increment_param": {1: {"id": "base:increment_param", "paramnames": []},},
	"set params": {1: {"id": "base:set_block_state_params", "paramnames": []},},
}


var whitespaceA: RegEx = RegEx.new()
var whitespaceP: RegEx = RegEx.new()
var digits: String = "0123456789"
var whitespace: String = " \t"
const comments: String = "#;"
const symbols: String = "[]:{},"
const quotes: String = "\"'"

var tokenspecs = [
	[StringUtils.regex(r"[#;][^\n]*"), TType.Comment, 0],
	[StringUtils.regex(r"([+-]?(\d*\.?\d+))\.\.([+-]?(\d+\.?\d*))"), TType.Range, -1],
	[StringUtils.regex(r"[+-]?(\d*\.?\d+)|(\d+\.?\d*)"), TType.Number, -1],
	[StringUtils.regex(r"\"((\\\")|[^\"])*\""), TType.String, -1],
#	[StringUtils.regex(r"\'((\\\')|[^\'])*\'"), TType.String, -1],
	[StringUtils.regex(r"""(?(DEFINE)(?'str'"([^"]|\\")*")){(?P>str):((?R)?|[^{}]*|(?P>str))}"""), TType.Dict, 1],
	[StringUtils.regex(r"[\[\]:{},]"), TType.Symbol, -1],
#	[],
	[StringUtils.regex(r"[^\n\s,\[\]]+(\[[^\n]*\])?"), TType.ID, -1],
	[StringUtils.regex(r"\n"), TType.NewLine, -1],
	[StringUtils.regex(r"\s+"), null, -1],
]

# flags:
# * 0: comments
# * 1: dicts
func tokenize(r: String, flags: Array[bool] = [true, true]):
	if len(r) <= 0: return []
	var tokens: Array = []
	var i = 0
	var x = 0
	var y = 0
	while i < len(r):
		var success = false
		if r[i] == "\r":
			i += 1
			continue
		if r[i] == "\n":
			tokens.append({value = "\n", pos = [x, y], type = TType.NewLine})
			i += 1
			y += 1
			x = 0
			continue
		if r[i] == "\r":
			i += 1
			continue
		for spec in tokenspecs:
			var regex: RegEx = spec[0]
			var type = spec[1]
			var flag = spec[2]
			var matched = regex.search(r, i)
			#if matched != null: prints(regex.get_pattern(), matched.get_string(), matched.get_start())
			if matched == null: continue
			if matched.get_start() != i: continue
			var matchlen = matched.get_end() - matched.get_start()
			i += matchlen
			x += matchlen
			success = true
			if flag != -1: if flags[flag]: break
			if type == null: break
			#prints(type, matched.get_string())
			tokens.append({value = matched.get_string(), pos = [x, y], type = type})
			break
		if !success:
			return ["Unknown symbol", r[i], r[i].unicode_at(0), "at", x, y, "(", i, ")"]
	return tokens

class Token:
	var value: String
	var pos: int
	var type: int

class Thing:
	var value
	var type: String
	func _init(value, type: String):
		self.value = value
		self.type = type

class Error:
	var value: String
	var token
	var after
	func _init(value: String, token, after: bool = false):
		self.value = value
		self.token = token
		self.after = after
		
	func throw():
		printerr(_to_string())
	
	func _to_string():
		return "{e} at line {x} char {y}".format({
			e = self.value,
			x = self.token.pos[1] + 1,
			y = self.token.pos[0] + 1 + int(self.after)*len(self.token.value),
		})

class Parser:
	var tokens
	var i
	
	func _init(tokens: Array):
		self.tokens = tokens
		self.i = 0
	
	func parse(): pass
	
	func consumeId(returnToken = false):
		if self.i >= len(self.tokens): return null
		var t = self.tokens[self.i]
		if t.type != TType.ID:
			return null
		self.i += 1
		if returnToken: return t
		return t.value
	
	func consumeExact(token):
		if self.i >= len(self.tokens): return null
		var t = self.tokens[self.i]
		if t.type != token.type: return null
		if t.value != token.value: return null
		self.i += 1
		return t.value
		
	func consumeFromValueList(token, values):
		if self.i >= len(self.tokens): return null
		var t = self.tokens[self.i]
		if t.type != token.type: return null
		if not t.value in values: return null
		self.i += 1
		return t.value
	
	func discardNewLines():
		var t = consumeExact({type = TType.NewLine, value = "\n"})
		while t != null:
			t = consumeExact({type = TType.NewLine, value = "\n"})
	
	func consumeScope(keepBraces = false):
		if self.i >= len(self.tokens): return null
		var t0 = self.tokens[self.i]
		if t0.type != TType.Symbol: return null
		if t0.value != "{": return null
		var s = self.i
		var i = self.i + 1
		var b = 1
		while b > 0 and i < len(self.tokens):
			var t = self.tokens[i]
			if t.type == TType.Symbol:
				if t.value == "{":
					b += 1
				if t.value == "}":
					b -= 1
			i += 1
		if keepBraces: i -= 1
		self.i = i
		return self.tokens.slice(s + int(!keepBraces), i - int(!keepBraces))
	

class TriggerParser extends Parser:
	
	func parse():
		var data = {
			
		}
		
		while self.i < len(self.tokens):
			var thing = parseThing()
			if thing == null:
				continue
			if thing.has_method("throw"):
				thing.throw()
				return null
			match thing.type:
				"name":
					data["stringId"] = thing.value
				"inherit":
					data["parent"] = thing.value
				"trigger":
					if data.get("triggers", null) == null:
						data["triggers"] = {}
					var instructions = parseInstructions(thing.value[1])
					data["triggers"][thing.value[0]] = instructions
		#print("\n".repeat(8))
		#print(JSON.stringify(data, "    ", false))
		return data
	
	func parseThing():
		discardNewLines()
		
		var t = consumeId(true)
		if self.i >= len(self.tokens):
			return null
		if t == null:
			return Error.new("Not an id", self.tokens[self.i])
		
		match t.value:
			"name":
				var name = consumeId()
				if name == null:
					return Error.new("Expected id after `name`", t, true)
				return Thing.new(name, "name")
			"inherit":
				var parent = consumeId()
				if parent == null:
					return Error.new("Expected id after `inherit`", t, true)
				return Thing.new(parent, "inherit")
			"trigger":
				var name = consumeId()
				if name == null:
					return Error.new("Expected id after `trigger`", t, true)
				discardNewLines()
				var scope = consumeScope()
				if scope == null:
					return Error.new("Expected trigger body for " + name, t, true)
				return Thing.new([name, scope], "trigger")
			_:
				return Thing.new(t, "unknown")
				
	func parseInstructions(tokens):
		#for token in tokens: print(token)
		var sp = ScopeParser.new(tokens)
		var scope = sp.parse()
		return scope

class ScopeParser extends Parser:
	func parse():
		var fails = 0
		var things = []
		while self.i < len(self.tokens):
			discardNewLines()
			var thing = parseThing()
			#print(thing)
			if thing == null:
				fails += 1
				if fails >= 100: break
				continue
			if thing.has_method("throw"):
				thing.throw()
				return null
			things.append(CRBEL.compileInstruction(thing.value))
		#prints("parsed", things)
		return things
	
	func consumeValue(returnToken = false):
		var t = self.tokens[self.i]
		if t.type not in [TType.ID, TType.Dict, TType.String, TType.Int, TType.Number, TType.Range]:
			return null
		if t.value in sep:
			return null
		self.i += 1
		if returnToken: return t
		return t.value
	
	func parseThing():
		if self.i >= len(self.tokens):
			return
		var w = consumeId(true)
		#print("i", w)
		if w == null:
			return Error.new("Expected a word, got", self.tokens[self.i])
		match w.value:
			"if": pass
			_:
				return parseInstruction([w])
	func parseInstruction(w):
		var p = consumeFromValueList({type = TType.ID}, sep)
		while p == null:
			#print("l",w)
			if consumeExact({type = TType.NewLine, value = "\n"}):
				break
			var t = consumeValue(true)
			if t != null: w.append(t)
			else: break
			p = consumeFromValueList({type = TType.ID}, sep)
		if p != null: self.i -= 1
		var params = {}
		#print("INSTR", w)
		while self.i < len(self.tokens):
			if consumeExact({type = TType.NewLine, value = "\n"}):
				self.i -= 1
				break
			p = consumeFromValueList({type = TType.ID}, sep)
			if p == null: break
			var args
			if p != "with":
				args = []
				var t = consumeFromValueList({type = TType.ID}, sep)
				while t == null:
					if consumeExact({type = TType.NewLine, value = "\n"}):
						self.i -= 1
						break
					var v = consumeValue(true)
					if v != null: args.append(v)
					else: break
					t = consumeFromValueList({type = TType.ID}, sep)
				if t != null: self.i -= 1
			else:
				args = {}
				var t = consumeFromValueList({type = TType.ID}, sep)
				while t == null:
					if consumeExact({type = TType.NewLine, value = "\n"}):
						self.i -= 1
						break
					var n = consumeValue()
					var v = CRBEL.compileValue(consumeValue(true))
					args[n] = v
					consumeExact({type = TType.Symbol, value = ","})
					t = consumeFromValueList({type = TType.ID}, sep)
				if t != null: self.i -= 1
			params[p] = args
		#prints("instr", w, params, self.tokens[self.i])
		return Thing.new([w, params], "instruction")

const paramsuffixes = {
	"at": "Off",
	"to": "2Off",
	"from": "1Off",
	"normals": "Normal"
}
func compileInstruction(instr):
	#print("\n\ncompiling", instr)
	var id: Array = instr[0]
	var compiledid = compileValue(id)
	#print(compiledid)
	var params: Dictionary = instr[1]
	var action = null
	var idlen = 0
	var paramlen = 0
	for i in range(len(id), 0, -1):
		var tryid = " ".join(compiledid.slice(0, i))
		#print(tryid)
		action = strtoactid.get(tryid)
		if (action != null) and action.has(len(id) - i):
			idlen = i
			paramlen = len(id) - i
			break
	if action == null: return Error.new("Unknown instruction '{0}'".format([" ".join(compiledid)]), id[0])
	#prints("action", action, idlen)
	var actionid = action[paramlen]["id"]
	var _action = {
		"actionId": actionid
	}
	var parameters = {}
	var paramnames = action[paramlen]["paramnames"]
	for i in paramlen:
		var paramvalue = compiledid[i + idlen]
		var paramname = action[paramlen]["paramnames"][i]
		parameters[paramname] = paramvalue
	for param in params.keys():
		if param == "with": continue
		var value = compileValue(params[param])
		match param:
			"at":
				if not actionid in [
					"base:play_sound_3d",
					"base:loot_drop",
					"base:item_drop",
				]: continue
				parameters["position"] = value
			"by":
				parameters["step"] = value
			_:
				if len(value) != 3:
					return Error.new("Expected 3 params, got {}".format(value), value[0] if len(value) > 0 else instr[0])
				parameters["x" + paramsuffixes[param]] = value[0]
				parameters["y" + paramsuffixes[param]] = value[1]
				parameters["z" + paramsuffixes[param]] = value[2]
	parameters.merge(params.get("with", {}))
	if len(parameters.keys()) > 0: _action["parameters"] = parameters
	if actionid == "base:play_sound_3d":
		if params.get("with", {}).has("pan"):
			_action["actionId"] = "base:play_sound_2d"
		if !params.get("with", {}).has("position"):
			_action["actionId"] = "base:play_sound_2d"
	return _action

func compileValue(token):
	if typeof(token) == TYPE_ARRAY:
		var values = []
		for t in len(token):
			#prints("v", values)
			values.append(compileValue(token[t]))
		#prints("v", values)
		return values
	match token.type:
		TType.Number, TType.Int:
			return float(token.value)
		TType.Range:
			var r = token.value.split("..")
			return [
				float(r[0]) if len(r[0]) > 0 else -9999,
				float(r[1]) if len(r[1]) > 0 else 9999,
			]
		TType.Dict:
			return JSON.parse_string(token.value)
		TType.String:
			return token.value.substr(1, -2)
		_:
			return token.value

func parse(raw: String):
	var tokens: Array = tokenize(raw, [true, false])
	#for token in tokens: print(token)
	#print("\n\n\n\n\n")
	var parser = TriggerParser.new(tokens)
	return parser.parse()
	#print(strtoactid["drop item"])
