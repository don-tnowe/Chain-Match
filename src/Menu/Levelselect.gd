extends Control

export(Array, Resource) var levels = []
export(Array, Texture) var areas = []
export(ButtonGroup) var areas_buttongroup

onready var node_areas = $"../Areas"


func _ready():
	for i in node_areas.get_child_count():
		var x = node_areas.get_child(i)
		x.icon = areas[i]
		x.connect("pressed", self, "select_area", [i])
	
	for i in get_child_count():
		var x = get_child(i)
		x.text = levels[i].name
		x.connect("pressed", self, "select", [i])
	
	select_area(0)


func select(idx:int):
	var area_idx = areas_buttongroup.get_pressed_button().get_position_in_parent()
	Meta.current_level = levels[idx].duplicate()
	Meta.current_level.name += "_" + str(area_idx)
	Meta.current_level.board_layout = areas[area_idx]
	
	get_tree().change_scene("res://src/Main/Main.tscn")


func select_area(idx:int):
	for i in get_child_count():
		var lvlname = str(get_child(i).text + "_" + str(idx))
		if lvlname in Meta.hiscores:
			get_child(i).self_modulate = Color.white
			get_child(i).get_node("Label").text = "HIGHSCORE: " + str(Meta.hiscores[lvlname])

		else:
			get_child(i).self_modulate = Color(2, 2, 2, 1)
			get_child(i).get_node("Label").text = ""
		
