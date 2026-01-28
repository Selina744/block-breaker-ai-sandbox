extends Node

##
## DiagnosticRunner
##
## Comprehensive diagnostic tool to identify and report issues preventing
## the brick breaker game from running properly. This script performs a
## detailed analysis and provides specific troubleshooting steps.
##
## To use this diagnostic:
## 1. Create a new scene in Godot
## 2. Add this script to the root node
## 3. Run the scene
## 4. Check the console output for detailed diagnostic information
##

##
## Run comprehensive diagnostics when the scene starts
##
func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("BRICK BREAKER GAME - COMPREHENSIVE DIAGNOSTICS")
	print("=".repeat(80))

	await get_tree().process_frame
	run_full_diagnostics()

##
## Execute all diagnostic checks
##
func run_full_diagnostics() -> void:
	var issues = []
	var warnings = []
	var fixes_available = []

	print("\n🔍 RUNNING DIAGNOSTICS...\n")

	# 1. Environment Check
	print("📋 ENVIRONMENT CHECK")
	print("-".repeat(40))
	var env_issues = check_environment()
	issues.append_array(env_issues)

	# 2. Project Structure Check
	print("\n📁 PROJECT STRUCTURE CHECK")
	print("-".repeat(40))
	var structure_issues = check_project_structure()
	issues.append_array(structure_issues)

	# 3. Script Validation
	print("\n📝 SCRIPT VALIDATION")
	print("-".repeat(40))
	var script_issues = check_scripts()
	issues.append_array(script_issues)

	# 4. Scene Validation
	print("\n🎬 SCENE VALIDATION")
	print("-".repeat(40))
	var scene_issues = check_scenes()
	issues.append_array(scene_issues)

	# 5. Input Configuration
	print("\n🎮 INPUT CONFIGURATION")
	print("-".repeat(40))
	var input_issues = check_input_configuration()
	if input_issues.size() > 0:
		issues.append_array(input_issues)
		fixes_available.append("Input map can be auto-fixed")

	# 6. Physics Settings
	print("\n⚙️ PHYSICS SETTINGS")
	print("-".repeat(40))
	var physics_issues = check_physics_settings()
	warnings.append_array(physics_issues)

	# 7. Common Issues Check
	print("\n🔧 COMMON ISSUES CHECK")
	print("-".repeat(40))
	var common_issues = check_common_issues()
	issues.append_array(common_issues)

	# Generate final report
	generate_final_report(issues, warnings, fixes_available)

##
## Check Godot environment and version
##
func check_environment() -> Array:
	var issues = []

	# Check Godot version
	var version_info = Engine.get_version_info()
	var version_string = "%d.%d.%d" % [version_info.major, version_info.minor, version_info.patch]

	print("Godot Version: %s" % version_string)

	# Check if version is compatible
	if version_info.major < 4 or (version_info.major == 4 and version_info.minor < 3):
		issues.append("❌ CRITICAL: Godot version %s detected. This game requires Godot 4.3 or later." % version_string)
	else:
		print("✅ Godot version is compatible")

	# Check platform
	print("Platform: %s" % OS.get_name())

	return issues

##
## Check project file structure
##
func check_project_structure() -> Array:
	var issues = []

	var required_files = [
		"project.godot",
		"scenes/main/MainGame.tscn",
		"scenes/components/Brick.tscn",
		"scripts/main/MainGameScript.gd",
		"scripts/managers/GameManager.gd",
		"scripts/controllers/PaddleController.gd",
		"scripts/controllers/BallController.gd",
		"scripts/components/Brick.gd",
		"scripts/managers/LevelManager.gd",
		"scripts/managers/UIManager.gd",
		"levels/level_1.json"
	]

	var required_directories = [
		"scenes/",
		"scripts/",
		"levels/",
		"scenes/main/",
		"scenes/components/",
		"scripts/main/",
		"scripts/managers/",
		"scripts/controllers/",
		"scripts/components/"
	]

	# Check directories
	for dir in required_directories:
		if not DirAccess.dir_exists_absolute("res://" + dir):
			issues.append("❌ Missing directory: " + dir)
		else:
			print("✅ Directory exists: " + dir)

	# Check files
	for file_path in required_files:
		if not FileAccess.file_exists("res://" + file_path):
			issues.append("❌ Missing file: " + file_path)
		else:
			print("✅ File exists: " + file_path)

	return issues

##
## Validate all GDScript files
##
func check_scripts() -> Array:
	var issues = []

	var scripts_to_check = {
		"res://scripts/main/MainGameScript.gd": "MainGameScript",
		"res://scripts/managers/GameManager.gd": "GameManager",
		"res://scripts/controllers/PaddleController.gd": "PaddleController",
		"res://scripts/controllers/BallController.gd": "BallController",
		"res://scripts/components/Brick.gd": "Brick",
		"res://scripts/managers/LevelManager.gd": "LevelManager",
		"res://scripts/managers/UIManager.gd": "UIManager"
	}

	for script_path in scripts_to_check:
		var class_name = scripts_to_check[script_path]

		if not ResourceLoader.exists(script_path):
			issues.append("❌ Script file missing: " + script_path)
			continue

		var script = load(script_path)
		if not script:
			issues.append("❌ Cannot load script: " + script_path)
			continue

		if script is GDScript:
			if script.can_instantiate():
				print("✅ Script valid: " + class_name)
			else:
				issues.append("❌ Script has syntax errors: " + class_name + " (" + script_path + ")")

	return issues

##
## Validate scene files and structure
##
func check_scenes() -> Array:
	var issues = []

	# Check MainGame scene
	if ResourceLoader.exists("res://scenes/main/MainGame.tscn"):
		var main_scene = load("res://scenes/main/MainGame.tscn")
		if main_scene:
			var instance = main_scene.instantiate()
			if instance:
				print("✅ MainGame scene can be instantiated")

				# Check required nodes
				var required_nodes = ["GameManager", "LevelManager", "Paddle", "Ball", "UIManager"]
				for node_name in required_nodes:
					if instance.has_node(node_name):
						print("✅ Node found: " + node_name)
					else:
						issues.append("❌ Missing node in MainGame: " + node_name)

				instance.queue_free()
			else:
				issues.append("❌ Cannot instantiate MainGame scene")
		else:
			issues.append("❌ Cannot load MainGame scene")

	# Check Brick scene
	if ResourceLoader.exists("res://scenes/components/Brick.tscn"):
		var brick_scene = load("res://scenes/components/Brick.tscn")
		if brick_scene:
			var instance = brick_scene.instantiate()
			if instance:
				print("✅ Brick scene can be instantiated")
				instance.queue_free()
			else:
				issues.append("❌ Cannot instantiate Brick scene")
		else:
			issues.append("❌ Cannot load Brick scene")

	return issues

##
## Check input map configuration
##
func check_input_configuration() -> Array:
	var issues = []

	var required_actions = [
		"move_left",
		"move_right",
		"launch_ball",
		"restart_game"
	]

	for action in required_actions:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			if events.size() > 0:
				print("✅ Input action configured: " + action)
			else:
				issues.append("❌ Input action has no events: " + action)
		else:
			issues.append("❌ Missing input action: " + action)

	return issues

##
## Check physics settings
##
func check_physics_settings() -> Array:
	var warnings = []

	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980)
	if gravity != 0:
		warnings.append("⚠️ Physics gravity is %d (should be 0 for brick breaker)" % gravity)
	else:
		print("✅ Physics gravity correctly set to 0")

	return warnings

##
## Check for common issues that prevent the game from running
##
func check_common_issues() -> Array:
	var issues = []

	# Check main scene setting
	var main_scene_path = ProjectSettings.get_setting("application/run/main_scene", "")
	if main_scene_path == "":
		issues.append("❌ No main scene set in project settings")
	elif main_scene_path != "res://scenes/main/MainGame.tscn":
		issues.append("❌ Main scene set to: " + main_scene_path + " (should be res://scenes/main/MainGame.tscn)")
	else:
		print("✅ Main scene correctly set")

	# Check for common file permission issues
	if not DirAccess.dir_exists_absolute("res://"):
		issues.append("❌ Cannot access project directory (permission issue?)")

	return issues

##
## Generate comprehensive final report with troubleshooting steps
##
func generate_final_report(issues: Array, warnings: Array, fixes_available: Array) -> void:
	print("\n" + "=".repeat(80))
	print("DIAGNOSTIC REPORT")
	print("=".repeat(80))

	if issues.size() == 0:
		print("🎉 NO CRITICAL ISSUES FOUND!")
		print("The game should run properly.")

		if warnings.size() > 0:
			print("\n⚠️ WARNINGS (%d):" % warnings.size())
			for warning in warnings:
				print("  " + warning)
	else:
		print("❌ CRITICAL ISSUES FOUND (%d):" % issues.size())
		for issue in issues:
			print("  " + issue)

		print("\n🔧 TROUBLESHOOTING STEPS:")
		print("1. Update Godot to version 4.3 or later")
		print("2. Ensure all files are present in the project directory")
		print("3. Check that scripts don't have syntax errors")
		print("4. Verify scene files can be opened in the Godot editor")
		print("5. Configure input map in Project Settings")

		if fixes_available.size() > 0:
			print("\n🛠️ AUTOMATIC FIXES AVAILABLE:")
			for fix in fixes_available:
				print("  - " + fix)
			print("\nRun FixCommonIssues.check_and_fix_all() to apply fixes")

	print("\n📋 NEXT STEPS:")
	if issues.size() == 0:
		print("✅ Game should work! If you still have issues:")
		print("   1. Check the console for runtime errors when running")
		print("   2. Verify your input devices are working")
		print("   3. Try running the TestRunner scene first")
	else:
		print("❌ Fix the issues above, then re-run diagnostics")
		print("   1. Address each critical issue listed")
		print("   2. Re-run this diagnostic tool")
		print("   3. If issues persist, check Godot editor errors")

	print("=".repeat(80))

##
## Quick input test for user interaction
##
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("\n🔄 Re-running diagnostics...")
		run_full_diagnostics()
	elif event.is_action_pressed("ui_cancel"):
		print("\n👋 Exiting diagnostics...")
		get_tree().quit()