extends SyntaxHighlighter

const symbols = "{},"

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
	No = 9,
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
	TType.No: {"color": Color.WHITE},
	TType.Comment: {"color": Color(0.32, 0.32, 0.32)},
	TType.Dict: {"color": Color(0.902, 0.677, 0)}
}

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
	#	colormap[t.pos] = colors[t.type]
	while i < len(tokens):
		var t = tokens[i]
		if (t.type == TType.ID) and (keywords.has(t.value.strip_edges())) and (i == 0):
			colormap[t.pos] = colors[TType.Keyword]
			if len(tokens) < 2:
				colormap[t.pos + len(t.value)] = colors[TType.ERROR]
				return colormap
			elif tokens[i + 1].type != TType.ID:
				colormap[tokens[i + 1].pos + len(t.value)] = colors[TType.ERROR]
			else:
				colormap[tokens[i + 1].pos] = colors[TType.Name]
			colormap[tokens[i + 1].pos + len(tokens[i + 1].value)] = colors[TType.ERROR]
			if len(tokens) > 2 and tokens[i + 2].type == TType.Symbol and tokens[i + 2].value == "{" and t.value.strip_edges() == "trigger":
				colormap[tokens[i + 2].pos] = colors[TType.Symbol]
			i += 1
		elif (t.type == TType.ID) and (actions.has(t.value.strip_edges())):
			if len(tokens) < 2 + int(actionSubType[actions.find(t.value.strip_edges())]):
				return colormap
			colormap[t.pos] = colors[TType.Action]
			#i += 1
			#t = tokens[i]
			#colormap[t.pos + len(t.value)] = colors[TType.ID]
			if actionSubType[actions.find(t.value.strip_edges())]:
				i += 1
				t = tokens[i]
				colormap[t.pos] = colors[TType.ActionSubType]
				#colormap[t.pos + len(t.value)] = colors[TType.No]
			i += 1
			while i < len(tokens):
				t = tokens[i]
				colormap[t.pos] = colors[t.type]
				if (t.type == TType.ID) and (sep.has(t.value.strip_edges())):
					colormap[t.pos] = colors[TType.Sep]
				i += 1
		else:
			colormap[t.pos] = colors[t.type]
		i += 1
	return colormap
