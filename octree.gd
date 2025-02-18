class_name OctTree extends Object

var value: int = 0
var elm_xyz: OctTree = null
var elm_xyZ: OctTree = null
var elm_xYz: OctTree = null
var elm_xYZ: OctTree = null
var elm_Xyz: OctTree = null
var elm_XyZ: OctTree = null
var elm_XYz: OctTree = null
var elm_XYZ: OctTree = null
const shift_xyz: int = 0
const shift_xyZ: int = 1
const shift_xYz: int = 2
const shift_xYZ: int = 3
const shift_Xyz: int = 4
const shift_XyZ: int = 5
const shift_XYz: int = 6
const shift_XYZ: int = 7

func get_elm(i: int) -> OctTree:
	match i:
		0: return elm_xyz
		1: return elm_xyZ
		2: return elm_xYz
		3: return elm_xYZ
		4: return elm_Xyz
		5: return elm_XyZ
		6: return elm_XYz
		7: return elm_XYZ
	return null

func set_elm(i: int, elm: OctTree):
	match i:
		0: elm_xyz = elm
		1: elm_xyZ = elm
		2: elm_xYz = elm
		3: elm_xYZ = elm
		4: elm_Xyz = elm
		5: elm_XyZ = elm
		6: elm_XYz = elm
		7: elm_XYZ = elm


# when communicating using Vector4i
# the associated values should be considered at Vector3(x,y,z)>>w

func _init(new_val: int = 0) -> void:
	value = new_val

func _notification(what) -> void:
	if (what == NOTIFICATION_PREDELETE):
		if elm_xyz != null: elm_xyz.free()
		if elm_xyZ != null: elm_xyZ.free()
		if elm_xYz != null: elm_xYz.free()
		if elm_xYZ != null: elm_xYZ.free()
		if elm_Xyz != null: elm_Xyz.free()
		if elm_XyZ != null: elm_XyZ.free()
		if elm_XYz != null: elm_XYz.free()
		if elm_XYZ != null: elm_XYZ.free()



# private
func get_single(input: Vector4i, elm: OctTree, shift: int, input_shift: Vector4i) -> bool:
	if elm == null or input.w == 0:
		return (value >> shift) & 1
	else:
		return elm_XYZ.get_value(input - input_shift)

func get_value(input: Vector4i) -> bool:
	if input.x >> input.w:
		if input.y >> input.w:
			if input.z >> input.w:
				return get_single(input, elm_XYZ, shift_XYZ, Vector4i(1 << input.w, 1 << input.w, 1 << input.w, 1))
			else:
				return get_single(input, elm_XYz, shift_XYz, Vector4i(1 << input.w, 1 << input.w, 0, 1))
		else:
			if input.z >> input.w:
				return get_single(input, elm_XyZ, shift_XyZ, Vector4i(1 << input.w, 0, 1 << input.w, 1))
			else:
				return get_single(input, elm_Xyz, shift_Xyz, Vector4i(1 << input.w, 0, 0, 1))
	else:
		if input.y >> input.w:
			if input.z >> input.w:
				return get_single(input, elm_xYZ, shift_xYZ, Vector4i(0, 1 << input.w, 1 << input.w, 1))
			else:
				return get_single(input, elm_xYz, shift_xYz, Vector4i(0, 1 << input.w, 0, 1))
		else:
			if input.z >> input.w:
				return get_single(input, elm_xyZ, shift_xyZ, Vector4i(0, 0, 1 << input.w, 1))
			else:
				return get_single(input, elm_xyz, shift_xyz, Vector4i(0, 0, 0, 1))

# returns a number between 0 and 8
func get_filled_in_this_layer() -> int:
	var result: int = 0;
	result += (value >> shift_xyz) & 1
	result += (value >> shift_xyZ) & 1
	result += (value >> shift_xYz) & 1
	result += (value >> shift_xYZ) & 1
	result += (value >> shift_Xyz) & 1
	result += (value >> shift_XyZ) & 1
	result += (value >> shift_XYz) & 1
	result += (value >> shift_XYZ) & 1
	return result

func is_leaf() -> bool:
	if elm_xyz != null: return false
	if elm_xyZ != null: return false
	if elm_xYz != null: return false
	if elm_xYZ != null: return false
	if elm_Xyz != null: return false
	if elm_XyZ != null: return false
	if elm_XYz != null: return false
	if elm_XYZ != null: return false
	return true

func set_single(input: Vector4i, elm: OctTree, shift: int, input_shift: Vector4i, new_val: bool) -> OctTree:
	if input.w == 0: # stop subdividing
		if new_val:
			value |= 1 << shift
		else:
			value &= ~(1 << shift)
		if elm != null:  # delete subdivision
			elm.free()
			return null
		return elm
	else: # keep subdividing
		if elm == null: # need to make a new oct tree
			var current_val: bool = (value >> shift) & 1
			if current_val != new_val: # if they are the same then we dont need to change anything
				var new_tree: OctTree
				if current_val:
					new_tree = OctTree.new(255)
				else:
					new_tree = OctTree.new(0)
				new_tree.set_value(input - input_shift, new_val)
				return new_tree
			return elm
		else: # there is an existing oct tree to use
			elm.set_value(input - input_shift, new_val)
			var fill: int = elm.get_filled_in_this_layer()
			var full_enough: bool = fill > 4
			if full_enough:
				value |= 1 << shift
			else:
				value &= ~(1 << shift)
			if (fill == 0 or fill == 8) and elm.is_leaf(): # layer is uniform, kill it
				elm.free()
				return null
			return elm


# returns the number filled in this layer
func set_value(input: Vector4i, new_val: bool) -> void:
	if input.x >> input.w:
		if input.y >> input.w:
			if input.z >> input.w:
				elm_XYZ = set_single(input, elm_XYZ, shift_XYZ, Vector4i(1 << input.w, 1 << input.w, 1 << input.w, 1), new_val)
			else:
				elm_XYz = set_single(input, elm_XYz, shift_XYz, Vector4i(1 << input.w, 1 << input.w, 0, 1), new_val)
		else:
			if input.z >> input.w:
				elm_XyZ = set_single(input, elm_XyZ, shift_XyZ, Vector4i(1 << input.w, 0, 1 << input.w, 1), new_val)
			else:
				elm_Xyz = set_single(input, elm_Xyz, shift_Xyz, Vector4i(1 << input.w, 0, 0, 1), new_val)
	else:
		if input.y >> input.w:
			if input.z >> input.w:
				elm_xYZ = set_single(input, elm_xYZ, shift_xYZ, Vector4i(0, 1 << input.w, 1 << input.w, 1), new_val)
			else:
				elm_xYz = set_single(input, elm_xYz, shift_xYz, Vector4i(0, 1 << input.w, 0, 1), new_val)
		else:
			if input.z >> input.w:
				elm_xyZ = set_single(input, elm_xyZ, shift_xyZ, Vector4i(0, 0, 1 << input.w, 1), new_val)
			else:
				elm_xyz = set_single(input, elm_xyz, shift_xyz, Vector4i(0, 0, 0, 1), new_val)

# private
func iterate_single(lamdba: Callable, new_pos: Vector4i, elm: OctTree, shift: int) -> void:
	if elm == null:
		lamdba.call(new_pos, (value>>shift) & 1)
	else:
		elm.iterate_all(lamdba, new_pos)

# will call lambda for ever bottom leaf
# is called with a Vector4i and a bool
# the bool indicates wether it is filled
# the vector4i is the position, it should be treated as Vector3(x/(1<<w),y/(1<<w),z/(1<<w))
func iterate_all(lambda: Callable, pos: Vector4i = Vector4i(0,0,0,0)) -> void:
	iterate_single(lambda, Vector4i((pos.x<<1), (pos.y<<1), (pos.z<<1), pos.w+1), elm_xyz, shift_xyz)
	iterate_single(lambda, Vector4i((pos.x<<1), (pos.y<<1), (pos.z<<1)+1, pos.w+1), elm_xyZ, shift_xyZ)
	iterate_single(lambda, Vector4i((pos.x<<1), (pos.y<<1)+1, (pos.z<<1), pos.w+1), elm_xYz, shift_xYz)
	iterate_single(lambda, Vector4i((pos.x<<1), (pos.y<<1)+1, (pos.z<<1)+1, pos.w+1), elm_xYZ, shift_xYZ)
	iterate_single(lambda, Vector4i((pos.x<<1)+1, (pos.y<<1), (pos.z<<1), pos.w+1), elm_Xyz, shift_Xyz)
	iterate_single(lambda, Vector4i((pos.x<<1)+1, (pos.y<<1), (pos.z<<1)+1, pos.w+1), elm_XyZ, shift_XyZ)
	iterate_single(lambda, Vector4i((pos.x<<1)+1, (pos.y<<1)+1, (pos.z<<1), pos.w+1), elm_XYz, shift_XYz)
	iterate_single(lambda, Vector4i((pos.x<<1)+1, (pos.y<<1)+1, (pos.z<<1)+1, pos.w+1), elm_XYZ, shift_XYZ)

# assumptions
# - pos_b is greater than (not equal) to pos_a
# - pos_a is greater than or equal to Vector3i(0,0,0)
# - pos_b is less than or equal to Vector3i(1<<depth, 1<<depth, 1<<depth)
func fill_aabb(pos_a: Vector3i, pos_b: Vector3i, depth: int, new_val: bool):
	for i in range(8):
		# pos_a.y >> depth			means the aabb is only in the top
		# not(pos_a.y >> depth)		means the aabb extends to the bottom
		# pos_b.y >> depth		 	means the aabb extends to the top
		# not(pos_b.y >> depth)		means the aabb is only in the bottom
		# i & 2			means i is in top
		# not(i & 2)		means i is in bottom
		# not(pos_a.y >> depth) if i & 2 else pos_b.y >> depth		means if it extends to the side that i is on
		# pos_b.y >> depth if i & 2 else not(pos_a.y >> depth)		means if it does not extend to the side that i is on
		if not(pos_b.x >> depth) if i & 4 else pos_a.x >> depth: continue
		if not(pos_b.y >> depth) if i & 2 else pos_a.y >> depth: continue
		if not(pos_b.z >> depth) if i & 1 else pos_a.z >> depth: continue
		# code executing here is garenteed to have an i that is inside the aabb
		
		var elm: OctTree = get_elm(i)
		
		if depth == 0:
			if elm != null: # if not a leaf - make it so
				elm.free()
				elm = null
				set_elm(i, elm)
			
			if new_val:
				value |= 1 << i # fill single
			else:
				value &= ~(1 << i) # clear single
		else:
			
			var next_pos_a: Vector3i = Vector3i()
			var next_pos_b: Vector3i = Vector3i()
			if i & 4:
				next_pos_a.x = max(pos_a.x - (1<<depth), 0)
				next_pos_b.x = max(pos_b.x - (1<<depth), 1)
			else:
				next_pos_a.x = min(pos_a.x, (1<<depth)-1)
				next_pos_b.x = min(pos_b.x, 1<<depth)
			if i & 2:
				next_pos_a.y = max(pos_a.y - (1<<depth), 0)
				next_pos_b.y = max(pos_b.y - (1<<depth), 1)
			else:
				next_pos_a.y = min(pos_a.y, (1<<depth)-1)
				next_pos_b.y = min(pos_b.y, 1<<depth)
			if i & 1:
				next_pos_a.z = max(pos_a.z - (1<<depth), 0)
				next_pos_b.z = max(pos_b.z - (1<<depth), 1)
			else:
				next_pos_a.z = min(pos_a.z, (1<<depth)-1)
				next_pos_b.z = min(pos_b.z, 1<<depth)
			
			if next_pos_a == Vector3i(0,0,0) and next_pos_b == Vector3i(1<<depth,1<<depth,1<<depth): # if the whole block needs to be filled
				if elm != null: # it will be contiguous
					elm.free()
					elm = null
					set_elm(i, elm)
				if new_val:
					value |= 1 << i
				else:
					value &= ~(1 << i)
			else:
				if elm == null: # its contiguous
					var old_val: bool = (value >> i) & 1
					if old_val == new_val: continue # its already correct
					# it is not already correct
					elm = OctTree.new(255 if old_val else 0)
					set_elm(i, elm)
					elm.fill_aabb(next_pos_a, next_pos_b, depth-1, new_val)
					pass
				else: # it is not contiguous
					elm.fill_aabb(next_pos_a, next_pos_b, depth-1, new_val)
					var fill: int = elm.get_filled_in_this_layer()
					# correct the LOD which is value
					if fill > 4:
						value |= 1 << i
					else:
						value &= ~(1 << i)
					if (fill == 0 or fill == 8) and elm.is_leaf(): # its now contiguous so we long need the subdivision
						elm.free()
						elm = null
						set_elm(i, elm)
