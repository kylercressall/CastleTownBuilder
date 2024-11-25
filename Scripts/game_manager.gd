extends Node2D

# Grid variables ----------
var grid = []

var held_item = -1
var confirm_sprite
var currently_holding_sprite

var game_entered = false

var sprites = {
	0: "Assets/Boxes/box-brown.png",
	1: "Assets/Boxes/box-red.png",
	2: "Assets/Boxes/box-blue.png",
	3: "Assets/Boxes/box-gray.png",
	4: "Assets/Boxes/box-yellow.png",
	10: "Assets/Card Patterns/Shed/shed.png",
	11: "Assets/Card Patterns/Cottage/cottage.png",
	12: "Assets/Card Patterns/Windmill/windmill_base_2.png",
	13: "Assets/Card Patterns/Chapel/full_chapel.png",
	14: "Assets/Card Patterns/Marketplace/marketplace.png",
	15: "Assets/Card Patterns/Tavern/tavern.png",
}

# placed_boxes keeps the color id of the box in each slot. -1 for empty.
var placed_boxes = []

# placed boxes instantiated sprites
var placed_box_sprites = []

# 4d array, [x][y][list of possible selections][building type, list of tile coords in Vector2s]

# holds selections that may be selected
# holds building type, then list of all box indexes used
# [0, Vector2(0,0), Vector2(0,1)]
# shed at 0,0 and 0,1
var buildable_tiles = [] 

var build_selector

signal create_new_selector

var open_selections = []

var open_selection_tiles = []

var holding_building_not_placed = false

# Turn/Game variables ---------------
var turn_number = 0

signal set_block_picker_single
signal set_block_picker_height
signal set_turn_order_number

signal create_animation
signal clear_animations

signal set_score_text

var setup_complete = false

func _ready() -> void:
	# Add all child nodes into a proper grid to easily access
	# grid[row-1][col-1]
	for j in range(0,5):
		var i = j*5
		grid.append([get_child(i), get_child(i+1), get_child(i+2), get_child(i+3), get_child(i+4)])
	
	for i in range(0,5):
		buildable_tiles.append([[], [], [], [], []])
	
	for i in range(0,5):
		placed_box_sprites.append([null, null, null, null, null])
	
	for i in range(0,5):
		placed_boxes.append([-1, -1, -1, -1, -1])
		
	confirm_sprite = get_node("confirm_sprite")
	
	build_selector = get_node("../Build Selector")
	if not build_selector:
		print("build_selector node not found in game_manager _ready")
	build_selector.hide()
	

# Turn/Game functions ---------
func start_turn():
	#
	turn_number += 1
	emit_signal("set_turn_order_number", turn_number)
	
	# teleport the block picker back up
	#emit_signal("set_block_picker_height", -1)
	emit_signal("set_block_picker_height", 2)
	
	# depending on the turn number, signal to set what block can be placed
	emit_signal("set_block_picker_single", -1)
	
	for row in grid:
		for cell in row:
			cell.set_green_highlight(-1)

func _on_block_picker_confirm_clicked() -> void:
	emit_signal("set_block_picker_height", 3)
	start_turn()
	
	for i in range(0,5):
		for j in range(0,5):
			grid[i][j].set_green_backing(-1)

# Grid functions ------------
func _on_camera_manager_game_start(set_value) -> void:
	game_entered = set_value
	
	# hide and show the point counters depending if we are in the game or not
	if game_entered:
		for row in grid:
			for cell in row:
				cell.show_point_counter()
	else:
		for row in grid:
			for cell in row:
				cell.show_point_counter(-1)

	if not setup_complete:
		#test_create_max_windmill_cottage_setup()
		test_create_chapel_setup()
		start_turn()
		setup_complete = true
	

func test_create_max_windmill_cottage_setup():
	var x_center = 3
	var y_center = 3
	
	held_item = 12
	create_sprite_to_place(x_center, y_center)
	
	held_item = 11
	create_sprite_to_place(x_center - 1, y_center - 1)
	held_item = 11
	create_sprite_to_place(x_center - 1, y_center)
	held_item = 11
	create_sprite_to_place(x_center - 1, y_center + 1)
	
	held_item = 11
	create_sprite_to_place(x_center, y_center - 1)
	held_item = 11
	create_sprite_to_place(x_center, y_center + 1)
	
	held_item = 11
	create_sprite_to_place(x_center + 1, y_center - 1)
	held_item = 11
	create_sprite_to_place(x_center + 1, y_center)
	held_item = 11
	create_sprite_to_place(x_center + 1, y_center + 1)
	
	held_item = 15
	create_sprite_to_place(x_center, y_center - 2)
	
	held_item = 14
	create_sprite_to_place(x_center-1, y_center - 2)
	
	tile_click_generic(0,0)

func test_create_chapel_setup():
	var x_center = 2
	var y_center = 2
	
	held_item = 13
	create_sprite_to_place(x_center, y_center)
	#held_item = 13
	#create_sprite_to_place(x_center-1, y_center)
	#held_item = 13
	#create_sprite_to_place(x_center+1, y_center)

	tile_click_generic(0,0)


func _on_block_picker_box_selected(num) -> void:
	# wood, brick, glass, stone, wheat
	held_item = num

func _on_static_body_2d_mouse_exited() -> void:
	# use a standalone staticbody to detect if mouse goes out of the grid
	confirm_sprite.position = Vector2(-1000, -1000)

func _on_selection_box_mouse_exited() -> void:
	build_selector.hide()

func tile_move_over_generic(x : int, y : int):
	# game has to be selected to mouse over tiles
	if not game_entered:
		return
	
	if held_item == -1:
		confirm_sprite.hide()
	else:
		confirm_sprite.show()
		
	# move the held sprite onto the tiles
	var tile = grid[x][y]
	if held_item >= 0:
		confirm_sprite.position = tile.position
		confirm_sprite.texture = load(sprites[held_item])
	if held_item == 15:
		confirm_sprite.scale = Vector2(.55, .55)
	else:
		confirm_sprite.scale = Vector2(1,1)

	holding_building_not_placed = false

	# If boxes aren't placed, mouseover with selection box
	# otherwise show blackout grid
	
	if placed_boxes[x][y] == -1:
		grid[x][y].set_black_border()
	else:
		grid[x][y].set_blackout()
	
func tile_click_generic(x : int, y: int):
	# game has to be selected to place tiles
	# Figure out the build selector if the tile has a properly placed building
	
	print("tile click: (",x,", ",y,"): ",held_item)
	
	if not game_entered:
		return
		
	if held_item >= 0 and held_item < 10 and placed_boxes[x][y] == -1:
		
		
		# Create new sprite2d that will visibly show the player where the box is
		create_sprite_to_place(x,y)
		
		# Remove the ability to choose another block (must be enabled later)
		emit_signal("set_block_picker_single", -2)
		
		# check for buildable land
		check_for_buildable()
		
		# Refresh the tile hover graphic
		tile_move_over_generic(x,y)
	
	# if a building is being held, place it if applicable. wait until we say we're ready to place
	if held_item >= 10 and placed_boxes[x][y] == -1 and not holding_building_not_placed:
		if Vector2(x,y) in open_selection_tiles:
			create_sprite_to_place(x,y)
			emit_signal("set_block_picker_single", -2)
			
			# check for buildable land
			check_for_buildable()
			
			# Refresh the tile hover graphic
			tile_move_over_generic(x,y)
			
			# un-paint all build location ground
			for i in range(0,5):
				for j in range(0,5):
					grid[i][j].set_green_backing(-1)
	
	# if the tile is buildable, show build selector
	if buildable_tiles[x][y]:
		# save that a yellow tile was clicked and opened the build selector
		
		#print("buildable_tile at coords (", x, ", ", y, ")")
		
		open_build_selector(x, y)
		
		# if a yellow tile is clicked while holding a box, it deselects it
		held_item = -1
	
	calculate_score()

func create_sprite_to_place(x,y):
	# Save the held item in the color tracking array
	placed_boxes[x][y] = held_item
	
	var new_sprite = Sprite2D.new()
	add_child(new_sprite)
	placed_box_sprites[x][y] = new_sprite
	
	new_sprite.texture = load(sprites[held_item])
	new_sprite.position = grid[x][y].position
	new_sprite.z_index = 4
	new_sprite.show()
	
	if held_item == 15:
		new_sprite.scale = Vector2(.55, .55)
	
	# Create windmill blades animation
	if held_item == 12:
		emit_signal("create_animation", 0, grid[x][y].position)
	
	# Create tavern smoke animation
	if held_item == 15:
		emit_signal("create_animation", 1, grid[x][y].position)

	
	held_item = -1

func check_for_buildable():
	'''only paints the yellow on the ground and stores it to get used to open the build selector'''
	
	# reset the counters on everything and just recalculate
	buildable_tiles = []
	for i in range(0,5):
		buildable_tiles.append([[], [], [], [], []])
	
	# reset the yellow ground too
	for x in range(0,5):
		for y in range(0,5):
			grid[x][y].set_yellow_backing(-1)
	
	var WOOD = 0
	var BRICK = 1
	var GLASS = 2
	var STONE = 3
	var WHEAT = 4
	
	var SHED_ID = 0
	var COTTAGE_ID = 1
	var WINDMILL_ID = 2
	var CHAPEL_ID = 3
	var MARKETPLACE_ID = 4
	var TAVERN_ID = 5
	
	# Find Sheds
	for x in range(0,5):
		for y in range(0,5):
			# find stone, then find wood around it
			if placed_boxes[x][y] == STONE:
				# check horizontal, y is changed not x
				if y < 4 and placed_boxes[x][y+1] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y+1))
					
					set_tile_selections(SHED_ID, used_tiles)
				
				# check horizontal, y is changed not x
				if y > 0 and placed_boxes[x][y-1] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					
					set_tile_selections(SHED_ID, used_tiles)
				
				# check vertical, x is changed not y
				if x < 4 and placed_boxes[x + 1][y] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x+1,y))
					
					set_tile_selections(SHED_ID, used_tiles)
				
				# check vertical, x is changed not y
				if x > 0 and placed_boxes[x - 1][y] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x-1,y))
					
					set_tile_selections(SHED_ID, used_tiles)
	
	# Find Cottages
	for x in range(0,5):
		for y in range(0,5):
			# find brick and then find surrounding pices
			if placed_boxes[x][y] == BRICK:
				# Wheat left, wood down
				if y > 0 and placed_boxes[x][y-1] == WHEAT and x > 0 and placed_boxes[x-1][y] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x-1,y))
					
					set_tile_selections(COTTAGE_ID, used_tiles)
				
				# Wheat down, wood right
				if x > 0 and placed_boxes[x-1][y] == WHEAT and y < 4 and placed_boxes[x][y+1] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x-1,y))
					used_tiles.append(Vector2(x,y+1))
					
					set_tile_selections(COTTAGE_ID, used_tiles)
					
				# Wheat up, wood left
				if x < 4 and placed_boxes[x+1][y] == WHEAT and y > 0 and placed_boxes[x][y-1] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x,y-1))
					
					set_tile_selections(COTTAGE_ID, used_tiles)
					
				# Wheat right, wood up
				if y < 4 and placed_boxes[x][y+1] == WHEAT and x < 4 and placed_boxes[x+1][y] == WOOD:
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x,y+1))
					
					set_tile_selections(COTTAGE_ID, used_tiles)
	
	# Find windmills
	for x in range(0,5):
		for y in range(0,5):
			# find wheat and then find surrounding pices
			# top left wheat
			if placed_boxes[x][y] == WHEAT:
				if (
					x > 0 and 
					placed_boxes[x-1][y] == WOOD and 
					y < 4 and 
					placed_boxes[x][y+1] == WOOD and
					placed_boxes[x-1][y+1] == WHEAT
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x-1,y))
					used_tiles.append(Vector2(x-1,y+1))
					
					set_tile_selections(WINDMILL_ID, used_tiles)
				
				# top right wheat
				if (
					y > 0 and 
					placed_boxes[x][y-1] == WOOD and 
					x > 0 and 
					placed_boxes[x-1][y] == WOOD and
					placed_boxes[x-1][y-1] == WHEAT
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x-1,y))
					used_tiles.append(Vector2(x-1,y-1))
					
					set_tile_selections(WINDMILL_ID, used_tiles)
	
	# Find chapels
	for x in range(0,5):
		for y in range(0,5):
			# find wheat and then find surrounding pices
			# middle stone
			if placed_boxes[x][y] == STONE:
				# left/right/up
				print("stone located, searching for chapels: ", x, ",", y)
				if (
					y < 4 and 
					placed_boxes[x][y+1] == GLASS and
					y > 0 and 
					placed_boxes[x][y-1] == GLASS and
					x < 4 and
					placed_boxes[x+1][y] == GLASS
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x+1,y))
					
					set_tile_selections(CHAPEL_ID, used_tiles)
				
				# right/up/down
				if (
					y < 4 and 
					placed_boxes[x][y+1] == GLASS and
					x < 4 and 
					placed_boxes[x+1][y] == GLASS and
					x > 0 and
					placed_boxes[x-1][y] == GLASS
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x-1,y))
					
					set_tile_selections(CHAPEL_ID, used_tiles)
				
				# left/right/down
				if (
					y > 0 and 
					placed_boxes[x][y-1] == GLASS and
					y < 4 and 
					placed_boxes[x][y+1] == GLASS and
					x > 0 and
					placed_boxes[x-1][y] == GLASS
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x-1,y))
					
					set_tile_selections(CHAPEL_ID, used_tiles)
				
				# left/up/down
				if (
					y > 0 and 
					placed_boxes[x][y-1] == GLASS and
					x < 4 and 
					placed_boxes[x+1][y] == GLASS and
					x > 0 and
					placed_boxes[x-1][y] == GLASS
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x-1,y))
					
					set_tile_selections(CHAPEL_ID, used_tiles)

	# Find Marketplaces
	for x in range(0,5):
		for y in range(0,5):
			if placed_boxes[x][y] == BRICK:
				# brick top left
				if (
					y < 4 and 
					placed_boxes[x][y+1] == STONE and
					x > 0 and
					placed_boxes[x-1][y] == WOOD and
					placed_boxes[x-1][y+1] == WHEAT
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x-1,y))
					used_tiles.append(Vector2(x-1,y+1))
					
					set_tile_selections(MARKETPLACE_ID, used_tiles)
				
				# brick bottom right
				if (
					y > 0 and 
					placed_boxes[x][y-1] == STONE and
					x < 4 and
					placed_boxes[x+1][y] == WOOD and
					placed_boxes[x+1][y-1] == WHEAT
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x+1,y-1))
					
					set_tile_selections(MARKETPLACE_ID, used_tiles)
				
				# brick top right
				if (
					x > 0 and 
					placed_boxes[x-1][y] == STONE and
					y > 0 and
					placed_boxes[x][y-1] == WOOD and
					placed_boxes[x-1][y-1] == WHEAT
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x-1,y))
					used_tiles.append(Vector2(x-1,y-1))
					
					set_tile_selections(MARKETPLACE_ID, used_tiles)
					
				# brick bottom left
				if (
					x < 4 and 
					placed_boxes[x+1][y] == STONE and
					y < 4 and
					placed_boxes[x][y+1] == WOOD and
					placed_boxes[x+1][y+1] == WHEAT
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x+1,y+1))
					
					set_tile_selections(MARKETPLACE_ID, used_tiles)
	
	# Find Taverns
	for x in range(0,5):
		for y in range(0,5):
			if placed_boxes[x][y] == GLASS:
				# glass bottom
				if (
					x < 4 and 
					placed_boxes[x+1][y] == WOOD and
					x < 3 and
					y > 0 and
					placed_boxes[x+2][y] == BRICK and
					placed_boxes[x+2][y-1] == BRICK
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x+1,y))
					used_tiles.append(Vector2(x+2,y))
					used_tiles.append(Vector2(x+2,y-1))
					
					set_tile_selections(TAVERN_ID, used_tiles)
				
				# Glass top
				if (
					x > 1 and 
					placed_boxes[x-1][y] == WOOD and
					y < 4 and
					placed_boxes[x-2][y] == BRICK and
					placed_boxes[x-2][y+1] == BRICK
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x-1,y))
					used_tiles.append(Vector2(x-2,y))
					used_tiles.append(Vector2(x-2,y+1))
					
					set_tile_selections(TAVERN_ID, used_tiles)
				
				# Glass right
				if (
					y > 1 and
					placed_boxes[x][y-1] == WOOD and
					x < 4 and
					placed_boxes[x][y-2] == BRICK and
					placed_boxes[x-1][y-2] == BRICK
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y-1))
					used_tiles.append(Vector2(x,y-2))
					used_tiles.append(Vector2(x-1,y-2))
					
					set_tile_selections(TAVERN_ID, used_tiles)
				
				# Glass left
				if (
					y < 4 and
					placed_boxes[x][y+1] == WOOD and
					x > 0 and
					placed_boxes[x][y+2] == BRICK and
					placed_boxes[x+1][y+2] == BRICK
					):
					var used_tiles = []
					used_tiles.append(Vector2(x,y))
					used_tiles.append(Vector2(x,y+1))
					used_tiles.append(Vector2(x,y+2))
					used_tiles.append(Vector2(x+1,y+2))
					
					set_tile_selections(TAVERN_ID, used_tiles)
					
					
func set_tile_selections(id, vectors):
	for tile in vectors:
		grid[tile.x][tile.y].set_yellow_backing()
		
	# Define the array to append for each tile
	var selection_data = vectors.duplicate()
	selection_data.insert(0, id)

	# Append tile_data to buildable_tiles for each tile in used_tiles
	for tile in vectors:
		buildable_tiles[tile.x][tile.y].append(selection_data)


func open_build_selector(x, y):
	'''if build selector is opened, calculate selections and create them'''

	
	# And reset if the same tile is clicked multiple times it doesn't create duplicate selections
	emit_signal("create_new_selector", [-1])
	
	# we know the tile is buildable already, checked in the single grid check in tile_click_generic
	
	# show the build selector
	build_selector.show()
	# move it to the right of the tile
	build_selector.position = Vector2(grid[x][y].position.x + 130, grid[x][y].position.y + 10)
	
		# holds lists of selections, [type, list of Vector2s with coords]
	var current_selections = buildable_tiles[x][y]
	
	# find what can be built based off of buildable tile
	for num in current_selections:
		emit_signal("create_new_selector", num)


func _on_build_selector_build_selection_building(selection) -> void:
	print("build selector picked")
	
	# variable to hold onto the item before clicking it down (for shed to not have double click select + place at once)
	holding_building_not_placed = true
	
	# +10 is added because 10+ in the sprites array is the building types
	var building_value = selection[0]
	var selection_vectors = selection.duplicate(true)
	selection_vectors.pop_front()
	
	# remove boxes at each of the selection vectors
	for vector in selection_vectors:
		# assume the vector is corectly a Vector2
		
		# switch the placed box to -1 to show empty
		placed_boxes[vector.x][vector.y] = -1

		placed_box_sprites[vector.x][vector.y].queue_free()
		placed_box_sprites[vector.x][vector.y] = null

	
	# re-paint the ground to remove old yellow
	check_for_buildable()
	
	
	# paint the available locations depending on building type
	if building_value == 0:
		# sheds can be placed anywhere there isn't a box/building\
		print(placed_boxes)
		for x in range(0,5):
			for y in range(0,5):
				if placed_boxes[x][y] == -1:
					open_selection_tiles.append(Vector2(x,y))
	else:
		# other buildings can only be placed where the boxes were previous
		open_selection_tiles = selection_vectors
	
	for vector in open_selection_tiles:
		grid[vector.x][vector.y].set_green_backing()
	
	# disable holding a box or selecting a new one
	held_item = -1
	build_selector.hide()
	emit_signal("set_block_picker_single", -3)
		
	# hold the building type, +10 to access the correct sprite
	held_item = building_value + 10
	
	
	
	
func _on_build_selector_highlight_selection(selection, num = 0) -> void:
	var vectors = selection.duplicate()
	vectors.pop_front()
	
	print("selection to highlight: ", vectors)
	if num == -1:
		# hide section
		for tile in vectors:
			grid[tile.x][tile.y].set_green_highlight(-1)
			print("unhighlighted tile (",tile.x,",",tile.y,")")
		return
	
	# highlight section
	for tile in vectors:
		grid[tile.x][tile.y].set_green_highlight()
		

# Point scoring

func calculate_score():
	# Sheds first
	var calculated_score = 0
	var calculated_chapels = false
	#13: "Assets/Card Patterns/Chapel/full_chapel.png",
	#14: "Assets/Card Patterns/Marketplace/marketplace.png",
	#15: "Assets/Card Patterns/Tavern/tavern.png",
	for x in range(0,5):
		for y in range(0,5):
			var cell = placed_boxes[x][y]
			# Sheds
			if cell == 10:
				calculated_score += 1
				grid[x][y].set_point_counter(1)
			
			# Windmills
			if cell == 12:
				calculated_score += 1
				grid[x][y].set_point_counter(1)
			
			# Cottages
			if cell == 11:
				var found_windmill = false
				# Range of the cells is clamped so it doesnt access a grid out of the array
				#for x2 in range(clamp(x-1,0,4),clamp(x+1,0,4)):
					#for y2 in range(clamp(y-1,0,4), clamp(y+1,0,4)):
						#if placed_boxes[x2][y2] == 12:
							#print("cottage found next to windmill")
							#found_windmill = true
				
				# check everything manually because it works. yuck\
				if x > 0 and y > 0 and placed_boxes[x-1][y-1] == 12:
					found_windmill = true
				
				if x > 0 and placed_boxes[x-1][y] == 12:
					found_windmill = true
					
				if x > 0 and y < 4 and placed_boxes[x-1][y+1] == 12:
					found_windmill = true
				
				if y > 0 and placed_boxes[x][y-1] == 12:
					found_windmill = true
				if y < 4 and placed_boxes[x][y+1] == 12:
					found_windmill = true
				
				if x < 4 and y > 0 and placed_boxes[x+1][y-1] == 12:
					found_windmill = true
				if x < 4 and placed_boxes[x+1][y] == 12:
					found_windmill = true
				if x < 4 and y < 4 and placed_boxes[x+1][y+1] == 12:
					found_windmill = true
				
				if found_windmill:
					calculated_score += 2
					grid[x][y].set_point_counter(2)
				found_windmill = false
			
			# Marketplace
			if cell == 14:
				# one point for every 4 buildings on the map
				var building_count = 0
				for x2 in range(0,5):
					for y2 in range(0,5):
						if placed_boxes[x2][y2] >= 10:
							building_count += 1
				
				var points_awarded = int(building_count/4)
				grid[x][y].set_point_counter(points_awarded)
				calculated_score += points_awarded
			
			# Tavern
			if cell == 15:
				# one point for every 4 buildings on the map
				var buildings = []
				
				# col
				var building = 0
				for x2 in range(0,5):
					building = placed_boxes[x2][y]
					if building >= 10 and x2 != x:
						if building not in buildings:
							buildings.append(placed_boxes[x2][y])
					
				# row
				for y2 in range(0,5):
					building = placed_boxes[x][y2]
					if building >= 10 and y2 != y:
						if building not in buildings:
							buildings.append(placed_boxes[x][y2])
				
				var points_awarded = buildings.size()
				print("Tavern unique buildings: ", buildings)
				grid[x][y].set_point_counter(points_awarded)
				calculated_score += points_awarded
	
			if cell == 13:
				# various points based on number of chapels

				var chapel_count = 0
				for x2 in range(0,5):
					for y2 in range(0,5):
						if placed_boxes[x2][y2] == 13:
							chapel_count += 1
				
				var points_awarded = -1 + 2 * chapel_count
				
				if chapel_count % 2 == 1:
					points_awarded *= -1
				
				grid[x][y].set_point_counter(points_awarded)
				
				if not calculated_chapels:
					calculated_score += points_awarded
					calculated_chapels = true

	emit_signal("set_score_text", calculated_score)








# Signal connections
# A1
func _on_a_1_tile_mouse_over() -> void:
	tile_move_over_generic(0, 0)

func _on_a_1_tile_clicked() -> void:
	tile_click_generic(0, 0)

# B1
func _on_b_1_tile_mouse_over() -> void:
	tile_move_over_generic(0, 1)

func _on_b_1_tile_clicked() -> void:
	tile_click_generic(0, 1)

# C1
func _on_c_1_tile_mouse_over() -> void:
	tile_move_over_generic(0, 2)

func _on_c_1_tile_clicked() -> void:
	tile_click_generic(0, 2)

# D1
func _on_d_1_tile_mouse_over() -> void:
	tile_move_over_generic(0, 3)
	
func _on_d_1_tile_clicked() -> void:
	tile_click_generic(0, 3)

# E1
func _on_e_1_tile_mouse_over() -> void:
	tile_move_over_generic(0, 4)

func _on_e_1_tile_clicked() -> void:
	tile_click_generic(0, 4)


func _on_a_2_tile_mouse_over() -> void:
	tile_move_over_generic(1, 0)

func _on_a_2_tile_clicked() -> void:
	tile_click_generic(1, 0)


func _on_b_2_tile_mouse_over() -> void:
	tile_move_over_generic(1, 1)

func _on_b_2_tile_clicked() -> void:
	tile_click_generic(1, 1)


func _on_c_2_tile_mouse_over() -> void:
	tile_move_over_generic(1, 2)

func _on_c_2_tile_clicked() -> void:
	tile_click_generic(1, 2)


func _on_d_2_tile_mouse_over() -> void:
	tile_move_over_generic(1, 3)

func _on_d_2_tile_clicked() -> void:
	tile_click_generic(1, 3)


func _on_e_2_tile_mouse_over() -> void:
	tile_move_over_generic(1, 4)

func _on_e_2_tile_clicked() -> void:
	tile_click_generic(1, 4)


func _on_a_3_tile_mouse_over() -> void:
	tile_move_over_generic(2, 0)

func _on_a_3_tile_clicked() -> void:
	tile_click_generic(2, 0)


func _on_b_3_tile_mouse_over() -> void:
	tile_move_over_generic(2, 1)

func _on_b_3_tile_clicked() -> void:
	tile_click_generic(2, 1)


func _on_c_3_tile_mouse_over() -> void:
	tile_move_over_generic(2, 2)

func _on_c_3_tile_clicked() -> void:
	tile_click_generic(2, 2)


func _on_d_3_tile_mouse_over() -> void:
	tile_move_over_generic(2, 3)

func _on_d_3_tile_clicked() -> void:
	tile_click_generic(2, 3)


func _on_e_3_tile_mouse_over() -> void:
	tile_move_over_generic(2, 4)

func _on_e_3_tile_clicked() -> void:
	tile_click_generic(2, 4)


func _on_a_4_tile_mouse_over() -> void:
	tile_move_over_generic(3, 0)

func _on_a_4_tile_clicked() -> void:
	tile_click_generic(3, 0)


func _on_b_4_tile_mouse_over() -> void:
	tile_move_over_generic(3, 1)

func _on_b_4_tile_clicked() -> void:
	tile_click_generic(3, 1)


func _on_c_4_tile_mouse_over() -> void:
	tile_move_over_generic(3, 2)

func _on_c_4_tile_clicked() -> void:
	tile_click_generic(3, 2)


func _on_d_4_tile_mouse_over() -> void:
	tile_move_over_generic(3, 3)

func _on_d_4_tile_clicked() -> void:
	tile_click_generic(3, 3)


func _on_e_4_tile_mouse_over() -> void:
	tile_move_over_generic(3, 4)

func _on_e_4_tile_clicked() -> void:
	tile_click_generic(3, 4)


func _on_a_5_tile_mouse_over() -> void:
	tile_move_over_generic(4, 0)

func _on_a_5_tile_clicked() -> void:
	tile_click_generic(4, 0)


func _on_b_5_tile_mouse_over() -> void:
	tile_move_over_generic(4, 1)

func _on_b_5_tile_clicked() -> void:
	tile_click_generic(4, 1)


func _on_c_5_tile_mouse_over() -> void:
	tile_move_over_generic(4, 2)

func _on_c_5_tile_clicked() -> void:
	tile_click_generic(4, 2)


func _on_d_5_tile_mouse_over() -> void:
	tile_move_over_generic(4, 3)

func _on_d_5_tile_clicked() -> void:
	tile_click_generic(4, 3)


func _on_e_5_tile_mouse_over() -> void:
	tile_move_over_generic(4, 4)

func _on_e_5_tile_clicked() -> void:
	tile_click_generic(4, 4)
