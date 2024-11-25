extends Node2D

signal box_selected
signal confirm_clicked

var buttons = []
var confirm_button

var BLOCK_PICKER_X = 620
var BLOCK_PICKER_Y_TOP = -200
var BLOCK_PICKER_Y_MID = 380
var BLOCK_PICKER_Y_BOT = 780

var BLOCK_PICKER_Y_SNAP_DISTANCE = 3

var ANIMATION_SPEED = 0.15

var height_state_queue = [] # 1 = top, 2 = mid, 3 = bottom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons.append(find_child("Wood"))
	buttons.append(find_child("Brick"))
	buttons.append(find_child("Glass"))
	buttons.append(find_child("Wheat"))
	buttons.append(find_child("Stone"))
	
	confirm_button = find_child("Confirm")
	
	position.x = BLOCK_PICKER_X
	position.y = BLOCK_PICKER_Y_BOT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(height_state_queue)
	# -1 = set straight to the top no animation
	if height_state_queue and height_state_queue[0] == -1:
		position = Vector2(BLOCK_PICKER_X, BLOCK_PICKER_Y_TOP)
		height_state_queue.pop_front()
	
	if height_state_queue and height_state_queue[0] == 1:
		if position.y > BLOCK_PICKER_Y_TOP:
			# +1 is added to the x lerp so it will actually reach the position and stop
			position = position.lerp(Vector2(BLOCK_PICKER_X, BLOCK_PICKER_Y_TOP - 1), ANIMATION_SPEED)
		
		if position.y == BLOCK_PICKER_Y_TOP:
			height_state_queue.pop_front()
	
	if height_state_queue and height_state_queue[0] == 2:
		if position.y < BLOCK_PICKER_Y_MID:
			# +1 is added to the x lerp so it will actually reach the position and stop
			position = position.lerp(Vector2(BLOCK_PICKER_X, BLOCK_PICKER_Y_MID + 50), ANIMATION_SPEED)
		if position.y > BLOCK_PICKER_Y_MID:
			# +1 is added to the x lerp so it will actually reach the position and stop
			position = position.lerp(Vector2(BLOCK_PICKER_X, BLOCK_PICKER_Y_MID - 50), ANIMATION_SPEED)
		
		# if close enough, snap into place
		if position.y < BLOCK_PICKER_Y_MID and position.y > BLOCK_PICKER_Y_MID - BLOCK_PICKER_Y_SNAP_DISTANCE:
			position.y = BLOCK_PICKER_Y_MID
		
		if position.y == BLOCK_PICKER_Y_MID:
			height_state_queue.pop_front()
	
	if height_state_queue and height_state_queue[0] == 3:
		if position.y < BLOCK_PICKER_Y_BOT:
			# +1 is added to the x lerp so it will actually reach the position and stop
			position = position.lerp(Vector2(BLOCK_PICKER_X, BLOCK_PICKER_Y_BOT + 1), ANIMATION_SPEED)
		
		# if close enough, snap into place
		if position.y < BLOCK_PICKER_Y_BOT and position.y > BLOCK_PICKER_Y_BOT - BLOCK_PICKER_Y_SNAP_DISTANCE:
			position.y = BLOCK_PICKER_Y_BOT
			
		if position.y == BLOCK_PICKER_Y_BOT:
			height_state_queue.pop_front()


func _on_wood_button_down() -> void:
	emit_signal("box_selected", 0)

func _on_brick_button_down() -> void:
	emit_signal("box_selected", 1)

func _on_glass_button_down() -> void:
	emit_signal("box_selected", 2)

func _on_stone_button_down() -> void:
	emit_signal("box_selected", 3)

func _on_wheat_button_down() -> void:
	emit_signal("box_selected", 4)

func _on_game_manager_set_block_picker_single(block_type) -> void:
	# card_backing(not used), wood, brick, glass, stone, wheat
	for button in buttons:
		hide_button(button)
	hide_button(confirm_button)
		
	# if given -1, show all blocks and hide confirm
	if block_type == -1:
		for button in buttons:
			show_button(button)
		hide_button(confirm_button)
		return
	
	# if given -2, hide all blocks and show confirm
	if block_type == -2:
		for button in buttons:
			hide_button(button)
		show_button(confirm_button)
		return
	
	# if given -3, hide literally everything
	if block_type == -3:
		for button in buttons:
			hide_button(button)
		hide_button(confirm_button)
		return
	
	if block_type == 0:
		show_button(buttons[0])
	if block_type == 1:
		show_button(buttons[1])
	if block_type == 2:
		show_button(buttons[2])
	if block_type == 3:
		show_button(buttons[3])
	if block_type == 4:
		show_button(buttons[4])

func show_button(button):
	if button:
		button.disabled = false
		button.get_child(0).modulate.a = 1
	else:
		print("button failed to show, block picker show_button")

	
func hide_button(button):
	if button:
		button.disabled = true
		button.get_child(0).modulate.a = 0.3
	else:
		print("button failed to hide, block picker hide_button")

func _on_game_manager_set_block_picker_height(height) -> void:
	height_state_queue.append(height)

func _on_confirm_button_down() -> void:
	emit_signal("confirm_clicked")

func _on_game_manager_set_turn_order_number(num) -> void:
	find_child("Turn Number").text = "Turn " + str(num)
