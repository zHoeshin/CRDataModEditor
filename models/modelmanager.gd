extends Node

var dir = null
var models: Dictionary = {}
var meshes: Dictionary = {}

var emptymodel = preload("res://models/precomputed/empty.tscn")
var unknownmodel = preload("res://models/precomputed/unknown.tscn").instantiate()
var emptysprite = preload("res://models/precomputed/sprite.tscn")

var cuboidscene = preload("res://models/precomputed/cuboid.tscn")
var cuboidShader = preload("res://models/precomputed/cuboid.gdshader")

func getModelMeshes(modelpath: String):
	var cached = meshes.get(modelpath, null)
	if cached != null:
		#prints("loaded", modelpath, "from cache")
		return meshes[modelpath].duplicate()
	#prints("loading", modelpath)
	var nodes: Array = []
	var _path = Program.getAssetPath(modelpath)
	var file = FileAccess.get_file_as_string(_path)
	if file == null:
		return []
	if file == "":
		return []
	var contents = JSON.parse_string(file)
	if contents == null:
		return []
	var textures = {}
	for texture in contents["textures"].keys():
		textures[texture] = TextureManager.getTexture(contents["textures"][texture]["fileName"])
	
	var cuboids
	if contents.has("parent"):
		var parentdata = getParentCuboidsAndTextures(contents)
		textures.merge(parentdata[1])
		cuboids = parentdata[0]
	else:
		cuboids = contents["cuboids"]
	var appliedtextures: Array = []
	for cuboid in cuboids:
		var c = getCuboidAsMesh(cuboid, textures)
		nodes.push_back(c)
	meshes[modelpath] = nodes
	return nodes.duplicate(true)

func getParentCuboidsAndTextures(contents):
	var parent = contents["parent"]
	var parentpath = Program.getAssetPath(parent)
	var parentcontents = FileAccess.get_file_as_string(parentpath)
	var pc = JSON.parse_string(parentcontents)
	var textures = {}
	if pc == null: return
	if pc.has("textures"):
		for texture in pc["textures"].keys():
			textures[texture] = TextureManager.getTexture(pc["textures"][texture]["fileName"])
	if pc.has("parent"):
		var parentdata = getParentCuboidsAndTextures(pc)
		textures.merge(parentdata[1])
		pc["cuboids"] = parentdata[0]
	return [pc.get("cuboids", []), textures]

func getModelScene(modelpath: String):
	var cached = models.get(modelpath, null)
	if cached != null:
		#prints("loaded", modelpath, "from cache")
		return cached.duplicate()
	var node = emptymodel.instantiate()
	var meshes = getModelMeshes(modelpath)
	if len(meshes) <= 0:
		return unknownmodel.duplicate()
	for m in meshes: node.add_child(m)
	models[modelpath] = node
	return node.duplicate()

func getCuboidAsMesh(cuboid, textures):
	var bounds = cuboid["localBounds"]
	var to  : Vector3 = Vector3(bounds[3], bounds[4], bounds[5])
	var from: Vector3 = Vector3(bounds[0], bounds[1], bounds[2])
	var size: Vector3 = from - to
	var c: MeshInstance3D = cuboidscene.instantiate()
	c.position = from - size / 2
	c.scale = size
	var s: ShaderMaterial =ShaderMaterial.new()
	s.shader = cuboidShader
	c.material_override = s
	var setAllTextures = textures.has("all")
	for facename in cuboid["faces"].keys():
		var face = cuboid["faces"][facename]
		var fn = facename.substr(5, 4)
		var texture: ImageTexture
		if setAllTextures:
			texture = textures["all"]
		else:
			texture = textures.get(face["texture"], Icon.EMPTY)
		var tsize: Vector2 = texture.get_size()
		var uvstart = Vector2(face["uv"][0], face["uv"][1])
		var uvend   = Vector2(face["uv"][2], face["uv"][3])
		var uvsize = uvend - uvstart
		s.set_shader_parameter(fn + "Texture", texture.duplicate())
		s.set_shader_parameter(fn + "UVstart", uvstart / tsize)
		s.set_shader_parameter(fn + "UVsize", uvsize / tsize)
	return c
