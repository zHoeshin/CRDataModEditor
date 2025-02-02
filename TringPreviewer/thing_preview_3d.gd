extends SubViewportContainer

func setThing(model: String, rotation: int = 0):
	if model == null: return
	if $SubViewport/Model/container != null:
		$SubViewport/Model/container.queue_free()
		await $SubViewport/Model/container.tree_exited
	var c = Node3D.new()
	$SubViewport/Model.add_child(c)
	c.name = "container"
	c.rotation_degrees.y = rotation
	var meshes = ModelManager.getModelMeshes(model)
	if meshes == null:
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

func setScaling(scale):
	stretch_shrink = true
	$SubViewport.size /= scale
	stretch = scale

func setRenderToThing2D(thing, die = false):
	await RenderingServer.frame_post_draw
	var img: Image = $SubViewport.get_texture().get_image()
	if thing != null:
		thing.setTexture(ImageTexture.create_from_image(img))
	if die: queue_free()
