tool
class_name Gem
extends Area2D


export(Array, Resource) var types
export(bool) var emit_particle setget emit_particles

onready var node_sprite = $"Sprite"
onready var node_collected_pip = $"CollectedPip"

var color := 0 setget set_color
var idx_in_chain := -1
var prev : Gem


func _process(_delta):
	if idx_in_chain != -1:
		node_sprite.position = Vector2(randf() - 0.5, randf() - 0.5) * 4


func set_color(c:int):
	color = c
	node_sprite.frame = c
	self_modulate = types[c].color


func clear_chain():
	var cur = self
	for i in idx_in_chain:
		var p = cur.prev
		cur.prev = null
		cur.idx_in_chain = -1
		cur = p


func emit_particles(_x = true):
	emit_particle = false
	$"Ptcl/Color".process_material.color_ramp = types[color].color_ramp
	$"Ptcl/Color".restart()
	$"Ptcl/Color".emitting = true
	$"Ptcl/White".restart()
	$"Ptcl/White".emitting = true


func get_chain() -> Array:
	var arr = Array()
	arr.resize(idx_in_chain)
	var cur = self
	for i in idx_in_chain:
		arr[i] = cur
		cur = cur.prev
	
	return arr


func _to_string():
	return str({
		"color": color,
		"in chain": idx_in_chain,
		"pos": position
	})
