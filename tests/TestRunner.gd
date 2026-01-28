extends Node

##
## TestRunner
##
## Main test runner that executes all validation tests and reports results.
## This can be run as a standalone scene to validate the game setup and
## identify common issues that prevent the game from running properly.
##
## Usage:
## 1. Set this as the main scene temporarily in project settings
## 2. Run the project to execute all tests
## 3. Check console output for test results and error reports
##

# Preload test classes to ensure they're available
const TestFrameworkClass = preload("res://tests/TestFramework.gd")
const SceneValidatorClass = preload("res://tests/debug/SceneValidator.gd")
const GameManagerTestsClass = preload("res://tests/unit/GameManagerTests.gd")

##
## Main entry point - run all tests
##
func _ready() -> void:
	print("======================================")
	print("BRICK BREAKER GAME - TEST RUNNER")
	print("======================================")
	print("Running comprehensive validation tests...")
	print("")

	# Wait a frame for scene to fully initialize
	await get_tree().process_frame

	run_all_tests()

##
## Execute all test suites
##
func run_all_tests() -> void:
	var all_passed = true

	# 1. Scene Validation
	print("\n--- SCENE VALIDATION ---")
	var scene_validator = SceneValidatorClass.new()
	add_child(scene_validator)
	scene_validator.validate_main_scene()
	all_passed = all_passed and scene_validator.test_framework.all_tests_passed()

	# 2. GameManager Unit Tests
	print("\n--- GAME MANAGER TESTS ---")
	var game_manager_tests = GameManagerTestsClass.new()
	add_child(game_manager_tests)
	game_manager_tests.run_tests()
	all_passed = all_passed and game_manager_tests.test_framework.all_tests_passed()

	# 3. Integration Tests
	print("\n--- INTEGRATION TESTS ---")
	run_integration_tests()

	# 4. Generate final report
	print_final_report(all_passed)

	# 5. Auto-load main game if tests pass
	if all_passed:
		print("\n✅ All tests passed! Loading main game in 3 seconds...")
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://scenes/main/MainGame.tscn")
	else:
		print("\n❌ Tests failed! Check the errors above.")
		print("The game may not work properly until these issues are resolved.")

##
## Run integration tests to check system interactions
##
func run_integration_tests() -> void:
	var framework = TestFramework.new()
	add_child(framework)

	# Test main scene loading
	framework.start_test("Main Scene Loading")

	var main_scene_instance = null
	var brick_instance = null

	# Try to load the main scene
	var main_scene_path = "res://scenes/main/MainGame.tscn"
	if not ResourceLoader.exists(main_scene_path):
		framework.fail_test("Main scene file not found")
	else:
		var main_scene_resource = load(main_scene_path)
		if not main_scene_resource:
			framework.fail_test("Cannot load main scene resource")
		else:
			main_scene_instance = main_scene_resource.instantiate()
			if not main_scene_instance:
				framework.fail_test("Cannot instantiate main scene")
			else:
				framework.pass_test("Main scene loads correctly")

	# Test level file loading
	framework.start_test("Level File Loading")

	var level_path = "res://levels/level_1.json"
	if not FileAccess.file_exists(level_path):
		framework.fail_test("Level 1 file not found")
	else:
		var file = FileAccess.open(level_path, FileAccess.READ)
		if not file:
			framework.fail_test("Cannot open level file")
		else:
			var json_text = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_text)
			if parse_result != OK:
				framework.fail_test("Invalid JSON in level file")
			else:
				framework.pass_test("Level file loads correctly")

	# Test brick scene loading
	framework.start_test("Brick Scene Loading")

	var brick_path = "res://scenes/components/Brick.tscn"
	if not ResourceLoader.exists(brick_path):
		framework.fail_test("Brick scene file not found")
	else:
		var brick_scene = load(brick_path)
		if not brick_scene:
			framework.fail_test("Cannot load brick scene")
		else:
			brick_instance = brick_scene.instantiate()
			if not brick_instance:
				framework.fail_test("Cannot instantiate brick")
			else:
				framework.pass_test("Brick scene loads correctly")

	# Clean up test instances - always execute regardless of test outcomes
	if main_scene_instance:
		main_scene_instance.queue_free()
	if brick_instance:
		brick_instance.queue_free()

	framework.print_test_summary()

##
## Print comprehensive final report
##
func print_final_report(all_passed: bool) -> void:
	print("\n" + "=".repeat(60))
	print("FINAL VALIDATION REPORT")
	print("=".repeat(60))

	if all_passed:
		print("✅ ALL TESTS PASSED")
		print("The game should run without issues.")
		print("If you're still experiencing problems, check:")
		print("  1. Godot version (requires 4.3+)")
		print("  2. Console for runtime errors")
		print("  3. Input device connectivity")
	else:
		print("❌ VALIDATION FAILED")
		print("The game has issues that need to be resolved:")
		print("  1. Check all error messages above")
		print("  2. Verify all scene files exist")
		print("  3. Check script syntax and references")
		print("  4. Ensure project settings are correct")

	print("\nTroubleshooting Tips:")
	print("- Make sure you're using Godot 4.3 or later")
	print("- Check that all .gd files have proper syntax")
	print("- Verify scene file paths match script references")
	print("- Ensure input map is properly configured")

	print("=".repeat(60))

##
## Handle any unhandled errors during testing
##
func _unhandled_exception(error) -> void:
	print("❌ CRITICAL ERROR DURING TESTING:")
	print(error)
	print("This indicates a serious issue with the game setup.")