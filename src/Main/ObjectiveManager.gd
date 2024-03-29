class_name ObjectiveManager
extends Node

signal failed(end_score)

export(NodePath) onready var node_fail_counter = get_node(node_fail_counter) as Label
export(NodePath) onready var node_score = get_node(node_score) as Label
export(NodePath) onready var node_score2 = get_node(node_score2) as Label

onready var level := Meta.current_level

var score := 0 setget set_score
var displayed_score := 0

var seconds_since_start := 0 setget set_seconds
var turns_since_start := 0 setget set_turns


func _process(_delta):
	if displayed_score != score:
		displayed_score += int(ceil((score - displayed_score) / 60.0))
		node_score.text = str(displayed_score)
		node_score.modulate = Color().from_hsv(displayed_score * 0.01, (score - displayed_score) * 0.05, 1)


func calculate_score(chain:Array, score_mult:float = 1) -> int:
	var result = 0
	var length_mult = 1
	# var length_mult = pow(1.5, chain.size() / 2 - 1)

	for gem in chain:
		if gem.color != 5:
			result += 10
		
		else:
			result += 30
			
	# Every two gems add a 0.5x multiplier.
	if chain.size() >= 3:
		result *= (chain.size() - 3) / 2 * 0.5 + 1

	return int(result * length_mult * score_mult * Meta.current_level.score_mult)
		

func preview_score(chain:Array, score_mult:float = 1):
	node_score2.visible = true
	node_score2.text = "+" + str(calculate_score(chain, score_mult))


func unpreview_score():
	node_score2.visible = false

	
func score_chain(chain:Array, score_mult:float = 1):
	unpreview_score()
	set_score(score + calculate_score(chain, score_mult))
	$"../Animation".pulse(node_score.get_parent())


func set_score(v:int):
	score = v


func update_fail(countdown:int):
	var left = level.fail_condition.countdown - countdown
	node_fail_counter.text = str(left)
		
	if left == 0:
		fail()


func fail():
	if Meta.hiscores.get(level.name, 0) < score:
		Meta.set_hiscore(level.name, score)
	
	$"TimerSeconds".stop()
	emit_signal("failed", score)
		

func set_turns(v):
	turns_since_start = v

	if v == 1:
		$"TimerSeconds".start()
		
	if !is_instance_valid(level.fail_condition):
		return
		
	if level.fail_condition.type == FailCondition.TURNS:
		update_fail(v)


func set_seconds(v):
	seconds_since_start = v
	
	if !is_instance_valid(level.fail_condition):
		return
		
	if level.fail_condition.type == FailCondition.TIME:
		update_fail(v)

		
func increment_second():
	set_seconds(seconds_since_start + 1)

