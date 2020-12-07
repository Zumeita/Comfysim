
// Directory to store/read each Entrance .ini file.
#define ENTRANCE_FOLDER "J_Core/Entrances"
// Amount of Enterances to read from the file.
#define MAX_ENTRANCES 3
//Max size of the string to format the folder/file directory.
#define MAX_FILE_NAME_LEN 35
#define MAX_ENTRANCE_NAME 35
#define MAX_3DTEXT_LEN 100
//#define INVALID_3DTEXT_ID -1

// Constants to make the script easier to read/understand.
#define ENTRANCE_TYPE_INTERIOR 0
#define ENTRANCE_TYPE_GATE 1
#define ENTRANCE_STATE_CLOSED 0
#define ENTRANCE_STATE_OPEN 1
#define ENTRANCE_FALSE 0
#define ENTRANCE_INSIDE 1
#define ENTRANCE_OUTSIDE 0

#define TEXT_COLOUR 0xCCCCCCAA
#define TEXT_DRAW_DISTANCE 10.5
#define INTERIOR_ENTRANCE_TEXT "{CCCCCC}%s\n{CCCCCC}Press '{FFFFFF}~k~CONVERSATION_YES~{CCCCCC}' to enter"
#define INTERIOR_EXIT_TEXT "{CCCCCC}%s\n{CCCCCC}Press '{FFFFFF}~k~CONVERSATION_YES~{CCCCCC}' to exit"
#define GATE_TEXT "{CCCCCC}%s\n{CCCCCC}Press '{FFFFFF}~k~CONVERSATION_YES~{CCCCCC}' to open"
	
//Enumerator for gEntData array.
enum ENTRANCE_DATA {
	Float:ex, Float:ey, Float:ez, Float:er, e_interior,
	Float:ex2, Float:ey2, Float:ez2, Float:er2, e_interior2,
	Float:trigger_distance, vehicles_allowed, type, speed,
	Float:ox, Float:oy, Float:oz, Float:orx, Float:ory, Float:orz,
	Float:cx, Float:cy, Float:cz, Float:crx, Float:cry, Float:crz,
	e_object_model, e_objectid, open_time, open_state, ename[MAX_ENTRANCE_NAME], ecolour, Text3D:enter_text_id, Text3D:exit_text_id
}

new gEntData[MAX_ENTRANCES][ENTRANCE_DATA];

// Used to track if a player is near an entrance or not.
new pEntData[PLAYERS] = ENTRANCE_FALSE;

new gEntranceTemplateType[] = { // 0 = Float, 1 = Integer, 2 = String
	2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ENTRANCE_TYPE_INTERIOR, 1, 2, 1, 1
};

new gEntranceTemplate[][] = {
	"reference_name", "x", "y", "z", "r", "interior", "x2", "y2", "z2", "r2", "interior2",
	"trigger_distance", "vehicles_allowed", "speed",
	"ox", "oy", "oz", "orx", "ory", "orz", "cx", "cy", "cz", "crx", "cry", "crz",
	"object_model", "object_mode", "object_time", "name", "3dtext"
};


stock EntranceTemplate(file_name[])
{

	printf("[DEBUG]: Setting up Entrance template for '%s'", file_name);
	
	for(new idx; idx < sizeof(gEntranceTemplate); idx++)
	{
		switch(gEntranceTemplateType[idx])
		{
		    case 0: // Float
			{
		        dini_FloatSet(file_name, gEntranceTemplate[idx], 0.0);
		        printf("[DEBUG]: Template - '%s' set to (0.0)", gEntranceTemplate[idx]);
			}
			case 1: // Integer
			{
			    dini_IntSet(file_name, gEntranceTemplate[idx], 0);
			    printf("[DEBUG]: Template - '%s' set to (0)", gEntranceTemplate[idx]);
			}
			case 2: // String
            {
			    dini_Set(file_name, gEntranceTemplate[idx], ""); // Empty string = no 3D Text.
			    printf("[DEBUG]: Template - '%s' set to (0)", gEntranceTemplate[idx]);
			}
		}
	}
	return 1;
}

// Function used to load entrances from the files, called OnGameModeInit()
stock LoadEntrances() {
	new file_name[MAX_FILE_NAME_LEN];
	for(new idx; idx < MAX_ENTRANCES; idx++) {
	
	    format(file_name, MAX_FILE_NAME_LEN, "%s/entrance_%d.ini", ENTRANCE_FOLDER, idx);
        printf("[DEBUG] Loading entrance from '%s' (%d).", file_name, idx);

    	if(!dini_Exists(file_name)) {
		    if(dini_Create(file_name)) {
		        printf("[DEBUG] File '%s' successfully created.", file_name);
		        EntranceTemplate(file_name);
			}
			else {
			    printf("[DEBUG] Unable to create file '%s'", file_name);
				break;
			}
		}

		gEntData[idx][ex] = dini_Float(file_name, "x");
		gEntData[idx][ey] = dini_Float(file_name, "y");
		gEntData[idx][ez] = dini_Float(file_name, "z");
		gEntData[idx][er] = dini_Float(file_name, "r");
		gEntData[idx][e_interior] = dini_Int(file_name, "interior");
		gEntData[idx][ex2] = dini_Float(file_name, "x2");
		gEntData[idx][ey2] = dini_Float(file_name, "y2");
		gEntData[idx][ez2] = dini_Float(file_name, "z2");
		gEntData[idx][er2] = dini_Float(file_name, "r2");
		gEntData[idx][e_interior2] = dini_Int(file_name, "interior2");
		gEntData[idx][trigger_distance] = dini_Float(file_name, "trigger_distance");
		gEntData[idx][vehicles_allowed] = dini_Int(file_name, "vehicles_allowed");
		gEntData[idx][speed] = dini_Int(file_name, "speed");
		gEntData[idx][ox] = dini_Float(file_name, "ox");
		gEntData[idx][oy] = dini_Float(file_name, "oy");
		gEntData[idx][oz] = dini_Float(file_name, "oz");
		gEntData[idx][orx] = dini_Float(file_name, "orx");
		gEntData[idx][ory] = dini_Float(file_name, "ory");
		gEntData[idx][orz] = dini_Float(file_name, "orz");
		gEntData[idx][cx] = dini_Float(file_name, "cx");
		gEntData[idx][cy] = dini_Float(file_name, "cy");
		gEntData[idx][cz] = dini_Float(file_name, "cz");
		gEntData[idx][crx] = dini_Float(file_name, "crx");
		gEntData[idx][crz] = dini_Float(file_name, "cry");
		gEntData[idx][crz] = dini_Float(file_name, "cry");
		gEntData[idx][e_object_model] = dini_Int(file_name, "object_model");
		gEntData[idx][open_time] = dini_Int(file_name, "object_time");
		gEntData[idx][open_state] = 0;
		format(gEntData[idx][ename], MAX_3DTEXT_LEN, dini_Get(file_name, "name"));
		
		if(!dini_Int(file_name, "3dtext")) { // no 3D Text for this entrance
		    //gEntData[idx][enter_text_id] = INVALID_3DTEXT_ID;
		    //gEntData[idx][exit_text_id] = INVALID_3DTEXT_ID;
		}
		else {
		    new string[MAX_3DTEXT_LEN];
		    if(gEntData[idx][e_object_model] == INVALID_OBJECT_ID) {
				format(string, MAX_3DTEXT_LEN, INTERIOR_ENTRANCE_TEXT, gEntData[idx][ename]);
				gEntData[idx][enter_text_id] = Create3DTextLabel(string, TEXT_COLOUR, gEntData[idx][ex], gEntData[idx][ey], gEntData[idx][ez], TEXT_DRAW_DISTANCE, 0, 1);
		  		format(string, MAX_3DTEXT_LEN, INTERIOR_EXIT_TEXT, gEntData[idx][ename]);
				gEntData[idx][exit_text_id] = Create3DTextLabel(string, TEXT_COLOUR, gEntData[idx][ex2], gEntData[idx][ey2], gEntData[idx][ez2], TEXT_DRAW_DISTANCE, 0, 1);
			}
			else {
			    format(string, MAX_3DTEXT_LEN, GATE_TEXT, gEntData[idx][ename]);
				gEntData[idx][enter_text_id] = Create3DTextLabel(string, TEXT_COLOUR, gEntData[idx][ox], gEntData[idx][oy], gEntData[idx][oz], TEXT_DRAW_DISTANCE, 0, 1);
			}
		}
		
		if(gEntData[idx][e_object_model] != -1) {
		    gEntData[idx][type] = ENTRANCE_TYPE_GATE;
		    gEntData[idx][e_objectid] = CreateObject(gEntData[idx][e_object_model], gEntData[idx][cx], gEntData[idx][cy], gEntData[idx][cz], gEntData[idx][crx], gEntData[idx][cry], gEntData[idx][crz], 250.0);
		}
		else {
			gEntData[idx][type] = ENTRANCE_TYPE_INTERIOR;
			gEntData[idx][e_objectid] = INVALID_OBJECT_ID;
		}
		
		printf("[DEBUG]: Loaded entrance '%s' with ID (%d) sucessfully!", dini_Get(file_name, "reference_name"), idx);
	}
	
	
	return 1;
}

hook OnGameModeInit() {
	LoadEntrances();
	return 1;
}

hook OnPlayerConnect(playerid) {
	pEntData[playerid] = ENTRANCE_FALSE;
	return 1;
}

hook OnPlayerDisconnect(playerid) {
	pEntData[playerid] = ENTRANCE_FALSE;
	return 1;
}

stock IsPlayerInAnyEntrance(playerid) {
	printf("[DEBUG] IsPlayerInAnyEntrance(%d) called.", playerid);
	
	new Float:x, Float:y, Float:z, interior, Float:distance, vehicleid = INVALID_VEHICLE_ID, ret = ENTRANCE_FALSE;
	
	for(new entranceid; entranceid < MAX_ENTRANCES; entranceid++) {
		if(gEntData[entranceid][vehicles_allowed] == 1) { // Allowed with vehicle and is IN a vehicle.
		    if(IsPlayerInAnyVehicle(playerid)) {
			    vehicleid = GetPlayerVehicleID(playerid);
			    GetVehiclePos(vehicleid, x, y, z);
			}
			else {
				GetPlayerPos(playerid, x, y, z);
			}
		}
		else {
		    if(IsPlayerInAnyVehicle(playerid)) {
		        ret = ENTRANCE_FALSE;
				break; // Move onto the next one. Cannot use this entrance even if position was correct.
			}
			else {
			    GetPlayerPos(playerid, x, y, z);
			}
		}

		interior = GetPlayerInterior(playerid);
		distance = GetDistBetweenTwoPoints(x, y, z, gEntData[entranceid][ex], gEntData[entranceid][ey], gEntData[entranceid][ez]);

		if(distance <= gEntData[entranceid][trigger_distance] && interior == gEntData[entranceid][e_interior]) {
			if(gEntData[entranceid][type] != ENTRANCE_TYPE_GATE) {
				pEntData[playerid] = ENTRANCE_OUTSIDE;
		    	ret = entranceid;
			}
		}
		else {
		    distance = GetDistBetweenTwoPoints(x, y, z, gEntData[entranceid][ex2], gEntData[entranceid][ey2], gEntData[entranceid][ez2]);
		    if(distance <= gEntData[entranceid][trigger_distance] && interior == gEntData[entranceid][e_interior2]) {
                if(gEntData[entranceid][type] != ENTRANCE_TYPE_GATE) {
					pEntData[playerid] = ENTRANCE_INSIDE;
			    	ret = entranceid;
				}
			}
		}
		printf("[DEBUG] IsPlayerInAnyEntrance(%d) returning entranceid (%d) [1-2 = In entrance, 0 = Not]", playerid, ret);
		ret = entranceid;
	}
	return ret;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES) {
	    new entranceid = IsPlayerInAnyEntrance(playerid);
	    
	    if(entranceid == ENTRANCE_FALSE) {
            printf("[DEBUG] OnPlayerKeyState(%d) - Not near any entrance!", playerid);
			return 1;
		} // Not near any entrances.
		
	    else {
	        if(gEntData[entranceid][type] == ENTRANCE_TYPE_GATE) {
	            printf("[DEBUG] OnPlayerKeyStateChange(%d), entranceid (%d) is type GATE", playerid, entranceid);
	            if(gEntData[entranceid][open_state] == ENTRANCE_STATE_CLOSED) {
	            	MoveObject(gEntData[entranceid][e_objectid], gEntData[entranceid][ox], gEntData[entranceid][oy], gEntData[entranceid][oz], gEntData[entranceid][speed], gEntData[entranceid][orx], gEntData[entranceid][ory], gEntData[entranceid][orz]);
					gEntData[entranceid][open_state] = ENTRANCE_STATE_OPEN;
					SetTimerEx("CloseEntrance", gEntData[entranceid][open_time], 0, "%d", entranceid);
				}
			}
			else { // Interior entrance
			    printf("[DEBUG] OnPlayerKeyStateChange(%d), entranceid (%d) is type INTERIOR", playerid, entranceid);
				if(IsPlayerInAnyVehicle(playerid) && gEntData[entranceid][vehicles_allowed] == 1) {
				    new vehicleid = GetPlayerVehicleID(playerid);
					switch(pEntData[playerid]) {
					    case ENTRANCE_OUTSIDE: {
					        SetVehiclePos(vehicleid, gEntData[entranceid][ex2], gEntData[entranceid][ey2], gEntData[entranceid][ez2]);
					        SetVehicleZAngle(vehicleid, gEntData[entranceid][er2]);
							LinkVehicleToInterior(vehicleid, gEntData[entranceid][e_interior2]);
							SetPlayerInterior(playerid, gEntData[entranceid][e_interior2]);
					        pEntData[playerid] = ENTRANCE_FALSE;
						}
						case ENTRANCE_INSIDE: {
						    SetVehiclePos(vehicleid, gEntData[entranceid][ex], gEntData[entranceid][ey], gEntData[entranceid][ez]);
					        SetVehicleZAngle(vehicleid, gEntData[entranceid][er]);
					        LinkVehicleToInterior(vehicleid, gEntData[entranceid][e_interior]);
					        SetPlayerInterior(playerid, gEntData[entranceid][e_interior]);
					        pEntData[playerid] = ENTRANCE_FALSE;
						}
					}
				}
				else {
				    switch(pEntData[playerid]) {
					    case ENTRANCE_OUTSIDE: {
					        SetPlayerPos(playerid, gEntData[entranceid][ex2], gEntData[entranceid][ey2], gEntData[entranceid][ez2]);
					        SetPlayerFacingAngle(playerid, gEntData[entranceid][er2]);
							SetPlayerInterior(playerid, gEntData[entranceid][e_interior2]);
					        pEntData[playerid] = ENTRANCE_FALSE;
						}
						case ENTRANCE_INSIDE: {
						    SetPlayerPos(playerid, gEntData[entranceid][ex], gEntData[entranceid][ey], gEntData[entranceid][ez]);
					        SetPlayerFacingAngle(playerid, gEntData[entranceid][er]);
					        SetPlayerInterior(playerid, gEntData[entranceid][e_interior]);
					        pEntData[playerid] = ENTRANCE_FALSE;
						}
					}
				}
			}
		}
	}
	
	return 1;
}

forward CloseEntrance(entranceid);
public CloseEntrance(entranceid)
{
	MoveObject(gEntData[entranceid][e_objectid], gEntData[entranceid][cx], gEntData[entranceid][cy], gEntData[entranceid][cz], gEntData[entranceid][speed], gEntData[entranceid][crx], gEntData[entranceid][cry], gEntData[entranceid][crz]);
	gEntData[entranceid][open_state] = ENTRANCE_STATE_CLOSED;
	printf("[DEBUG] CloseEntrance(%d) called", entranceid);
					
	return 1;
}

