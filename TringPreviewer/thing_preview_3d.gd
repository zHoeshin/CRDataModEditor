extends SubViewportContainer

func setThing(model: String, rotation: int = 0):
	if model == null: return
	if $SubViewport/Empty/container != null:
		$SubViewport/Empty/container.queue_free()
		await $SubViewport/Empty/container.tree_exited
	var c = Node3D.new()
	$SubViewport/Model.add_child(c)
	c.name = "container"
	c.rotation_degrees.y = rotation
	var meshes = ModelManager.getModelMeshes(model)
	if meshes == null or not len(meshes):
		$SubViewport/Unknown.visible = true
		$SubViewport/Model.visible = false
		return
	$SubViewport/Unknown.visible = false
	$SubViewport/Model.visible = true
	for m in meshes:
		$SubViewport/Model/container.add_child(m.duplicate())

func clearThing():
	if $SubViewport/Model/container != null:
		$SubViewport/Model/container.queue_free()
		await $SubViewport/Empty/container.tree_exited

func setRotation(rotation: int):
	if $SubViewport/Model/container != null:
		$SubViewport/Model/container.rotation_degrees.y = rotation

func setSize(size: Vector2):
	$SubViewport.size = size
