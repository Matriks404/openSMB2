# NOTE

This is a proof of concept branch for the prototype Nintendo 3DS version of the project. Use instructions below to install it.

This is also not officially supported, do not post new issues when on this branch. Pull requests are welcome.

# Running

1. Install LÖVE Potion 2.4.1 (not newer ones) on your console (from [here](https://github.com/lovebrew/lovepotion/releases))

2. Download zip file with this project by clicking on the green button called `Code`, then `Download ZIP`, and extract files to some folder on your computer (Alternatively execute `git clone git://github.com/Matriks404/openSMB2.git` command in the desired directory, if you have git installed).

3. Copy these files to your 3DS microSD card (to directory `/3ds/game/`).

4. Download gamepack(s) from:
	* [openSMB2-ExampleGamepack](https://github.com/Matriks404/openSMB2-ExampleGamepack/tree/3ds) project for an example openSMB2 game;

	* [This Google Drive link](https://drive.google.com/drive/folders/1cz5gJ-IXvqTIJ7fUArD30UN9Qg4sfeGX?usp=sharing) (select them and click `Download` button) and extract the appropriate `<gamepack name>.3ds.pack.zip` contents to the `/3ds/save/openSMB2/games/` directory on microSD card (that goes to your 3DS).

* NOTE: Make sure to update your resources if necessary (e.g. if you update your local repository).

5. Run LÖVE Potion using the Homebrew Launcher.

# Screenshots

![Launcher](/screenshots/1.png)
![Title screen](/screenshots/2.png)
![Level editor](/screenshots/3.png)

# 3rd party font

This project uses modified 3rd party **Dogica** fonts by **Roberto Mocci** for the launcher (in [`/resources/images/font/`](/resources/images/font/) directory), the license for the font can be found [here](/3rd%20party%20licenses/dogica_license.txt).

# Gameplay

* Stuff that is working:
	* Simple launcher
	* Title screen
	* Character select and level intro
	* Pretty much non-existent gameplay
	* Level editor (see section below)

* Controls:
	* At any time:
		* Right shoulder button - Mute the game
		* Left shoulder button - Enable debugging info (that displays game version, FPS counter and other debug stuff)
	* In any menu (launcher or pause screen):
		* Up or down button - Select option
		* `A` or `START` - Execute selected option
	* On the title screen:
		* `START` button - Enter character select screen
		* `Y` button - Enter level editor (see section below)
	* In character select screen:
		* Left or right buttons - Select character
		* `A` button - Play the game with selected character
	* During gameplay:
		* Left or right buttons - Move the character left or right
		* `B` button - Activate character running state
		* `START` button - Pause
	* `START` button on pause screen - Unpause

# Level editor

* In the level editor main menu:
	* Press `A` to enter editing of the level 1-1 (this is temporary).
	* Press `SELECT` to quit to the title screen.

* In the level editor proper:
	* In any mode:
		* Press `START` to play the level (Note that it automatically saves the level and game doesn't return to level editor afterwards).
		* Press left shoulder button to switch between level areas.
		* Press right shoulder button to change editor mode (normal one or starting position movement tool)
		* Press `SELECT` to quit to the main level editor menu.
	* When in normal editing mode (`MODE-N`):
		* Press `Y` or `X` buttons to change selected tile.
		* Use D-Pad buttons to move edit cursor.
		* Press `A` to place tile.
		* Press `B` to remove tile.
	* When in starting position movement tool mode (`MODE-S`):
		* Use D-pad buttons to move starting position pixel-by-pixel.

# Debug mode

You can enable debug mode by pressing `SELECT` in the launcher or on the title screen.

When enabled, the debugging info (which is usually displayed when you press the left shoulder button) will be permanently shown unless you disable this mode.

You will also gain access to these additional debugging features inside the game:

* Press `Y` to pause the application by not advancing ticks.
	* Note that enabling this will result in most input not being checked, notably except the button that changes the mute state.
	* When in paused state press `X` button to advance single timer tick.
* Press `SELECT` for the character to die.