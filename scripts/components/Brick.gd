extends StaticBody2D
class_name Brick

##
## Brick
##
## Represents an individual destructible brick in the game. Handles collision
## detection, destruction effects, different brick types, and scoring integration.
## Bricks form the primary targets that players must destroy to complete levels.
##
## Features:
## - Multiple brick types with different properties
## - Hit point system for multi-hit bricks
## - Visual feedback for damage states
## - Destruction effects and animations
## - Score value configuration per brick type
## - Collision detection with ball
##
## Brick Types:
## - BASIC: Single hit, standard points
## - STRONG: Multiple hits required, higher points
## - SPECIAL: Unique behavior, bonus points
##

# Brick type enumeration for different brick behaviors
enum BrickType {
	BASIC,   ## Standard single-hit brick
	STRONG,  ## Multi-hit brick requiring 2-3 hits
	SPECIAL  ## Special brick with unique properties
}

# Brick configuration
@export var brick_type: BrickType = BrickType.BASIC
@export var max_hit_points: int = 1
@export var score_value: int = 100
@export var brick_width: float = 60.0
@export var brick_height: float = 20.0

# Current state
var current_hit_points: int
var is_destroyed: bool = false

# Visual states based on damage
var color_full_health: Color = Color.CYAN
var color_damaged: Color = Color.ORANGE
var color_critical: Color = Color.RED

# Node references
@onready var sprite: ColorRect = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Signals for game coordination
signal brick_destroyed(brick: Brick, score_value: int)

##
## Initialize brick properties and appearance
##
func _ready() -> void:
	_setup_brick_properties()
	_setup_appearance()
	_setup_collision()

	print("[Brick] Brick initialized - Type: %s, HP: %d, Score: %d" %
		  [BrickType.keys()[brick_type], max_hit_points, score_value])

##
## Configure brick properties based on type
##
func _setup_brick_properties() -> void:
	current_hit_points = max_hit_points

	# Configure properties based on brick type
	match brick_type:
		BrickType.BASIC:
			max_hit_points = 1
			score_value = 100
			color_full_health = Color.CYAN

		BrickType.STRONG:
			max_hit_points = 2
			score_value = 200
			color_full_health = Color.GREEN

		BrickType.SPECIAL:
			max_hit_points = 1
			score_value = 500
			color_full_health = Color.MAGENTA

	current_hit_points = max_hit_points

##
## Set up visual appearance based on brick type and state
##
func _setup_appearance() -> void:
	if sprite:
		sprite.size = Vector2(brick_width, brick_height)
		sprite.position = Vector2(-brick_width / 2.0, -brick_height / 2.0)
		_update_visual_state()

##
## Set up collision detection
##
func _setup_collision() -> void:
	if collision_shape and collision_shape.shape == null:
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(brick_width, brick_height)
		collision_shape.shape = rect_shape

	# Set collision layer for bricks
	collision_layer = 4  # Brick layer
	collision_mask = 0   # Bricks don't actively collide with anything

##
## Handle being hit by the ball or other objects
## @returns: true if brick was destroyed by this hit
##
func hit() -> bool:
	if is_destroyed:
		return false

	current_hit_points -= 1
	print("[Brick] Brick hit - Remaining HP: %d" % current_hit_points)

	_update_visual_state()

	# Check if brick should be destroyed
	if current_hit_points <= 0:
		destroy()
		return true

	return false

##
## Destroy this brick and handle cleanup
##
func destroy() -> void:
	if is_destroyed:
		return

	print("[Brick] Brick destroyed - Score awarded: %d" % score_value)

	is_destroyed = true

	# Emit signal for score tracking
	brick_destroyed.emit(self, score_value)

	# Play destruction effect
	_play_destruction_effect()

	# Remove from scene
	queue_free()

##
## Update visual appearance based on current damage state
##
func _update_visual_state() -> void:
	if not sprite:
		return

	# Calculate damage ratio for visual feedback
	var damage_ratio = float(current_hit_points) / float(max_hit_points)

	if damage_ratio > 0.66:
		sprite.color = color_full_health
	elif damage_ratio > 0.33:
		sprite.color = color_damaged
	else:
		sprite.color = color_critical

##
## Play visual and audio effects when brick is destroyed
##
func _play_destruction_effect() -> void:
	# TODO: Add particle effects, screen shake, or sound effects
	print("[Brick] Playing destruction effect")

	# Simple flash effect before destruction
	if sprite:
		sprite.color = Color.WHITE

##
## Get the score value this brick awards when destroyed
## @returns: Score points awarded for destroying this brick
##
func get_score_value() -> int:
	return score_value

##
## Get the current hit points remaining
## @returns: Current hit points
##
func get_hit_points() -> int:
	return current_hit_points

##
## Get the maximum hit points for this brick
## @returns: Maximum hit points
##
func get_max_hit_points() -> int:
	return max_hit_points

##
## Get the brick type
## @returns: BrickType enum value
##
func get_brick_type() -> BrickType:
	return brick_type

##
## Check if this brick has been destroyed
## @returns: true if brick is destroyed
##
func is_brick_destroyed() -> bool:
	return is_destroyed

##
## Set brick type and update properties accordingly
## @param new_type: New BrickType to assign
##
func set_brick_type(new_type: BrickType) -> void:
	brick_type = new_type
	_setup_brick_properties()
	_setup_appearance()

##
## Factory method to create a brick with specific configuration
## @param type: Type of brick to create
## @param pos: Position to place the brick
## @returns: Configured Brick instance
##
static func create_brick(type: BrickType, pos: Vector2) -> Brick:
	var brick = preload("res://scenes/components/Brick.tscn").instantiate()
	brick.position = pos
	brick.set_brick_type(type)
	return brick