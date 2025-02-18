extends Node3D

func _ready() -> void:
	$thing.depth = %detail.value
	$thing.fill_AABB(AABB(Vector3(0,0,0),Vector3(1,0.07,1)), true)
	print("rendering...")
	$thing.visualize()
	print("done!")

func get_cam_pos() -> Vector3:
	return $Camera3D.global_position * $thing.global_transform.affine_inverse()

func _on_copy_position_pressed() -> void:
	%x1.value = get_cam_pos().x
	%y1.value = get_cam_pos().y
	%z1.value = get_cam_pos().z


func _on_copy_position_2_pressed() -> void:
	%x2.value = get_cam_pos().x
	%y2.value = get_cam_pos().y
	%z2.value = get_cam_pos().z


func get_aabb() -> AABB:
	return AABB(
		Vector3(
			min(%x1.value, %x2.value),
			min(%y1.value, %y2.value),
			min(%z1.value, %z2.value),
		),
		Vector3(
			abs(%x1.value - %x2.value),
			abs(%y1.value - %y2.value),
			abs(%z1.value - %z2.value)
		)
	)


func _on_fill_button_pressed() -> void:
	print("proccessing...")
	$thing.fill_AABB(get_aabb(), true)
	print("rendering...")
	$thing.visualize()
	print("done!")


func _on_clear_button_pressed() -> void:
	print("proccessing...")
	$thing.fill_AABB(get_aabb(), false)
	print("rendering...")
	$thing.visualize()
	print("done!")


func _on_reset_button_pressed() -> void:
	print("proccessing...")
	$thing.reset()
	print("rendering...")
	$thing.visualize()
	print("done!")


func _on_detail_value_changed(value: float) -> void:
	$thing.depth = value
