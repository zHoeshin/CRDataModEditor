extends SyntaxHighlighter

const symbols = "{},"

var keywords: Array = ["name", "inherit", "trigger"]
var actions: Array = ["explode", "drop", "place", "set", "grow", "leaf_decay", "run_trigger", "increment_param", "play"]
var actionSubType = [false, true, false, true, true, false, false, false, false]
var sep = ["to", "with", "from", "by", "at"]



var whitespaceA: RegEx = RegEx.new()
var whitespaceP: RegEx = RegEx.new()
var digits: String = "0123456789"

func _ready():
	whitespaceA.compile("\\s*")
	whitespaceP.compile("\\s+")


func _get_line_syntax_highlighting(line):
	var tokens = CRBELtoJSON.tokenize(get_text_edit().get_line(line), false)
	#return
	#if tokens == null:
		#return {0: {"color": Color.GRAY}}
	#if len(tokens) <= 0:
		#return {0: {"color": Color.GRAY}}
	var colormap = {0: {"color": Color(0.32, 0.32, 0.32)}}
	var i: int = 0
	#for t in tokens:
	#	colormap[t.pos] = CRBELtoJSON.colors[t.type]
	while i < len(tokens):
		var t = tokens[i]
		if (t.type == CRBELtoJSON.TType.ID) and (keywords.has(t.value.strip_edges())) and (i == 0):
			colormap[t.pos] = CRBELtoJSON.colors[CRBELtoJSON.TType.Keyword]
			if len(tokens) < 2:
				colormap[t.pos + len(t.value)] = CRBELtoJSON.colors[CRBELtoJSON.TType.ERROR]
				return colormap
			elif tokens[i + 1].type != CRBELtoJSON.TType.ID:
				colormap[tokens[i + 1].pos + len(t.value)] = CRBELtoJSON.colors[CRBELtoJSON.TType.ERROR]
			else:
				colormap[tokens[i + 1].pos] = CRBELtoJSON.colors[CRBELtoJSON.TType.Name]
			colormap[tokens[i + 1].pos + len(tokens[i + 1].value)] = CRBELtoJSON.colors[CRBELtoJSON.TType.ERROR]
			if len(tokens) > 2 and tokens[i + 2].type == CRBELtoJSON.TType.Symbol and tokens[i + 2].value == "{" and t.value.strip_edges() == "trigger":
				colormap[tokens[i + 2].pos] = CRBELtoJSON.colors[CRBELtoJSON.TType.Symbol]
			i += 1
		elif (t.type == CRBELtoJSON.TType.ID) and (actions.has(t.value.strip_edges())):
			if len(tokens) < 2 + int(actionSubType[actions.find(t.value.strip_edges())]):
				return colormap
			colormap[t.pos] = CRBELtoJSON.colors[CRBELtoJSON.TType.Action]
			#i += 1
			#t = tokens[i]
			#colormap[t.pos + len(t.value)] = CRBELtoJSON.colors[CRBELtoJSON.TType.ID]
			if actionSubType[actions.find(t.value.strip_edges())]:
				i += 1
				t = tokens[i]
				colormap[t.pos] = CRBELtoJSON.colors[CRBELtoJSON.TType.ActionSubType]
				#colormap[t.pos + len(t.value)] = CRBELtoJSON.colors[CRBELtoJSON.TType.No]
			i += 1
			while i < len(tokens):
				t = tokens[i]
				colormap[t.pos] = CRBELtoJSON.colors[t.type]
				if (t.type == CRBELtoJSON.TType.ID) and (sep.has(t.value.strip_edges())):
					colormap[t.pos] = CRBELtoJSON.colors[CRBELtoJSON.TType.Sep]
				i += 1
		else:
			colormap[t.pos] = CRBELtoJSON.colors[t.type]
		i += 1
	return colormap
