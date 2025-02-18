extends Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var scaled_mouse_movement: Vector2 = event.relative * 0.001
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			basis = basis.rotated(basis.z.normalized(), scaled_mouse_movement.x)
		else:
			basis = basis.rotated(-basis.y.normalized(), scaled_mouse_movement.x).rotated(-basis.x.normalized(), scaled_mouse_movement.y)
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton:
		if event.is_pressed():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position -= basis.z * delta
	if Input.is_action_pressed("ui_down"):
		position += basis.z * delta
	if Input.is_action_pressed("ui_left"):
		position -= basis.x * delta
	if Input.is_action_pressed("ui_right"):
		position += basis.x * delta
	if Input.is_action_pressed("ui_page_up"):
		position += basis.y * delta
	if Input.is_action_pressed("ui_page_down"):
		position -= basis.y * delta
