# Sketchybar Integration

Display pomodoro status in [sketchybar](https://github.com/FelixKratz/SketchyBar).

## Setup

1. Copy the plugin to your sketchybar plugins directory:

   ```bash
   cp plugins/pomodoro.sh ~/.config/sketchybar/plugins/
   chmod +x ~/.config/sketchybar/plugins/pomodoro.sh
   ```

2. Update the `POMODORO` path in `pomodoro.sh` to match your installation.

3. Add the snippet from `sketchybarrc` to your sketchybar configuration.

4. Reload sketchybar:

   ```bash
   sketchybar --reload
   ```
