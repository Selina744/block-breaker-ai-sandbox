extends Node2D

##
## MainGameScript
##
## The main orchestrator script that connects all game systems and manages
## the overall game flow. This script initializes all managers, sets up
## references between systems, and handles the main game loop coordination.
##
## Responsibilities:
## - Initialize all game managers and controllers
## - Set up cross-references between systems
## - Handle main game loop coordination
## - Manage scene transitions and cleanup
## - Coordinate input handling between systems
##
## System Integration:
## This script ensures all game systems can communicate with each other
## and provides a central point for managing the overall game state.
##

# Manager and controller references
@onready var game_manager: GameManager = $GameManager
@onready var level_manager: LevelManager = $LevelManager
@onready var paddle: PaddleController = $Paddle
@onready var ball: BallController = $Ball
@onready var ui_manager: UIManager = $UIManager

##
## Initialize the main game and set up all systems
##
func _ready() -> void:
	print("[MainGame] Main game initializing...")

	# Give systems time to initialize
	await get_tree().process_frame

	# Set up cross-references between systems
	_setup_system_references()

	# Initialize the game
	_initialize_game()

	print("[MainGame] Main game initialization complete")

##
## Set up references between all game systems for communication
##
func _setup_system_references() -> void:
	print("[MainGame] Setting up system references")

	# Set game manager references in other systems
	if level_manager and game_manager:
		level_manager.set_game_manager_reference(game_manager)
		game_manager.level_manager = level_manager

	# Set paddle and ball references
	if ball and paddle:
		ball.set_paddle_reference(paddle)

	if ball and game_manager:
		ball.set_game_manager_reference(game_manager)
		game_manager.ball_controller = ball

	if paddle and game_manager:
		game_manager.paddle_controller = paddle

	# Set UI manager reference
	if ui_manager and game_manager:
		ui_manager.connect_to_game_manager(game_manager)
		game_manager.ui_manager = ui_manager

	print("[MainGame] System references configured")

##
## Initialize the game with default level and starting state
##
func _initialize_game() -> void:
	print("[MainGame] Initializing game state")

	# Load the first level
	if level_manager:
		level_manager.load_level(1)

	# Update UI to show initial state
	if ui_manager:
		ui_manager.update_game_state(GameManager.GameState.READY)

	print("[MainGame] Game ready to play")

##
## Handle main game input that affects multiple systems
##
func _input(event: InputEvent) -> void:
	# Handle restart input at the main level
	if event.is_action_pressed("restart_game"):
		_handle_restart_request()

##
## Handle game restart requests
##
func _handle_restart_request() -> void:
	if game_manager:
		var current_state = game_manager.get_current_state()

		# Allow restart from game over state or when game is active
		if current_state == GameManager.GameState.GAME_OVER or current_state == GameManager.GameState.PLAYING:
			print("[MainGame] Restart requested")
			game_manager.restart_game()

			# Update UI state
			if ui_manager:
				ui_manager.update_game_state(GameManager.GameState.READY)

##
## Clean up resources and systems when the game ends
##
func _exit_tree() -> void:
	print("[MainGame] Main game cleanup")
	# Additional cleanup can be added here if needed