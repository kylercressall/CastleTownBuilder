extends StaticBody2D

var MAX_SCALE = Vector2(1.25,1.25)
var NORMAL_SCALE = Vector2(0.8,0.8)
var SCALE_UP_SPEED = 0.1
var SCALE_DOWN_SPEED = 0.3

var card_parent

var card_grow = false
var card_grow_override = false

var STARTING_COORDS
var GROW_COORDS = Vector2(870, 290)
var MOVE_SPEED_UP = 0.2
var MOVE_SPEED_DOWN = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_parent = get_parent()
	STARTING_COORDS = card_parent.position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if card_grow:
		card_parent.z_index = 20
		card_parent.scale = card_parent.scale.lerp(MAX_SCALE, SCALE_UP_SPEED)
		#card_parent.position = card_parent.position.lerp(GROW_COORDS, MOVE_SPEED_UP)
	else:
		card_parent.z_index = 4
		card_parent.scale = card_parent.scale.lerp(NORMAL_SCALE, SCALE_DOWN_SPEED)
		#card_parent.position = card_parent.position.lerp(STARTING_COORDS, MOVE_SPEED_DOWN)



func _on_mouse_entered() -> void:
	card_grow = true

func _on_mouse_exited() -> void:
	card_grow = false
