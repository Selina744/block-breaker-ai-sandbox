extends Node
class_name TestFramework

##
## TestFramework
##
## A simple testing framework for validating game systems and identifying issues.
## Provides utilities for running unit tests, integration tests, and debugging
## game functionality.
##
## Features:
## - Test case management with pass/fail tracking
## - Assertion utilities for common test scenarios
## - Debug output formatting and logging
## - Performance timing for test execution
## - Error catching and reporting
##

# Test result tracking
var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[Dictionary] = []

# Current test context
var current_test_name: String = ""
var test_start_time: float = 0

##
## Start a new test case
## @param test_name: Name of the test being run
##
func start_test(test_name: String) -> void:
	current_test_name = test_name
	test_start_time = Time.get_time_dict_from_system().hour * 3600.0 + \
					  Time.get_time_dict_from_system().minute * 60.0 + \
					  Time.get_time_dict_from_system().second
	tests_run += 1
	print("[TEST] Starting: %s" % test_name)

##
## End the current test case with a pass result
## @param message: Optional success message
##
func pass_test(message: String = "") -> void:
	tests_passed += 1
	var duration = _get_test_duration()
	var result = {
		"name": current_test_name,
		"status": "PASS",
		"message": message,
		"duration": duration
	}
	test_results.append(result)
	print("[TEST] PASS: %s (%.3fs) %s" % [current_test_name, duration, message])

##
## End the current test case with a fail result
## @param message: Error message explaining the failure
##
func fail_test(message: String) -> void:
	tests_failed += 1
	var duration = _get_test_duration()
	var result = {
		"name": current_test_name,
		"status": "FAIL",
		"message": message,
		"duration": duration
	}
	test_results.append(result)
	print("[TEST] FAIL: %s (%.3fs) %s" % [current_test_name, duration, message])

##
## Assert that a condition is true
## @param condition: Boolean condition to test
## @param message: Message to display if assertion fails
## @returns: true if assertion passed
##
func assert_true(condition: bool, message: String = "Assertion failed") -> bool:
	if not condition:
		fail_test(message)
		return false
	return true

##
## Assert that a condition is false
## @param condition: Boolean condition to test
## @param message: Message to display if assertion fails
## @returns: true if assertion passed
##
func assert_false(condition: bool, message: String = "Assertion failed") -> bool:
	if condition:
		fail_test(message)
		return false
	return true

##
## Assert that two values are equal
## @param actual: The actual value
## @param expected: The expected value
## @param message: Optional message for failure
## @returns: true if assertion passed
##
func assert_equals(actual, expected, message: String = "") -> bool:
	if actual != expected:
		var fail_msg = "Expected: %s, Got: %s" % [expected, actual]
		if message != "":
			fail_msg = "%s - %s" % [message, fail_msg]
		fail_test(fail_msg)
		return false
	return true

##
## Assert that an object is not null
## @param obj: Object to check
## @param message: Optional message for failure
## @returns: true if assertion passed
##
func assert_not_null(obj, message: String = "Object is null") -> bool:
	if obj == null:
		fail_test(message)
		return false
	return true

##
## Assert that an object is valid (exists and is not freed)
## @param obj: Object to check
## @param message: Optional message for failure
## @returns: true if assertion passed
##
func assert_valid(obj, message: String = "Object is invalid") -> bool:
	if obj == null or not is_instance_valid(obj):
		fail_test(message)
		return false
	return true

##
## Assert that a node has a specific child
## @param parent: Parent node to check
## @param child_name: Name of the child node
## @param message: Optional message for failure
## @returns: true if assertion passed
##
func assert_has_child(parent: Node, child_name: String, message: String = "") -> bool:
	if not parent.has_node(child_name):
		var fail_msg = "Node %s does not have child: %s" % [parent.name, child_name]
		if message != "":
			fail_msg = "%s - %s" % [message, fail_msg]
		fail_test(fail_msg)
		return false
	return true

##
## Print comprehensive test results summary
##
func print_test_summary() -> void:
	print("\n" + "=".repeat(60))
	print("TEST SUMMARY")
	print("=".repeat(60))
	print("Tests Run: %d" % tests_run)
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)

	if tests_failed > 0:
		print("\nFAILURES:")
		for result in test_results:
			if result.status == "FAIL":
				print("  - %s: %s" % [result.name, result.message])

	var success_rate = float(tests_passed) / float(tests_run) * 100.0 if tests_run > 0 else 0.0
	print("\nSuccess Rate: %.1f%%" % success_rate)
	print("=".repeat(60))

##
## Check if all tests passed
## @returns: true if no tests failed
##
func all_tests_passed() -> bool:
	return tests_failed == 0

##
## Get the duration of the current test
## @returns: Test duration in seconds
##
func _get_test_duration() -> float:
	var current_time = Time.get_time_dict_from_system().hour * 3600.0 + \
					   Time.get_time_dict_from_system().minute * 60.0 + \
					   Time.get_time_dict_from_system().second
	return current_time - test_start_time

##
## Utility function to safely get a node with error handling
## @param node_path: NodePath to the target node
## @param from_node: Node to search from (defaults to scene tree root)
## @returns: Found node or null if not found
##
func safe_get_node(node_path: NodePath, from_node: Node = null) -> Node:
	var search_node = from_node if from_node != null else get_tree().current_scene

	if search_node == null:
		print("[TEST WARNING] Search node is null")
		return null

	if not search_node.has_node(node_path):
		print("[TEST WARNING] Node not found: %s" % node_path)
		return null

	return search_node.get_node(node_path)

##
## Utility function to check if a script has required methods
## @param script_instance: Instance of the script to check
## @param required_methods: Array of method names that should exist
## @returns: Array of missing methods (empty if all found)
##
func check_required_methods(script_instance: Object, required_methods: Array) -> Array:
	var missing_methods = []

	for method_name in required_methods:
		if not script_instance.has_method(method_name):
			missing_methods.append(method_name)

	return missing_methods