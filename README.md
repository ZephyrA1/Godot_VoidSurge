# Void Surge

A top-down arena survival roguelite built in Godot 4.6.2. Survive 10 waves of enemies, manage your weapon's heat, and choose upgrades to build your perfect run.

## GitHub Repository

[View the GitHub repository here](https://github.com/ZephyrA1/CSCI4160_VoidSurge.git).

## Demo Video

[Watch the video essay on YouTube (unlisted)](https://youtu.be/zemfBS0gRrw)

## How to Run

### From Export (Recommended)
1. Navigate to the `build/` folder in this project directory.
2. Double-click `VoidSurge.exe` to play. (Keep `VoidSurge.pck` in the same folder — the game needs both files to run.)

### From Source (Godot Editor)
1. Install [Godot 4.6.2](https://godotengine.org/download) (standard version, not .NET).
2. Open Godot and click **Import** → navigate to this folder → select `project.godot`.
3. Press **F5** or click the Play button to run.

### Exporting a Build
1. Open the project in Godot Editor.
2. Go to **Project → Export**.
3. Add a **Windows Desktop** preset (or your target platform).
4. Click **Export Project** and choose an output folder.

## Controls

| Action | Keyboard / Mouse | Gamepad |
|--------|------------------|---------|
| Move | WASD or Arrow Keys | Left Stick |
| Aim | Mouse cursor | — |
| Shoot | Left Mouse Button (hold for auto-fire) | RT (Right Trigger) |
| Dash | Space or Right Mouse Button | A (South Button) |
| Pause | Escape | Start |
| Select Upgrade | Click button or press 1 / 2 / 3 | — |

## Game Overview

- **Goal:** Survive all 10 waves of enemies to win.
- **Heat System:** Shooting builds heat. High heat = bonus damage, but overheating (100%) deals self-damage and locks your weapon for 2.5 seconds.
- **Dash:** Invincible dash that damages enemies you pass through. Use it to dodge or as an offensive tool when overheated.
- **Upgrades:** After each wave, pick 1 of 3 random upgrades. Build synergies across damage, heat management, dash power, and survivability.

### Enemy Types
- **Chaser (red triangle):** Rushes directly at you. Dangerous in groups.
- **Shooter (orange square):** Keeps distance and fires projectiles.
- **Dasher (purple diamond):** Circles you, then charges in fast bursts.

## Project Structure

```
project.godot              # Godot project configuration
scenes/                    # All .tscn scene files
  main_menu.tscn           # Title screen
  game.tscn                # Main gameplay scene
  hud.tscn                 # Heads-up display
  upgrade_panel.tscn       # Between-wave upgrade selection
  pause_menu.tscn          # Pause overlay
  game_over_screen.tscn    # Death screen
  win_screen.tscn          # Victory screen
  player.tscn              # Player entity
  enemies/                 # Enemy scenes
  projectiles/             # Bullet scenes
scripts/                   # All GDScript files
  autoload/
    game_manager.gd        # Global state singleton
  player.gd                # Player controller
  enemy_base.gd            # Base enemy class
  chaser_enemy.gd          # Chaser AI
  shooter_enemy.gd         # Shooter AI
  dasher_enemy.gd          # Dasher AI
  wave_manager.gd          # Wave spawning logic
  upgrade_panel.gd         # Upgrade UI and selection
  hud.gd                   # HUD updates
  game.gd                  # Game scene orchestration
  game_camera.gd           # Camera with screen shake
  main_menu.gd             # Main menu logic
  pause_menu.gd            # Pause logic
  game_over_screen.gd      # Game over logic
  win_screen.gd            # Win screen logic
  player_bullet.gd         # Player projectile
  enemy_bullet.gd          # Enemy projectile
docs/
  Final Project - Void Surge - GDD.pdf                   # Game Design Document (MDA)
  Final Project - Void Surge - Postmortem.pdf            # Development Postmortem
```

## Known Issues

- No audio implemented. The game relies on visual feedback (hit flashes, screen shake, color shifts, particle effects).
- On very large monitors, the arena may appear small due to the fixed arena size. The viewport scales but the play area is constant.
- Upgrade cards are generated in code; first display may have a brief layout adjustment frame.

## Asset Credits / Licenses

- **Engine:** [Godot Engine 4.6.2](https://godotengine.org/) — MIT License
- **All game art:** Procedurally generated using Godot's built-in Polygon2D, Line2D, and code-generated textures. No external art assets used.
- **Font:** Godot's default built-in font.
- **Code:** Original work, all rights reserved.
