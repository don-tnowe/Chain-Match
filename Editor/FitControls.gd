tool
extends EditorScript


func _run():
	var children = get_editor_interface().get_selection().get_selected_nodes()[0].get_children()
	var increment = 1.0 / children.size()
	var cur_top = 0
	for i in children:
		i.anchor_top = cur_top
		cur_top += increment
		i.anchor_bottom = cur_top
