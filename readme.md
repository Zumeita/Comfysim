# Recent Changes (Changelog)
## Build version 0.2.3 ALPHA
Docuentation started 07/12/2020 - any changes/implementations before then have not been noted here.

#### 15/12/2020
##### Improvements/Bug Fixes
- [Issue #9](https://github.com/Zumeita/Comfysim/issues/9) has been resolved & closed, optimisation to code (See issue for more detail).
- The quite large (~400 changes code wise) has increased the build version to from 0.2.2 to 0.2.3 (Optimisation/patch increment).

#### 11/12/2020
##### Added Functionality
- Base Gamemode code has been recoded into version 0.2.x
- J_MapLoader: is now version 2.1 (See bug fixes below).
- J_MapLoader: Implemented a method to store 'Long draw distance' model IDs, such as Runways, large objects, etc.
- Registration, Login system (with auto-login) implemented, file system using Y_Ini
- Basic Skin selection implemented, to be impoved on in the future, implemented Y_Classes.
- Death textdraws 'Wasted' implemented - basically a copy of GTA Online's death text.
##### Mapping
- Some modifications to the interior of LSPD - however these aren't working at Skin Selection, so this is a WIP.
##### Bug Fixes
- J_MapLoader: Major rewrite of Maps.ini loading code to function correctly after user input to the file
- J_MapLoader: String sizes adjusted to fix bug where many decimal places in float values of a .MAP file would cause the object not to load.
- J_MapLoader: Small adjustment to the .MAP parsing code to fix Z Rotation of Objects & Vehicles not loading correctly.
- J_MapLoader: Adjustment to a loop within the J_MapLoaderFuncs.inc file to allow setting of the Interior value parsed from the .MAP file
- Overhaul of the gamemode to 0.2.x fixed a major bug where 'sometimes' a death would run through the spawn sequence again.
- Loading & Saving code is properly working now after the overhaul and addition of Y_Ini.
- J_MentalState: A bug where the player colour would not load correctly, this was fixed during the overhaul to 0.2.x
- Screen fades given more resources so they are alot smoother now.
- General code optimiziation is on-going as and when.



#### 09/12/2020
#####  Added Functionality
- J_MapLoader has been overhauled, version 2.0 is now current.
- J_MapLoader can now load MTA .map files directly from the [Maps directory](scriptfiles/Comfysim/Maps), with the file name entered in [maps.ini](scriptfiles/Comfysim/Maps/maps.ini)
- J_MapLoader currently supports Objects, Vehicles & Removed World Objects - note: vehicle colours, paintjobs & modifications are not supported.

#### 08/12/2020
##### Added Functionality
- J_MapLoader implemented and tested - This is a Filterscript that loads maps in the form of an .inc file from the Maps folder.
- Functions added to J_Functions which store detailed information about Objects & Vehicles in memory, this will make future scripts more compatible with eachother and engine features very easy to implement as the data will already be present.


#### 7/12/2020
##### Added Functionality
- J_Entrances engine scripted & first implementation to Flint County Airfield for testing.
- J_Entrances dynamically loads entrances from 'scriptfiles/Comfysim/entrance_<id>.ini'.
- J_Entrances supports toggling of 3DText at all entrances.
- J_Entrances fully supports moving gates and/or barriers with variable speed/stay open times, using the 'Y' key.
- J_Entrances fully supports entering and exiting interiors (or other areas) using the 'Y' key.
- Debug command '/ent <entrance id>' implemented for debugging purposes to teleport to an entrance.
##### Mapping
- Flint County Airfield received a door on the apron side of the FBO as it was missing.
- The village at the peak of Chilliad has received some additional detailing, clutter & improvements.
- The roads from the base of Chilliad to the top have had further mapping improvements.
- The farm north-east of Chilliad has received its first itteration of mapping in the form of removed objects & grass airfield outlined.
##### AI NPCs
- A coach driving from the base to the top of Chilliad has been implemented for testing.
- A Cropduster flying from the newly mapped farm, then onto Flint County airfield and then back, implemented for testing.
