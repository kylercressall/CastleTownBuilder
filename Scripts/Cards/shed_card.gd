extends Node2D

var pattern_sprite


var sprites = [
	"Assets/Card Patterns/Shed/shed-4.png", 
	"Assets/Card Patterns/Shed/shed-3.png",
	"Assets/Card Patterns/Shed/shed-2.png",
	"Assets/Card Patterns/Shed/shed-1.png"
	]

var current_sprite = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pattern_sprite = get_node("Pattern")
	if not pattern_sprite:
		print("pattern_sprite not found in shed_card _ready")

	pattern_sprite.texture = load(sprites[0])

func rotate_pressed():
	if current_sprite < len(sprites)-1:
		current_sprite += 1
	else:
		current_sprite = 0
	
	pattern_sprite.texture = load(sprites[current_sprite])
	# scrapped the rotating sprite on the button because it didn't work well
	

func _on_rotate_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		rotate_pressed()
