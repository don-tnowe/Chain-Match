class_name Board
extends Control

export(Array, NodePath) var pip_collectors := []
export(PackedScene) var scene_gem

onready var node_board := $"TL/Board"
onready var node_line := $"TL/Line"
onready var node_tween := $"Tween"
onready var objective := $"Objective"

const tile_idx_by_color := [
	Color.black
]
const highlighted_color := Color(2, 2, 2, 1)
const unhighlighted_color := Color(0.3, 0.3, 0.3, 1)

var board_cell_size := Vector2(48, 48)
var board_contents := {}
var board_rect := Rect2()
var bag_draw : Array = Meta.bag.duplicate()
var bag_discard := [0, 0, 0, 0, 0, 0]

var chain_tip : Gem
var selected_gem : Gem

var selected_ability


func _ready():
	randomize()
	board_cell_size = node_board.cell_size
	load_board(Meta.current_level.board_layout)


func load_board(texture:Texture):
	var fall_from = {}
	var img = texture.get_data()
	img.lock()
	node_board.clear()

	for i in img.get_size().x:
		for j in img.get_size().y:
			var tile = tile_idx_by_color.find(img.get_pixel(i, j))
			node_board.set_cell(i, j, tile, false, false, false, Vector2((i + j) % 2, 0))

			if tile == 0:
				var gem = scene_gem.instance()
				node_board.add_child(gem)
				gem.connect("mouse_entered", self, "mouse_enter_gem", [gem])
				gem.position = Vector2(i, j) * board_cell_size + board_cell_size * 0.5
		
				board_contents[gem.position] = gem
				fall_from[gem.position] = Vector2(0, -img.get_size().y * board_cell_size.y)
				board_rect = board_rect.expand(gem.position)
			
	$"TL".position -= img.get_size() * node_board.cell_size * 0.5 
	img.unlock()

	drop_chain(fall_from)
	node_tween.start()


func mouse_enter_gem(gem:Gem):
	var last_selected_gem = selected_gem
	selected_gem = gem
	highlight_all_gems()

	if chain_tip == null:
		gem.modulate = highlighted_color
		if is_instance_valid(last_selected_gem) && last_selected_gem.modulate == highlighted_color:
			last_selected_gem.modulate = Color.white

		return

	# If it's the chain's last gem, no action.
	if chain_tip == gem && chain_tip.idx_in_chain > 1:
		return

	# if it's in the chain, trace chain back 
	if gem.idx_in_chain != -1:
		# (but not too far back!)
		if chain_tip.idx_in_chain - gem.idx_in_chain > 2:
			return

		while chain_tip != gem:
			var p = chain_tip.prev
			chain_tip.idx_in_chain = -1
			chain_tip.prev = null
			chain_tip = p

		set_chain_tip(chain_tip)
		return

	# check if gem connects
	var diff = (gem.position - chain_tip.position).abs()
	if diff.x > board_cell_size.x || diff.y > board_cell_size.y:
		return

	elif chain_tip.color != 5 && gem.color != 5 && gem.color != chain_tip.color:
		return
	
	# add to chain
	gem.prev = chain_tip
	gem.idx_in_chain = chain_tip.idx_in_chain + 1
	set_chain_tip(gem)


func set_chain_tip(gem:Gem):
	var chain = gem.get_chain()
	var points = []
	points.resize(chain.size())

	for i in points.size():
		points[i] = chain[i].position

	node_line.points = PoolVector2Array(points)

	chain_tip = gem
	objective.preview_score(chain)
	highlight_all_gems()

	$"SoundConnect".global_position = gem.global_position
	$"SoundConnect".pitch_scale = pow(2, chain_tip.idx_in_chain / 12.0)
	$"SoundConnect".play()


func collect_chain(chain:Array, gives_charges:bool = true, score_mult:float = 1):
	var fall_vec = Vector2(0, -board_cell_size.y)
	var fall_from = {}

	chain.sort_custom(self, "compare_y")

	for gem in chain: 
		var gem_pos = gem.position
		var pos = gem_pos - (fall_from[gem_pos] if gem_pos in fall_from else Vector2.ZERO)

		while pos in board_contents:
			fall_from[pos] = (fall_from[pos] if pos in fall_from else Vector2.ZERO) + fall_vec
			pos += fall_vec
		
		board_contents[gem_pos].emit_particles()
		if gives_charges:
			play_collect_vfx(board_contents[gem_pos], chain)
			
	objective.score_chain(chain, score_mult, node_tween)
	drop_chain(fall_from)
	node_tween.start()

	# $"SoundChainEnd".pitch_scale = 2 / (chain.size() * 0.1 + 1)
	$"SoundChainEnd".pitch_scale = 2 / (chain.size() * 0.3)
	$"SoundChainEnd".volume_db = chain.size() * 0.5 - 9
	$"SoundChainEnd".play()
	

func play_collect_vfx(gem:Gem, chain:Array):
	if gem.color >= 5:
		return

	var time1 = 0.5
	var time_wait = randf() * chain.size() * 0.05
	var time2 = 0.5
	var collector = get_node(pip_collectors[gem.color])

	# position
	var dest1 = gem.global_position + Vector2(randf() - 0.5, randf() - 0.5) * 192
	var dest2 = collector.global_position
	node_tween.interpolate_property(
		gem.node_collected_pip, "global_position",
		gem.global_position, dest1, time1,
		Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		gem.node_collected_pip, "global_position",
		dest1, dest2, time2,
		Tween.TRANS_QUART, Tween.EASE_IN, time1 + time_wait
	)
	if collector.get_parent().has_method("charge"):
		node_tween.interpolate_callback(collector.get_parent(), time1 + time2 + time_wait, "charge")
	
	# angle
	gem.node_collected_pip.rotation = gem.global_position.angle_to_point(dest1)
	node_tween.interpolate_callback(gem.node_collected_pip, time1, "look_at", dest2)
	
	# scale
	var scale1 = Vector2(0.3, 0.3)
	var scale2 = Vector2(1, 0.2)
	node_tween.interpolate_property(
		gem.node_collected_pip, "scale",
		Vector2(1.5, 0.33), scale1, time1,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		gem.node_collected_pip, "scale",
		scale1, scale2, time2,
		Tween.TRANS_QUART, Tween.EASE_IN, time1 + time_wait
	)
	node_tween.interpolate_property(
		gem.node_collected_pip, "scale",
		scale2, Vector2(0, 2), 0.1,
		Tween.TRANS_CUBIC, Tween.EASE_OUT, time1 + time2 + time_wait
	)

	# color
	node_tween.interpolate_property(
		gem.node_collected_pip, "modulate",
		Color.white, gem.self_modulate, time1
	)
	gem.set_color(get_random_gem_color())

	# sfx
	node_tween.interpolate_callback($"SoundCollect", time1 + time2 + time_wait, "play")


func drop_chain(fall_from:Dictionary):
	var new_colors = {}
	var falling_positions = fall_from.keys()
	var edge = Vector2()

	for x in falling_positions:
		if x.x < edge.x:
			edge.x = x.x

		if x.y > edge.y:
			edge.y = x.y 

	for x in falling_positions:
		if !(x + fall_from[x] in board_contents):
			new_colors[x] = get_random_gem_color()
			node_tween.interpolate_property(
				board_contents[x].node_sprite, "modulate",
				Color(4, 4, 4, 0), Color.white, 0.5,
				Tween.TRANS_QUART, Tween.EASE_IN
			)

		else:
			new_colors[x] = board_contents[x + fall_from[x]].color
			
		play_fall_animation(x, fall_from[x], edge)

	for x in new_colors:
		board_contents[x].set_color(new_colors[x])


func play_fall_animation(gem_pos:Vector2, fall_from:Vector2, edge:Vector2):
	var anim_time = 0.5
	var anim_delay = (
		abs(gem_pos.y - edge.y)
		+ abs(gem_pos.x - edge.x)
	) * 0.001 + 0.05
	var kickback = Vector2((randf() - 0.5) * 8, -16)

	node_tween.interpolate_property(
		board_contents[gem_pos].node_sprite, "position",
		fall_from, fall_from + kickback, anim_delay,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		board_contents[gem_pos].node_sprite, "position",
		fall_from + kickback, Vector2(0, -0.5 * kickback.y), anim_time,
		Tween.TRANS_QUART, Tween.EASE_IN, anim_delay
	)
	node_tween.interpolate_property(
		board_contents[gem_pos].node_sprite, "position",
		Vector2(0, -0.5 * kickback.y), Vector2(), 0.1,
		Tween.TRANS_CUBIC, Tween.EASE_OUT, anim_delay + anim_time
	)
	node_tween.interpolate_callback($"SoundFall", anim_delay + anim_time, "play")


func start_chain(gem:Gem):
	chain_tip = gem
	chain_tip.idx_in_chain = 1
	mouse_enter_gem(chain_tip)


func stop_chain(interrupt:bool = false):
	if interrupt && selected_ability != null:
		selected_ability.release()
		selected_ability = null
		highlight_all_gems()

	if chain_tip == null:
		return

	if !interrupt && chain_tip.idx_in_chain >= 3:
		collect_chain(chain_tip.get_chain())
		objective.turns_since_start += 1

	objective.unpreview_score()
	chain_tip.clear_chain()
	
	chain_tip = null
	node_line.points = PoolVector2Array()

	highlight_all_gems()


func activate_ability():
	if selected_ability.can_cast() && selected_ability.activate():
		stop_chain(true)		


func highlight_all_gems():
	if selected_ability != null:
		for x in board_contents:
			board_contents[x].modulate = selected_ability.get_highlight_color(board_contents[x])
			
	else:
		for x in board_contents:
			board_contents[x].modulate = get_highlight_color(board_contents[x])


func get_highlight_color(gem:Gem):
	if chain_tip == null:
		return Color.white

	if gem.idx_in_chain != -1:
		return highlighted_color

	if gem.color == 5 || chain_tip.color == 5:
		return Color.white

	if chain_tip.color == gem.color:
		return Color.white

	return unhighlighted_color


func get_random_gem_color():
	var sum = 0
	for x in bag_draw:
		sum += x
	
	if sum == 0:
		var swap = bag_draw
		bag_draw = bag_discard
		bag_discard = swap
		for x in bag_draw:
			sum += x

	var rand = randi() % sum
	for i in bag_draw.size():
		if rand >= bag_draw[i]:
			rand -= bag_draw[i]
		
		else:
			bag_draw[i] -= 1
			bag_discard[i] += 1
			return i


func compare_y(a:Gem, b:Gem):
	if a.position.y == b.position.y:
		return a.position.x > b.position.x

	else:
		return a.position.y > b.position.y


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if selected_ability != null:
					activate_ability()

				elif selected_gem != null:
					start_chain(selected_gem)

			else:
				stop_chain()

		elif event.button_index == BUTTON_RIGHT:
			stop_chain(true)
			
	elif event is InputEventKey:
		if event.is_action("ui_cancel"):
			stop_chain(true)


func mouse_leave_board():
	if !is_instance_valid(selected_gem):
		return
		
	if !is_instance_valid(chain_tip):
		selected_gem.modulate = Color.white
		selected_gem = null
				
