extends Reference

export var difficulty := 1.0
export var min_difficulty := 1.0
export var max_difficulty := 10.0
export var turns_reward := 3.0

var board:Board
var manager:ObjectiveManager


func chain_updated(chain:Array):
  pass


func chain_collected(chain:Array):
  pass


func _to_string():
  return "Do nothing!!!"

