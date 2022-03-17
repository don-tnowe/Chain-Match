# tool
class_name Ability
extends Control

signal activated
signal cancelled

onready var node_board
onready var node_button := $"Button"
onready var node_icon := $"Icon"
onready var node_bar_fill := $"Bar/Fill"
onready var node_bar_label := $"Bar/Label"
onready var node_bar_count := $"Bar/Count"
onready var node_tween := $"Tween"

var data setget set_ability
var actions
var charges_held := 0
var charges_full := false
var recharge := 0


func _ready():
	set_ability(Meta.abilities[get_position_in_parent()])
	node_button.shortcut.shortcut.scancode += get_position_in_parent()
	update_charge_count()
	charge(0)


func set_ability(v):
	if v == null || !is_inside_tree():
		visible = false
		return

	visible = true
	data = v
	$"Labels/Label".text = v.name
	$"Labels/Label2".text = v.description
	node_icon.texture = v.icon
	node_bar_fill.self_modulate = v.color
	node_bar_fill.max_value = v.charge_needed
	node_bar_fill.value = recharge
	actions = v.actions.new()
	$"SoundCharged".stream = v.sfx_ready
	$"SoundSelect".stream = v.sfx_select
	$"SoundActivate".stream = v.sfx_activate


func update_charge_count():
	var has = charges_held > 0

	node_bar_count.text = "x" + str(charges_held)
	node_bar_count.visible = has
	node_button.disabled = !has
	node_button.self_modulate = data.color if has else Color.gray

	charges_full = charges_held == data.max_charges


func charge(amount:int = 1):
	recharge += amount * Meta.current_level.abil_mult

	if recharge >= data.charge_needed:
		if charges_held <= data.max_charges - 2:
			charges_held += 1
			recharge -= data.charge_needed
			node_bar_fill.value = 0
		
		else:
			charges_held = data.max_charges
			recharge = data.charge_needed
			node_bar_fill.value = recharge
		
		if !charges_full:
			node_tween.interpolate_property(
				$"Control/Control/Flash", "scale:x",
				rect_size.length(), 0, 1,
				Tween.TRANS_CUBIC, Tween.EASE_OUT 
			)
			$"SoundCharged".play()

		update_charge_count()
	
	node_bar_label.text = str(floor(data.charge_needed - recharge))
	# node_bar_fill.value = recharge

	node_tween.interpolate_property(
		node_bar_fill, "value", 
		node_bar_fill.value, recharge, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		node_icon, "rect_scale", 
		Vector2(0.2, 0.2), Vector2.ONE, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	node_tween.start()


func select():
	if charges_held < 1:
		return 

	get_tree().set_input_as_handled()

	if node_board.selected_ability == self:
		release()
		node_board.selected_ability = null
		node_board.highlight_all_gems()
		return

	if node_board.selected_ability != null:
		node_board.selected_ability.release(true)
		
	node_board.selected_ability = self
	node_board.highlight_all_gems()
	node_button.self_modulate = data.color * 2
	$"SoundSelect".play()


func release(chosen_another:bool = false):
	update_charge_count()
	actions.cancel()
	if !chosen_another:
		emit_signal("cancelled")


func activate() -> bool:
	if actions.activate(node_board, node_board.selected_gem):
		if charges_held == data.max_charges:
			recharge -= data.charge_needed
			charge(0)
	
		charges_held -= 1
		update_charge_count()
		emit_signal("activated")
		$"SoundActivate".play()
		return true
	
	$"SoundClick".play()
	return false


func can_cast() -> bool:
	return actions.can_cast(node_board, node_board.selected_gem)


func get_highlight_color(gem:Gem) -> Color:
	return actions.get_highlight_color(gem, node_board.selected_gem)
