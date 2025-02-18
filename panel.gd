extends Control

var t: float = 1
var chilling: bool = true
var show: bool = true

func _process(delta: float) -> void:
	if chilling: return
	if show:
		t += delta * 5
		if t >= 1:
			t = 1
			chilling = true
	else:
		t -= delta * 5
		if t <= 0:
			t = 0
			chilling = true
			visible = false
	
	rotation = pow(1 - t, 3) * 1.5707963268



func _on_show_options_toggled(toggled_on: bool) -> void:
	show = toggled_on
	chilling = false
	visible = true
