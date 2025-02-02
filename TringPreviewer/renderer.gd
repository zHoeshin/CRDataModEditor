extends SubViewport

func setThing(model: String, rotation: int = 0):
	if model == null: return
	if $Model/container != null:
		$Model/container.queue_free()
		await $Model/container.tree_exited
	var c = Node3D.new()
	$Model.add_child(c)
	c.name = "container"
	c.rotation_degrees.y = rotation
	var meshes = ModelManager.getModelMeshes(model)
	if meshes == null:
		$Unknown.visible = true
		$Model.visible = false
		return
	$Unknown.visible = false
	$Model.visible = true
	for m in meshes:
		$Model/container.add_child(m.duplicate())

func clearThing():
	if $Model/container != null:
		$Model/container.queue_free()
		await $/Empty/container.tree_exited

func setRotation(rotation: int):
	if $Model/container != null:
		$Model/container.rotation_degrees.y = rotation

func setSize(size: Vector2):
	size = size

func setScaling(scale):
	size /= scale

func setRenderToThing2D(thing, die = false):
	#RenderingServer.viewport_set_update_mode(self.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ONCE)
	#RenderingServer.force_draw()
	await RenderingServer.frame_post_draw
	#RenderingServer.viewport_set_active(self.get_viewport_rid(), true)
	var img: Image = get_texture().get_image()
	if thing != null:
		thing.setTexture(ImageTexture.create_from_image(img))
	if die: queue_free()
