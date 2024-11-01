extends Node
class_name SimplePartialApplicator

var f = null
var arg = null

func _init(callable: Callable, arg: Variant):
	self.f = callable
	self.arg = arg

func invoke():
	if f == null: return
	if arg == null: return f.call()
	return f.call(arg)
