extends RigidBody2D
class_name BallController

##
## BallController
##
## Manages the ball physics, movement, collision handling, and game state
## interactions. This is the core gameplay element that bounces between
## paddle, walls, and bricks to create the main game mechanics.
##
## Features:
## - Constant velocity ball movement with physics simulation
## - Wall and boundary collision handling
## - Paddle collision with dynamic bounce angles
## - Brick collision detection and destruction
## - Ball reset and launch mechanics
## - Out-of-bounds detection for life loss
##
## Collision Layers:
## - Walls: Perfect reflection
## - Paddle: Directional bounce based on impact position
## - Bricks: Destroy brick and reflect ball
## - Bottom boundary: Life loss trigger
##

# Ball movement configuration
@export var ball_speed: float = 300.0        ## Ball movement speed in pixels/second
@export var max_speed: float = 500.0         ## Maximum ball speed to prevent runaway velocity
@export var min_speed: float = 200.0         ## Minimum ball speed to maintain gameplay flow
@export var speed_increase_rate: float = 1.02 ## Speed multiplier per brick hit

# Ball properties
@export var ball_radius: float = 8.0         ## Visual and collision radius of the ball

# Launch configuration
var is_attached_to_paddle: bool = true       ## Whether ball is waiting for launch
var paddle_offset: Vector2 = Vector2(0, -20) ## Offset from paddle when attached

# Game state tracking
var initial_position: Vector2                ## Starting position for resets
var screen_bounds: Rect2                     ## Screen boundaries for collision detection

# Node references
var paddle: PaddleController
var game_manager: GameManager

# Visual components
@onready var sprite: ColorRect = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

##
## Initialize ball properties and setup collision detection
##
func _ready() -> void:
	print("[BallController] Ball controller initialized")

	# Store initial position for resets
	initial_position = position

	# Get screen boundaries
	var viewport_size = get_viewport().get_visible_rect().size
	screen_bounds = Rect2(Vector2.ZERO, viewport_size)

	# Set up ball appearance and physics
	_setup_ball_appearance()
	_setup_collision_shape()
	_setup_physics_properties()

	# Connect collision signals
	body_entered.connect(_on_collision)

	print("[BallController] Ball initialized at position: %s" % position)

##
## Handle physics updates and ball state management
## @param delta: Time elapsed since last frame
##
func _physics_process(delta: float) -> void:
	if is_attached_to_paddle and paddle:
		_follow_paddle()
	else:
		_check_boundaries()
		_maintain_speed()

##
## Handle input for ball launching
##
func _input(event: InputEvent) -> void:
	# Launch ball when space is pressed, ball is attached to paddle, and game is in ready state
	if event.is_action_pressed("launch_ball") and is_attached_to_paddle:
		# Check if game is in the correct state to launch ball
		if game_manager and game_manager.is_game_ready():
			launch_ball()
		else:
			print("[BallController] Cannot launch ball - game not in ready state")

##
## Launch the ball from the paddle with initial upward velocity
##
func launch_ball() -> void:
	if not is_attached_to_paddle:
		return

	print("[BallController] Launching ball from paddle")

	is_attached_to_paddle = false
	freeze = false

	# Notify game manager that game has started
	if game_manager:
		game_manager.start_game()

	# Set initial upward velocity with slight random angle
	var launch_angle = randf_range(-PI/6, PI/6)  # ±30 degrees variation
	var launch_direction = Vector2(sin(launch_angle), -cos(launch_angle))
	linear_velocity = launch_direction * ball_speed

	print("[BallController] Ball launched with velocity: %s" % linear_velocity)

##
## Reset ball to attached state on paddle
##
func reset_ball() -> void:
	print("[BallController] Resetting ball to paddle")

	is_attached_to_paddle = true
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	if paddle:
		position = paddle.position + paddle_offset

##
## Make ball follow paddle when attached
##
func _follow_paddle() -> void:
	if paddle:
		position = paddle.position + paddle_offset

##
## Check if ball has gone out of bounds and handle accordingly
##
func _check_boundaries() -> void:
	# Check if ball has fallen below the screen (life loss)
	if position.y > screen_bounds.size.y + ball_radius:
		print("[BallController] Ball fell out of bounds")
		_handle_ball_lost()

	# Check side boundaries and top boundary for collision
	var velocity_changed = false

	# Left and right walls
	if position.x <= ball_radius or position.x >= screen_bounds.size.x - ball_radius:
		linear_velocity.x = -linear_velocity.x
		position.x = clampf(position.x, ball_radius, screen_bounds.size.x - ball_radius)
		velocity_changed = true

	# Top wall
	if position.y <= ball_radius:
		linear_velocity.y = abs(linear_velocity.y)  # Ensure downward direction
		position.y = ball_radius
		velocity_changed = true

	if velocity_changed:
		print("[BallController] Wall collision - New velocity: %s" % linear_velocity)

##
## Maintain ball speed within configured bounds
##
func _maintain_speed() -> void:
	var current_speed = linear_velocity.length()

	if current_speed > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	elif current_speed < min_speed and current_speed > 0:
		linear_velocity = linear_velocity.normalized() * min_speed

##
## Handle collision with other game objects
## @param body: The body that collided with the ball
##
func _on_collision(body: Node) -> void:
	print("[BallController] Collision detected with: %s" % body.name)

	if body is PaddleController:
		_handle_paddle_collision(body)
	elif body.has_method("destroy"):  # Brick collision
		_handle_brick_collision(body)

##
## Handle collision with the paddle
## @param paddle_body: The paddle controller that was hit
##
func _handle_paddle_collision(paddle_body: PaddleController) -> void:
	print("[BallController] Paddle collision detected")

	# Get bounce direction from paddle based on impact position
	var bounce_direction = paddle_body.calculate_bounce_direction(position)

	# Apply bounce direction while maintaining speed
	var current_speed = linear_velocity.length()
	linear_velocity = bounce_direction * current_speed

	# Optional: Increase speed slightly on paddle hits, but only if not at max speed
	if current_speed < max_speed * 0.9:  # Only increase when below 90% of max speed
		linear_velocity *= speed_increase_rate
		# Clamp to maximum speed to prevent runaway velocity
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed

	print("[BallController] Paddle bounce - New velocity: %s" % linear_velocity)

##
## Handle collision with a brick
## @param brick: The brick that was hit
##
func _handle_brick_collision(brick: Node) -> void:
	print("[BallController] Brick collision with: %s" % brick.name)

	# Destroy the brick
	if brick.has_method("destroy"):
		brick.destroy()

	# Notify game manager of brick destruction
	if game_manager:
		game_manager.on_brick_destroyed()

	# Simple collision response - reverse Y velocity for basic bounce
	# More sophisticated collision detection could be added here
	linear_velocity.y = -linear_velocity.y

	# Increase ball speed slightly, but only if not at max speed
	var current_speed = linear_velocity.length()
	if current_speed < max_speed * 0.9:  # Only increase when below 90% of max speed
		linear_velocity *= speed_increase_rate
		# Clamp to maximum speed to prevent runaway velocity
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed

##
## Handle ball going out of bounds (life loss)
##
func _handle_ball_lost() -> void:
	print("[BallController] Ball lost - Player loses a life")

	if game_manager:
		game_manager.lose_life()

##
## Set up the visual appearance of the ball
##
func _setup_ball_appearance() -> void:
	if sprite:
		sprite.size = Vector2(ball_radius * 2, ball_radius * 2)
		sprite.position = Vector2(-ball_radius, -ball_radius)
		sprite.color = Color.YELLOW
		print("[BallController] Ball appearance configured")

##
## Set up the collision shape for physics interactions
##
func _setup_collision_shape() -> void:
	if collision_shape and collision_shape.shape == null:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = ball_radius
		collision_shape.shape = circle_shape
		print("[BallController] Collision shape configured")

##
## Set up physics properties for realistic ball behavior
##
func _setup_physics_properties() -> void:
	# Configure RigidBody2D properties
	gravity_scale = 0.0  # Disable gravity for classic brick breaker feel
	freeze = true        # Start frozen until launched
	linear_damp = 0.0    # No air resistance
	angular_damp = 0.0   # No rotational dampening
	bounce = 1.0         # Perfect elasticity

	# Set collision layer and mask for proper collision detection
	collision_layer = 1  # Ball layer
	collision_mask = 2 | 4 | 8  # Collide with paddle, bricks, and walls

	print("[BallController] Physics properties configured")

##
## Set the reference to the paddle for attachment behavior
## @param paddle_ref: Reference to the PaddleController
##
func set_paddle_reference(paddle_ref: PaddleController) -> void:
	paddle = paddle_ref
	print("[BallController] Paddle reference set")

##
## Set the reference to the game manager for score tracking
## @param manager_ref: Reference to the GameManager
##
func set_game_manager_reference(manager_ref: GameManager) -> void:
	game_manager = manager_ref
	print("[BallController] Game manager reference set")

##
## Get current ball speed
## @returns: Current speed in pixels/second
##
func get_current_speed() -> float:
	return linear_velocity.length()

##
## Check if ball is currently attached to paddle
## @returns: true if ball is waiting to be launched
##
func is_ball_attached() -> bool:
	return is_attached_to_paddle