#define MAX_VEHICLE_COMPONENTS 14
#define MAX_REMOVED_OBJECTS 300

enum E_VEHICLE_DATA {
	vehicle_id, colour1, colour2
}

enum E_REMOVED_OBJECTS_DATA {
	rm_modelid, rm_lodmodel,
	Float:rmx, Float:rmy, Float:rmz, Float:rm_radius
}

new
	gMapObjectData[MAX_OBJECTS],
	gMapObjects,

	gObjectData[MAX_OBJECTS],
	gObjects,

	gMapVehicleData[MAX_VEHICLES][E_VEHICLE_DATA],
	gMapVehicleMods[MAX_VEHICLES][MAX_VEHICLE_COMPONENTS],
	gMapVehicles,

	gVehicleData[MAX_VEHICLES][E_VEHICLE_DATA],
	gVehicleMods[MAX_VEHICLES][MAX_VEHICLE_COMPONENTS],
	gVehicles,

	gRemovedObjectData[MAX_REMOVED_OBJECTS][E_REMOVED_OBJECTS_DATA],
	gRemovedObjects,

	gObjectIdTracker = INVALID_OBJECT_ID,
	gVehicleIdTracker = INVALID_VEHICLE_ID,

	gLongDrawDistance[] = {
		3783,	// las2xref01_lax (Runway - FCAF)
		5736,	// studoff02_law (Apron - FCAF)

		19121,	// White Runway Light (Custom SA-MP Object, replaces bollardlight)
		19122,	// Blue Taxi Light (Custom SA-MP Object, replaces bollardlight)
		10764,	// app_light_sfs05e (Approach lighting from SFAP)

		18234,	// cuntw_shed2_ (FBO at FCAF)
		9245,	// cstguard_sfn01 (Control tower at FCAF)
		16101,	// des_windsockpole (Windsock Pole)
		16368,	// bonyrd_windsock (Windstock Sock)
		16409,	// by_weehangr (Hangar at FCAF, originally garage in Verdant Meadows)
		3626,	//dckwrkhut (enterable 'construction' hut)
		1243,	// Bouy
		19954,	// >> Arrow sign
		19961,	// Right Turn Ahead Sign
		19953,	// << Arrow sign
		19960	// Left Turn Ahead Sign
	}

;


#include <streamer>

forward J_RemoveWorldObject(modelid, lodmodel, Float:x, Float:y, Float:z, Float:radius);
public J_RemoveWorldObject(modelid, lodmodel, Float:x, Float:y, Float:z, Float:radius)
{
	gRemovedObjectData[gRemovedObjects][rm_modelid] = modelid;
	gRemovedObjectData[gRemovedObjects][rm_lodmodel] = lodmodel;
	gRemovedObjectData[gRemovedObjects][rmx] = x;
	gRemovedObjectData[gRemovedObjects][rmy] = y;
	gRemovedObjectData[gRemovedObjects][rmz] = z;
	gRemovedObjectData[gRemovedObjects][rm_radius] = radius;
	gRemovedObjects++;
	return 1;
}

forward J_CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid, interiorid, playerid, Float:streamdistance, Float:drawdistance, bool:ismap);
public J_CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid, interiorid, playerid, Float:streamdistance, Float:drawdistance, bool:ismap)
{
//stock J_CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = STREAMER_OBJECT_SD, Float:drawdistance = STREAMER_OBJECT_DD, bool:ismap = true, STREAMER_TAG_AREA areaid = STREAMER_TAG_AREA -1, priority = 0) {
	//gObjectCountTracker = (Iter_Count(iObjects)+1); // This also serves to reset the variable since last use.

	P:7("[J_Functions] DEBUG: J_CreateDynamicObject function call");

	if(streamdistance == -1.0) { streamdistance = STREAMER_OBJECT_SD; }
	if(drawdistance == -1.0) { drawdistance = 300.0; if(interiorid != 0) { P:0("[J_MapLoaderFuncs]: drawdistance = -1"); } }

	for(new a; a < sizeof(gLongDrawDistance); a++) {
		if(modelid == gLongDrawDistance[a]) {
			streamdistance = 1000.0;
			drawdistance = 1000.0;
			P:7("[J_Functions] Found object that requires a longer draw distance, set as required.");
		}
	}

	// CreateDynamicObject returns the Object ID of the newly created object.
	gObjectIdTracker = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, worldid, interiorid, playerid, streamdistance, drawdistance, STREAMER_TAG_AREA:-1, 0);
	if(interiorid!= 0) {
		P:0("[J_MapLoaderFuncs]: Model (%d), X (%f), Y (%f), Z (%f), Interior ID %d, World ID (%d), playerid (%d), SD (%f), DD (%f), ", modelid, x, y, z, interiorid, worldid, playerid, streamdistance, drawdistance);
	}
	if(!(gObjectIdTracker!= INVALID_OBJECT_ID)) {  // Object did not create successfully
		P:7("[J_Functions] ERROR: Object was not created.");
		return INVALID_OBJECT_ID;
	}
	
	if(ismap) { // If this bool is true, this object was added using J_MapLoader, so it is removed OnFilterScriptExit() of J_MapLoader, not elsewhere.
		gMapObjectData[gMapObjects] = gObjectIdTracker; // Add the Object ID to the Map objects ID storage array at the same index as the Iteration.
		P:7("[J_Functions] DEBUG: J_CreateDynamicObject function parsed successfully with object ID %d, ismap = true, count was %d.", gMapObjectData[gMapObjects], gMapObjects);
		gMapObjects++;
		gObjectIdTracker = INVALID_OBJECT_ID;
		return gObjectIdTracker;
	}

	//Iter_Add(iObjects, gObjectCountTracker); // Add the Object ID returned from CreateDynamicObject() to the Iterator iObjects for referencing.
	gObjectData[gObjects] = gObjectIdTracker; // Add the Object ID to the global 'other' Objects ID storage array at the same index as the Iteration.
	gObjects++;
	P:7("[J_Functions] DEBUG: J_CreateDynamicObject function parsed successfully with object ID %d, ismap = false, count is now %d.", gObjectData[gObjects], gObjects);
	gObjectIdTracker = INVALID_OBJECT_ID;
	return gObjectIdTracker; // This function can return a Object ID, doesn't really matter.
}


J_AddComponentsToVehicle(vehicleid, vidx, bool:ismap, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left) { // Disgusting function - Not sure how to clean this up. I'll work to find a way but the functionality is there!
	if(ismap) {
		P:7("[J_Functions] DEBUG: J_AddComponentsToVehicle called, ismap = true");
		gMapVehicleMods[vidx][0] = Spoiler;
		gMapVehicleMods[vidx][1] = Hood;
		gMapVehicleMods[vidx][2] = Roof;
		gMapVehicleMods[vidx][3] = Sideskirt;
		gMapVehicleMods[vidx][4] = Lamps;
		gMapVehicleMods[vidx][5] = Nitro;
		gMapVehicleMods[vidx][6] = Exhaust;
		gMapVehicleMods[vidx][7] = Wheels;
		gMapVehicleMods[vidx][8] = Stereo;
		gMapVehicleMods[vidx][9] = Hydraulics;
		gMapVehicleMods[vidx][10] = Front_Bumper;
		gMapVehicleMods[vidx][11] = Rear_Bumper;
		gMapVehicleMods[vidx][12] = Vent_Right;
		gMapVehicleMods[vidx][13] = Vent_Left;

		for(new idx; idx < MAX_VEHICLE_COMPONENTS; idx++) {
			AddVehicleComponent(vehicleid, gMapVehicleMods[vidx][idx]);
		}
		return 1;
	}

	P:7("[J_Functions] DEBUG: J_AddComponentsToVehicle called, ismap = false");
	gVehicleMods[vidx][0] = Spoiler;
	gVehicleMods[vidx][1] = Hood;
	gVehicleMods[vidx][2] = Roof;
	gVehicleMods[vidx][3] = Sideskirt;
	gVehicleMods[vidx][4] = Lamps;
	gVehicleMods[vidx][5] = Nitro;
	gVehicleMods[vidx][6] = Exhaust;
	gVehicleMods[vidx][7] = Wheels;
	gVehicleMods[vidx][8] = Stereo;
	gVehicleMods[vidx][9] = Hydraulics;
	gVehicleMods[vidx][10] = Front_Bumper;
	gVehicleMods[vidx][11] = Rear_Bumper;
	gVehicleMods[vidx][12] = Vent_Right;
	gVehicleMods[vidx][13] = Vent_Left;

	for(new idx; idx < MAX_VEHICLE_COMPONENTS; idx++) {
		AddVehicleComponent(vehicleid, gMapVehicleMods[vidx][idx]);
	}
	
	return 1;
}

forward J_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren, interior, bool:ismap, bool:ismodified, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left);
public J_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren, interior, bool:ismap, bool:ismodified, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left) {
	//gVehicleCountTracker = (Iter_Count(iVehicles));
	P:7("[J_Functions] DEBUG: J_CreateVehicle function call");

	gVehicleIdTracker = CreateVehicle(vehicletype, x, y, z, rotation, color1, color2, respawn_delay, addsiren);
	LinkVehicleToInterior(gVehicleIdTracker, interior);
	P:7("J_Functions] DEBUG: J_CreateVehicle ID %d", gVehicleIdTracker);

	if(gVehicleIdTracker == INVALID_VEHICLE_ID) { // Vehicle did not create successfully
		P:7("[J_Functions] ERROR: Vehicle was not created.");
		return INVALID_VEHICLE_ID;
	}

	if(ismodified) {
		P:7("[J_Functions] DEBUG: J_CreateVehicle vehicle id %d is modified.", gMapVehicleData[gVehicles][vehicle_id]);
		if(ismap) {
			J_AddComponentsToVehicle(gVehicleIdTracker, gMapVehicles , ismap, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left);
		}
		else {
			J_AddComponentsToVehicle(gVehicleIdTracker, gVehicles , ismap, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left);
		}
	}

	if(ismap) { // If this bool is true, this vehicle was added using J_MapLoader, so it is removed OnFilterScriptExit() of J_MapLoader, not elsewhere.
		//Iter_Add(iMapVehicles, gVehicleCountTracker+1);
		gMapVehicleData[gMapVehicles][vehicle_id] = gVehicleIdTracker;
		gMapVehicles++;
		P:7("[J_Functions] DEBUG: J_CreateVehicle function parsed successfully with vehicle ID %d, ismap = true, count is now %d.", gVehicleIdTracker, gMapVehicles);
		gVehicleIdTracker = INVALID_VEHICLE_ID;
		return gVehicleIdTracker;
	}

	//Iter_Add(iVehicles, gVehicleCountTracker); // Add to the global iVehicles iterator.
	gVehicleData[gVehicles][vehicle_id] = gVehicleIdTracker;
	gVehicles++;
	P:7("[J_Functions] DEBUG: J_CreateVehicle function parsed successfully with vehicle ID %d, ismap = false, count is now %d.", gVehicleIdTracker, gMapVehicles);
	gVehicleIdTracker = INVALID_VEHICLE_ID;
	return gVehicleIdTracker;

}