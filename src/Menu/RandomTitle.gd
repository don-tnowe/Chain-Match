extends Label

export(Array, String) var texts := []

func _ready():
	randomize()
	text = str(texts[OS.get_ticks_usec() % texts.size()])
