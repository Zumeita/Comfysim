
#define _DEBUG 7 // Comment out to disable console print debugging

#include <a_samp>
#include <YSI\YSI_Coding\y_hooks>
#include <YSI\YSI_Core\y_debug>
//#include <streamer> // Included above J_Functions as that script redefines CreateDynamicObject().
#include <Comfysim\J_Functions> // This is needed for J_CreateDynamicObject & J_CreateVehicle functions.
#include "C:\Users\Joe\Desktop\SAMP_Workbench\Comfysim\Maps\example_map.inc" // I hate this but relative paths don't seem to be working with the new compiler + Sublime Text editor ?? Should be '..\etc\etc' where '..\' == ROOT DIRECTORY



hook OnFilterScriptInit() {
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
