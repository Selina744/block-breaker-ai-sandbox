extends Node
class_name LevelManager

##
## LevelManager
##
## Handles loading, managing, and transitioning between game levels. This system
## provides an easy way to create new levels through data files and manages the
## lifecycle of bricks and level-specific game objects.
##
## Features:
## - Level loading from JSON configuration files
## - Dynamic brick placement and management
## - Level progression and completion detection
## - Easy level creation system for designers
## - Support for different brick types and layouts
## - Level-specific properties (background, music, etc.)
##
## Level File Format:
## JSON files in levels/ directory containing brick layout data, metadata,
## and level-specific configuration options.
##

# Level configuration
@export var current_level_number: int = 1
@export var levels_directory: String = "res://levels/"

# Level data storage
var current_level_data: Dictionary = {}
var active_bricks: Array[Brick] = []

# Brick spacing and positioning
const BRICK_MARGIN_X: float = 4.0
const BRICK_MARGIN_Y: float = 4.0
const LEVEL_START_Y: float = 100.0
const LEVEL_MARGIN_X: float = 50.0

# Node references
var brick_container: Node2D
var game_manager: GameManager

##
## Initialize the level manager and prepare for level loading
##
func _ready() -> void:
	print("[LevelManager] Level Manager initialized")
	_create_brick_container()

##
## Load and set up the specified level
## @param level_number: Level number to load (1-based)
## @returns: true if level loaded successfully
##
func load_level(level_number: int) -> bool:
	print("[LevelManager] Loading level %d" % level_number)

	current_level_number = level_number

	# Try to load level data from file
	var level_file_path = levels_directory + "level_%d.json" % level_number
	var level_data = _load_level_data(level_file_path)

	if level_data.is_empty():
		# If no level file found, create default level
		print("[LevelManager] Level file not found, creating default level")
		level_data = _create_default_level()

	current_level_data = level_data
	_build_level_from_data(level_data)

	return true

##
## Reload the current level (useful for restarts and level completion)
##
func reload_current_level() -> void:
	print("[LevelManager] Reloading current level %d" % current_level_number)
	_clear_current_level()
	load_level(current_level_number)

##
## Get the number of bricks remaining in the current level
## @returns: Number of active bricks that haven't been destroyed
##
func get_remaining_brick_count() -> int:
	# Filter out destroyed bricks and count remaining
	var remaining = 0
	for brick in active_bricks:
		if brick != null and not brick.is_brick_destroyed():
			remaining += 1
	return remaining

##
## Clear all bricks from the current level
##
func _clear_current_level() -> void:
	print("[LevelManager] Clearing current level")

	# Remove all active bricks
	for brick in active_bricks:
		if brick != null and is_instance_valid(brick):
			brick.queue_free()

	active_bricks.clear()

	# Clear brick container
	if brick_container:
		for child in brick_container.get_children():
			child.queue_free()

##
## Create the container node for organizing bricks
##
func _create_brick_container() -> void:
	if not brick_container:
		brick_container = Node2D.new()
		brick_container.name = "BrickContainer"
		add_child(brick_container)
		print("[LevelManager] Brick container created")

##
## Load level data from a JSON file
## @param file_path: Path to the level JSON file
## @returns: Dictionary containing level data, or empty dict if failed
##
func _load_level_data(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		print("[LevelManager] Level file not found: %s" % file_path)
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("[LevelManager] Failed to open level file: %s" % file_path)
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		print("[LevelManager] Failed to parse level JSON: %s" % file_path)
		return {}

	print("[LevelManager] Level data loaded successfully from: %s" % file_path)
	return json.data

##
## Build the level layout from loaded data
## @param level_data: Dictionary containing level configuration and brick layout
##
func _build_level_from_data(level_data: Dictionary) -> void:
	print("[LevelManager] Building level from data")

	# Extract level metadata
	var level_name = level_data.get("name", "Untitled Level")
	var level_description = level_data.get("description", "")

	print("[LevelManager] Level: %s - %s" % [level_name, level_description])

	# Get brick layout data
	var bricks_data = level_data.get("bricks", [])

	if bricks_data.is_empty():
		print("[LevelManager] No brick data found, creating default layout")
		_create_default_brick_layout()
	else:
		_create_bricks_from_data(bricks_data)

##
## Create bricks from layout data array
## @param bricks_data: Array of brick configuration dictionaries
##
func _create_bricks_from_data(bricks_data: Array) -> void:
	for brick_info in bricks_data:
		var brick_dict = brick_info as Dictionary

		# Extract brick properties
		var x = brick_dict.get("x", 0)
		var y = brick_dict.get("y", 0)
		var brick_type_string = brick_dict.get("type", "BASIC")

		# Convert type string to enum
		var brick_type = _string_to_brick_type(brick_type_string)

		# Create and position brick
		_create_brick_at_position(Vector2(x, y), brick_type)

##
## Create a default level when no level file is available
## @returns: Dictionary containing default level data
##
func _create_default_level() -> Dictionary:
	return {
		"name": "Level 1",
		"description": "Classic brick breaker layout",
		"version": 1,
		"bricks": _generate_default_brick_data()
	}

##
## Create default brick layout in a classic grid pattern
##
func _create_default_brick_layout() -> void:
	print("[LevelManager] Creating default brick layout")

	var rows = 5
	var cols = 10
	var brick_width = 64.0
	var brick_height = 24.0

	var start_x = LEVEL_MARGIN_X + brick_width / 2.0
	var start_y = LEVEL_START_Y

	for row in range(rows):
		for col in range(cols):
			var x = start_x + col * (brick_width + BRICK_MARGIN_X)
			var y = start_y + row * (brick_height + BRICK_MARGIN_Y)

			# Vary brick types by row for visual interest
			var brick_type = Brick.BrickType.BASIC
			if row == 0:
				brick_type = Brick.BrickType.SPECIAL
			elif row < 2:
				brick_type = Brick.BrickType.STRONG

			_create_brick_at_position(Vector2(x, y), brick_type)

##
## Generate default brick data for level file
## @returns: Array of brick configuration dictionaries
##
func _generate_default_brick_data() -> Array:
	var brick_data = []
	var rows = 5
	var cols = 10
	var brick_width = 64.0
	var brick_height = 24.0

	var start_x = LEVEL_MARGIN_X + brick_width / 2.0
	var start_y = LEVEL_START_Y

	for row in range(rows):
		for col in range(cols):
			var x = start_x + col * (brick_width + BRICK_MARGIN_X)
			var y = start_y + row * (brick_height + BRICK_MARGIN_Y)

			var brick_type_string = "BASIC"
			if row == 0:
				brick_type_string = "SPECIAL"
			elif row < 2:
				brick_type_string = "STRONG"

			brick_data.append({
				"x": x,
				"y": y,
				"type": brick_type_string
			})

	return brick_data

##
## Create a brick at the specified position
## @param pos: Position to place the brick
## @param brick_type: Type of brick to create
##
func _create_brick_at_position(pos: Vector2, brick_type: Brick.BrickType) -> void:
	# Load brick scene and create instance
	var brick_scene = preload("res://scenes/components/Brick.tscn")
	var brick = brick_scene.instantiate() as Brick

	# Configure brick
	brick.position = pos
	brick.set_brick_type(brick_type)

	# Connect destruction signal
	brick.brick_destroyed.connect(_on_brick_destroyed)

	# Add to scene and tracking
	brick_container.add_child(brick)
	active_bricks.append(brick)

##
## Handle brick destruction and track remaining bricks
## @param brick: The brick that was destroyed
## @param score_value: Score points awarded
##
func _on_brick_destroyed(brick: Brick, score_value: int) -> void:
	print("[LevelManager] Brick destroyed - %d bricks remaining" % get_remaining_brick_count())

	# Remove from active bricks array
	active_bricks.erase(brick)

##
## Convert string representation to BrickType enum
## @param type_string: String representation of brick type
## @returns: Corresponding BrickType enum value
##
func _string_to_brick_type(type_string: String) -> Brick.BrickType:
	match type_string.to_upper():
		"BASIC":
			return Brick.BrickType.BASIC
		"STRONG":
			return Brick.BrickType.STRONG
		"SPECIAL":
			return Brick.BrickType.SPECIAL
		_:
			print("[LevelManager] Unknown brick type: %s, defaulting to BASIC" % type_string)
			return Brick.BrickType.BASIC

##
## Get current level metadata
## @returns: Dictionary containing level information
##
func get_current_level_info() -> Dictionary:
	return {
		"number": current_level_number,
		"name": current_level_data.get("name", "Level %d" % current_level_number),
		"description": current_level_data.get("description", ""),
		"total_bricks": active_bricks.size(),
		"remaining_bricks": get_remaining_brick_count()
	}

##
## Set game manager reference for coordination
## @param manager_ref: Reference to the GameManager
##
func set_game_manager_reference(manager_ref: GameManager) -> void:
	game_manager = manager_ref
	print("[LevelManager] Game manager reference set")