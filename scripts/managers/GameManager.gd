extends Node
class_name GameManager

##
## GameManager
##
## The central game state manager that handles the overall game flow, scoring,
## and coordination between different game systems. This singleton manages the
## game lifecycle from start to finish.
##
## Features:
## - Game state management (Ready, Playing, GameOver, Paused)
## - Score tracking and display
## - Lives management
## - Level progression and completion
## - Game restart and reset functionality
##
## Signals:
## - game_started: Emitted when the game begins
## - game_over: Emitted when player loses all lives
## - score_changed: Emitted when score updates
## - lives_changed: Emitted when lives change
## - level_completed: Emitted when all bricks are destroyed
##

# Game states enum for clear state management
enum GameState {
	READY,     ## Game is ready to start, waiting for player input
	PLAYING,   ## Game is actively being played
	PAUSED,    ## Game is paused (for future pause functionality)
	GAME_OVER  ## Game has ended, showing game over screen
}

# Game event signals for communication between systems
signal game_started
signal game_over
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_completed

# Current game state
var current_state: GameState = GameState.READY

# Player progression tracking
var score: int = 0
var lives: int = 3
var current_level: int = 1

# Score values for different actions
const BRICK_SCORE_VALUE: int = 100
const LEVEL_COMPLETION_BONUS: int = 1000

# References to game systems - set by MainGame scene
var paddle_controller: PaddleController
var ball_controller: BallController
var level_manager: LevelManager
var ui_manager: UIManager

##
## Initialize the game manager with default values
##
func _ready() -> void:
	print("[GameManager] Game Manager initialized")
	_reset_game_state()

##
## Start a new game, resetting all progress and beginning level 1
##
func start_game() -> void:
	print("[GameManager] Starting new game")
	current_state = GameState.PLAYING
	_reset_game_state()
	game_started.emit()

##
## Pause the current game (preserves game state)
##
func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		print("[GameManager] Game paused")

##
## Resume a paused game
##
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		print("[GameManager] Game resumed")

##
## End the current game and transition to game over state
##
func end_game() -> void:
	print("[GameManager] Game over - Final score: %d" % score)
	current_state = GameState.GAME_OVER
	game_over.emit()

##
## Restart the game completely, maintaining the same level
##
func restart_game() -> void:
	print("[GameManager] Restarting game")
	start_game()
	if level_manager:
		level_manager.reload_current_level()

##
## Add points to the player's score
## @param points: Number of points to add
##
func add_score(points: int) -> void:
	score += points
	print("[GameManager] Score updated: %d (+%d)" % [score, points])
	score_changed.emit(score)

##
## Award points for destroying a brick
##
func on_brick_destroyed() -> void:
	add_score(BRICK_SCORE_VALUE)

	# Check if level is complete (no bricks remaining)
	if level_manager and level_manager.get_remaining_brick_count() == 0:
		_complete_level()

##
## Remove a life from the player and handle game over if necessary
##
func lose_life() -> void:
	lives -= 1
	print("[GameManager] Life lost - Remaining lives: %d" % lives)
	lives_changed.emit(lives)

	if lives <= 0:
		end_game()
	else:
		# Reset ball position for next attempt
		if ball_controller:
			ball_controller.reset_ball()
		current_state = GameState.READY

##
## Complete the current level and advance to the next
##
func _complete_level() -> void:
	print("[GameManager] Level %d completed!" % current_level)

	# Award level completion bonus
	add_score(LEVEL_COMPLETION_BONUS)

	# Advance to next level
	current_level += 1
	level_completed.emit()

	# TODO: Implement multiple levels
	# For now, just restart the same level with bonus score
	if level_manager:
		level_manager.reload_current_level()

	if ball_controller:
		ball_controller.reset_ball()

	current_state = GameState.READY

##
## Reset all game state to initial values
##
func _reset_game_state() -> void:
	score = 0
	lives = 3
	current_level = 1
	score_changed.emit(score)
	lives_changed.emit(lives)

##
## Check if the game is currently in a playing state
## @returns: true if game is active and being played
##
func is_game_active() -> bool:
	return current_state == GameState.PLAYING

##
## Check if the game is ready to start
## @returns: true if game is in ready state
##
func is_game_ready() -> bool:
	return current_state == GameState.READY

##
## Get the current game state
## @returns: Current GameState enum value
##
func get_current_state() -> GameState:
	return current_state