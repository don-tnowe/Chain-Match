extends Node

onready var brd := get_parent()
onready var node_board_tl := $"../TL"

var selected_gem:Gem = null
var last_click_msec:int = 0


func input_on_gem(_viewport:Node, event:InputEvent, _shape_idx:int, gem:Gem):
	if event is InputEventScreenTouch:
		if event.index > 0: 
			return

		if event.pressed:
			if brd.chain_tip == null:
				selected_gem = gem
				if brd.selected_ability == null:
					brd.start_chain(gem)

		else: 
			brd.stop_chain()
			mouse_leave_board()

	elif event is InputEventMouseButton:
		selected_gem = gem

		if (
			event.button_index == BUTTON_LEFT
			&& event.pressed
			&& brd.selected_ability == null 
			&& brd.chain_tip == null
			&& OS.get_ticks_msec() > last_click_msec + 17
		):
			last_click_msec = OS.get_ticks_msec()
			brd.start_chain(gem)

	if event is InputEventScreenDrag || event is InputEventMouseMotion:
		if selected_gem != gem:
			selected_gem = gem
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
			if !event.pressed:
				if brd.selected_ability != null:
					last_click_msec = OS.get_ticks_msec()
					brd.selected_gem = selected_gem
					brd.activate_ability()
					mouse_leave_board()
			
				elif brd.chain_tip != null && OS.get_ticks_msec() > last_click_msec + 100:
					last_click_msec = OS.get_ticks_msec()
					mouse_leave_board()
					brd.stop_chain()

		elif event.button_index == BUTTON_RIGHT:
			brd.stop_chain(true)
			
	elif event is InputEventKey:
		if event.is_action("ui_cancel"):
			brd.stop_chain(true)


func mouse_leave_board():
	if !is_instance_valid(selected_gem):
		return
		
	if !is_instance_valid(brd.chain_tip):
		selected_gem = null
		brd.selected_gem = null
		brd.highlight_all_gems()
