class_name FailCondition
extends Resource

enum {
	FAIL_TIME,
	FAIL_TURNS
}

export var fail_countdown := 120
export(int, "Seconds", "Turns") var fail_objective := FAIL_TURNS
