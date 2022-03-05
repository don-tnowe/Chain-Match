class_name FailCondition
extends Resource

enum {
	TIME,
	TURNS
}

export var countdown := 120
export(int, "Seconds", "Turns") var type := TURNS
