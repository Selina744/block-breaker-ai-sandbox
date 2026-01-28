extends CharacterBody2D
class_name PaddleController

##
## PaddleController
##
## Handles the player-controlled paddle including movement, input processing,
## boundary constraints, and ball collision interactions. The paddle serves as
## the primary player interface for controlling ball direction and preventing
## the ball from falling off the screen.
##
## Features:
## - Smooth horizontal movement with configurable speed
## - Screen boundary collision detection and clamping
## - Ball bounce direction calculation based on impact position
## - Visual feedback and animation support
## - Collision shape management
##
## Input Mapping:
## - A/Left Arrow: Move paddle left
## - D/Right Arrow: Move paddle right
##

# Movement configuration
@export var movement_speed: float = 400.0  ## Paddle movement speed in pixels/second
@export var paddle_width: float = 80.0     ## Visual width of the paddle for positioning

# Screen boundaries for clamping paddle position
var screen_width: float
var paddle_half_width: float

# Input state tracking for smooth movement
var input_direction: float = 0.0

# Node references
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: ColorRect = $Sprite

##
## Initialize paddle properties and screen boundaries
##
func _ready() -> void:
	print("[PaddleController] Paddle controller initialized")

	# Get screen dimensions for boundary calculations
	screen_width = get_viewport().get_visible_rect().size.x
	paddle_half_width = paddle_width / 2.0

	# Set up paddle visual appearance
	_setup_paddle_appearance()

	# Set up collision shape
	_setup_collision_shape()

	print("[PaddleController] Screen width: %d, Paddle width: %d" % [screen_width, paddle_width])

##
## Process player input and update paddle movement
## @param delta: Time elapsed since last frame
##
func _physics_process(delta: float) -> void:
	_handle_input()
	_update_movement(delta)
	_clamp_to_screen_bounds()

##
## Process input events for paddle movement
##
func _handle_input() -> void:
	# Reset input direction
	input_direction = 0.0

	# Check for movement input (supports both WASD and arrow keys)
	if Input.is_action_pressed("move_left"):
		input_direction -= 1.0
	if Input.is_action_pressed("move_right"):
		input_direction += 1.0

##
## Update paddle position based on input and movement speed
## @param delta: Time elapsed since last frame
##
func _update_movement(delta: float) -> void:
	# Calculate velocity based on input direction and movement speed
	velocity.x = input_direction * movement_speed

	# Apply movement using Godot's built-in physics
	move_and_slide()

##
## Ensure paddle stays within screen boundaries
##
func _clamp_to_screen_bounds() -> void:
	# Clamp paddle position to screen boundaries accounting for paddle width
	var min_x = paddle_half_width
	var max_x = screen_width - paddle_half_width

	if position.x < min_x:
		position.x = min_x
		velocity.x = 0  # Stop movement at boundary
	elif position.x > max_x:
		position.x = max_x
		velocity.x = 0  # Stop movement at boundary

##
## Calculate ball bounce direction based on where it hits the paddle
## This creates more dynamic and controllable ball movement
## @param ball_position: Current position of the ball
## @returns: Normalized direction vector for ball bounce
##
func calculate_bounce_direction(ball_position: Vector2) -> Vector2:
	# Calculate relative position of ball impact on paddle (-1.0 to 1.0)
	var relative_intersect_x = (ball_position.x - position.x) / paddle_half_width

	# Clamp to ensure the value stays within bounds
	relative_intersect_x = clampf(relative_intersect_x, -1.0, 1.0)

	# Calculate bounce angle (maximum 60 degrees from vertical)
	var max_bounce_angle = PI / 3.0  # 60 degrees in radians
	var bounce_angle = relative_intersect_x * max_bounce_angle

	# Create direction vector (always bounces upward)
	var direction = Vector2(sin(bounce_angle), -abs(cos(bounce_angle)))

	print("[PaddleController] Ball bounce - Relative X: %.2f, Angle: %.2f, Direction: %s" %
		  [relative_intersect_x, rad_to_deg(bounce_angle), direction])

	return direction.normalized()

##
## Set up the visual appearance of the paddle
##
func _setup_paddle_appearance() -> void:
	# Configure the paddle sprite (using ColorRect for simplicity)
	if sprite:
		sprite.size = Vector2(paddle_width, 12.0)
		sprite.position = Vector2(-paddle_half_width, -6.0)
		sprite.color = Color.WHITE
		print("[PaddleController] Paddle appearance configured")

##
## Set up the collision shape for physics interactions
##
func _setup_collision_shape() -> void:
	if collision_shape and collision_shape.shape == null:
		# Create a rectangular collision shape matching the paddle size
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(paddle_width, 12.0)
		collision_shape.shape = rect_shape
		print("[PaddleController] Collision shape configured")

##
## Get the current width of the paddle
## @returns: Paddle width in pixels
##
func get_paddle_width() -> float:
	return paddle_width

##
## Get the current movement speed of the paddle
## @returns: Movement speed in pixels/second
##
func get_movement_speed() -> float:
	return movement_speed

##
## Set a new movement speed for the paddle
## @param new_speed: New movement speed in pixels/second
##
func set_movement_speed(new_speed: float) -> void:
	movement_speed = new_speed
	print("[PaddleController] Movement speed updated to: %.1f" % movement_speed)