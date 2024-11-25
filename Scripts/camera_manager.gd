extends Node2D

var CAMERA_X_POS_TITLE = 50
var CAMERA_X_POS_GAME = 530
var CAMERA_X_POS_SETTINGS = -1024

var CAMERA_SPEED = 0.08
var CAMERA_Y_POS = 290

var camera
enum {
	title_state,
	game_state,
	settings_state
}
var current_camera_state = title_state


signal game_start

func _ready() -> void:
	camera = get_node("../Camera2D")
	if not camera:
		print("Camera node not found in gamemanager _ready")


func _process(_delta: float) -> void:
	# Move to game state if clicked
	if current_camera_state == game_state:
		if camera.position.x <= CAMERA_X_POS_GAME:
			# +1 is added to the x lerp so it will actually reach the position and stop
			camera.position = camera.position.lerp(Vector2(CAMERA_X_POS_GAME + 1, CAMERA_Y_POS), CAMERA_SPEED)
	
	# Move to title state if clicked
	if current_camera_state == title_state:
		if camera.position.x >= CAMERA_X_POS_GAME:
			camera.position = camera.position.lerp(Vector2(CAMERA_X_POS_TITLE + 1, CAMERA_Y_POS), CAMERA_SPEED)
		if camera.position.x <= CAMERA_X_POS_GAME:
			camera.position = camera.position.lerp(Vector2(CAMERA_X_POS_TITLE - 1, CAMERA_Y_POS), CAMERA_SPEED)

	# Move to game state if clicked
	if current_camera_state == settings_state:
		if camera.position.x >= CAMERA_X_POS_SETTINGS:
			camera.position = camera.position.lerp(Vector2(CAMERA_X_POS_SETTINGS + 1, CAMERA_Y_POS), CAMERA_SPEED)


func _on_start_game_button_down() -> void:
	current_camera_state = game_state
	emit_signal("game_start", true)


func _on_title_screen_button_down() -> void:
	current_camera_state = title_state
	emit_signal("game_start", false)


func _on_settings_button_down() -> void:
	current_camera_state = settings_state


func _on_title_screen_2_button_down() -> void:
	current_camera_state = title_state
	emit_signal("game_start", false)
