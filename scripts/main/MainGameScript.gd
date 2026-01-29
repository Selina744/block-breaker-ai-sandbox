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

	# Validate all critical nodes exist before proceeding
	var missing_nodes = []
	if not game_manager:
		missing_nodes.append("GameManager")
	if not level_manager:
		missing_nodes.append("LevelManager")
	if not ball:
		missing_nodes.append("Ball (BallController)")
	if not paddle:
		missing_nodes.append("Paddle (PaddleController)")
	if not ui_manager:
		missing_nodes.append("UIManager")

	if missing_nodes.size() > 0:
		print("[MainGame] ERROR: Missing critical nodes: %s" % ", ".join(missing_nodes))
		print("[MainGame] Game cannot function without these nodes. Check scene structure.")
		return

	# All nodes exist, set up references safely
	level_manager.set_game_manager_reference(game_manager)
	game_manager.level_manager = level_manager

	ball.set_paddle_reference(paddle)
	ball.set_game_manager_reference(game_manager)
	game_manager.ball_controller = ball

	game_manager.paddle_controller = paddle

	# Set UI manager reference (already validated to exist)
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