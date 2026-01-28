extends Node2D

##
## MainGameScript_Safe
##
## Improved version of the main game script with comprehensive error handling
## and validation to prevent crashes during initialization. This version includes
## better error reporting and graceful fallback behavior.
##

# Preload helper classes
const FixCommonIssuesClass = preload("res://tests/FixCommonIssues.gd")

# Manager and controller references with safe initialization
var game_manager: GameManager
var level_manager: LevelManager
var paddle: PaddleController
var ball: BallController
var ui_manager: UIManager

# Initialization state tracking
var initialization_complete: bool = false
var initialization_errors: Array[String] = []

##
## Initialize the main game with comprehensive error handling
##
func _ready() -> void:
	print("[MainGame] Starting safe initialization...")

	# Apply common fixes first
	_apply_common_fixes()

	# Wait for scene to be fully ready
	await get_tree().process_frame

	# Get node references safely
	_get_node_references()

	# Validate all systems are available
	if not _validate_systems():
		_handle_initialization_failure()
		return

	# Set up system cross-references
	_setup_system_references()

	# Initialize the game
	_initialize_game()

	initialization_complete = true
	print("[MainGame] Safe initialization complete!")

##
## Apply common fixes that might prevent the game from running
##
func _apply_common_fixes() -> void:
	print("[MainGame] Applying common fixes...")

	# Fix input map if needed - with error handling
	if FixCommonIssuesClass:
		FixCommonIssuesClass.fix_input_map()
		print("[MainGame] Common fixes applied successfully")
	else:
		print("[MainGame] Warning: FixCommonIssues class not available")

##
## Safely get references to all child nodes
##
func _get_node_references() -> void:
	print("[MainGame] Getting node references...")

	# Use get_node_or_null for safe reference getting
	game_manager = get_node_or_null("GameManager") as GameManager
	level_manager = get_node_or_null("LevelManager") as LevelManager
	paddle = get_node_or_null("Paddle") as PaddleController
	ball = get_node_or_null("Ball") as BallController
	ui_manager = get_node_or_null("UIManager") as UIManager

	# Log what we found
	print("[MainGame] Node references acquired:")
	print("  GameManager: %s" % ("✓" if game_manager else "✗"))
	print("  LevelManager: %s" % ("✓" if level_manager else "✗"))
	print("  Paddle: %s" % ("✓" if paddle else "✗"))
	print("  Ball: %s" % ("✓" if ball else "✗"))
	print("  UIManager: %s" % ("✓" if ui_manager else "✗"))

##
## Validate all required systems are available and functional
##
func _validate_systems() -> bool:
	print("[MainGame] Validating systems...")

	var validation_passed = true

	# Check GameManager
	if not game_manager:
		initialization_errors.append("GameManager node not found")
		validation_passed = false
	elif not game_manager.has_method("start_game"):
		initialization_errors.append("GameManager missing required methods")
		validation_passed = false

	# Check LevelManager
	if not level_manager:
		initialization_errors.append("LevelManager node not found")
		validation_passed = false

	# Check PaddleController
	if not paddle:
		initialization_errors.append("Paddle node not found")
		validation_passed = false
	elif not paddle is CharacterBody2D:
		initialization_errors.append("Paddle is not a CharacterBody2D")
		validation_passed = false

	# Check BallController
	if not ball:
		initialization_errors.append("Ball node not found")
		validation_passed = false
	elif not ball is RigidBody2D:
		initialization_errors.append("Ball is not a RigidBody2D")
		validation_passed = false

	# Check UIManager
	if not ui_manager:
		initialization_errors.append("UIManager node not found")
		validation_passed = false

	# Check collision shapes
	if paddle and not paddle.get_node_or_null("CollisionShape2D"):
		initialization_errors.append("Paddle missing CollisionShape2D")
		validation_passed = false

	if ball and not ball.get_node_or_null("CollisionShape2D"):
		initialization_errors.append("Ball missing CollisionShape2D")
		validation_passed = false

	if validation_passed:
		print("[MainGame] ✓ All systems validated successfully")
	else:
		print("[MainGame] ✗ System validation failed:")
		for error in initialization_errors:
			print("  - %s" % error)

	return validation_passed

##
## Set up references between all game systems for communication
##
func _setup_system_references() -> void:
	print("[MainGame] Setting up system references...")

	# Set game manager references in other systems
	if level_manager and game_manager:
		if level_manager.has_method("set_game_manager_reference"):
			level_manager.set_game_manager_reference(game_manager)
		game_manager.level_manager = level_manager

	# Set paddle and ball references
	if ball and paddle:
		if ball.has_method("set_paddle_reference"):
			ball.set_paddle_reference(paddle)

	if ball and game_manager:
		if ball.has_method("set_game_manager_reference"):
			ball.set_game_manager_reference(game_manager)
		game_manager.ball_controller = ball

	if paddle and game_manager:
		game_manager.paddle_controller = paddle

	# Set UI manager reference
	if ui_manager and game_manager:
		if ui_manager.has_method("connect_to_game_manager"):
			ui_manager.connect_to_game_manager(game_manager)
		game_manager.ui_manager = ui_manager

	print("[MainGame] System references configured")

##
## Initialize the game with default level and starting state
##
func _initialize_game() -> void:
	print("[MainGame] Initializing game state...")

	# Load the first level
	if level_manager and level_manager.has_method("load_level"):
		level_manager.load_level(1)
	else:
		print("[MainGame] Warning: Could not load level")

	# Update UI to show initial state
	if ui_manager and ui_manager.has_method("update_game_state") and game_manager:
		ui_manager.update_game_state(game_manager.GameState.READY)
	else:
		print("[MainGame] Warning: Could not update UI state")

	print("[MainGame] Game ready to play")

##
## Handle initialization failure with helpful error reporting
##
func _handle_initialization_failure() -> void:
	print("[MainGame] ❌ INITIALIZATION FAILED!")
	print("The game cannot start due to the following issues:")

	for error in initialization_errors:
		print("  ❌ %s" % error)

	print("\nTroubleshooting steps:")
	print("1. Make sure you're using Godot 4.3 or later")
	print("2. Check that all scene files exist in the correct locations")
	print("3. Verify that all scripts are properly attached to nodes")
	print("4. Check the console for additional error messages")

	# Create a simple error display
	_create_error_display()

##
## Create a simple error display UI
##
func _create_error_display() -> void:
	var error_label = Label.new()
	error_label.text = "Game Initialization Failed!\nCheck console for details.\n\nPress ESC to quit."
	error_label.position = Vector2(50, 50)
	error_label.size = Vector2(700, 200)
	error_label.add_theme_font_size_override("font_size", 24)
	add_child(error_label)

##
## Handle main game input with safe error handling
##
func _input(event: InputEvent) -> void:
	# Exit on escape if initialization failed
	if not initialization_complete and event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		return

	# Handle restart input at the main level
	if event.is_action_pressed("restart_game"):
		_handle_restart_request()

##
## Handle game restart requests with error checking
##
func _handle_restart_request() -> void:
	if not initialization_complete:
		print("[MainGame] Cannot restart - initialization failed")
		return

	if game_manager and game_manager.has_method("get_current_state"):
		var current_state = game_manager.get_current_state()

		# Allow restart from game over state or when game is active
		if current_state == game_manager.GameState.GAME_OVER or current_state == game_manager.GameState.PLAYING:
			print("[MainGame] Restart requested")
			if game_manager.has_method("restart_game"):
				game_manager.restart_game()

			# Update UI state
			if ui_manager and ui_manager.has_method("update_game_state"):
				ui_manager.update_game_state(game_manager.GameState.READY)

##
## Clean up resources and systems when the game ends
##
func _exit_tree() -> void:
	print("[MainGame] Main game cleanup")

##
## Get initialization status for external checking
##
func is_initialized() -> bool:
	return initialization_complete

##
## Get list of initialization errors
##
func get_initialization_errors() -> Array[String]:
	return initialization_errors