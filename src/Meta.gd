extends Node


const abilities_res_folder := "res://Assets/Custom/Abilities/"


var bag := [20, 20, 20, 20, 20, 4]
var abilities := [
	load(abilities_res_folder + "Fire.tres"),
	load(abilities_res_folder + "Hammer.tres"),
	load(abilities_res_folder + "Link.tres"),
	load(abilities_res_folder + "Lightning.tres"),
	load(abilities_res_folder + "Recolor.tres")
]

var current_level := Level.new()
var hiscores := {}


func _ready():
	var file = File.new()
	if !file.file_exists("user://hiscores.dat"):
		return
		
	file.open("user://hiscores.dat", File.READ)
	hiscores = file.get_var()


func set_hiscore(level:String, score:int):
	hiscores[level] = score

	var file = File.new()
	file.open("user://hiscores.dat", File.WRITE)
	file.store_var(hiscores)
