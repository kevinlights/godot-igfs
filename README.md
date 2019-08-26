# IGFS - Inter Galactic Flight Simulator - WIP

**IGFS is an open source multiplayer space-flight game made with Godot Engine.**  Explore the galaxy through open space, land in space stations, and play with your friends.

![Sun and planet](https://gitlab.com/pjtsearch/godot-igfs/raw/master/Assets/images/screenshot0.png)

## Goals:
* Accepting missions, buying goods, and acquiring ships in space stations.
* Multiple solar systems.
* Hyperspace travel.
* Public servers.
* Ship vs ship combat.
* Currency sytem and resources (eg. fuel).
* Planet claiming, getting taxes from claimed planets, and planetary takeovers.

## Downloading and Installing game:
1. Go to [jobs](https://gitlab.com/pjtsearch/godot-igfs/-/jobs) and download the artifact for your platform.
2. Move the artifact (called ````igfs-<your platform>.tar.gz````) to the desired location where you want to keep the game.
3. Extract the archive there.
4. Then run the executable to start the game!
5. If you find any bugs, or have and feature requests, please report them on the [issue tracker](https://gitlab.com/pjtsearch/godot-igfs/issues).
    #### Note:
    Currently, to join a multiplayer server, you have to edit the ````settings.cfg```` file, that sould be in the same directory as the game executable. If it is not there, then create it. Add this to the bottom of the file:
    ````
    [multiplayer]
    is_host=false
    address="<the ip address of the host>"
    port=<the port number of the host>
    ````

## Development
##### Current development branch: refactoring0
### Setting up:
1. This project is based on Godot 3.2. If you haven't already, build the latest version of Godot. The instructions are [here](https://docs.godotengine.org/en/3.1/development/compiling/index.html).
2. Clone the repository:

        git clone git@gitlab.com:pjtsearch/godot-igfs.git
3. Go to project directory:
   
        cd godot-igfs 
4. Switch to current development branch:
   
        git checkout <current development branch>
5. Now you can open the ````project.godot```` with Godot and start contributing!
6. If you find any bugs, or have and feature requests, please report them on the [issue tracker](https://gitlab.com/pjtsearch/godot-igfs/issues).

*Thank you.  Contributions are highly apperciated.*

### Todo:
* Moving code from the large scripts of the root nodes into the child node that they concern, or to a new node for that specific purpose.
* Sending the ship type in multiplayer, and displaying that ship type on all peers.