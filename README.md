Game resources are not yet available, sorry!

# Running

1. Install LOVE Engine 64-bit in default directory, which is "C:\Program Files\LOVE".

2. Drag game folder onto LOVE program shortcut.

3. Download resources (not yet available) and put them in game directory.

4. Move levels (in `_move_to_saves_directory` and put them in game save directory.
    * On Windows: `%appdata%\LOVE\openSMB2`
    * On Mac: `/Users/<username>/Library/Application Support/LOVE/openSMB2`
    * On Linux: `$XDG_DATA_HOME/love/openSMB2`


# Gameplay:

* Screens that work are:
    * Title screen
    * Intro story
    * Character select
    * levelbook (just right before starting a level).
    * Very basic gameplay screen prototype

* Push START button on title screen to enter character select. START button is a S key. You can also wait to enter intro story screen (you can start from here as well).

* On character select screen you can select your character by pressing left or right key. You can choose character by pressing X.

* To quit you can close window by clicking on X on title bar, or by pressing ESC button.


# Debugging:

* Press CTRL+D on title screen to enable debug mode and enter debug screen. Here you can:
    * Toggle FPS counter.
    * Toggle Frames counter.
    * Enter level editor (just very basic functions)
    * Start game in debug mode which allows above counters to work.

* In level editor menu:
    * Press one of the keys that will enter editing of some level.
    * Press Q to quit to debug screen.

* In level editor:
    * Press B to change background color (Black/Blue)
    * Press 4 or 6 on keypad to shrink or stretch width
    * Press 2 or 8 on keypad to shrink or stretch height
    * Press [ or ] to switch between level areas.
    * Press L to load level again.
    * Press S to save level.
    * Press P to play this level (Game doesn't return to level editor after doing that)
    * Press Q to quit to menu.