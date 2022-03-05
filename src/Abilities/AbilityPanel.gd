extends Control


onready var node_buttons = $"Buttons"
onready var node_tween = $"Tween"


var size_in = 170
var size_out = 520
var size_selected = 40
var is_closing = true


func _ready():
	for x in node_buttons.get_children():
		x.get_node("Button").connect("mouse_entered", self, "mouse_entered", [x])
		x.get_node("Button").connect("mouse_exited", self, "mouse_exited", [x])


func mouse_entered(target:Control):
	is_closing = false
	target.margin_right = size_selected
	if target.charges_held > 0:
		node_tween.interpolate_property(
			target.node_button, "modulate", 
			Color(2, 2, 2, 1), Color.white, 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
	$"Sound".pitch_scale = 1.5
	$"Sound".play()

	if node_tween.is_active():
		yield(node_tween, "tween_all_completed")
	
	node_tween.start()

	if !is_closing:
		open()


func mouse_exited(target:Control):
	target.margin_right = 0
	$"Sound".pitch_scale = 0.66
	$"Sound".play()

	if node_tween.is_active():
		is_closing = true
		yield(node_tween, "tween_all_completed")
		if is_closing:
			close()

	else:
		close()


func open():
	node_tween.interpolate_property(
		node_buttons, "margin_right", 
		node_buttons.margin_right, size_out, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	node_tween.start()


func close():
	is_closing = true
	node_tween.interpolate_property(
		node_buttons, "margin_right", 
		node_buttons.margin_right, size_in, 0.66,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	)
	node_tween.start()
