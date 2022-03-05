class_name AbilityActions
extends Reference


func can_cast(board:Board, _selected_gem:Gem) -> bool:
	return board.selected_gem != null


func get_highlight_color(gem:Gem, selected_gem:Gem) -> Color:
	return Board.unhighlighted_color if gem != selected_gem else Color.white


# Returns true if it modified board state and used up a charge.
func activate(board:Board, gem:Gem) -> bool:
	board.collect_chain([gem.position])
	return true


# Override if the ability takes multiple targets.
func cancel():
	pass