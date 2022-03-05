tool
extends EditorScript


func _run():
	var children = get_editor_interface().get_selection().get_selected_nodes()[0].get_children()
	for i in children:
		i.position = Vector2(
			round(i.position.x),
			round(i.position.y)
		)
