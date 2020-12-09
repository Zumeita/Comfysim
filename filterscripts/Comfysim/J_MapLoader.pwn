#define _DEBUG 7 // Comment out to disable console print debugging

#include <a_samp>
#include <YSI\YSI_Coding\y_hooks>
#include <YSI\YSI_Core\y_debug>
#include <Comfysim\J_Functions> // This is needed for J_CreateDynamicObject & J_CreateVehicle functions.

#define VAL_TYPE_INT 0
#define VAL_TYPE_FLOAT 1
#define MAX_MAP_STRING_SIZE 1024
#define MAX_MAPS 30

#define VAL_PARAMS 20 // 0-7 is for Objects, 8-13 is for Vehicles, 13-19 is for Removed objects.

enum E_PARSE_DATA {
	start_pos, end_pos, int_val, Float:float_val
}

new 
	gMaps, // Global map counter
	gFile_Start,
	gTempStr[10],
	gStringData[VAL_PARAMS][E_PARSE_DATA]
;

enum E_STR_DATA {
	needle[7], str_ref[7], start_val, end_val, val_type
}

// <removeWorldObject id="removeWorldObject (sm_veg_tree7_big) (3)" radius="14.085081" interior="0" model="703" lodModel="0" posX="-274.35156" posY="-2272.3828" posZ="28.07813" rotX="0" rotY="0" rotZ="0"></removeWorldObject> 
new gRefData[VAL_PARAMS][E_STR_DATA] = {
		
		// Object Rules
		{"model=", "scale", 7, 2, VAL_TYPE_INT},
		{" posX=", "posY=", 7, 2, VAL_TYPE_FLOAT},
		{" posY=", "posZ=", 7, 2, VAL_TYPE_FLOAT},
		{" posZ=", "rotX=", 7, 2, VAL_TYPE_FLOAT},
		{" rotX=", "rotY=", 7, 2, VAL_TYPE_FLOAT},
		{" rotY=", "rotZ=", 7, 2, VAL_TYPE_FLOAT},
		{" rotZ=", "</obj", 7, 2, VAL_TYPE_FLOAT},
		{" rior=", "alpha", 7, 2, VAL_TYPE_INT}, // index 7

		// Vehicle Rules
		{"model=", "colli", 7, 2, VAL_TYPE_INT},
		{" posX=", "posY=", 7, 2, VAL_TYPE_FLOAT},
		{" posY=", "posZ=", 7, 2, VAL_TYPE_FLOAT},
		{" posZ=", "rotX=", 7, 2, VAL_TYPE_FLOAT},
		{" rotZ=", "color=", 7, 2, VAL_TYPE_FLOAT}, // Only need Z rotation.
		{"rior=", "healt=", 7, 2, VAL_TYPE_INT}, // Index 13

		{"model=", "lodMo", 7, 2, VAL_TYPE_INT},
		{"Model=", "posX=", 7, 2, VAL_TYPE_INT},
		{" posX=", "posY=", 7, 2, VAL_TYPE_FLOAT},
		{" posY=", "posZ=", 7, 2, VAL_TYPE_FLOAT},
		{" posZ=", "rotX=", 7, 2, VAL_TYPE_FLOAT},
		{"adius=", "inter", 7, 2, VAL_TYPE_FLOAT}
};

stock J_GetDataFromMapFile(index, const string[MAX_MAP_STRING_SIZE]) {
	gStringData[index][start_pos] = (strfind(string, gRefData[index][needle])+gRefData[index][start_val]);
	gStringData[index][end_pos] = (strfind(string, gRefData[index][str_ref])-gRefData[index][end_val]);
	strmid(gTempStr, string, gStringData[index][start_pos], gStringData[index][end_pos]);
	switch(gRefData[index][val_type]) {
		case VAL_TYPE_INT: {
			gStringData[index][int_val] = strval(gTempStr);
		}
		case VAL_TYPE_FLOAT: {
			gStringData[index][float_val] = floatstr(gTempStr);
		}
	}
	return 1;
}

stock J_LoadMaps() {

	//enum e_map { path[50] }

	new 
		File:file= fopen("Comfysim/Maps/maps.ini", io_read), // Open the map list file.
		map_path[MAX_MAPS][70],
		str[MAX_MAP_STRING_SIZE]
	;

	if(!file) {
			P:4("J_MapLoader]: No maps.ini found.");
			return 0;
	}

	while(fread(file, str)) {
		format(map_path[gMaps], 70, "Comfysim/Maps/%s.map", str);
		P:4("[J_MapLoader]: Loaded map %s", map_path[gMaps]);
		gMaps++;
	}

	fclose(file);
	P:4("[J_MapLoader]: Loaded %d maps.", gMaps);

	for(new i; i < gMaps; i++) { // Run the load code for every single map loaded in from maps.ini
		file = fopen(map_path[i], io_read);
		P:4("[J_MapLoader]: Attempting to load %s...", map_path[i]);

		if(file) {
			while(fread(file, str)) {
				if(!gFile_Start) {
					if(strfind(str, "<map edf:definitions") != -1) {
						gFile_Start  = 1;
						P:4("[J_MapLoader]: Found starting line of file 'test_map.map', tracker assigned, continuing...");
					}
					else {
						P:4("[J_MapLoader]: Invalid .map syntax!");
						return 1;
					}
				} // VAL_PARAMS 14 // 0-7 is for Objects, 8-13 is for Vehicles.
				else {
					if(strfind(str, "object id=") != -1) { // Line being loaded is an object
						for(new idx; idx < 7; idx++) { // Only need to loop 7 times out of 13 which is index 0-7 (sizeof VAL_PARAMS - 2)
							J_GetDataFromMapFile(idx, str);
						}
						J_CreateDynamicObject(gStringData[0][int_val], gStringData[1][float_val], gStringData[2][float_val], gStringData[3][float_val],  gStringData[4][float_val], gStringData[5][float_val], gStringData[6][float_val], -1, gStringData[7][int_val], -1, -1.0, -1.0, true);
						P:4("[J_MapLoader]: J_CreateDynamicObject(%d, %f, %f, %f,  %f, %f, %f, -1, %d, -1, -1.0, -1.0, true);", gStringData[0][int_val], gStringData[1][float_val], gStringData[2][float_val], gStringData[3][float_val],  gStringData[4][float_val], gStringData[5][float_val], gStringData[6][float_val], gStringData[7][int_val]);
					}
					else if(strfind(str, "vehicle id=") != -1) { // Line being loaded is a vehicle
						for(new idx = 8; idx < 14; idx++ ) { // Only need to loop 2 times, from index 8 (VAL_PARAMS-2) to index 10 (VAL_PARAMS)
							J_GetDataFromMapFile(idx, str);
							
							//J_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren, interior, bool:ismap, bool:ismodified, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left);
							//CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren=0, );
						}
						
						J_CreateVehicle(gStringData[8][int_val], gStringData[9][float_val], gStringData[10][float_val], gStringData[11][float_val], gStringData[12][float_val], -1, -1, -1, 0, gStringData[13][int_val], true, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
						P:4("[J_MapLoader]: J_CreateVehicle(%d, %.1f, %.1f, %.1f, %.1f, -1, -1, -1, 0, %d, true, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);", gStringData[8][int_val], gStringData[9][float_val], gStringData[10][float_val], gStringData[11][float_val], gStringData[12][float_val], gStringData[13][int_val]);
					}
					else if(strfind(str, "removeWorld") != -1) { // Line being loaded is a Removed Object.
						for(new idx = 13; idx < VAL_PARAMS; idx++ ) { // Only need to loop 2 times, from index 8 (VAL_PARAMS-2) to index 10 (VAL_PARAMS)
							J_GetDataFromMapFile(idx, str);
							//RemoveBuilding()
							
							//J_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren, interior, bool:ismap, bool:ismodified, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left);
							//CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren=0, );
						}
						J_RemoveWorldObject(gStringData[14][int_val], gStringData[15][int_val], gStringData[16][float_val], gStringData[17][float_val], gStringData[18][float_val], gStringData[19][float_val]);
						P:4("[J_MapLoader]: J_RemoveBuilding(%d, %d, %f, %f, %f, %f);", gStringData[14][int_val], gStringData[15][int_val], gStringData[16][float_val], gStringData[17][float_val], gStringData[18][float_val], gStringData[19][float_val]);
					}
				}

					//J_CreateDynamicObject(gStringData[0][int_val], gStringData[1][float_val], gStringData[2][float_val], gStringData[3][float_val],  gStringData[4][float_val], gStringData[5]][float_val], gStringData[6][float_val], -1, gStringData[7][int_val], -1, -1.0, -1.0, true);

					/*gStringData[index]strfind(str, gStringData[index][needle];
					gStringData[index][]

					new val = strfind(str, "model="); // 7 Chars - model="
					new eval = strfind(str, "scale", true, (val+7));
					new end = (eval-2);
					new start = (val+7);

					//P:4("[xml_test]: val: %d, eval: %d, end: %d, start:%d", val, eval, end, start);
					//P:4("[xml_test]: %s", str);
					new temp[5];
					strmid(temp, str, start, end);
					//P:4("[xml_test]: temp = %s", temp);

					or(new idx = start, idxt; idx < end; idx++,idxt++) {
						strins(temp, str[idx], idxt, sizeof(temp));
						P:4("[xml_test]: str %s, idx %d, idxt %d", str[idx], idx, idxt);
					}

					new model = strval(temp);
					P:4("[xml_test] model: %d", model);*/

			}
			fclose(file);
			//printf("[xml_test]: %s", str);
			gFile_Start = 0;
			P:4("[J_MapLoader]: Successfully loaded map '%s.", map_path[i]);
		}

	}
	return 1;
}

hook OnPlayerConnect(playerid) {
	for(new i; i < gRemovedObjects; i++) {
		RemoveBuildingForPlayer(playerid, gRemovedObjectData[i][rm_modelid],gRemovedObjectData[i][rmx], gRemovedObjectData[i][rmy], gRemovedObjectData[i][rmz], gRemovedObjectData[i][rm_radius]);
		if(gRemovedObjectData[i][rm_lodmodel] != 0) {
			P:4("[J_MapLoader]: Removing Object %d, %d, %f, %f, %f, %f", gRemovedObjectData[i][rm_modelid],gRemovedObjectData[i][rmx], gRemovedObjectData[i][rmy], gRemovedObjectData[i][rmz], gRemovedObjectData[i][rm_radius]);
			RemoveBuildingForPlayer(playerid, gRemovedObjectData[i][rm_lodmodel],gRemovedObjectData[i][rmx], gRemovedObjectData[i][rmy], gRemovedObjectData[i][rmz], gRemovedObjectData[i][rm_radius]);
		}
	}
}

hook OnFilterScriptInit() {

	J_LoadMaps();
	return 1;
}

hook OnFilterScriptExit() {
	// Rather than looping thousands, only loop what is used, 10 objects? 10 loops.
	P:4("[J_MapLoader] DEBUG: OnFilterScriptExit()");
	for(new idx; idx < gMapObjects; idx++) {
		DestroyDynamicObject(gMapObjectData[gMapObjects]);
	}
	for(new idx; idx < gMapVehicles; idx++) {
		P:4("[J_MapLoader] DEBUG: Removed vehicle id (%d) at gMapVehicles index (%d", gMapVehicleData[idx][vehicle_id], idx);
		DestroyVehicle(gMapVehicleData[idx][vehicle_id]);
	}
	/*foreach(new idx : iMapObjects) {
		DestroyDynamicObject(gMapObjects[idx]);
	}
	foreach(new idx : iMapVehicles) {
		DestroyVehicle(gMapVehicles[idx][vehicle_id]);
	}*/

	return 1;
}
