extends Node2D

var SELECTION_X = -90
var SELECTION_Y_TOP = -35
var SELECTION_Y_SPACING = 60

var current_selections = []

var BLACK_BORDER_HEIGHT_INCREMENT = 60
var ORANGE_FOREGROUND_HEIGHT_INCREMENT = 60

signal build_selection_building
signal highlight_selection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func build_selector(list_of_selection):
	# builds only one selection at a time, may be changed later
	
	var type = list_of_selection[0]
	# temp magic numbers until a proper build structure is made
	if type == -1:
		# Reset all selections
		for sel in current_selections:
			sel.queue_free()
		current_selections = []
		return
	if type < -1:
		print("build_selector must have a value >= -1 to create a selection")
		return
	
	# Create the selection
	var selection = load("res://Scenes/selection.tscn").instantiate()
	add_child(selection)
	current_selections.append(selection)
	selection.z_index = z_index + 1
	
	selection.set_selection_value(list_of_selection)
	
	
	
	
	if len(current_selections) <= 0:
		print("something went wrong, build_selector build_selector")
		return
	
	# Set the proper x and y for each selector
	selection.position.x = SELECTION_X
	
	if len(current_selections) == 1:
		selection.position.y = SELECTION_Y_TOP
	else:
		selection.position.y = SELECTION_Y_TOP + SELECTION_Y_SPACING * (len(current_selections)-1)

func selection_chosen(selection):
	print("building chosen: ", selection)
	emit_signal("build_selection_building", selection)
	
func selection_highlight(selection, num = 0):
	if num == -1:
		#print("selection un-highlighted: ", selection)
		emit_signal("highlight_selection", selection, -1)
		return
	#print("selection highlighted: ", selection)
	emit_signal("highlight_selection", selection)


func _on_button_button_down() -> void:
	build_selector(0)
	build_selector(1)

func _on_button_2_button_down() -> void:
	build_selector(-1)

func _on_game_manager_create_new_selector(num = -1) -> void:
	build_selector(num)
