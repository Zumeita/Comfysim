/*
	Functions used throughout the Comfysim scripts will be stored here as a central repository / include.

	This needs to be <included> below <streamer> as this script redefines CreateDynamicObject()
*/

// Includes (To be changed)
/*#define _DEBUG 7 // Comment out to disable console print debugging

#include <a_samp>
#include <streamer>
#include <YSI\YSI_Coding\y_hooks>
#include <YSI\YSI_Core\y_debug>
#include <YSI\YSI_Data\y_foreach>*/

// Constants
#define MAX_VEHICLE_COMPONENTS 14
#define MAX_REMOVED_OBJECTS 300

enum E_VEHICLE_DATA {
	vehicle_id, colour1, colour2
}

enum E_REMOVED_OBJECTS_DATA {
	rm_modelid, rm_lodmodel,
	Float:rmx, Float:rmy, Float:rmz, Float:rm_radius
}

// Iterators
new //Iterator:iMapObjects<MAX_OBJECTS>, // Tracks map objects created by J_CreateDynamicObject
	gMapObjectData[MAX_OBJECTS],
	gMapObjects,
	//Iterator:iObjects<MAX_OBJECTS>, // Tracks all other objects created in other scripts
	gObjectData[MAX_OBJECTS],
	gObjects,
	//Iterator:iMapVehicles<MAX_VEHICLES>, // Tracks vehicles created by J_CreateVehicle
	gMapVehicleData[MAX_VEHICLES][E_VEHICLE_DATA],
	gMapVehicleMods[MAX_VEHICLES][MAX_VEHICLE_COMPONENTS],
	gMapVehicles,
	//Iterator:iVehicles<MAX_VEHICLES>, // Tracks all other vehicles created in other scripts
	gVehicleData[MAX_VEHICLES][E_VEHICLE_DATA],
	gVehicleMods[MAX_VEHICLES][MAX_VEHICLE_COMPONENTS],
	gVehicles,

	gRemovedObjectData[MAX_REMOVED_OBJECTS][E_REMOVED_OBJECTS_DATA],
	gRemovedObjects,

	gObjectIdTracker = INVALID_OBJECT_ID,
	gVehicleIdTracker = INVALID_VEHICLE_ID
	//gObjectCountTracker,
	//gVehicleCountTracker
;

// Function redefinitions
/*#if defined CreateDynamicObject // So we can use CreateDynamicObject straight from a converter without having to change to J_CreateDynamicObject
	#undef CreateDynamicObject
#endif
#define CreateDynamicObject J_CreateDynaimcObject*/



// Functions

/*hook OnFilterScriptInit() { // Initialize the Iterators as they are multi-dimensional.
	Iter_Init(iMapObjects);
	Iter_Init(iObjects);
	Iter_Init(iMapVehicles);
	Iter_Init(iVehicles);
	return 1;
}
*/

#include <streamer>

/* gRemovedObjectId[MAX_REMOVED_OBJECTS],
	gRemovedObjects,
	*/

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

	P:4("[J_Functions] DEBUG: J_CreateDynamicObject function call");

	if(streamdistance == -1.0) { streamdistance = STREAMER_OBJECT_SD; }
	if(drawdistance == -1.0) { drawdistance = STREAMER_OBJECT_DD; }

	// CreateDynamicObject returns the Object ID of the newly created object.
	gObjectIdTracker = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, worldid, interiorid, playerid, streamdistance, drawdistance, STREAMER_TAG_AREA:-1, 0);
	if(!(gObjectIdTracker!= INVALID_OBJECT_ID)) {  // Object did not create successfully
		P:4("[J_Functions] ERROR: Object was not created.");
		return INVALID_OBJECT_ID;
	}
	
	if(ismap) { // If this bool is true, this object was added using J_MapLoader, so it is removed OnFilterScriptExit() of J_MapLoader, not elsewhere.
		gMapObjectData[gMapObjects] = gObjectIdTracker; // Add the Object ID to the Map objects ID storage array at the same index as the Iteration.
		P:4("[J_Functions] DEBUG: J_CreateDynamicObject function parsed successfully with object ID %d, ismap = true, count was %d.", gMapObjectData[gMapObjects], gMapObjects);
		gMapObjects++;
		gObjectIdTracker = INVALID_OBJECT_ID;
		return gObjectIdTracker;
	}

	//Iter_Add(iObjects, gObjectCountTracker); // Add the Object ID returned from CreateDynamicObject() to the Iterator iObjects for referencing.
	gObjectData[gObjects] = gObjectIdTracker; // Add the Object ID to the global 'other' Objects ID storage array at the same index as the Iteration.
	gObjects++;
	P:4("[J_Functions] DEBUG: J_CreateDynamicObject function parsed successfully with object ID %d, ismap = false, count is now %d.", gObjectData[gObjects], gObjects);
	gObjectIdTracker = INVALID_OBJECT_ID;
	return gObjectIdTracker; // This function can return a Object ID, doesn't really matter.
}


J_AddComponentsToVehicle(vehicleid, vidx, bool:ismap, Spoiler, Hood, Roof, Sideskirt, Lamps, Nitro, Exhaust, Wheels, Stereo, Hydraulics, Front_Bumper, Rear_Bumper, Vent_Right, Vent_Left) { // Disgusting function - Not sure how to clean this up. I'll work to find a way but the functionality is there!
	if(ismap) {
		P:4("[J_Functions] DEBUG: J_AddComponentsToVehicle called, ismap = true");
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

	P:4("[J_Functions] DEBUG: J_AddComponentsToVehicle called, ismap = false");
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
	P:4("[J_Functions] DEBUG: J_CreateVehicle function call");

	gVehicleIdTracker = CreateVehicle(vehicletype, x, y, z, rotation, color1, color2, respawn_delay, addsiren);
	LinkVehicleToInterior(gVehicleIdTracker, interior);
	P:4("J_Functions] DEBUG: J_CreateVehicle ID %d", gVehicleIdTracker);

	if(gVehicleIdTracker == INVALID_VEHICLE_ID) { // Vehicle did not create successfully
		P:4("[J_Functions] ERROR: Vehicle was not created.");
		return INVALID_VEHICLE_ID;
	}

	if(ismodified) {
		P:4("[J_Functions] DEBUG: J_CreateVehicle vehicle id %d is modified.", gMapVehicleData[gVehicles][vehicle_id]);
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
		P:4("[J_Functions] DEBUG: J_CreateVehicle function parsed successfully with vehicle ID %d, ismap = true, count is now %d.", gVehicleIdTracker, gMapVehicles);
		gVehicleIdTracker = INVALID_VEHICLE_ID;
		return gVehicleIdTracker;
	}

	//Iter_Add(iVehicles, gVehicleCountTracker); // Add to the global iVehicles iterator.
	gVehicleData[gVehicles][vehicle_id] = gVehicleIdTracker;
	gVehicles++;
	P:4("[J_Functions] DEBUG: J_CreateVehicle function parsed successfully with vehicle ID %d, ismap = false, count is now %d.", gVehicleIdTracker, gMapVehicles);
	gVehicleIdTracker = INVALID_VEHICLE_ID;
	return gVehicleIdTracker;

}

forward Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2);
public Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower(floatabs(floatsub(x, x2)),2)+floatpower(floatabs(floatsub(y, y2)),2)+floatpower(floatabs(floatsub(z, z2)),2));
}
