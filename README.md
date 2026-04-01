# CS301TD

> A Flutter-powered, classroom-themed tower defense prototype built around a looping menu, a single 1280×720 battlefield, dozens of portrait-based towers, and a wave-based campaign that culminates in miniboss fights.

## Overview
- Starts in a cinematic menu that plays `assets/music/bg.mp3`, animates the title/subtitle, and lets the player mute the soundtrack before jumping into the battlefield.
- Forces a landscape orientation and routes to four screens: the menu, the game itself, the shop, and the tower upgrade panel.
- Ships most of the gameplay logic inside `lib/screens/game_screen.dart`: wave spawning, enemy movement along `kPathPoints`, projectile/damage tracing, victory/defeat overlays, and tower placement.

## How to Play
1. **Launch** the app (`flutter run -d <device>`) and tap anywhere on the menu to start; use the mute button in the top-right corner if you want to silence the looping theme.
2. **Observe** the HUD: the left corner shows the current wave (`wave / maxWaves`), while the right corner displays remaining lives and current money.
3. **Buy towers** via the gold `Shop` button in the bottom bar. The shop lets you filter by rarity/class, sorts affordable towers first, and returns the selected tower to your inventory.
4. **Drag towers** from the horizontal inventory into the battle area. The playfield is a `DragTarget` laid on top of `assets/maps/level1.png`, so just drop a tower where you want it to fire along the path.
5. **Upgrade towers** by tapping them on the map; the upgrade screen summarizes stats, ability bonuses, and the evolving cost for each tier.
6. **Survive 10 waves**. Every 5th wave spawns a miniboss (see `minibossDefs` in `game_screen.dart`), and clearing all waves shows a victory overlay while losing all lives triggers a defeat overlay and lets you restart.

## Project Structure
- `lib/main.dart` initializes Flutter, forces landscape, and registers `/` (menu) and `/game` routes.
- `lib/screens/menu_screen.dart` handles the animated menu, background music (via `audioplayers`), and the tap-to-start gesture.
- `lib/screens/game_screen.dart` defines tower/enemy models, once-per-frame updates (`Timer.periodic` at 16 ms), HUD, inventory/shop interactions, tower placement, and wave logic (`startWave`, `hitEnemy`, etc.).
- `lib/screens/shop_screen.dart` exposes responsive filter controls, affordability highlighting, and a grid that shrinks from six columns on wide screens to two on phones.
- `lib/screens/tower_upgrade_screen.dart` renders a hero card with glowing rarity borders, evolution specs, and ability lists driven by `TowerAbility`.
- `lib/widgets/mute_button.dart` is a reusable icon switch used by the menu screen.

## Assets
All assets referenced in `pubspec.yaml` are grouped under `flutter.assets`:
- `assets/music/` – menu background loop.
- `assets/menu/` – menu background/title/subtitle sprites.
- `assets/maps/` – currently `level1.png`, stretched for the battlefield.
- `assets/game/classmates/` – tower portraits that appear in the shop, inventory cards, and upgrade hero panel.
- `assets/game/weapons/` – weapon sprites assets referenced by `TowerType.weaponPath`.
- `assets/game/enemies/` – enemy/miniboss sprites, used during wave playback.

To add a new tower:
1. Import its portrait/weapon assets into the appropriate folders and update `pubspec.yaml` if you add new directories.
2. Append a `TowerType` in `buildTowerTypes()` (include `id`, `name`, `cost`, rarity/class, stats, asset paths, and `TowerAbility` entries).
3. The shop automatically surfaces the tower if it fits the selected filters and budget.

To change the map or enemy path:
- Swap `assets/maps/level1.png` for a new image and adjust the `kPathPoints` list at the top of `game_screen.dart`.
- Modify `enemyDefs` or `minibossDefs` to tweak health/speed/bounty values or add new enemy types.

## Getting Started
1. Install Flutter 3.10.1 (or later) and set up the tooling for your target platforms (Android SDK, Xcode, Visual Studio for Windows, etc.).
2. Fetch dependencies: `flutter pub get`.
3. Run the app on your desired platform:
   ```bash
   flutter run -d windows   # Desktop
   flutter run -d chrome    # Web (music may need manual start)
   flutter run              # First connected mobile device
   ```
4. Build release artifacts as needed: `flutter build windows`, `flutter build web`, or `flutter build apk`.

## Development
- `flutter analyze` keeps the project linted (uses `flutter_lints`).
- `flutter test` currently acts as a smoke test; add widget/unit tests as you expand the project.
- The game loop is a `Timer.periodic` in `initState`, so mind the 16 ms tick when profiling or adjusting gameplay pacing.
- Background music uses `AudioPlayer`. Web browsers require a tap before playback because `_initMusic()` is skipped on web until interaction occurs.

## Next Steps
1. Expand tower variety by adding classmates/portrait art plus new `TowerAbility` effects inside `hitEnemy`.
2. Introduce new maps and selectable battlefields (update `kPathPoints` and map assets).
3. Add unlockables or persistent progression by persisting `money` or `ownedTowers` between sessions.
4. Polish UI transitions (shop filters, upgrade animations) and add accessibility text for the HUD widgets.
