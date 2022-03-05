extends Control


func display(end_score:int):
	visible = true
	$"Anim".play("Init")
	$"ScoreScaler/Score".text = str(end_score)
	$"HighscoreScaler/Highscore".text = str(Meta.hiscores[Meta.current_level.name])
	$"Sound".play()


func exit():
	get_tree().change_scene("res://src/Menu/Levelselect.tscn")  # TMP
