extends Node

onready var brd = get_parent()
onready var node_board_tl := $"../TL"


func input_on_gem(_viewport:Node, event:InputEvent, _shape_idx:int, gem:Gem):
	if event is InputEventScreenTouch:
		if event.pressed:
			brd.selected_gem = gem
			if brd.selected_ability == null:
				brd.stop_chain(true)  # Apparently the input_event signal is emmitted after tree _input 
				brd.start_chain(gem)

	elif event is InputEventMouseMotion || event is InputEventScreenDrag:
		if brd.selected_gem != gem:
			brd.mouse_enter_gem(gem)


func _unhandled_input(event):
	if event is InputEventScreenDrag:
		if event.index > 0: 
			node_board_tl.position += event.relative
			node_board_tl.position = Vector2(
				clamp(node_board_tl.position.x, -brd.board_rect.size.x, 0),
				clamp(node_board_tl.position.y, -brd.board_rect.size.y, 0)
			)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if (
						brd.selected_ability == null 
						&& brd.selected_gem != null 
						&& !is_instance_valid(brd.chain_tip)
					):
					brd.start_chain(brd.selected_gem)

			else:
				if brd.selected_ability != null:
					brd.activate_ability()

				brd.stop_chain()

		elif event.button_index == BUTTON_RIGHT:
			brd.stop_chain(true)
			
	elif event is InputEventKey:
		if event.is_action("ui_cancel"):
			brd.stop_chain(true)


func mouse_leave_board():
	var selected_gem = brd.selected_gem

	if !is_instance_valid(selected_gem):
		return
		
	if !is_instance_valid(brd.chain_tip):
		selected_gem.modulate = Color.white
		selected_gem = null
