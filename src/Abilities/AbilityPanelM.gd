extends Control


onready var node_buttons = $"Buttons"
onready var node_panel = $"Panel"
onready var node_tween = $"Tween"


func _ready():
	for x in node_buttons.get_children():
		x.get_node("Button").connect("button_down", self, "set_opened", [x, true])
		x.connect("activated", self, "set_opened", [x, false])
		x.connect("cancelled", self, "set_opened", [x, false])
		set_opened(x, false)


func set_opened(x:Control, opened:bool):
	$"Panel/Label".text = x.get_node("Labels/Label").text
	$"Panel/Label2".text = x.get_node("Labels/Label2").text
	node_panel.self_modulate = x.node_button.self_modulate

	node_tween.interpolate_property(
		node_panel, "margin_bottom", 
		node_panel.margin_bottom, 224 if opened else node_panel.margin_top, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	node_tween.start()
