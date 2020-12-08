

public OnFilterScriptInit() { // This include is only used in a Filterscript (J_MapLoader)
	
	//Add your objects & vehicles here.

	// J_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren, bool:ismap, bool:ismodified, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left);
	
	// vehicletype 							The model ID for the vehicle.
	// Float:x, y, z, rotation 				The coordinates of the vehicle.
	// Colour1, Colour2						The colour(s) of the vehicle (Colour IDs)
	// respawn_delay						The delay until the car is respawned without a driver in SECONDS, Using -1 will prevent the vehicle from respawning. (This is the default we are using currently)
	// addsiren								1 or 0 (yes or no), Toggles the H key = Siren (Including sound effects), DOES NOT ADD THE SIREN OBJECT. 
	// ismap 								true or false, Leave this set to True as this is a map include file.
	// ismodified							true or false, If this is true, the following 13 numbers are read as Component IDs (see: https://open.mp/docs/scripting/resources/Componentslots ) -
	//										each number corresponds to a slot from the above wiki article. WARNING: Make sure the Component ID is 100% Correct, otherwise the SA-MP Client will crash upon rendering the vehicle!!!!

	J_CreateVehicle(405,2494.2000000,-1671.2000000,13.3000000,0.0000000,34,25,-1, 0, true, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); //Sentinel
	J_CreateVehicle(412,2489.6001000,-1670.9000000,13.3000000,0.0000000,63,62,-1, 0, true, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); //Voodoo
	J_CreateVehicle(451,2484.8999000,-1671.0000000,13.1000000,0.0000000,32,32,-1, 0, true, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); //Turismo


	// J_CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid, interiorid, playerid, Float:streamdistance, Float:drawdistance, bool:ismap);

	// modelid 								The model ID of the object.
	// Float<x, y, z, rx, ry, rz 			The coordinates of the object, inc rotation.
	// worlid 								The Virtual World of the object , leave this as -1
	// interiorid 							The Interior ID of the object, this is converted automatically by the MTA>SAMP Converter.
	// playerid 							The Player ID who the object is being created for. Leave this as -1 for ALL PLAYERS. (In the case of a map Include, this is ALWAYS -1)
	// streamdistance 						Same as Draw Distance for the sake of what we are doing in this script. (DEFAULT = STREAMER_OBJECT_SD)
	// drawdistance 						Draw distance of the object. (DEFAULT = STREAMER_OBJECT_DD)
	// ismap 								true or false, defines if this object is a Map include object or not. Leaave this as True.

	J_CreateDynamicObject(1345,2489.0000000,-1659.9000000,13.1000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, STREAMER_OBJECT_SD, STREAMER_OBJECT_DD, true); //object(cj_dumpster)
	J_CreateDynamicObject(1345,2489.0000000,-1659.9000000,13.1000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, STREAMER_OBJECT_SD, STREAMER_OBJECT_DD, true);
	J_CreateDynamicObject(1344,2488.8000000,-1663.0000000,13.1000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, STREAMER_OBJECT_SD, STREAMER_OBJECT_DD, true); //object(cj_dumpster2) (1)
	J_CreateDynamicObject(1343,2489.1001000,-1665.3000000,13.1000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, STREAMER_OBJECT_SD, STREAMER_OBJECT_DD, true); //object(cj_dumpster3) (1)

	return 1; // Continue to other scripts.
}

public OnPlayerConnect(playerid) {

	RemoveBuildingForPlayer(playerid, 1345, 2489.0000000,-1659.9000000,13.1000000, 1.0);
	
	return 1;
}




/* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Code to be ignored
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

// This is just to allow OnPlayerConnect to work properly from an Include
#if defined _ALS_OnPlayerConnect
#undef OnPlayerConnect
#else
#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect J_MapLoader_OnPlayerConnect
#if defined J_MapLoader_OnPlayerConnect
forward J_MapLoader_OnPlayerConnect(playerid);
#endif

#if defined _ALS_OnFilterScriptInit
#undef OnFilterScriptInit
#else
#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit J_MapLoader_OnFilterScriptInit
#if defined J_MapLoader_OnFilterScriptInit
forward J_MapLoader_OnFilterScriptInit();
#endif