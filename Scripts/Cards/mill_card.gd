extends Node2D

var pattern_sprite

var sprites = [
	"Assets/Card Patterns/Windmill/windmill_pattern_1.PNG", 
	"Assets/Card Patterns/Windmill/windmill_pattern_2.PNG", 
	]

var current_sprite = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pattern_sprite = get_node("Pattern")
	if not pattern_sprite:
		print("pattern_sprite not found in cottage_card _ready")
	
	pattern_sprite.texture = load(sprites[0])

func rotate_pressed():
	if current_sprite < len(sprites)-1:
		current_sprite += 1
	else:
		current_sprite = 0
	
	pattern_sprite.texture = load(sprites[current_sprite])

func _on_rotate_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		rotate_pressed()
