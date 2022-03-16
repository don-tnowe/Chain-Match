extends Control


onready var node_buttons = $"Buttons"
onready var node_tween = $"Tween"


var size_in = 86.8
var is_closed = true


func _ready():
	for x in node_buttons.get_children():
		x.get_node("Button").connect("button_down", self, "press", [x])


func press(x):
	is_closed = !is_closed

	if is_closed:
		open(x)

	else:
		close(x)


func open(x:Control):
	node_tween.interpolate_property(
		x, "anchor_left", 
		x.anchor_left, 0, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		x, "anchor_right", 
		x.anchor_right, 1.0, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	move_child(x, get_child_count())
	node_tween.start()


func close(x:Control):
	var width = 1.0 / x.get_parent().get_child_count()
	var left = x.get_position_in_parent() * width
	node_tween.interpolate_property(
		x, "anchor_left", 
		x.anchor_left, left, 0.5,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		x, "anchor_right", 
		x.anchor_right, left + width, 0.5,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	node_tween.start()