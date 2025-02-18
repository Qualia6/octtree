class_name OctTreeObject extends MeshInstance3D

var octTree: OctTree = OctTree.new()
var depth: int = 6

func reset():
	octTree.free()
	octTree = OctTree.new()

func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		octTree.free()

func get_state(pos: Vector3) -> bool:
	var scaled_pos: Vector3i = pos * (1 << depth)
	return octTree.get_value(Vector4i(scaled_pos.x, scaled_pos.y, scaled_pos.z, depth))

func set_state(pos: Vector3, value: bool):
	var scaled_pos: Vector3i = pos * (1 << depth)
	octTree.set_value(Vector4i(scaled_pos.x, scaled_pos.y, scaled_pos.z, depth), value)

func fill_AABB(aabb: AABB, value: bool):
	var scaled_a: Vector3i = aabb.position * (2<<depth)
	var scaled_b: Vector3i = aabb.end * (2<<depth)
	var pos_a: Vector3i = scaled_a.min(scaled_b).max(Vector3i(0, 0, 0))
	var pos_b: Vector3i = scaled_a.max(scaled_b).min(Vector3i(2<<depth, 2<<depth, 2<<depth))
	var diff: Vector3i = pos_b - pos_a
	if diff.x == 0 or diff.y == 0 or diff.z == 0:
		print("invalid size")
	else:
		octTree.fill_aabb(pos_a, pos_b, depth, value)
	#for x in range(scaled_a.x, scaled_b.x+1):
		#for y in range(scaled_a.y, scaled_b.y+1):
			#for z in range(scaled_a.z, scaled_b.z+1):
				#octTree.set_value(Vector4i(x, y, z, depth), value)

func fill_AABB_old(aabb: AABB, value: bool):
	var scaled_a: Vector3i = aabb.position * (2<<depth)
	var scaled_b: Vector3i = aabb.end * (2<<depth)
	for x in range(scaled_a.x, scaled_b.x+1):
		for y in range(scaled_a.y, scaled_b.y+1):
			for z in range(scaled_a.z, scaled_b.z+1):
				octTree.set_value(Vector4i(x, y, z, depth), value)

var index: int
func add_cube(corner_a: Vector3, corner_b: Vector3, verts: PackedVector3Array, normals: PackedVector3Array, colors: PackedColorArray, indices: PackedInt32Array, color: Color):
	verts.append_array([
		corner_b,
		Vector3(corner_a.x, corner_b.y, corner_b.z),
		Vector3(corner_b.x, corner_a.y, corner_b.z),
		Vector3(corner_a.x, corner_a.y, corner_b.z),
		Vector3(corner_b.x, corner_b.y, corner_a.z),
		Vector3(corner_a.x, corner_b.y, corner_a.z),
		Vector3(corner_b.x, corner_a.y, corner_a.z),
		corner_a
	])
	colors.append_array([
		color,
		color,
		color,
		color,
		color,
		color,
		color,
		color,
	])
	normals.append_array([
		Vector3(1,1,1),#0
		Vector3(-1,1,1),#1
		Vector3(1,-1,1),#2
		Vector3(-1,-1,1),#3
		Vector3(1,1,-1),#4
		Vector3(-1,1,-1),#5
		Vector3(1,-1,-1),#6
		Vector3(-1,-1,-1),#7
	])
	indices.append_array([
		#Z
		index, index+2, index+1,
		index+1, index+2, index+3,
		#z
		index+4, index+5, index+6, 
		index+5, index+7, index+6, 
		#Y
		index, index+1, index+4, 
		index+1, index+5, index+4, 
		#y
		index+2, index+6, index+3, 
		index+3, index+6, index+7,
		#X
		index, index+4, index+2, 
		index+2, index+4, index+6,
		#x
		index+1, index+3, index+5,
		index+3, index+7, index+5
	])
	index += 8

func visualize():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var colors = PackedColorArray()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	index = 0
	
	octTree.iterate_all(func(pos: Vector4i, fill: bool):
		var color: Color
		if fill:
			color = Color.CRIMSON
		else:
			color = Color.DODGER_BLUE
			color.a = 0.05
		var size: float = 1.0 / (1<<pos.w)
		var center: Vector3 = Vector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5) * size
		var corner_a: Vector3 = center - Vector3(0.5,0.5,0.5) * size
		var corner_b: Vector3 = center + Vector3(0.5,0.5,0.5) * size
		add_cube(corner_a, corner_b, verts, normals, colors, indices, color)
	)
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_COLOR] = colors
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	mesh = ArrayMesh.new()
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
