extends Control


export var scrolls_x := true
export var scrolls_y := true
export var threshold := 16.0
export(Array, NodePath) var scrollable_containers


var scrolled_node
var pressed_node
var pressed_node_was_disabled := false
var scrolled_dist := Vector2()


func _ready():
	for x in scrollable_containers:
		for y in get_node(x).get_children():
			y.connect("button_down", self, "button_down", [y])


func _input(event):
	if event is InputEventScreenDrag:
		if scrolled_node == null:
			return

		if scrolls_x:
			scrolled_dist.x += event.relative.x
			scrolled_node.rect_position.x += event.relative.x

		if scrolls_y:
			scrolled_dist.y += event.relative.y
			scrolled_node.rect_position.y += event.relative.y

		scrolled_node.rect_position = Vector2(
			clamp(
				scrolled_node.rect_position.x, 
				rect_position.x + rect_size.x - scrolled_node.rect_size.x, 
				rect_position.x
				),
			clamp(
				scrolled_node.rect_position.y, 
				rect_position.y,
				rect_position.y + rect_size.y - scrolled_node.rect_size.y
				)
		)
		
		if scrolled_dist.length_squared() > threshold * threshold: 
			pressed_node.disabled = true

	elif event is InputEventScreenTouch:
		if !event.pressed:
			scrolled_dist = Vector2()
			if is_instance_valid(pressed_node):
				pressed_node.disabled = pressed_node_was_disabled
		

func button_down(x:Control):
	scrolled_node = x.get_parent()
	pressed_node = x
	pressed_node_was_disabled = x.disabled
	
