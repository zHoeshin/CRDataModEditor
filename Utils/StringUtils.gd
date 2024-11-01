extends Node

func trimSuffixes(str: String, suffixes: Array, returnSuffix = false):
	for suffix in suffixes:
		var s = str.trim_suffix(suffix)
		if s != str:
			if returnSuffix: return [s, suffix]
			return s
	if returnSuffix: return [str, null]
	return str
