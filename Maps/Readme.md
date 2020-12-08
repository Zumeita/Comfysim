# J_MapLoader Documentation

## Description

J_MapLoader is a script used to parse multiple map files and compile into one FilterScript.\
The map files are in the form of MTA XML > PAWN .inc (Include) files and the instructions to do this are found below.\

## Prerequisites

Copy my example map file from https://github.com/Zumeita/Comfysim/blob/main/Maps/example_map.inc and save it somewhere.\
You will be using this alot so always keep a copy, alternatively you can just copy and paste from the above link every time..\

## Instructions

1). Open 'https://www.convertffs.com'\
2). Copy and paste the entire contents of your MTA .map file to white box.\
3). Set the Output to 'Incognito's Streamer Plugin' and 'SA-MP CreateVehicle'.\
4). Set 'Vehicle respawn time' to -1 and then click 'Convert'\
5). Copy all the output to a text editor (Notepad++ is good for this).\
6). Press CTRL+H, top box enter 'CreateDynamicObject', bottom box enter 'J_CreateDynamicObject', then click 'Replace All'.\
7). Press CTRL+H, top box enter '); //object', bottom box enter '-1, -1, -1, -1, -1, true); //object', then click 'Replace All'\
8). Press CTRL+H, top box enter 'CreateVehicle', bottom box enter 'J_CreateVehicle', then click 'Replace All'.\
9). Press CTRL+H, top box enter '-1); //', bottom box enter '-1, 0, true, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); //', then click 'Replace All'.\
10). Using the template from Prerequisites, copy all of the J_CreateVehicle() and J_CreateDynamicVehicle() lines, overwriting the ones in the template.\
11). IMPORTANT: When you paste your entries, select them all again, this time in the template, and then press 'TAB' to indent properly, otherwise this will cause compiler errors.\
12). If you have no world objects to remove, save the template as "your_map_name.inc" and select 'All files' from the drop down menu, continue to 'Commit to Git'.\

### Optional - Removing World Objects 

12). You will need to download xConverter from my repo. (https://github.com/Zumeita/Comfysim/raw/main/Maps/xConverter.exe) and open it, select language 'EN' top right.\
13). Copy the contents of your MTA .map file to the top box and click 'Convert' (Don't worry about any settings, we don't need any of it).\
14). Select all the RemoveBuildingForPlayer() entries from the bottom box.\
15). Paste them in the same location as the example RemoveBuildingForPlayer() entries in the template you downloaded earlier, overwritin\
16). Indent and Save as per step 11 and 12 of Instructions.\

### Commit to Git

1). Browse to 'https://github.com/Zumeita/Comfysim/tree/main/Maps'\
2). Click 'Add File' and select 'Upload Files'.\
3). Drag or choose the map.inc file you saved.\
4). Enter a brief description under 'Commit changes'.\
5). Optionally, you can enter an extended description below.\
6). Click 'Commit changes'.\

You have now converted your .Map to a format the J_MapLoader script can read.\
I will commit the changes to the J_MapLoader script to load your map on my side.\

