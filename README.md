# Running

1. Install LÖVE Engine on your computer.

2. Download zip file with this project by clicking on `Clone or download` and `Download ZIP` buttons, and extract files to some folder on your computer (Alternatively execute `git clone git://github.com/Matriks404/openSMB2.git` command in the desired directory, if you have git installed).

3. Download gamepack(s) from this [link](https://drive.google.com/drive/folders/1cz5gJ-IXvqTIJ7fUArD30UN9Qg4sfeGX?usp=sharing) (select them and click `Download` button) and extract the appropriate `<gamepack name>.pack.zip` contents to the following directory:

	* On Windows: `%appdata%\LOVE\openSMB2\games\`
	* On GNU/Linux: `~/.local/share/love/openSMB2/games/`
	* On macOS: `/Users/user/Library/Application Support/LOVE/openSMB2/games`

* NOTE: Make sure to update your resources if necessary (e.g. if you update your local repository).

4. Run the game!
	* On Windows: Drag game folder onto LÖVE program shortcut.
	* On GNU/Linux and macOS: Execute `love .` in the console (you might need to change directory to game path first).

# Screenshots

![Title screen](/screenshots/1.png)
![Intro story](/screenshots/2.png)
![Character select](/screenshots/3.png)
![Gameplay](/screenshots/4.png)
![Debug screen](/screenshots/5.png)
![Level editor](/screenshots/6.png)

# 3rd party font

This project uses modified 3rd party font called **Dogica** by **Roberto Mocci** for the launcher (in [/resources/images/font/dogica.png](/resources/images/font/dogica.png)), the license for the font can be found [here](/3rd%20party%20licenses/dogica_license.txt).

# Gameplay

* Stuff that is working:
	* Simple launcher for gamepacks
	* Title screen
	* Character select and level intro
	* Pretty much non-existent gameplay
	* Level editor (see below)

* Controls:
	* On any screen:
		* `-` or `=` key - Scale graphics down or up (only integer scaling).
		* `ALT+ENTER` or `F11` key - Enable or disable fullscreen mode.
	* In launcher:
		* `Up` or `Down` - Select gamepack.
		* `ENTER` or `S` - Run the currently selected gamepack.
	* `S` key on title screen - Enter character select screen.
	* In character select screen:
		* `Left` or `Right` key - Select character
		* `X` key - Choose character
	* During gameplay:
		* `Left` or `Right` key - Move left or right
		* `Z` key - Run
		* `S` key - Pause
	* `S` key on pause screen - Unpause
	* On game over screen:
		* `A` key - Select option
		* `S` key - Choose option
	* `ESC` key - Quit the game

# Debugging

* Press `CTRL+D` on title screen to enable debug mode and enter debug screen. Here you can:
	* Toggle FPS counter.
	* Toggle Frames counter.
	* Toggle Mute option.
	* Enter level editor (see below).
	* Start game in debug mode which allows above options to work.

* Also during gameplay (when debug mode is enabled) you can:
	* Press `A` to ascend.
	* Press `D` to die.

# Level editor

* In the level editor main menu:
	* Press one of the keys that will enter editing of some level.
	* Press `Q` to quit to the debug screen.

* In the level editor proper:
	* In any mode:
		* Resize the window to have more screen space for editing purposes.
		* Press `L` to load the level (useful if you replace the files and need to reload the level in the editor).
		* Press `V` to save the level.
		* Press `P` to play the level (Note that it automatically saves the level and game doesn't return to level editor afterwards).
		* Press `[` or `]` to switch between level areas.
		* Press `Tab` to change editor mode (normal one or starting position movement tool)
		* Press `C` to change editor view type (normal or detailed, where the latter is showing hexadecimal values of tiles on top of them).
		* To move the view:
			* Press `CTRL` + arrow keys to move the view by one tile.
			* Press `Page up` or `Page down` to move the view by one screen up or down.
			* Press `CTRL` + (`Page up` or `Page down`) to move the view by one screen left or right.
			* Press `Home` or `End` to jump view to the vertical start or end.
			* Press `CTRL` + (`Home` or `End`) to jump view to the horizontal start or end.
		* Press `Q` to quit to the main level editor menu.
	* When in normal editing mode (`MODE-N`):
		* Press `T` to change area type (horizontal or vertical).
		* Press `B` to change background color.
		* Press `M` to change music.
		* Press `R` to resize the area to valid size (that is height of maximum 240 pixels for horizontal levels and width of exact 256 pixels for vertical levels).
		* Press `4` or `6` on keypad to shrink or stretch width.
		* Press `8` or `2` on keypad to shrink or stretch height.
		* Press `W`, `S`, `A`, `D` keys to change selected tile.
		* Press arrow keys to move edit cursor.
		* Press `X` to place tile.
		* Press `Z` to remove tile.
	* When in starting position movement tool mode (`MODE-S`):
		* Press arrow keys to move starting position pixel-by-pixel.
		* Press `SHIFT` + arrow keys to move starting position by 16 pixels each time.