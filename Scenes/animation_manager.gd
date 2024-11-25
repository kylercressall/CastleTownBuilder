extends Node2D

var animations = []

var windmill_fan = load("res://Scenes/Animations/windmill_fans.tscn")
var smoke = load("res://Scenes/Animations/smoke.tscn")


func _on_game_manager_create_animation(num, pos) -> void:
	# Windmill Blades
	if num == 0:
		var sprite = windmill_fan.instantiate()
		sprite.position = pos
		add_child(sprite)
		
		animations.append(sprite)
	
	# Tavern Smoke
	if num == 1:
		var sprite = smoke.instantiate()
		sprite.position = pos + Vector2(13, -21)
		add_child(sprite)
		
		animations.append(sprite)

func _on_game_manager_clear_animations() -> void:
	for anim in animations:
		anim.queue_free()
	animations = []
