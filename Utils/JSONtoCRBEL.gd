extends Node

"""
explode at X Y Z with radius R, [replaceWIth B=base:air[default]]
grow tree P at X Y Z
drop item ID [at X Y Z = 0 0 0]
leaf_decay PARAM with [maxDist MD = maxint, onCompleteDecay TRIGGER = none]
drop loot ID [at X Y Z = 0 0 0]
play SOUND with pan, [pitch = 1, volume = 1]
play SOUND [at X Y Z = 0 0 0] with [pitch = 1, volume = 1]
place ID at X Y Z
run_trigger ID at X Y Z with [delay = 0]
set area BLOCKID with [before TRIGGER_BEFORE = none, after TRIGGER_AFTER = none]
set cuboid BLOCKID from X1 Y1 Z1 to X2 Y2 Z2
set sphere BLOCKID at X Y Z with radius R
set sphere_segment BLOCKID at X Y Z with radius R, normals XN YN ZN
increment_param PARAM at X Y Z by STEP with [delay DELAY = 0]
set param PARAM to VALUE at X Y Z with [delay DELAY = 0]"""

const coordinate = ["position", "xOff", "yOff", "zOff", "x1Off", "y1Off", "z1Off", "x2Off", "y2Off", "z2Off", "xNormal", "yNormal", "zNormal"]

const actidtostr = {
	"base:explode": "explode",
	"base:grow_tree_coconut": "grow base:tree_coconut",
	"base:grow_tree_poplar": "grow base:tree_poplar",
	"base:item_drop": "drop item",
	"base:leaf_decay": "leaf_decay",
	"base:loot_drop": "drop loot",
	"base:play_sound_2d": "play",
	"base:play_sound_3d": "play",
	"base:replace_block_state": "set block",
	"base:run_trigger": "run_trigger",
	"base:set_cuboid": "set cube",
	"base:set_sphere": "set sphere",
	"base:set_spherical_segment": "sphere segment",
	"base:increment_param": "increment_param",
	"base:set_block_state_params": "set params"
}

const actionVars = {
	"base:explode": "",
	"base:grow_tree_coconut": "",
	"base:grow_tree_poplar": "",
	"base:item_drop": "",
	"base:leaf_decay": "paramName",
	"base:loot_drop": "lootId",
	"base:play_sound_2d": "sound",
	"base:play_sound_3d": "sound",
	"base:replace_block_state": "blockStateId",
	"base:run_trigger": "triggerId",
	"base:set_cuboid": "blockStateId",
	"base:set_sphere": "blockStateId",
	"base:set_spherical_segment": "blockStateId",
	"base:increment_param": "paramName",
	"base:set_block_state_params": "params"
}

func convert(raw):
	var text = ""
	var d = JSON.parse_string(raw)
	text += "name {n}\n".format({n = d["stringId"]})
	if d.has("parent"):
		text += "inherit {p}\n".format({p = d["parent"]})
	
	for tn in d["triggers"].keys():
		var t = d["triggers"][tn]
		text += "trigger {tn} {\n".format({tn = tn})
		for i in t:
			text += "\t"
			text += convertAction(i)
			text += "\n"
		text += "}\n"
	
	return text

func convertAction(action):
	var id = action["actionId"]
	var params = action["parameters"]
	
	var at = getVec3(params, "at", "Off")
	var from = getVec3(params, "from", "2Off")
	var to = getVec3(params, "to", "2Off")
	var normals = getVec3(params, "normals", "Normal")
	
	if params.has("position"):
		at = "at {0} {1} {2}".format(params["position"])
	
	var v = ""
	if actionVars.has(id) and !actionVars[id].is_empty():
		v = "{param}".format({param = params[actionVars[id]]})
	
	var witharr = []
	for k in params.keys():
		if k in coordinate: continue
		if actionVars.has(id) and !actionVars[id].is_empty():
			if actionVars[id] == k:
				continue
		witharr.append("{n} {v}".format({n = k, v = params[k]}))
	
	var r1 = " ".join([actidtostr[id], v, at, from, to, normals].filter(func(e): return !e.is_empty()))
	var r2 = ", ".join(witharr)
	if !r2.is_empty():
		r2 = " with " + r2
	return r1 + r2

func getVec3(params, str = "at", suf = "Off"):
	if !params.has("x" + suf): return ""
	return "{str} {x} {y} {z}".format({
			x = params["x" + suf],
			y = params["y" + suf],
			z = params["z" + suf],
			str = str
		})
