extends Control
class_name UIManager

##
## UIManager
##
## Manages the user interface elements including score display, lives counter,
## game state messages, and level information. Provides a clean interface
## between game logic and visual presentation.
##
## Features:
## - Real-time score and lives display
## - Game state messaging (ready, game over, paused)
## - Level information display
## - Input instruction overlay
## - Responsive UI layout
## - Easy styling and theming support
##
## UI Elements:
## - Score label: Current player score
## - Lives label: Remaining lives display
## - State label: Current game state message
## - Level label: Current level information
## - Instructions label: Input controls help
##

# UI Labels and display elements
@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var state_label: Label = $StateLabel
@onready var level_label: Label = $LevelLabel
@onready var instructions_label: Label = $InstructionsLabel

# Current display values
var current_score: int = 0
var current_lives: int = 3
var current_level: int = 1

# Game manager reference
var game_manager: GameManager

##
## Initialize UI manager and set up initial display
##
func _ready() -> void:
	print("[UIManager] UI Manager initialized")
	_setup_ui_layout()
	_update_all_displays()

##
## Set up the positioning and styling of UI elements
##
func _setup_ui_layout() -> void:
	# Configure main UI container
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Set up individual UI elements
	_setup_score_display()
	_setup_lives_display()
	_setup_state_display()
	_setup_level_display()
	_setup_instructions_display()

	print("[UIManager] UI layout configured")

##
## Configure score display positioning and style
##
func _setup_score_display() -> void:
	if score_label:
		score_label.position = Vector2(20, 20)
		score_label.add_theme_font_size_override("font_size", 24)
		score_label.text = "Score: 0"

##
## Configure lives display positioning and style
##
func _setup_lives_display() -> void:
	if lives_label:
		lives_label.position = Vector2(200, 20)
		lives_label.add_theme_font_size_override("font_size", 24)
		lives_label.text = "Lives: 3"

##
## Configure game state message display
##
func _setup_state_display() -> void:
	if state_label:
		state_label.position = Vector2(350, 300)
		state_label.add_theme_font_size_override("font_size", 32)
		state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		state_label.text = "Press SPACE to Start"

##
## Configure level information display
##
func _setup_level_display() -> void:
	if level_label:
		level_label.position = Vector2(400, 20)
		level_label.add_theme_font_size_override("font_size", 24)
		level_label.text = "Level: 1"

##
## Configure instructions display
##
func _setup_instructions_display() -> void:
	if instructions_label:
		instructions_label.position = Vector2(20, 550)
		instructions_label.add_theme_font_size_override("font_size", 16)
		instructions_label.text = "Controls: A/D or Arrow Keys to move, SPACE to launch, R to restart"

##
## Update score display
## @param new_score: New score value to display
##
func update_score(new_score: int) -> void:
	current_score = new_score
	if score_label:
		score_label.text = "Score: %d" % current_score

##
## Update lives display
## @param new_lives: New lives count to display
##
func update_lives(new_lives: int) -> void:
	current_lives = new_lives
	if lives_label:
		lives_label.text = "Lives: %d" % current_lives

		# Color coding for low lives
		if current_lives <= 1:
			lives_label.add_theme_color_override("font_color", Color.RED)
		elif current_lives <= 2:
			lives_label.add_theme_color_override("font_color", Color.ORANGE)
		else:
			lives_label.add_theme_color_override("font_color", Color.WHITE)

##
## Update level display
## @param new_level: New level number to display
##
func update_level(new_level: int) -> void:
	current_level = new_level
	if level_label:
		level_label.text = "Level: %d" % current_level

##
## Update game state message
## @param state: Current GameManager.GameState value
##
func update_game_state(state: GameManager.GameState) -> void:
	if not state_label:
		return

	match state:
		GameManager.GameState.READY:
			state_label.text = "Press SPACE to Start"
			state_label.add_theme_color_override("font_color", Color.WHITE)
			state_label.visible = true

		GameManager.GameState.PLAYING:
			state_label.visible = false

		GameManager.GameState.PAUSED:
			state_label.text = "PAUSED"
			state_label.add_theme_color_override("font_color", Color.YELLOW)
			state_label.visible = true

		GameManager.GameState.GAME_OVER:
			state_label.text = "GAME OVER - Press R to Restart"
			state_label.add_theme_color_override("font_color", Color.RED)
			state_label.visible = true

##
## Show level completion message
##
func show_level_completed() -> void:
	if state_label:
		state_label.text = "Level Complete! - Press SPACE for Next"
		state_label.add_theme_color_override("font_color", Color.GREEN)
		state_label.visible = true

##
## Connect to game manager signals for automatic UI updates
## @param manager_ref: Reference to the GameManager
##
func connect_to_game_manager(manager_ref: GameManager) -> void:
	game_manager = manager_ref

	if game_manager:
		# Connect signals for automatic updates
		game_manager.score_changed.connect(update_score)
		game_manager.lives_changed.connect(update_lives)
		game_manager.level_completed.connect(show_level_completed)

		print("[UIManager] Connected to game manager signals")

##
## Update all displays with current values
##
func _update_all_displays() -> void:
	update_score(current_score)
	update_lives(current_lives)
	update_level(current_level)
	update_game_state(GameManager.GameState.READY)

##
## Handle input for UI-specific controls
##
func _input(event: InputEvent) -> void:
	# Handle restart input
	if event.is_action_pressed("restart_game") and game_manager:
		if game_manager.get_current_state() == GameManager.GameState.GAME_OVER:
			game_manager.restart_game()

##
## Show temporary message overlay
## @param message: Text to display
## @param duration: How long to show the message (seconds)
##
func show_temporary_message(message: String, duration: float = 2.0) -> void:
	if state_label:
		state_label.text = message
		state_label.add_theme_color_override("font_color", Color.YELLOW)
		state_label.visible = true

		# Hide message after duration
		await get_tree().create_timer(duration).timeout

		# Only hide if we haven't changed to a different message
		if state_label.text == message:
			state_label.visible = false

##
## Get current UI state for debugging
## @returns: Dictionary containing current UI values
##
func get_ui_state() -> Dictionary:
	return {
		"score": current_score,
		"lives": current_lives,
		"level": current_level,
		"state_visible": state_label.visible if state_label else false,
		"state_text": state_label.text if state_label else ""
	}

##
## Reset UI to initial state
##
func reset_ui() -> void:
	current_score = 0
	current_lives = 3
	current_level = 1
	_update_all_displays()
	print("[UIManager] UI reset to initial state")