
#include <a_samp>
#include <gvar>

#if !defined _FCNPC_included
	#tryinclude <FCNPC>
#endif

#if !defined _FCNPC_included
	#tryinclude "FCNPC"
#endif

#if !defined _FCNPC_includeds
	#tryinclude "../FCNPC"
#endif

#if !defined _FCNPC_included
	#error Add FCNPC.inc to your scripts directory
#endif

#define COLOR_STANDARD_NPC						0xffffffff

#define MAX_AI 7

#define MAX_AIRPORTS 5
#define AIRPORT_LS 0
#define AIRPORT_SF 1
#define AIRPORT_LV 2
#define CHILLIAD_DOWN 3
#define CHILLIAD_UP 4

enum AI_DATA {t
	id,
	vehicle_model,
	vehicle_id,
	skinid,h
	cycles,
	start_cycle,
	cc1,
	cc2
}

new AI[MAX_AI][AI_DATA] = {
	{INVALID_PLAYER_ID, 577, INVALID_VEHICLE_ID, 69, 3, 0, 1, 1},
	{INVALID_PLAYER_ID, 577, INVALID_VEHICLE_ID, 69, 3, 1, 1, 1},
	{INVALID_PLAYER_ID, 519, INVALID_VEHICLE_ID, 69, 3, 2, 1, 1},
	{INVALID_PLAYER_ID, 487, INVALID_VEHICLE_ID, 69, 2, 0, 1, 1}, // Only 2 recordings for chilliad chopper.
	{INVALID_PLAYER_ID, 487, INVALID_VEHICLE_ID, 69, 2, 1, 1, 1},
	//{INVALID_PLAYER_ID, 400, INVALID_VEHICLE_ID, 69, 2, 0, 51, 51}, // Chilliad Jeep
	{INVALID_PLAYER_ID, 437, INVALID_VEHICLE_ID, 161, 1, 0, 1, 1}, // Chilliad Bus
	{INVALID_PLAYER_ID, 512, INVALID_VEHICLE_ID, 161, 1, 0, 1, 1} // Cropduster airfield TNG.
};

new AI_Name[MAX_AI][MAX_PLAYER_NAME] = {
	{"AI_AT400_ONE"},
	{"AI_AT400_TWO"},
	{"AI_SHAMAL_ONE"},
	{"AI_CHILLIAD_HELI"},
	{"AI_CHILLIAD_HELI_TWO"},
	//{"AI_CHILLIAD_JEEP_ONE"},
	{"AI_CHILLIAD_BUS"},
	{"AI_CROPDUSTER"}
};

new gPlaybackCycle[MAX_AI] = {0, ...};



public OnFilterScriptInit()
{
	for(new idx = 0; idx < MAX_AIRPORTS; idx++) {
	    SetAirportUnoccupied(idx); // Set all airports unoccupied.
	 }

	for(new idx = 0; idx < MAX_AI; idx++) {
		printf("IDX: %d", idx);
	    AI[idx][vehicle_id] = CreateVehicle(AI[idx][vehicle_model], 0.0, 0.0, 0.0, 0.0, AI[idx][cc1], AI[idx][cc2], 0);
	    AI[idx][id] = FCNPC_Create(AI_Name[idx]);
	    printf("[AI DEBUG]: AI (%d) vehicle ID Created is (%d), model var (%d)", AI[idx][id], AI[idx][vehicle_id], AI[idx][vehicle_model]);
	    
	    if(AI[idx][id] != INVALID_PLAYER_ID && AI[idx][vehicle_id] != INVALID_VEHICLE_ID)
	    {
	        FCNPC_Spawn(AI[idx][id], AI[idx][skinid], 0.0, 0.0, 0.0);
	        FCNPC_SetInvulnerable(AI[idx][id], true);
	        SetPlayerColor(AI[idx][id], COLOR_STANDARD_NPC);
	        FCNPC_PutInVehicle(AI[idx][id], AI[idx][vehicle_id], 0);
	        
	        gPlaybackCycle[idx] = AI[idx][start_cycle];
	        /*if(idx > AI[idx][cycles]) {
	            gPlaybackCycle[idx] = 0;
			}
			else {
	        	gPlaybackCycle[idx] = idx;
			}*/
	        NextPlayback(idx);
		}
	}

	SetTimer("DebugPrint", 10000, 0);
	
	return 1;
}

forward DebugPrint();
public DebugPrint()
{
	print("-------------------------------------------------------------------------");
	print("AI_Controller initialized successfully, below is some information:");
	printf("AI Loaded: %d, Vehicles Loaded: %d", sizeof(AI), sizeof(AI));
	new ainame[MAX_PLAYER_NAME];
	for(new idx = 0; idx < MAX_AI; idx++) {
	    GetPlayerName(AI[idx][id], ainame, MAX_PLAYER_NAME);
	    printf("AI '%s' (%d) connected, using vehicle ID (%d)", ainame, AI[idx][id], AI[idx][vehicle_id]);
	}
	print("-------------------------------------------------------------------------");
	return 1;
}

public OnFilterScriptExit()
{
	for(new idx = 0; idx < MAX_AI; idx++)
	{
	    FCNPC_StopPlayingPlayback(AI[idx][vehicle_id]);
	    DestroyVehicle(AI[idx][vehicle_id]);
	    AI[idx][vehicle_id] = INVALID_VEHICLE_ID;
	    FCNPC_Destroy(AI[idx][id]);
	    AI[idx][id] = INVALID_PLAYER_ID;
	    gPlaybackCycle[idx] = 0;
	}
	return 1;
}

public FCNPC_OnFinishPlayback(npcid)
{
	for(new idx = 0; idx < MAX_AI; idx++)
	{
	    if(npcid == AI[idx][id])
	    {
	        new ainame[MAX_PLAYER_NAME];
			GetPlayerName(npcid, ainame, MAX_PLAYER_NAME);
			printf("[AI DEBUG]: AI '%s' (%d) OnFinishPlayback(%d) called, will attempt to play next recording...", ainame, npcid, npcid);
	        NextPlayback(idx);
		}
	}
	return 1;
}

public FCNPC_OnVehicleTakeDamage(npcid, issuerid, vehicleid, Float:amount, weaponid, Float:fX, Float:fY, Float:fZ)
{
	for(new idx = 0; idx < MAX_AI; idx++)
	{
	    if(npcid == AI[idx][id])
	    {
	        return 0;
		}
	}
	
	return 1;
}

forward TryAgain(index);
public TryAgain(index)
{
    new ainame[MAX_PLAYER_NAME];
	GetPlayerName(AI[index][id], ainame, MAX_PLAYER_NAME);
	printf("[AI DEBUG]: AI '%s' (%d) TryAgain(%d) called, will try...", ainame, AI[index][id], index);
	NextPlayback(index);
	return 1;
}

NextPlayback(index)
{
	new ainame[MAX_PLAYER_NAME];
	GetPlayerName(AI[index][id], ainame, MAX_PLAYER_NAME);
	printf("[AI DEBUG]: AI '%s' (%d) NextPlayback(%d) called", ainame, AI[index][id], index);
	
	if(gPlaybackCycle[index] >= AI[index][cycles]) {
	    gPlaybackCycle[index] = 0;
	}
	
	if(AI[index][vehicle_model] == 577) // AT-400
	{
		switch(gPlaybackCycle[index])
		{
		    case 0:
			{ // Los Santos Airport
		        if(GetAirportOccupied(AIRPORT_LS) != 1)
				{
			        FCNPC_StartPlayingPlayback(AI[index][id], "at400_ls_to_sf");
					SetAirportOccupied(AIRPORT_LS);
					SetAirportUnoccupied(AIRPORT_LV);
					printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Los Santos), LS = (%d), LV = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				}
				else
				{
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Los Santos), LS = (%d), LV = (%d), Airport blocked, try again in 10 seconds...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				    SetTimerEx("TryAgain", 20000, 0, "d", index);
				}
			}
			case 1:
			{ // San Fierro Airport
			    if(GetAirportOccupied(AIRPORT_SF) != 1)
				{
				    FCNPC_StartPlayingPlayback(AI[index][id], "at400_sf_to_lv");
				    SetAirportOccupied(AIRPORT_SF);
				    SetAirportUnoccupied(AIRPORT_LS);
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (San Fierro), SF = (%d), LS = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_SF), GetAirportOccupied(AIRPORT_LS));
				}
				else
				{
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (San Fierro), LS = (%d), LV = (%d), Airport blocked, try again in 10 seconds...", ainame,AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				    SetTimerEx("TryAgain", 20000, 0, "d", index);
				}
			}
			case 2:
			{ // Las Venturas Airport
				if(GetAirportOccupied(AIRPORT_LV) != 1)
				{
		            FCNPC_StartPlayingPlayback(AI[index][id], "at400_lv_to_ls");
		            SetAirportOccupied(AIRPORT_LV);
		            SetAirportUnoccupied(AIRPORT_SF);
		            printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Las Venturas), LV = (%d), SF = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LV), GetAirportOccupied(AIRPORT_SF));
				}
				else
				{
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Las Venturas), LS = (%d), LV = (%d), Airport blocked, try again in 10 seconds...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				    SetTimerEx("TryAgain", 20000, 0, "d", index);
				}
			}
		}
	}
	else if(AI[index][vehicle_model] == 519) // Shamal
	{
	    switch(gPlaybackCycle[index]) {
		    case 0: { // Los Santos Airport
		        if(GetAirportOccupied(AIRPORT_LS) != 1) {
			        FCNPC_StartPlayingPlayback(AI[index][id], "shamal_ls_to_sf");
					SetAirportOccupied(AIRPORT_LS);
					SetAirportUnoccupied(AIRPORT_LV);
					printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Los Santos), LS = (%d), LV = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				}
				else {
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Los Santos), LS = (%d), LV = (%d), Airport blocked, try again in 10 seconds...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				    SetTimerEx("TryAgain", 20000, 0, "d", index);
				}
			}
			case 1: { // San Fierro Airport
			    if(GetAirportOccupied(AIRPORT_SF) != 1) {
				    FCNPC_StartPlayingPlayback(AI[index][id], "shamal_sf_to_lv");
				    SetAirportOccupied(AIRPORT_SF);
				    SetAirportUnoccupied(AIRPORT_LS);
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (San Fierro), SF = (%d), LS = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_SF), GetAirportOccupied(AIRPORT_LS));
				}
				else {
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (San Fierro), LS = (%d), LV = (%d), Airport blocked, try again in 10 seconds...", ainame,AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				    SetTimerEx("TryAgain", 20000, 0, "d", index);
				}
			}
			case 2: { // Las Venturas Airport
				if(GetAirportOccupied(AIRPORT_LV) != 1) {
		            FCNPC_StartPlayingPlayback(AI[index][id], "shamal_lv_to_ls");
		            SetAirportOccupied(AIRPORT_LV);
		            SetAirportUnoccupied(AIRPORT_SF);
		            printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Las Venturas), LV = (%d), SF = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LV), GetAirportOccupied(AIRPORT_SF));
				}
				else {
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Las Venturas), LS = (%d), LV = (%d), Airport blocked, try again in 10 seconds...", ainame, AI[index][id], GetAirportOccupied(AIRPORT_LS), GetAirportOccupied(AIRPORT_LV));
				    SetTimerEx("TryAgain", 20000, 0, "d", index);
				}
			}
		}
	}
	else if(AI[index][vehicle_model] == 487) // Maverick
	{
	    switch(gPlaybackCycle[index]) {
	        case 0: { // Bottom of Chilliad
	            if(GetAirportOccupied(CHILLIAD_UP) != 1) {
	            	FCNPC_StartPlayingPlayback(AI[index][id], "chilliad_heli_up");
                    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Chilliad_Bottom_To_Top), Up = (%d), Down = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(CHILLIAD_UP), GetAirportOccupied(CHILLIAD_DOWN));
				}
				else {
					SetTimerEx("TryAgain", 10000, 0, "d", index);
					printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Chilliad_Bottom_To_Top), Up = (%d), Down = (%d), Airport blocked, try again in 10 seconds...", ainame, AI[index][id], GetAirportOccupied(CHILLIAD_UP), GetAirportOccupied(CHILLIAD_DOWN));
				}
			}
			case 1: {
				if(GetAirportOccupied(CHILLIAD_DOWN) != 1) { // Top of Chilliad
                	FCNPC_StartPlayingPlayback(AI[index][id], "chilliad_heli_down");
                	printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Chilliad_Top_To_Bottom), Up = (%d), Down = (%d), playback starting...", ainame, AI[index][id], GetAirportOccupied(CHILLIAD_UP), GetAirportOccupied(CHILLIAD_DOWN));
				}
				else {
				    printf("[AI DEBUG]: AI '%s' (%d) Cycle = (Chilliad_Top_To_Bottom), Up = (%d), Down = (%d), Airport blocked, try again in 10 seconds...", ainame, AI[index][id], GetAirportOccupied(CHILLIAD_UP), GetAirportOccupied(CHILLIAD_DOWN));
				    SetTimerEx("TryAgain", 1000, 0, "d", index);
				}
			}
		}
	}
	else if(AI[index][vehicle_model] == 400) // Landstalker (Jeep)
	{
	    switch(gPlaybackCycle[index]) {
	        case 0: {// Bottom of Chilliad
	            FCNPC_StartPlayingPlayback(AI[index][id], "chilliad_jeep_up");
			}
			case 1: {//Top of Chilliad
			    FCNPC_StartPlayingPlayback(AI[index][id], "chilliad_jeep_down");
			}
		}
	}
	else if(AI[index][vehicle_model] == 437) // Chilliad Coach
	{
	    switch(gPlaybackCycle[index]) {
	        case 0: {// Bottom of Chilliad
	            FCNPC_StartPlayingPlayback(AI[index][id], "chilliad_bus2");
			}
		}
	}
	else if(AI[index][vehicle_model] == 512) // Cropduster
	{
	    switch(gPlaybackCycle[index]) {
	        case 0: {
	            FCNPC_StartPlayingPlayback(AI[index][id], "cropduster");
			}
		}
	}
	
	
	gPlaybackCycle[index]++;

	if(gPlaybackCycle[index] >= AI[index][cycles]) {
	    gPlaybackCycle[index] = 0;
	}
}


stock SetAirportUnoccupied(airportid)
{
	switch(airportid) {
	    case AIRPORT_LS: { // 0
	        SetGVarInt("AI_LSAP", 0, 0);
		}
		case AIRPORT_SF: { // 1
			SetGVarInt("AI_SFAP", 0, 1);
		}
		case AIRPORT_LV: { // 2
		    SetGVarInt("AI_LVAP", 0, 2);
		}
		case CHILLIAD_DOWN: { //3
		    SetGVarInt("CH_DN", 0, 3);
		}
		case CHILLIAD_UP: {  //4
		    SetGVarInt("CH_UP", 0, 4);
		}
	}
	return 1;
}

stock SetAirportOccupied(airportid)
{
	switch(airportid) {
	    case AIRPORT_LS: { // 0
	        SetGVarInt("AI_LSAP", 1, 0);
		}
		case AIRPORT_SF: { // 1
			SetGVarInt("AI_SFAP", 1, 1);
		}
		case AIRPORT_LV: { // 21
		    SetGVarInt("AI_LVAP", 1, 2);
		}
		case CHILLIAD_DOWN: { //3
		    SetGVarInt("CH_DN", 1, 3);
		}
		case CHILLIAD_UP: {  //4
		    SetGVarInt("CH_UP", 1, 4);
		}
	}
	return 1;
}

stock GetAirportOccupied(airportid)
{
	new r = -1;

	switch(airportid) {
	    case AIRPORT_LS: { // 0
	        r = GetGVarInt("AI_LSAP", 0);
		}
		case AIRPORT_SF: { // 1
			r = GetGVarInt("AI_SFAP", 1);
		}
		case AIRPORT_LV: { // 21
		    r = GetGVarInt("AI_LVAP", 2);
		}
		case CHILLIAD_DOWN: { //3
		    r = GetGVarInt("CH_DN", 3);
		}
		case CHILLIAD_UP: {  //4
		    r=GetGVarInt("CH_UP", 4);
		}
	}
	return r;
}

// EOF

