extends Node


export(NodePath) var path_board
export(Array, PackedScene) var scene_abilities := [null, null]
export(Array, int) var board_top := [0, 136]

func _ready():
	if OS.window_size.x > OS.window_size.y:
		call_deferred("align", 0)
	
	else:
		call_deferred("align", 1)


func align(platform_idx:int):
	var abis = scene_abilities[platform_idx].instance()
	var brd = get_node(path_board)
	
	brd.margin_top = board_top[platform_idx]
	get_parent().add_child(abis)
	
	for i in abis.node_buttons.get_child_count():
		var x = abis.node_buttons.get_child(i)
		brd.pip_collectors[i] = x.get_node("Collect")
		x.node_board = brd

	
