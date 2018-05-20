# Running

1. Install LÖVE Engine on your computer.

2. Download zip file with this project by clicking on `Clone or download` and `Download ZIP` buttons, and extract files to some folder on your computer.

3. Download resources from this [link](https://drive.google.com/drive/folders/1Gqw8yUSekHwrbAnHErZbr7AdeugurBRq?usp=sharing) (select them and click `Download` button) and extract them in `resources` directory.

	* NOTE: Make sure to update your resources if necessary (e.g. if you update your local repository).
	* BEWARE! You should only download these files if you legally own them in any format (such as original NES cartridge with Super Mario Bros. 2).

4. Move levels (in `_move_to_saves_directory`) to game save directory.
	* On Windows: `%appdata%\LOVE\openSMB2`
	* On Mac: `/Users/<username>/Library/Application Support/LOVE/openSMB2`
	* On Linux: `$XDG_DATA_HOME/love/openSMB2`

5. Drag game folder onto LOVE program shortcut to run it!

# Gameplay:

* Screens that work are:
	* Title screen
	* Intro story
	* Character select
	* Levelbook (just right before starting a level)
	* Basic gameplay screen

* Controls:
	* `S` key on title screen - Enter character select screen.
	* In character select screen:
		* `Left` or `Right` key - Select character
		* `X` key - Choose character
	* During gameplay:
		* `Left` or `Right` key - Move left or right
		* `Z` key - Run
		* `S` key - Pause
	* `S` key on pause screen - Unpause
	* `X` on title bar or `ESC` key - Quit the game

# Screenshots

![Title screen](/screenshots/1.png)
![Intro story](/screenshots/2.png)
![Character select](/screenshots/3.png)
![Levelbook](/screenshots/4.png)
![Gameplay](/screenshots/5.png)
![Debug screen](/screenshots/6.png)
![Level editor menu](/screenshots/7.png)
![Level editor](/screenshots/8.png)


# Debugging:

* Press `CTRL+D` on title screen to enable debug mode and enter debug screen. Here you can:
	* Toggle FPS counter.
	* Toggle Frames counter.
	* Toggle Mute option.
	* Enter level editor (just very basic functions)
	* Start game in debug mode which allows above counters to work.
	
* During gameplay:
	* Press `8` or `2` on keypad to scroll level horizontally.

* In level editor menu:
	* Press one of the keys that will enter editing of some level.
	* Press `Q` to quit to debug screen.

* In level editor:
	* Press `B` to change background color (Black/Blue)
	* Press `M` to change music
	* Press `4` or `6` on keypad to shrink or stretch width
	* Press `8` or `2` on keypad to shrink or stretch height
	* Press `[` or `]` to switch between level areas. Beware that it will automatically save current level and area!
	* Press arrow keys to move edit cursor.
	* Press `W`, `S`, `A`, `D` keys to change selected tile
	* Press `Z` to remove tile
	* Press `X` to place tile
	* Press `L` to load level again.
	* Press `V` to save level.
	* Press `P` to play this level (Game doesn't return to level editor after doing that)
	* Press `Q` to quit to menu.
	* Press `E` to save and quit to menu.