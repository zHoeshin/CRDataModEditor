extends Node

func parse(condition, customconds = {}):
	var c = condition.keys()[0]
	var conds = condition[c]
	var stringified = []
	if typeof(conds) == TYPE_ARRAY:
		for cond in conds:
			stringified.push_back(parse(cond))
	else: stringified = conds
	var r = ""
	match c:
		"and":
			r = "(".repeat(int(len(stringified)>1)) +\
			" & ".join(stringified) + ")".repeat(int(len(stringified)>1))
		"or":
			r = "(".repeat(int(len(stringified)>1)) +\
			" | ".join(stringified) + ")".repeat(int(len(stringified)>1))
		"xor":
			r = "(".repeat(int(len(stringified)>1)) +\
			" ^ ".join(stringified) + ")".repeat(int(len(stringified)>1))
		"not":
			r = "!" + stringified
		_:
			if r in customconds:
				r = customconds[c].call(stringified)
			else: r = String(stringified)
	return r

class Token:
	var value
	var type
	func _init(value, type):
		self.value = value
		self.type = type
	
	func _to_string():
		return self.type + "(" + self.value + ")"

const whitespace = " \t\n"
const op = "!&^|"
const paren = "()"
const quotes = "\""
func tokenize(r: String):
	if len(r) <= 0: return []
	var tokens: Array = []
	var i: int = 0
	var c: String = ""
	while i < len(r):
		if r[i] in whitespace:
			i += 1; continue
		elif r[i] in op:
			tokens.append(Token.new(r[i], "op"))
			i += 1; continue
		elif r[i] in paren:
			tokens.append(Token.new(r[i], "paren"))
			i += 1; continue
		elif r[i] in quotes:
			var q = r[i]
			var s = i
			i += 1
			var v = ""
			while i < len(r):
				if r[i] == q: break
				if r[i] == "\\":
					if i + 1 < len(r):
						i += 1
					else: return []
				v += r[i]
				i += 1
			tokens.append(Token.new(v, "id"))
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
				elif r[i] in op:
					break
				elif r[i] in paren:
					break
				v += r[i]
				i += 1
			i -= 1
			if v.strip_edges() != "\n":
				tokens.append(Token.new(v.strip_edges(), "id"))
		i += 1
	return tokens

const opmap = {
	"&": "and",
	"|": "or",
	"^": "xor",
}
func compile(raw, wrapper = null):
	var tokens = tokenize(raw)
	print(tokens)
	var queue = []
	var stack = []
	while len(tokens):
		var token = tokens.pop_front()
		print(token)
		if token.type == "id":
			queue.push_back(token)
		if token.type == "op":
			while len(stack) and (stack[-1].type != "paren") and (op.find(stack[-1].value) <= op.find(token.value)):
				queue.push_back(stack.pop_back())
			stack.push_back(token)
		if token.type == "paren":
			if token.value == "(":
				stack.push_back(token)
				continue
			while len(stack) and (stack[-1].type != "paren"):
				queue.push_back(stack.pop_back())
			stack.pop_back()
			
	while len(stack):
		var token = stack.pop_back()
		if token.type == "paren": continue
		queue.push_back(token)
	
	print(queue)
	
	stack = []
	for token in queue:
		if token.type == "id":
			stack.push_back(token)
		if token.type == "op":
			if token.value == "!":
				var oper = stack.pop_back()
				if oper is Token:
					oper = wrapper.call(oper.value)
				stack.push_back({
					"not": oper
				})
			else:
				var oper2 = stack.pop_back()
				var oper1 = stack.pop_back()
				if oper1 is Token:
					oper1 = wrapper.call(oper1.value)
				if oper2 is Token:
					oper2 = wrapper.call(oper2.value)
				stack.push_back({
					opmap[token.value]: [
						oper1, oper2
					]
				})
	
	var r = stack[0]
	if r is Token:
		r = wrapper.call(r.value)
	return r
