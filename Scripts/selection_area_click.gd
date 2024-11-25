extends Node2D

signal build_selection_chosen

var build_selector

var stored_selection
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_selector = get_parent()
	if not build_selector:
		print("build_selector not found in selection _ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_selection_field_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		build_selector.selection_chosen(stored_selection)

func set_selection_value(selection):
	stored_selection = selection
	
	var build_sprite = find_child("Building Sprite")
	var build_label = find_child("Building Label")
	var image_path = "path goes here"
	var title = "description goes here"
	var image_scale = Vector2(1,1)
	
	if stored_selection[0] == 0:
		# Build shed
		image_path = "res://Assets/Card Patterns/Shed/shed.png"
		title = "Shed"
	
	if stored_selection[0] == 1:
		# Build cottage
		image_path = "res://Assets/Card Patterns/Cottage/cottage.png"
		title = "Cottage"
	
	if stored_selection[0] == 2:
		# Build cottage
		image_path = "res://Assets/Card Patterns/Windmill/windmill_static.png"
		image_scale = Vector2(0.4, 0.4)
		title = "Windmill"
	
	if stored_selection[0] == 3:
		# Build cottage
		image_path = "res://Assets/Card Patterns/Chapel/full_chapel.png"
		image_scale = Vector2(0.7, 0.7)
		title = "Chapel"
	
	if stored_selection[0] == 4:
		# Build cottage
		image_path = "res://Assets/Card Patterns/Marketplace/marketplace.png"
		image_scale = Vector2(0.7, 0.7)
		title = "Marketplace"
	
	if stored_selection[0] == 5:
		# Build cottage
		image_path = "res://Assets/Card Patterns/Tavern/tavern.png"
		image_scale = Vector2(0.4, 0.4)
		title = "Tavern"
		
	build_sprite.texture = load(image_path)
	build_sprite.scale = image_scale
	build_label.text = title


func _on_selection_field_mouse_entered() -> void:
	build_selector.selection_highlight(stored_selection)


func _on_selection_field_mouse_exited() -> void:
	build_selector.selection_highlight(stored_selection, -1)
