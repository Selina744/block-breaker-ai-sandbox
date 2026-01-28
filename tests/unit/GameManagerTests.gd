extends Node
class_name GameManagerTests

##
## GameManagerTests
##
## Unit tests for the GameManager system to validate state management,
## scoring, lives tracking, and game flow functionality.
##

var test_framework: TestFramework
var game_manager: GameManager

##
## Initialize test environment
##
func _ready() -> void:
	test_framework = TestFramework.new()
	add_child(test_framework)

##
## Run all GameManager tests
##
func run_tests() -> void:
	print("[GAME_MANAGER_TESTS] Starting GameManager unit tests...")

	_setup_test_environment()

	test_initial_state()
	test_score_management()
	test_lives_management()
	test_state_transitions()
	test_game_restart()
	test_brick_destruction_handling()

	test_framework.print_test_summary()
	print("[GAME_MANAGER_TESTS] GameManager tests completed.")

##
## Set up test environment with a GameManager instance
##
func _setup_test_environment() -> void:
	# Create fresh GameManager instance for testing
	if game_manager:
		game_manager.queue_free()

	game_manager = GameManager.new()
	add_child(game_manager)

##
## Test initial game state and default values
##
func test_initial_state() -> void:
	test_framework.start_test("GameManager Initial State")

	if not test_framework.assert_not_null(game_manager, "GameManager instance should exist"):
		return

	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.READY, "Initial state should be READY"):
		return

	if not test_framework.assert_equals(game_manager.score, 0, "Initial score should be 0"):
		return

	if not test_framework.assert_equals(game_manager.lives, 3, "Initial lives should be 3"):
		return

	if not test_framework.assert_equals(game_manager.current_level, 1, "Initial level should be 1"):
		return

	test_framework.pass_test("All initial values are correct")

##
## Test score management functionality
##
func test_score_management() -> void:
	test_framework.start_test("GameManager Score Management")

	# Reset to known state
	game_manager.score = 0

	# Test adding score
	game_manager.add_score(100)
	if not test_framework.assert_equals(game_manager.score, 100, "Score should be 100 after adding 100"):
		return

	# Test adding more score
	game_manager.add_score(50)
	if not test_framework.assert_equals(game_manager.score, 150, "Score should be 150 after adding 50 more"):
		return

	# Test brick destruction scoring
	var initial_score = game_manager.score
	game_manager.on_brick_destroyed()
	if not test_framework.assert_equals(game_manager.score, initial_score + game_manager.BRICK_SCORE_VALUE, "Brick destruction should add correct points"):
		return

	test_framework.pass_test("Score management works correctly")

##
## Test lives management and game over conditions
##
func test_lives_management() -> void:
	test_framework.start_test("GameManager Lives Management")

	# Reset to known state
	game_manager.lives = 3
	game_manager.current_state = GameManager.GameState.PLAYING

	# Test losing a life
	game_manager.lose_life()
	if not test_framework.assert_equals(game_manager.lives, 2, "Should have 2 lives after losing one"):
		return

	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.READY, "State should be READY after losing life"):
		return

	# Test losing all lives
	game_manager.lose_life()  # Down to 1
	game_manager.lose_life()  # Down to 0, should trigger game over

	if not test_framework.assert_equals(game_manager.lives, 0, "Should have 0 lives after losing all"):
		return

	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.GAME_OVER, "State should be GAME_OVER when no lives left"):
		return

	test_framework.pass_test("Lives management works correctly")

##
## Test game state transitions
##
func test_state_transitions() -> void:
	test_framework.start_test("GameManager State Transitions")

	# Test start game
	game_manager.start_game()
	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.PLAYING, "State should be PLAYING after start_game()"):
		return

	# Test pause game
	game_manager.pause_game()
	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.PAUSED, "State should be PAUSED after pause_game()"):
		return

	# Test resume game
	game_manager.resume_game()
	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.PLAYING, "State should be PLAYING after resume_game()"):
		return

	# Test end game
	game_manager.end_game()
	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.GAME_OVER, "State should be GAME_OVER after end_game()"):
		return

	test_framework.pass_test("State transitions work correctly")

##
## Test game restart functionality
##
func test_game_restart() -> void:
	test_framework.start_test("GameManager Game Restart")

	# Modify game state
	game_manager.score = 500
	game_manager.lives = 1
	game_manager.current_level = 3
	game_manager.current_state = GameManager.GameState.GAME_OVER

	# Test restart
	game_manager.restart_game()

	if not test_framework.assert_equals(game_manager.score, 0, "Score should be reset to 0"):
		return

	if not test_framework.assert_equals(game_manager.lives, 3, "Lives should be reset to 3"):
		return

	if not test_framework.assert_equals(game_manager.current_level, 1, "Level should be reset to 1"):
		return

	if not test_framework.assert_equals(game_manager.current_state, GameManager.GameState.PLAYING, "State should be PLAYING after restart"):
		return

	test_framework.pass_test("Game restart works correctly")

##
## Test brick destruction handling (without level manager)
##
func test_brick_destruction_handling() -> void:
	test_framework.start_test("GameManager Brick Destruction Handling")

	var initial_score = game_manager.score

	# Test brick destruction
	game_manager.on_brick_destroyed()

	if not test_framework.assert_equals(game_manager.score, initial_score + game_manager.BRICK_SCORE_VALUE, "Brick destruction should add correct score"):
		return

	test_framework.pass_test("Brick destruction handling works correctly")

##
## Check if GameManager has all required methods
##
func test_required_methods() -> void:
	test_framework.start_test("GameManager Required Methods")

	var required_methods = [
		"start_game",
		"pause_game",
		"resume_game",
		"end_game",
		"restart_game",
		"add_score",
		"lose_life",
		"on_brick_destroyed",
		"is_game_active",
		"is_game_ready",
		"get_current_state"
	]

	var missing_methods = test_framework.check_required_methods(game_manager, required_methods)

	if missing_methods.size() > 0:
		test_framework.fail_test("Missing methods: " + str(missing_methods))
		return

	test_framework.pass_test("All required methods are present")