# Recent Changes (Changelog)
## Build version 0.1.2 ALPHA
Docuentation started 07/12/2020 - any changes/implementations before then have not been noted here.

#### 09/12/2020
#####  Added Functionality
- J_MapLoader has been redone, version 2.0 is now current.
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