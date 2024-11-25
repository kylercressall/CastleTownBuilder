extends Node2D

var hover_sprite
var buildable_sprite
var build_location_sprite
var green_highlight_sprite
var point_counter

var black_border
var gray_back
var yellow_back
var green_back
var green_highlight

var point_count = 0

var point_sprites = {
	0: null,
	-1: "Assets/Tiling/Point Counter/-1point.png",
	1: "Assets/Tiling/Point Counter/1point.png",
	2: "Assets/Tiling/Point Counter/2point.png",
	3: "Assets/Tiling/Point Counter/3point.png",
	4: "Assets/Tiling/Point Counter/4point.png",
	5: "Assets/Tiling/Point Counter/5point.png",
	6: "Assets/Tiling/Point Counter/6point.png",
	7: "Assets/Tiling/Point Counter/7point.png",
	8: "Assets/Tiling/Point Counter/8point.png",
	9: "Assets/Tiling/Point Counter/9point.png",
	10: "Assets/Tiling/Point Counter/10point.png",
	11: "Assets/Tiling/Point Counter/10above.png",
}


signal tile_mouse_over
#signal tile_mouse_gone
signal tile_clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hover_sprite = get_node("Hover Sprite")
	if not hover_sprite:
		print("pattern_sprite not found in grid_tile _ready")
	
	buildable_sprite = get_node("Yellow Buildable")
	if not buildable_sprite:
		print("pattern_sprite not found in grid_tile _ready")
	
	build_location_sprite = get_node("Green Build Location")
	if not build_location_sprite:
		print("build_location_sprite not found in grid_tile _ready")
	
	green_highlight_sprite = get_node("Green Highlight")
	if not green_highlight_sprite:
		print("green_highlight_sprite not found in grid_tile _ready")
	
	point_counter = get_node("Point Counter")
	if not point_counter:
		print("point_counter not found in grid_tile _ready")
	
	
	hover_sprite.texture = null
	buildable_sprite.texture = null
	build_location_sprite.texture = null
	green_highlight_sprite.texture = null
	
	point_counter.texture = null
	
	black_border = load("res://Assets/Tiling/grid-border-1.png")
	gray_back = load("res://Assets/Tiling/transparent_black.png")
	yellow_back = load("res://Assets/Tiling/yellow_backing.png")
	green_back = load("res://Assets/Tiling/green_backing.png")
	green_highlight = load("res://Assets/Tiling/green_highlight.png")

func mouse_overlap():
	emit_signal("tile_mouse_over")

func set_black_border():
	hover_sprite.texture = black_border

func set_blackout():
	hover_sprite.texture = gray_back


func _on_static_body_2d_mouse_entered() -> void:
	emit_signal("tile_mouse_over")

func _on_static_body_2d_mouse_exited() -> void:
	hover_sprite.texture = null
	#emit_signal("tile_mouse_gone")

func _on_static_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#print("mouse click detected")
		emit_signal("tile_clicked")

func set_yellow_backing(val = 0):
	if val == -1:
		buildable_sprite.texture = null
		return
	buildable_sprite.texture = yellow_back

func set_green_backing(val = 0):
	if val == -1:
		build_location_sprite.texture = null
		return
	build_location_sprite.texture = green_back
	
func set_green_highlight(val = 0):
	if val == -1:
		green_highlight_sprite.texture = null
		return
	green_highlight_sprite.texture = green_highlight

func set_point_counter(num):
	# create particle effecct, points went up
	if num > point_count:
		create_point_gain_animation()
		pass
	
	# create particle effecct, points went down	
	elif num < point_count:
		create_point_gain_animation(-1)
		pass
	else:
		# points didn't change
		return
	
	point_count = num
	if point_count < 0:
		point_counter.texture = load(point_sprites[-1])
	elif point_count > 10:
		point_counter.texture = load(point_sprites[11])
	else:
		point_counter.texture = load(point_sprites[num])


func show_point_counter(num = 0):
	if num == -1:
		point_counter.hide()
	else:
		point_counter.show()
	
func create_point_gain_animation(num = 1):
	var anim
	if num > 0:
		anim = load("res://Scenes/Animations/point_gain.tscn").instantiate()

	if num < 0:
		anim = load("res://Scenes/Animations/point_loss.tscn").instantiate()

	if anim:
		anim.position.x += 22
		anim.position.y += 22
		add_child(anim)
		anim.show()
		anim.z_index = 100
		anim.emitting = true
	
	
	
	
	
	
	
	
	
	
