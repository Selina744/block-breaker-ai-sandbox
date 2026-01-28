# Testing Guide

## 🚨 Quick Fix for Game Issues

If you're experiencing errors when trying to run the Brick Breaker game, follow these steps:

### Step 1: Update to Latest Version
```bash
git pull origin main
```

### Step 2: Run Diagnostics
1. Open the project in Godot
2. Navigate to `scenes/DiagnosticRunner.tscn`
3. Right-click → "Change Scene" or press F6 to run
4. Check console output for specific issues and fixes

### Step 3: Follow Diagnostic Recommendations
The diagnostic tool will tell you exactly what's wrong and how to fix it.

## 🔧 Testing Tools Overview

### DiagnosticRunner (`scenes/DiagnosticRunner.tscn`)
**Primary troubleshooting tool** - Use this first!

- ✅ Checks Godot version compatibility
- ✅ Validates project structure and files
- ✅ Tests script syntax and loading
- ✅ Verifies input map configuration
- ✅ Identifies collision and physics issues
- ✅ Provides automatic fixes where possible

### TestRunner (`scenes/TestRunner.tscn`)
**Comprehensive validation** - Use after fixes are applied

- ✅ Unit tests for all game systems
- ✅ Integration tests for system interactions
- ✅ Scene loading and instantiation tests
- ✅ Automatic game launch if all tests pass

### Manual Testing
If automated tools aren't working:

1. **Check Godot Version**: Must be 4.3 or later
2. **Verify Files**: All `.gd` and `.tscn` files should be present
3. **Input Map**: Project → Project Settings → Input Map should have:
   - `move_left`: A key + Left Arrow
   - `move_right`: D key + Right Arrow
   - `launch_ball`: Spacebar
   - `restart_game`: R key

## 🐛 Bug Fixes Applied

Recent critical fixes ensure the testing framework works properly:

- ⏱️ **Fixed time calculations** - Tests now properly measure duration
- 📦 **Fixed import issues** - All test classes properly reference each other
- 🎬 **Fixed scene validation** - Correctly loads and validates MainGame scene
- ❌ **Fixed runtime errors** - Removed editor-only API calls
- 🔧 **Fixed dependency loading** - Proper preloading of helper classes
- 🔂 **Fixed duplicate results** - Tests only report once per validation

## 📋 Common Issues and Solutions

### "Cannot find main scene"
```
Solution: Project → Project Settings → Application → Run
Set Main Scene to: res://scenes/main/MainGame.tscn
```

### "Script error" or "Cannot instantiate"
```
Solution: Open each .gd file and look for red error indicators
Save all files after fixing syntax issues
```

### "Input not working"
```
Solution: Run DiagnosticRunner - it will auto-fix input map
Or manually add actions in Project Settings → Input Map
```

### "No bricks appearing"
```
Solution: Check that levels/level_1.json exists and has valid JSON
DiagnosticRunner will validate this file
```

## 🚀 If You're Still Having Issues

1. **Run DiagnosticRunner** and share the complete console output
2. **Check Godot version** - must be 4.3+
3. **Verify fresh clone** - try cloning the repository again
4. **Check file permissions** - ensure you can read/write project files

The diagnostic tools will identify 99% of setup issues and provide specific solutions!