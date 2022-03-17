extends Node


onready var node_tween := $"Tween"


func gem_spawn(gem:Gem):
	node_tween.interpolate_property(
		gem.node_sprite, "modulate",
		Color(4, 4, 4, 0), Color.white, 0.5,
		Tween.TRANS_QUART, Tween.EASE_IN
	)
	node_tween.start()


func play_fall_animation(gem_pos:Vector2, fall_from:Vector2, edge:Vector2):
	var anim_time = 0.5
	var anim_delay = (
		abs(gem_pos.y - edge.y)
		+ abs(gem_pos.x - edge.x)
	) * 0.001 + 0.05
	var kickback = Vector2((randf() - 0.5) * 8, -16)
	var sprite = get_parent().board_contents[gem_pos].node_sprite

	node_tween.interpolate_property(
		sprite, "position",
		fall_from, fall_from + kickback, anim_delay,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		sprite, "position",
		fall_from + kickback, Vector2(0, -0.5 * kickback.y), anim_time,
		Tween.TRANS_QUART, Tween.EASE_IN, anim_delay
	)
	node_tween.interpolate_property(
		sprite, "position",
		Vector2(0, -0.5 * kickback.y), Vector2(), 0.1,
		Tween.TRANS_CUBIC, Tween.EASE_OUT, anim_delay + anim_time
	)
	node_tween.interpolate_callback($"SoundFall", anim_delay + anim_time, "play")
	node_tween.start()

	
func play_collect_vfx(gem:Gem, chain:Array):
	if gem.color >= 5:
		return

	if !is_instance_valid(get_parent().pip_collectors[gem.color]):
		return

	var collector = get_parent().pip_collectors[gem.color]
	var time1 = 0.5
	var time_wait = randf() * chain.size() * 0.05
	var time2 = 0.5

	# position
	var dest1 = gem.global_position + Vector2(randf() - 0.5, randf() - 0.5) * 192
	var dest2 = collector.global_position
	node_tween.interpolate_property(
		gem.node_collected_pip, "global_position",
		gem.global_position, dest1, time1,
		Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		gem.node_collected_pip, "global_position",
		dest1, dest2, time2,
		Tween.TRANS_QUART, Tween.EASE_IN, time1 + time_wait
	)
	if collector.get_parent().has_method("charge"):
		node_tween.interpolate_callback(collector.get_parent(), time1 + time2 + time_wait, "charge")
	
	# angle
	gem.node_collected_pip.rotation = gem.global_position.angle_to_point(dest1)
	node_tween.interpolate_callback(gem.node_collected_pip, time1, "look_at", dest2)
	
	# scale
	var scale1 = Vector2(0.3, 0.3)
	var scale2 = Vector2(1, 0.2)
	node_tween.interpolate_property(
		gem.node_collected_pip, "scale",
		Vector2(1.5, 0.33), scale1, time1,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	node_tween.interpolate_property(
		gem.node_collected_pip, "scale",
		scale1, scale2, time2,
		Tween.TRANS_QUART, Tween.EASE_IN, time1 + time_wait
	)
	node_tween.interpolate_property(
		gem.node_collected_pip, "scale",
		scale2, Vector2(0, 2), 0.1,
		Tween.TRANS_CUBIC, Tween.EASE_OUT, time1 + time2 + time_wait
	)

	# color
	node_tween.interpolate_property(
		gem.node_collected_pip, "modulate",
		Color.white, gem.self_modulate, time1
	)

	# sfx
	node_tween.interpolate_callback($"SoundCollect", time1 + time2 + time_wait, "play")


func bob_score():
	node_tween.interpolate_property(
		$"../../Score/ScoreScaler", "scale",
		Vector2.ONE * 2, Vector2.ONE, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	node_tween.start()