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
	var rainbow_only = true

	for gem in chain:
		if gem.color != 5:
			result += 10
			rainbow_only = false
		
		else:
			result += 40
		
	# Every three gems add a 0.5x multiplier.
	if chain.size() >= 3:
		result *= (chain.size() / 3) * 0.5 + 0.5

	# A sacrifice for victory.
	if rainbow_only:
		result *= chain.size()

	return result * score_mult * Meta.current_level.score_mult
		

func preview_score(chain:Array, score_mult:float = 1):
	node_score2.visible = true
	node_score2.text = "+" + str(calculate_score(chain, score_mult))


func unpreview_score():
	node_score2.visible = false

	
func score_chain(chain:Array, score_mult:float = 1, node_tween:Tween = null):
	unpreview_score()
	set_score(score + calculate_score(chain, score_mult))

	if is_instance_valid(node_tween):
		node_tween.interpolate_property(
			node_score.get_parent(), "scale",
			Vector2.ONE * 2, Vector2.ONE, 1,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT
		)


func set_score(v:int):
	score = v


func update_fail(countdown:int):
	node_fail_counter.text = str(level.fail_countdown - countdown)
		
	if countdown > level.fail_countdown:
		fail()


func fail():
	if Meta.hiscores.get(level.name, 0) < score:
		Meta.set_hiscore(level.name, score)
	
	$"TimerSeconds".stop()
	emit_signal("failed", score)
		

func set_turns(v):
	turns_since_start = v
	if level.fail_objective == Level.FAIL_TURNS:
		update_fail(v)

	if v == 1:
		$"TimerSeconds".start()


func set_seconds(v):
	seconds_since_start = v
	if level.fail_objective == Level.FAIL_TIME:
		update_fail(v)

		
func increment_second():
	set_seconds(seconds_since_start + 1)

