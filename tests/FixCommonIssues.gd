extends Node
class_name FixCommonIssues

##
## FixCommonIssues
##
## Utility script to automatically detect and fix common issues that
## prevent the Godot brick breaker game from running properly.
## This addresses the most frequent problems users encounter.
##

##
## Check and fix common issues automatically
##
static func check_and_fix_all() -> Dictionary:
	var issues_found = []
	var fixes_applied = []

	print("[FIX] Starting automatic issue detection and repair...")

	# 1. Check collision shapes
	var collision_issue = check_collision_shapes()
	if collision_issue != "":
		issues_found.append(collision_issue)

	# 2. Check input map
	var input_issue = check_input_map()
	if input_issue != "":
		issues_found.append(input_issue)
		fix_input_map()
		fixes_applied.append("Input map configuration")

	# 3. Check physics settings
	var physics_issue = check_physics_settings()
	if physics_issue != "":
		issues_found.append(physics_issue)

	# 4. Check scene file paths
	var scene_issue = check_scene_files()
	if scene_issue != "":
		issues_found.append(scene_issue)

	# 5. Check for common script errors
	var script_issue = check_script_syntax()
	if script_issue != "":
		issues_found.append(script_issue)

	return {
		"issues_found": issues_found,
		"fixes_applied": fixes_applied,
		"total_issues": issues_found.size(),
		"total_fixes": fixes_applied.size()
	}

##
## Check collision shape configuration
##
static func check_collision_shapes() -> String:
	# This would need to be called from a scene context
	return ""

##
## Check input map configuration
##
static func check_input_map() -> String:
	var required_actions = ["move_left", "move_right", "launch_ball", "restart_game"]
	var missing_actions = []

	for action in required_actions:
		if not InputMap.has_action(action):
			missing_actions.append(action)

	if missing_actions.size() > 0:
		return "Missing input actions: " + str(missing_actions)

	return ""

##
## Fix input map by adding missing actions
##
static func fix_input_map() -> void:
	print("[FIX] Fixing input map configuration...")

	# Add move_left action
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var key_a = InputEventKey.new()
		key_a.physical_keycode = KEY_A
		InputMap.action_add_event("move_left", key_a)

		var key_left = InputEventKey.new()
		key_left.physical_keycode = KEY_LEFT
		InputMap.action_add_event("move_left", key_left)

	# Add move_right action
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var key_d = InputEventKey.new()
		key_d.physical_keycode = KEY_D
		InputMap.action_add_event("move_right", key_d)

		var key_right = InputEventKey.new()
		key_right.physical_keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", key_right)

	# Add launch_ball action
	if not InputMap.has_action("launch_ball"):
		InputMap.add_action("launch_ball")
		var key_space = InputEventKey.new()
		key_space.physical_keycode = KEY_SPACE
		InputMap.action_add_event("launch_ball", key_space)

	# Add restart_game action
	if not InputMap.has_action("restart_game"):
		InputMap.add_action("restart_game")
		var key_r = InputEventKey.new()
		key_r.physical_keycode = KEY_R
		InputMap.action_add_event("restart_game", key_r)

	print("[FIX] Input map fixed!")

##
## Check physics settings
##
static func check_physics_settings() -> String:
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980)
	if gravity != 0:
		return "Physics gravity should be 0 for brick breaker gameplay"

	return ""

##
## Check scene files exist
##
static func check_scene_files() -> String:
	var required_scenes = [
		"res://scenes/main/MainGame.tscn",
		"res://scenes/components/Brick.tscn"
	]

	var missing_scenes = []
	for scene_path in required_scenes:
		if not ResourceLoader.exists(scene_path):
			missing_scenes.append(scene_path)

	if missing_scenes.size() > 0:
		return "Missing scene files: " + str(missing_scenes)

	return ""

##
## Check for basic script syntax issues
##
static func check_script_syntax() -> String:
	var script_files = [
		"res://scripts/main/MainGameScript.gd",
		"res://scripts/managers/GameManager.gd",
		"res://scripts/controllers/PaddleController.gd",
		"res://scripts/controllers/BallController.gd",
		"res://scripts/components/Brick.gd",
		"res://scripts/managers/LevelManager.gd",
		"res://scripts/managers/UIManager.gd"
	]

	var script_issues = []
	for script_path in script_files:
		if not ResourceLoader.exists(script_path):
			script_issues.append("Missing: " + script_path)
		else:
			var script = load(script_path)
			if not script:
				script_issues.append("Cannot load: " + script_path)

	if script_issues.size() > 0:
		return "Script issues: " + str(script_issues)

	return ""