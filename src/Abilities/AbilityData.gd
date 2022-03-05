class_name AbilityData
extends Resource

export var name := ""
export var description := ""
export(Texture) var icon
export var color := Color.white
export var max_charges := 1
export var charge_needed := 50
export(Script) var actions 
export(AudioStream) var sfx_ready
export(AudioStream) var sfx_select
export(AudioStream) var sfx_activate

func _to_string():
  return name + "(Cost: " + str(charge_needed) + ", color: " + str(color) + ")"
