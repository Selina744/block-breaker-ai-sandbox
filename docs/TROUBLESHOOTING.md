# Troubleshooting Guide

This guide helps you identify and fix common issues that prevent the Brick Breaker game from running properly in Godot.

## 🔍 Quick Diagnostic Tool

Before troubleshooting manually, run the automated diagnostic tool:

1. Open the project in Godot
2. In the FileSystem dock, navigate to `scenes/DiagnosticRunner.tscn`
3. Double-click to open the scene
4. Press F6 or click "Run Current Scene"
5. Check the console output for detailed diagnostic information

## 🚨 Common Issues and Solutions

### 1. "Cannot find main scene" or Blank Screen

**Symptoms**: Game doesn't start, shows blank screen, or error about main scene

**Causes**:
- Main scene not set in project settings
- MainGame.tscn file missing or corrupted
- Script not attached to main scene

**Solutions**:
```
1. In Godot, go to Project → Project Settings
2. Under Application → Run, set Main Scene to: res://scenes/main/MainGame.tscn
3. Verify the file exists in FileSystem dock
4. Open MainGame.tscn and ensure the root node has MainGameScript.gd attached
```

### 2. "Script Error" or "Cannot instantiate script"

**Symptoms**: Error messages about script loading, syntax errors

**Causes**:
- Syntax errors in GDScript files
- Missing class_name declarations
- Incorrect node references

**Solutions**:
```
1. Open each .gd file in the Godot editor
2. Look for red error indicators in the script editor
3. Check for typos, missing semicolons, incorrect indentation
4. Verify all @onready var declarations match actual node names
5. Save all scripts after fixing
```

### 3. "Cannot find node" Errors

**Symptoms**: Console errors about missing nodes like "Ball", "Paddle", "GameManager"

**Causes**:
- Scene structure doesn't match script expectations
- Nodes renamed or missing
- Incorrect node hierarchy

**Solutions**:
```
1. Open scenes/main/MainGame.tscn
2. Verify the scene structure matches:
   MainGame (Node2D)
   ├── GameManager (Node)
   ├── LevelManager (Node)
   ├── Paddle (CharacterBody2D)
   │   ├── CollisionShape2D
   │   └── Sprite (ColorRect)
   ├── Ball (RigidBody2D)
   │   ├── CollisionShape2D
   │   └── Sprite (ColorRect)
   └── UIManager (Control)
       ├── ScoreLabel (Label)
       ├── LivesLabel (Label)
       ├── LevelLabel (Label)
       ├── StateLabel (Label)
       └── InstructionsLabel (Label)

3. If nodes are missing, recreate them with correct names and types
4. Ensure scripts are attached to the right nodes
```

### 4. Input Not Working

**Symptoms**: Paddle doesn't move, ball doesn't launch with SPACE

**Causes**:
- Input map not configured
- Wrong key codes
- Input actions missing

**Solutions**:
```
1. Go to Project → Project Settings → Input Map
2. Verify these actions exist with correct keys:
   - move_left: A key + Left Arrow
   - move_right: D key + Right Arrow
   - launch_ball: Spacebar
   - restart_game: R key

3. If missing, add them manually or run the auto-fix:
   - Open DiagnosticRunner scene and run it
   - It will automatically create missing input actions
```

### 5. Collision Detection Not Working

**Symptoms**: Ball passes through paddle/bricks, no collision response

**Causes**:
- Missing collision shapes
- Wrong collision layers/masks
- Incorrect physics settings

**Solutions**:
```
1. Check Paddle CollisionShape2D:
   - Should have RectangleShape2D with size 80x12
   - Paddle collision_layer = 2

2. Check Ball CollisionShape2D:
   - Should have CircleShape2D with radius 8
   - Ball collision_layer = 1, collision_mask = 14

3. Check Brick CollisionShape2D:
   - Should have RectangleShape2D with size 60x20
   - Brick collision_layer = 4

4. Verify Project Settings → Physics → 2D:
   - Default gravity should be 0 (not 9.8 or 980)
```

### 6. Level Not Loading / No Bricks Appearing

**Symptoms**: Game starts but no bricks visible, empty level

**Causes**:
- Missing level JSON file
- Invalid JSON format
- LevelManager not working

**Solutions**:
```
1. Verify levels/level_1.json exists
2. Open the file and check JSON is valid
3. Ensure it contains a "bricks" array with brick definitions
4. Check console for LevelManager error messages
5. If file is missing, copy from the repository or recreate it
```

### 7. UI Elements Missing or Not Updating

**Symptoms**: No score display, lives counter not working

**Causes**:
- UIManager nodes missing
- Signal connections failed
- Label nodes not found

**Solutions**:
```
1. Open MainGame.tscn
2. Verify UIManager node structure (see section 3 above)
3. Check that UIManager script is attached
4. Ensure all Label nodes exist with correct names
5. Verify signals are connected in code (not scene connections)
```

### 8. Godot Version Compatibility

**Symptoms**: Various errors, features not working, script errors

**Causes**:
- Using Godot version older than 4.3
- API changes in different versions

**Solutions**:
```
1. Check your Godot version: Help → About
2. Download Godot 4.3 or later from https://godotengine.org/
3. Close and reopen the project in the new version
4. If prompted, let Godot convert the project
```

## 🧪 Testing Tools

### Automated Tests

Run comprehensive tests to validate your setup:

1. **Diagnostic Runner** (`scenes/DiagnosticRunner.tscn`)
   - Complete system validation
   - Identifies all common issues
   - Provides specific fix recommendations

2. **Test Runner** (`scenes/TestRunner.tscn`)
   - Unit tests for all systems
   - Integration testing
   - Validates game functionality

### Manual Testing Steps

If automated tools aren't available:

1. **Basic Scene Loading**:
   ```
   - Open MainGame.tscn in editor
   - Check for any error messages
   - Verify all nodes have green icons (no missing scripts)
   ```

2. **Script Validation**:
   ```
   - Open each .gd file
   - Look for red error underlines
   - Save each file to trigger syntax checking
   ```

3. **Resource Validation**:
   ```
   - Check FileSystem dock for missing file icons (red)
   - Verify all scene files can be opened
   - Confirm JSON files have valid syntax
   ```

## 🔧 Auto-Fix Tools

Some issues can be automatically resolved:

### Using FixCommonIssues Script

```gdscript
# In a script or scene
var fixer = FixCommonIssues.new()
var result = FixCommonIssues.check_and_fix_all()
print("Issues found: ", result.total_issues)
print("Fixes applied: ", result.total_fixes)
```

### Manual Fixes

If auto-fix doesn't work, apply these manually:

1. **Input Map Setup**:
   ```
   Project → Project Settings → Input Map

   Add these actions:
   - move_left: A key (65) + Left Arrow (4194319)
   - move_right: D key (68) + Right Arrow (4194321)
   - launch_ball: Space key (32)
   - restart_game: R key (82)
   ```

2. **Physics Settings**:
   ```
   Project → Project Settings → Physics → 2D

   Set:
   - Default Gravity: 0
   - Default Gravity Vector: (0, 0)
   ```

3. **Main Scene Setting**:
   ```
   Project → Project Settings → Application → Run

   Set:
   - Main Scene: res://scenes/main/MainGame.tscn
   ```

## 📋 Step-by-Step Validation

Follow this checklist to ensure everything is set up correctly:

### ✅ Environment
- [ ] Godot version 4.3 or later
- [ ] Project opens without errors
- [ ] All files visible in FileSystem dock

### ✅ Project Structure
- [ ] scenes/main/MainGame.tscn exists
- [ ] scenes/components/Brick.tscn exists
- [ ] All script files in scripts/ directory exist
- [ ] levels/level_1.json exists

### ✅ Scene Configuration
- [ ] MainGame.tscn has MainGameScript.gd attached
- [ ] All required child nodes present (GameManager, Paddle, Ball, etc.)
- [ ] Collision shapes configured on Paddle and Ball
- [ ] UI elements present under UIManager

### ✅ Scripts
- [ ] All .gd files open without syntax errors
- [ ] Class names match expected types
- [ ] No red error indicators in script editor

### ✅ Settings
- [ ] Main scene set to MainGame.tscn
- [ ] Input map configured with all actions
- [ ] Physics gravity set to 0

### ✅ Testing
- [ ] DiagnosticRunner reports no critical issues
- [ ] TestRunner passes all tests
- [ ] Game can be run with F5

## 🆘 Getting Help

If you're still experiencing issues:

1. **Run the diagnostic tool** and share the complete output
2. **Check the Godot console** for error messages during startup
3. **Verify file permissions** - ensure you can read/write to project directory
4. **Try a fresh clone** of the repository to rule out local modifications
5. **Check system requirements** - ensure your system supports Godot 4.3+

### Sharing Debug Information

When reporting issues, include:

```
1. Godot version (Help → About)
2. Operating system
3. Complete console output from DiagnosticRunner
4. Any error messages when trying to run the game
5. Screenshot of project structure in FileSystem dock
```

## 💡 Prevention Tips

To avoid issues in the future:

1. **Always use supported Godot versions** (4.3+)
2. **Save frequently** and commit working versions to Git
3. **Run diagnostic tests** after making significant changes
4. **Validate scripts** after editing by saving and checking for errors
5. **Test regularly** during development to catch issues early

---

*This troubleshooting guide is maintained as part of the Brick Breaker game project. If you discover new issues or solutions, please update this documentation.*