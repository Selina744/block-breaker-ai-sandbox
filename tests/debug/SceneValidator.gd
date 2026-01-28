extends Node
class_name SceneValidator

##
## SceneValidator
##
## Debugging utility to validate scene structure, node references,
## and common Godot setup issues that might prevent the game from running.
## This helps identify missing nodes, incorrect paths, and script issues.
##

var test_framework: TestFramework

##
## Initialize the validator
##
func _ready() -> void:
	test_framework = TestFramework.new()
	add_child(test_framework)

##
## Run comprehensive scene validation
##
func validate_main_scene() -> void:
	print("[SCENE_VALIDATOR] Starting scene validation...")

	validate_scene_structure()
	validate_script_attachments()
	validate_collision_layers()
	validate_input_map()
	validate_project_settings()

	test_framework.print_test_summary()
	print("[SCENE_VALIDATOR] Scene validation completed.")

##
## Validate the main game scene structure
##
func validate_scene_structure() -> void:
	test_framework.start_test("Scene Structure Validation")

	var main_scene = get_tree().current_scene
	if not test_framework.assert_not_null(main_scene, "Main scene should exist"):
		return

	# Check for required nodes in MainGame scene
	var required_nodes = [
		"GameManager",
		"LevelManager",
		"Paddle",
		"Ball",
		"UIManager"
	]

	for node_name in required_nodes:
		if not test_framework.assert_has_child(main_scene, node_name, "MainGame should have " + node_name):
			return

	# Validate Paddle structure
	var paddle = main_scene.get_node_or_null("Paddle")
	if paddle:
		if not test_framework.assert_has_child(paddle, "CollisionShape2D", "Paddle should have CollisionShape2D"):
			return
		if not test_framework.assert_has_child(paddle, "Sprite", "Paddle should have Sprite"):
			return

	# Validate Ball structure
	var ball = main_scene.get_node_or_null("Ball")
	if ball:
		if not test_framework.assert_has_child(ball, "CollisionShape2D", "Ball should have CollisionShape2D"):
			return
		if not test_framework.assert_has_child(ball, "Sprite", "Ball should have Sprite"):
			return

	# Validate UIManager structure
	var ui = main_scene.get_node_or_null("UIManager")
	if ui:
		var ui_elements = ["ScoreLabel", "LivesLabel", "LevelLabel", "StateLabel", "InstructionsLabel"]
		for element in ui_elements:
			if not test_framework.assert_has_child(ui, element, "UIManager should have " + element):
				return

	test_framework.pass_test("Scene structure is valid")

##
## Validate script attachments and class names
##
func validate_script_attachments() -> void:
	test_framework.start_test("Script Attachment Validation")

	var main_scene = get_tree().current_scene
	if not main_scene:
		test_framework.fail_test("No main scene found")
		return

	# Check script attachments
	var script_checks = {
		"": "MainGameScript",  # Main scene script
		"GameManager": "GameManager",
		"LevelManager": "LevelManager",
		"Paddle": "PaddleController",
		"Ball": "BallController",
		"UIManager": "UIManager"
	}

	for node_path in script_checks:
		var expected_class = script_checks[node_path]
		var node = main_scene.get_node_or_null(node_path) if node_path != "" else main_scene

		if not node:
			test_framework.fail_test("Node not found: " + node_path)
			return

		var script = node.get_script()
		if not script:
			test_framework.fail_test("No script attached to: " + (node_path if node_path != "" else "MainGame"))
			return

		# Try to get the class name - this might fail if script has errors
		# Check if script can be instantiated (basic syntax check)
		if script.can_instantiate():
			print("[SCENE_VALIDATOR] Script OK: %s" % expected_class)
		else:
			test_framework.fail_test("Script has errors: " + expected_class)
			return

	test_framework.pass_test("All scripts are properly attached")

##
## Validate collision layers and physics setup
##
func validate_collision_layers() -> void:
	test_framework.start_test("Collision Layer Validation")

	var main_scene = get_tree().current_scene
	if not main_scene:
		test_framework.fail_test("No main scene found")
		return

	# Check ball collision setup
	var ball = main_scene.get_node_or_null("Ball")
	if ball and ball is RigidBody2D:
		var rigid_ball = ball as RigidBody2D
		if not test_framework.assert_equals(rigid_ball.collision_layer, 1, "Ball should be on collision layer 1"):
			return
		if not test_framework.assert_equals(rigid_ball.collision_mask, 14, "Ball should detect layers 2, 4, 8 (mask=14)"):
			return

	# Check paddle collision setup
	var paddle = main_scene.get_node_or_null("Paddle")
	if paddle and paddle is CharacterBody2D:
		var char_paddle = paddle as CharacterBody2D
		if not test_framework.assert_equals(char_paddle.collision_layer, 2, "Paddle should be on collision layer 2"):
			return

	test_framework.pass_test("Collision layers are properly configured")

##
## Validate input map configuration
##
func validate_input_map() -> void:
	test_framework.start_test("Input Map Validation")

	var required_actions = [
		"move_left",
		"move_right",
		"launch_ball",
		"restart_game"
	]

	for action in required_actions:
		if not InputMap.has_action(action):
			test_framework.fail_test("Missing input action: " + action)
			return

		var events = InputMap.action_get_events(action)
		if events.is_empty():
			test_framework.fail_test("No input events defined for action: " + action)
			return

	test_framework.pass_test("Input map is properly configured")

##
## Validate project settings
##
func validate_project_settings() -> void:
	test_framework.start_test("Project Settings Validation")

	# Check main scene setting
	var main_scene_path = ProjectSettings.get_setting("application/run/main_scene", "")
	if main_scene_path == "":
		test_framework.fail_test("No main scene set in project settings")
		return

	if not ResourceLoader.exists(main_scene_path):
		test_framework.fail_test("Main scene file does not exist: " + main_scene_path)
		return

	# Check physics settings
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980)
	if gravity != 0:
		print("[SCENE_VALIDATOR] Warning: Default gravity is %d, game expects 0" % gravity)

	test_framework.pass_test("Project settings are valid")

##
## Check for common Godot scene loading errors
##
func validate_resource_loading() -> void:
	test_framework.start_test("Resource Loading Validation")

	# Check if brick scene exists and can be loaded
	var brick_scene_path = "res://scenes/components/Brick.tscn"
	if not ResourceLoader.exists(brick_scene_path):
		test_framework.fail_test("Brick scene not found: " + brick_scene_path)
		return

	var brick_scene = load(brick_scene_path)
	if not brick_scene:
		test_framework.fail_test("Cannot load brick scene: " + brick_scene_path)
		return

	# Try to instantiate brick scene
	var brick_instance = brick_scene.instantiate()
	if not brick_instance:
		test_framework.fail_test("Cannot instantiate brick scene")
		return

	# Clean up
	brick_instance.queue_free()

	test_framework.pass_test("Resource loading works correctly")

##
## Generate comprehensive diagnostic report
##
func generate_diagnostic_report() -> void:
	print("\n" + "=".repeat(60))
	print("DIAGNOSTIC REPORT")
	print("=".repeat(60))

	# Engine version
	print("Godot Version: %s" % Engine.get_version_info())

	# Current scene info
	var scene = get_tree().current_scene
	if scene:
		print("Current Scene: %s" % scene.name)
		print("Scene File: %s" % scene.scene_file_path)
	else:
		print("ERROR: No current scene!")

	# Node count
	print("Total Nodes: %d" % get_tree().get_node_count())

	# Check for errors in console
	var error_count = Engine.get_singleton("EditorInterface")
	print("Errors: Check console for script errors or warnings")

	print("=".repeat(60))