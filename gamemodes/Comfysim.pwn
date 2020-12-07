
#include <a_samp>

#include <core>
#include <float>

#define PLAYERS 30

#include <jit>
#include "YSI\YSI_Visual\Y_Commands.inc"

#include <dini2> 					// To be removed in a later release - this is a little outdated but will do me for now. Possibly replaced by Y_ini or MySQL.
#include <screen-colour-fader>		// Functionality to fade a players screen.
#include <streamer>					// Incognito / Y_Less' Object streamer.
#include <sscanf2>

#include "comfysim\J_Functions.inc" // Central repository for all useful functions created for / used by the ComfySim scripts.
#include "Comfysim\J_Entrances.inc" // Entrance/Interior/Gates engine to control entrances into Interiors, gates into areas etc.

// Forwards
forward StopPlayerSpecialAction(playerid);

// Constants
#define DIALOG_BOX_MENTAL_STATE 0

#define MAX_AMOUNT_OF_WEATHER_TYPES 8
#define WEATHER_TYPE_CLEAR 0
#define WEATHER_TYPE_CLOUDY 1
#define WEATHER_TYPE_PRESTORM 2
#define WEATHER_TYPE_RAIN 3
#define WEATHER_TYPE_FOG 4
#define WEATHER_CHAT_COLOUR 0x51A8FFFF

// Colours
#define CHAT_COLOUR_WHITE 0xFFFFFFFF
#define CHAT_COLOUR_PALE_YELLOW 0xFFFF6CFF
#define CHAT_COLOUR_PALE_DARK_GREEN 0x00954AFF
#define CHAT_COLOUR_PALE_RED 0xFF8080FF

#define SCREEN_COLOUR_BLACK 0x000000FF
#define SCREEN_COLOUR_TRANSPARENT 0x00000000

#define CHAT_COLOUR_NORMAL "FFFFFF"
#define CHAT_COLOUR_UNSTABLE "D5CACE"
#define CHAT_COLOUR_DERANGED "DFC1B7"
#define CHAT_COLOUR_MANIAC "C57264"
#define CHAT_COLOUR_PSYCHO "BA4139"
#define BLIP_COLOUR_NORMAL 0xFFFFFFFF
#define BLIP_COLOUR_UNSTABLE 0xD5CACEFF
#define BLIP_COLOUR_DERANGED 0xDFC1B7FF
#define BLIP_COLOUR_MANIAC 0xC57264FF
#define BLIP_COLOUR_PSYCHO 0xBA4139FF


// Other
#define SPAWN_CAM_ZOOM_INITIAL 6000
#define SPAWN_CAM_ZOOM_1 2000
#define SPAWN_CAM_ZOOM_2 3000
#define SPAWN_CAM_ZOOM_3 4000
#define SPAWN_ANIMATION_LENGTH_EXTRA 2500 // How long after camera is ready before player can move.
#define SPAWN_LOCATION_COUNT 11
#define SPAWN_NO_ANIMATION 0
#define SPAWN_SMOKING 1
#define SPAWN_SITTING 2

// Variables & Arrays

new gTimeHours = 12;
new gTimeMinutes = 0;
new gTimeWeatherUpdate = 0; // Variable to keep track of when to update the weather
new gWeatherType = 0; // Variable to track current weather type for patterns.

enum REMOVED_OBJECTS_DATA {
    ro_modelid,
	Float:rox,
	Float:roy,
	Float:roz,
	Float:ro_radius
}
    
new RemovedObjectsData[11][REMOVED_OBJECTS_DATA] = {

	//Airport blockers (11)
	{705, -1783.8828, -264.625, 17.61719, 27.506569}, // sm_veg_tree7vbig
	{705, -1819.25, -279.78906, 14.98438, 27.506569}, // sm_veg_tree7vbig
	{705, -1780.1328, -223.8125, 15.64063, 27.506569}, // sm_veg_tree7vbig
	{712, 1474.8125, 1921.4922, 19.25781, 14.100514}, // vsg_palm03
	{652, 1477.1172, 1986.4688, 9.59375, 12.086936}, // sjmpalmbig
	{652, 1477.1172, 1986.4688, 9.59375, 12.086936}, // sjmpalmbig
	{645, 1478.7344, 2021.7656, 9.82031, 14.408298}, // veg_palmbig14
	{7979, 1477.3984, 1172.4453, 12.89063, 16.088779}, // blastdef01_lvS
	{3664, 1388.0078, -2593.0, 19.28125, 17.001591}, //lastblastde_LAS
	{3664, 1388.0078, -2494.2656, 19.28125, 17.001591}, //lastblastde_LAS
	{3664, 2042.7734, -2442.1875, 19.28125, 17.001591} //lastblastde_LAS
    
};

enum HOSPITAL_DATA {
	Float:hx,
	Float:hy,
	Float:hz,
	Float:hr
}

new HospitalData[8][HOSPITAL_DATA] = {
	{1177.7179,-1323.4457,14.0845,269.8842}, // Los Santos All Saints
	{2032.8688,-1405.5126,17.2320,156.5682}, // Los Santos County General
	{1244.2462,331.2754,19.5547,337.4333}, // Red County Crippen Memorial Montgomery
	{1607.7214,1822.5175,10.8203,0.5218}, // Las Venturas Hospital
	{-1514.7462,2523.3435,55.8153,0.7756}, // El Quebrados Medical Center
	{-319.7820,1049.8525,20.3403,323.0506}, // Fort Carson Medical Center
	{-2653.8699,635.3766,14.4531,179.7929}, // San Fierro Medical Center
	{-2208.1658,-2286.6106,30.6250,321.7350} // Angel Pine Medical Center
};

enum WEATHER_DATA {
	weatherid,
	weather_type
}

new wData[][WEATHER_DATA] = {
	{0, WEATHER_TYPE_CLEAR},
	{2, WEATHER_TYPE_CLEAR},
	{3, WEATHER_TYPE_CLEAR},
	{4, WEATHER_TYPE_CLOUDY},
	{7, WEATHER_TYPE_CLOUDY},
	{8, WEATHER_TYPE_RAIN},
	{9, WEATHER_TYPE_FOG},
	{11, WEATHER_TYPE_CLEAR},
	{12, WEATHER_TYPE_CLOUDY},
	{13, WEATHER_TYPE_CLEAR},
	{14, WEATHER_TYPE_CLEAR},
	{15, WEATHER_TYPE_CLOUDY},
	{17, WEATHER_TYPE_CLEAR},
	{18, WEATHER_TYPE_CLEAR}
};

enum PLAYER_DATA {
	pSpawned,
	pDied, // Tracks if the player has just died - as to not go through the spawn stuff again, instead to a hospital
 	pAccount,
	pSkin,
	pMoney,
	pColour[7], // Chat & Blip colour, standard is white but moves towards red when going physco like in GTA V.
	pMentalState, // 0-19 = Normal, 20-39 = Unstable, 40-59 = Deranged, 60-79 = Maniac, 80-100 = Physcopath
	pMentalStateTracker, // Used just to keep track of when to reduce a players mental state by 1 digit.
	Float:dx, Float:dy, Float:dz // Death coordinates
}

new pData[PLAYERS][PLAYER_DATA];

//Textdraws for Players

new PlayerText:Dialogbox_MentalState[PLAYERS][1];

enum SPAWN_SETTINGS {
	Float:spawn_x,
	Float:spawn_y,
	Float:spawn_z,
	Float:spawn_r,
	Float:spawn_cam_x,
	Float:spawn_cam_y,
	Float:spawn_cam_z,
	spawn_action
}
	
//X, Y, Z, R, cx, cy, cz, Spawn_Action (Special Action +/ Animation)
new gSpawnLocations[SPAWN_LOCATION_COUNT][SPAWN_SETTINGS] = {
{1038.1876, -1338.0356, 13.7266, 0.0, 1065.8121, -1301.5342, 35.0, SPAWN_SMOKING}, // Donut Shop
{528.2549, -1762.5322, 14.2766, 174.8838, 489.8164, -1793.8965, 30.0, SPAWN_SMOKING}, // Beach Middle
{415.7593, -1763.1497, 7.9316, 178.1622, 391.3931, -1794.6553, 30.0, SPAWN_SITTING}, // Beach near Pier (Sitting)
{1618.3438,-1266.3647,17.5162,90.9632, 1570.5660,-1306.6669,35.0, SPAWN_SITTING}, // CitySpawn Sitting
{1786.3164,-1365.0077,15.7578,55.2949, 1743.9032,-1345.1633,35.0, SPAWN_SMOKING}, // CitySpawn2 Standing
{1721.3593,-1706.3845,13.5000,93.6053, 1704.6844,-1738.2620,35.0, SPAWN_SITTING} ,// CitySpawn3 Sitting
{1654.1577,-1658.8549,22.5156,179.7386, 1673.9297,-1721.2039,40.0, SPAWN_SMOKING}, // CitySpawn4 Standing
{1567.8849,-1891.4739,13.5593,0.9240, 1562.9254,-1848.5099,35.0, SPAWN_SMOKING}, // CitySpawn5 Smoking
{1084.8290,-2244.7095,46.6754,93.4118, 1016.4048,-2217.1956,65.0, SPAWN_SITTING}, // CitySpawn6 Sitting
{1186.8945,-2034.5500,69.0078,180.9623, 1262.0525,-2052.4900,105.0, SPAWN_SITTING}, // CitySpawn7 Sitting
{514.2604,-1487.7915,14.4823,271.0856, 554.7294,-1520.9540,35.0, SPAWN_SMOKING} // CitySpawn8 Smoking

};
new gSpawnAnimationLength = SPAWN_CAM_ZOOM_INITIAL + SPAWN_CAM_ZOOM_1 + SPAWN_CAM_ZOOM_2 + SPAWN_CAM_ZOOM_3;


//stocks

stock ini_GetKey( const line[] )
{
	new keyRes[256];
	keyRes[0] = 0;
    if ( strfind( line , "=" , true ) == -1 ) return keyRes;
    strmid( keyRes , line , 0 , strfind( line , "=" , true ) , sizeof( keyRes) );
    return keyRes;
}

stock ini_GetValue( const line[] )
{
	new valRes[256];
	valRes[0]=0;
	if ( strfind( line , "=" , true ) == -1 ) return valRes;
	strmid( valRes , line , strfind( line , "=" , true )+1 , strlen( line ) , sizeof( valRes ) );
	return valRes;
}

stock RemoveMapObjectsForPlayer(playerid) // Runs through the array of objects we don't want and removes them for the playerid. Ran on Connect.
{
	for(new idx; idx < sizeof(RemovedObjectsData); idx++)
	{
	    RemoveBuildingForPlayer(playerid, RemovedObjectsData[idx][ro_modelid], RemovedObjectsData[idx][rox], RemovedObjectsData[idx][roy], RemovedObjectsData[idx][roz], RemovedObjectsData[idx][ro_radius]);
	}
	
	return 1;
}

// Main

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
	
}

// Rest of the script


public OnGameModeInit()
{
    //LoadEntrances();
    
	// Don't use these lines if it's a filterscript
	SetGameModeText("Nostalgic Feels");
	ShowPlayerMarkers(true);
	LimitPlayerMarkerRadius(1000.0);
	ShowNameTags(true);
	SetNameTagDrawDistance(50.0);
	EnableTirePopping(true);
	AllowInteriorWeapons(false);
	EnableZoneNames(true);
	
	
	AddStaticVehicle(500,334.3177,-1788.9360,5.0078,0.1155,-1, -1); // beachcar
	AddStaticVehicle(499,436.5108,-1749.4336,9.0195,312.9471,-1, -1); // van
	AddStaticVehicle(424,438.5664,-1801.8202,5.3285,178.4680,6,16); // buggy1
	AddStaticVehicle(424,442.2759,-1801.8157,5.3282,359.0239,24,53); // buggy2
	AddStaticVehicle(471,445.6248,-1801.1389,5.0258,216.6332,120,114); // quad1
	AddStaticVehicle(468,447.6053,-1800.9272,5.2161,191.1629,3,3); // sanchez1
	AddStaticVehicle(468,449.5095,-1800.7885,5.2160,177.0111,3,3); // sanchez2
	AddStaticVehicle(510,443.0365,-1793.1632,5.1485,36.1938,28,28); // mountainbike1
	AddStaticVehicle(510,444.8435,-1793.1376,5.1483,31.4828,6,6); // mountainbike2
	AddStaticVehicle(510,446.7779,-1793.0811,5.1478,32.6675,2,2); // mountainbike3
	AddStaticVehicle(509,448.5404,-1792.9265,5.0519,4.8074,36,1); // bike1
	AddStaticVehicle(495,446.2188,-1812.9210,5.8999,270.2325,119,122); // sandking1
	AddStaticVehicle(495,412.8730,-1811.9198,5.8892,203.1042,116,115); // sandking2
	AddStaticVehicle(473,401.4613,-1908.9554,-0.1211,258.6542,56,15); // Dinghy1
	AddStaticVehicle(472,403.7529,-1914.2020,-0.0582,258.6229,56,53); // coastguard
	AddStaticVehicle(539,434.0924,-1891.1439,1.2974,176.1587,86,70); // hovercraft1
	AddStaticVehicle(568,422.5140,-1791.8767,5.4128,215.2673,17,1); // buggy
	AddStaticVehicle(555,324.6437,-1788.8699,4.4676,180.7923,68,1); // beachcar1
	AddStaticVehicle(554,317.9506,-1809.6345,4.5577,359.9064,65,32); // beachcar2
	AddStaticVehicle(573,478.1149,-1808.4072,6.4938,180.0492,115,43); // bigsandtruck
	AddStaticVehicle(400,347.1636,-1809.6080,4.6521,179.1212,62,1); // beachlandst
	AddStaticVehicle(436,337.2500,-1809.5281,4.2710,180.1088,95,1); // beachcar3
	AddStaticVehicle(439,334.1067,-1809.4047,4.3828,0.7935,67,8); // beachcar4
	AddStaticVehicle(500,324.3439,-1809.3550,4.5977,179.6623,75,84); // beachcar5
	AddStaticVehicle(491,311.5935,-1809.8698,4.2150,359.9707,30,72); // beachcar6
	AddStaticVehicle(516,318.2476,-1788.8229,4.5138,179.8207,119,1); // beachcar7
	AddStaticVehicle(506,322.4286,-1764.2473,4.2643,1.0312,52,52); // beachhousecar1
	AddStaticVehicle(440,478.0871,-1764.7271,5.6427,269.6983,118,118); // beachcar8
	AddStaticVehicle(560,498.3313,-1733.4628,11.1739,263.9120,52,39); // beachcar9
	
	SetWorldTime(12); // Noon for now.
	SetTimer("GlobalTime", 2000, true); //
	SetTimer("SaveStats", 300000, true); // Large timer that will save stats of players regularly.
	SetTimer("PlayerStatUpdate", 216000, true); // Used to update various players data during the game on a longer timer. (3.6 Minutes)
	
	new rand = random(sizeof(wData));
	SetWeather(wData[rand][weatherid]);
	gWeatherType = wData[rand][weather_type];

	return 1;
}

forward PlayerStatUpdate();
public PlayerStatUpdate()
{
	for(new idx = 0; idx < PLAYERS; idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && pData[idx][pSpawned]) // Player is connected, not an NPC and is passed the spawn sequence.
	    {
	        new mental_state = pData[idx][pMentalState];
	        
			if(mental_state)
			{
				pData[idx][pMentalState]--;
				mental_state = pData[idx][pMentalState];
				printf("Debug: ID %d's mental state is now %d.", idx, mental_state);
				
				if(mental_state <= 19)
				{
				    if(strcmp(pData[idx][pColour], CHAT_COLOUR_NORMAL, true) == 1)
				    {
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, " * Your mental state lowered changed to Normal.");
					}
					SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 39 && mental_state > 19)
				{
				    if(strcmp(pData[idx][pColour], CHAT_COLOUR_UNSTABLE, true) == 1)
				    {
				        new string[128];
				        format(string, sizeof(string), "* Your mental state has changed to {%s} Unstable.", CHAT_COLOUR_UNSTABLE);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
					}
					
				    SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 59 && mental_state > 39)
				{
				    if(strcmp(pData[idx][pColour], CHAT_COLOUR_DERANGED, true) == 1)
				    {
				        new string[128];
				        format(string, sizeof(string), "* Your mental state has changed to {%s} Deranged.", CHAT_COLOUR_DERANGED);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
					}
					SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 79 && mental_state > 59)
				{
				    if(strcmp(pData[idx][pColour], CHAT_COLOUR_MANIAC, true) == 1)
				    {
				        new string[128];
				        format(string, sizeof(string), "* Your mental state has changed to {%s} Maniac.", CHAT_COLOUR_MANIAC);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
					}
				    SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 100 && mental_state > 79)
				{
				    if(strcmp(pData[idx][pColour], CHAT_COLOUR_PSYCHO, true) == 1)
				    {
				        new string[128], player_name[MAX_PLAYER_NAME];
        				format(string, sizeof(string), "* Your mental state has changed to {%s} Physcotic.", CHAT_COLOUR_PSYCHO);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
				        GetPlayerName(idx, player_name, MAX_PLAYER_NAME);
				        format(string, sizeof(string), "{FFFFFF}* %s is going {%s}Physco!", player_name, CHAT_COLOUR_PSYCHO);
				        SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
					}
				    SetPlayerMentalState(idx, mental_state);
				}
			}
		}
	}
			
	return 1;
}

forward SaveStats();
public SaveStats()
{
	print("Saving players stats...");
	for(new idx; idx < PLAYERS; idx++)
	{
	    if(!IsPlayerNPC(idx) && IsPlayerConnected(idx)) // is not an NPC and is actually connected.
	    {
	        if(pData[idx][pSpawned] == 1) // is properly spawned
	        {
	            SavePlayerDataToFile(idx); // Save players stats to file.
			}
		}
	}
	
	return 1;
}

stock CreateTextDrawsForPlayer(playerid) // So we only create when needed.
{
    Dialogbox_MentalState[playerid][0] = CreatePlayerTextDraw(playerid, 45.000000, 295.000000, "WARNING: Your Mental State~n~level is rising. Players will earn~n~RP for killing you if your~n~Mental State level is high.");
	PlayerTextDrawFont(playerid, Dialogbox_MentalState[playerid][0], 1);
	PlayerTextDrawLetterSize(playerid, Dialogbox_MentalState[playerid][0], 0.104166, 1.049997);
	PlayerTextDrawTextSize(playerid, Dialogbox_MentalState[playerid][0], 292.000000, 53.500000);
	PlayerTextDrawSetOutline(playerid, Dialogbox_MentalState[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, Dialogbox_MentalState[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, Dialogbox_MentalState[playerid][0], 2);
	PlayerTextDrawColor(playerid, Dialogbox_MentalState[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, Dialogbox_MentalState[playerid][0], 255);
	PlayerTextDrawBoxColor(playerid, Dialogbox_MentalState[playerid][0], 135);
	PlayerTextDrawUseBox(playerid, Dialogbox_MentalState[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, Dialogbox_MentalState[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, Dialogbox_MentalState[playerid][0], 0);
	
	// This is creation only. Make sure they are hidden below for later use.
	PlayerTextDrawHide(playerid, Dialogbox_MentalState[playerid][0]);
	
	return 1;
}

stock RemoveTextDrawsForPlayer(playerid) // Delete from memory once done.
{
	PlayerTextDrawDestroy(playerid, Dialogbox_MentalState[playerid][0]);
	return 1;
}

stock ShowPlayerDialogBox(playerid, dialogid) // dialogid switch to show different boxes.
{
	switch(dialogid)
	{
	    case DIALOG_BOX_MENTAL_STATE:
	    {
			PlayerTextDrawShow(playerid, Dialogbox_MentalState[playerid][0]);
			SetTimerEx("HidePlayerDialogBox", 7500, 0, "dd", playerid, dialogid);
			return 1;
		}
	}
	
	return 1;
}

forward HidePlayerDialogBox(playerid, dialogid); // This is a callback so we can use it in timers.
public HidePlayerDialogBox(playerid, dialogid) // dialogid switch to hide different boxes.
{
	print("HidePlayerDialogBox Called!");
	switch(dialogid)
	{
	    case DIALOG_BOX_MENTAL_STATE:
	    {
			PlayerTextDrawHide(playerid, Dialogbox_MentalState[playerid][0]);
			return 1;
		}
	}

	return 1;
}

	

stock SetWeatherEx(weatherID, weather_to, weather_from)
{
	// Send forcast message.
	if(weather_from == WEATHER_TYPE_CLEAR && weather_to  == WEATHER_TYPE_CLEAR) {
        SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}The sky will be remaining clear."); return 1; }
	else if(weather_from == WEATHER_TYPE_CLEAR && weather_to  == WEATHER_TYPE_CLOUDY) {
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}The sky will be turning cloudy."); return 1; }
	else if(weather_from == WEATHER_TYPE_CLOUDY && weather_to  == WEATHER_TYPE_CLEAR) {
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}The sky will be clearing up."); return 1; }
	else if(weather_from == WEATHER_TYPE_CLOUDY && weather_to  == WEATHER_TYPE_CLOUDY) {
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}The sky will be remaining cloudy."); return 1; }
	else if(weather_from == WEATHER_TYPE_CLOUDY && weather_to  == WEATHER_TYPE_RAIN) {
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}It's going get stormy - heavy rain and high winds. Be careful out there!"); return 1; }
	else if(weather_from == WEATHER_TYPE_CLOUDY && weather_to  == WEATHER_TYPE_FOG) {
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}It's going to get foggy with low visibility. Watch out!"); return 1; }
	else if(weather_from == WEATHER_TYPE_RAIN && weather_to  == WEATHER_TYPE_CLOUDY) { // this is always the case.
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}The storm is clearing up and the sky will be turning cloudy."); return 1; }
	else if(weather_from == WEATHER_TYPE_FOG && weather_to  == WEATHER_TYPE_CLOUDY) { // this is always the case.
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, "* {51A8FF}Weather Forecast: {FFFFFF}The fog will be lifting and the sky will be turning cloudy."); return 1; }

	print("[DEBUG] Weather Forecast sent out, timer set for 5 minutes.");
	SetTimerEx("ChangeWeather", 300000, 0, "d", weatherID);
	
	return 1;
}

forward ChangeWeather(weather);
public ChangeWeather(weather)
{
	SetWeather(weather);
    print("[DEBUG] Weather successfully changed after 5 minutes.");
}

forward GlobalTime();
public GlobalTime()
{
	if(gTimeMinutes < 60)
	{
	    gTimeMinutes++; // add a minute to the clock.
	}
	else
	{
	    //Minutes = 60, 1 hr. Add an hour, reset mins.
	    gTimeMinutes = 0;
	    gTimeWeatherUpdate++; // Increase time tracker variable once per hour

		printf("[DEBUG] Weather Tracker: %d/5 until weather changes.", gTimeWeatherUpdate);
	    if(gTimeWeatherUpdate >= 5) // Every 10 minutes, 1/5 chance to change the weather.
	    {
	        gTimeWeatherUpdate = 0;
	    	new rand = 1; //random(1); // 1/2 Chance every 10 mins to change the weather .

	    	if(rand == 1) // Rolled changing the weather.
	    	{
                print("[DEBUG] Weather changing...");

	    	    new random_weather;
	    	    new weather_array[MAX_AMOUNT_OF_WEATHER_TYPES][WEATHER_DATA];
	    	    new array_tracker = 0;

	    	    if(gWeatherType == WEATHER_TYPE_CLEAR)
	    	    {
					rand = random(1);
					if(rand == 0) // Stay Clear
					{
					    for(new idx; idx < sizeof(wData); idx++)
					    {
					        if(wData[idx][weather_type] == gWeatherType)
					        {
								weather_array[array_tracker][weatherid] = wData[idx][weatherid];
								weather_array[array_tracker][weather_type] = wData[idx][weather_type];
								array_tracker++;
							}
						}

					    random_weather = random(array_tracker); // Random weather out of the new array of specific weather types.
					    SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
					    gWeatherType = WEATHER_TYPE_CLEAR;
					    printf("[DEBUG] Weather changing from type 'CLEAR' to type 'CLEAR' (ID: %d).", weather_array[array_tracker][weatherid]);
					}
					else // Turn Cloudy
					{
					    for(new idx; idx < sizeof(wData); idx++)
					    {
					        if(wData[idx][weather_type] == gWeatherType)
					        {
       	                        weather_array[array_tracker][weatherid] = wData[idx][weatherid];
								weather_array[array_tracker][weather_type] = wData[idx][weather_type];
								array_tracker++;
							}
						}

					    random_weather = random(array_tracker);
					    SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
					    gWeatherType = WEATHER_TYPE_CLOUDY;
					    printf("[DEBUG] Weather changing from type 'CLEAR' to type 'CLOUDY' (ID: %d).", weather_array[array_tracker][weatherid]);
					}
				}

	    	    else if(gWeatherType == WEATHER_TYPE_CLOUDY)
	    	    {
					rand = random(2);
					if(rand == 0) // Turn Clear
					{
					    for(new idx; idx < sizeof(wData); idx++)
					    {
					        if(wData[idx][weather_type] == gWeatherType)
					        {
								weather_array[array_tracker][weatherid] = wData[idx][weatherid];
								weather_array[array_tracker][weather_type] = wData[idx][weather_type];
								array_tracker++;
							}
						}

         				random_weather = random(array_tracker);
					    SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
					    gWeatherType = WEATHER_TYPE_CLEAR;
					    printf("[DEBUG] Weather changing from type 'CLOUDY' to type 'CLEAR' (ID: %d).", weather_array[array_tracker][weatherid]);
					}
					else if(rand == 1) // Stay Cloudy
					{
					    for(new idx; idx < sizeof(wData); idx++)
					    {
					        if(wData[idx][weather_type] == gWeatherType)
					        {
								weather_array[array_tracker][weatherid] = wData[idx][weatherid];
								weather_array[array_tracker][weather_type] = wData[idx][weather_type];
								array_tracker++;
							}
						}

					    random_weather = random(array_tracker);
					    SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
					    gWeatherType = WEATHER_TYPE_CLOUDY;
					    printf("[DEBUG] Weather changing from type 'CLOUDY' to type 'CLOUDY' (ID: %d).", weather_array[array_tracker][weatherid]);
					}
					else // Rolled bad weather - Rain or Fog. Less chance of Fog.
					{
					    rand = random(3);

					    if(rand != 3) // Did not roll Fog
					    {
						    for(new idx; idx < sizeof(wData); idx++)
						    {
						        if(wData[idx][weather_type] == gWeatherType)
						        {
									weather_array[array_tracker][weatherid] = wData[idx][weatherid];
									weather_array[array_tracker][weather_type] = wData[idx][weather_type];
									array_tracker++;
								}
							}

						    random_weather = random(array_tracker);
						    SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
						    gWeatherType = WEATHER_TYPE_RAIN;
						    printf("[DEBUG] Weather changing from type 'CLOUDY' to type 'RAIN' (ID: %d).", weather_array[array_tracker][weatherid]);
						}
						else
						{
						    gWeatherType = WEATHER_TYPE_FOG;
						    SetWeatherEx(wData[6][weatherid], wData[6][weather_type], gWeatherType); // Fog INDEX not ID
						    print("[DEBUG] Weather changing from type 'CLOUDY' to type 'FOG'");
						}
					}
				}

				else if(gWeatherType == WEATHER_TYPE_RAIN)
	    	    {
					rand = random(1);
					if(rand != 1) // Turn Cloudy, otherwise remain unchanged (Rain).
					{
					    for(new idx; idx < sizeof(wData); idx++)
					    {
					        if(wData[idx][weather_type] == gWeatherType)
					        {
								weather_array[array_tracker][weatherid] = wData[idx][weatherid];
								weather_array[array_tracker][weather_type] = wData[idx][weather_type];
								array_tracker++;
							}
						}

					    random_weather = random(array_tracker);
					    SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
					    gWeatherType = WEATHER_TYPE_CLOUDY;
					    printf("[DEBUG] Weather changing from type 'RAIN' to type 'CLOUDY' (ID: %d).", weather_array[array_tracker][weatherid]);
					}
				}

				else // Only other option would be Fog, and back to cloudy. Dont want fog for long.
	    	    {
					for(new idx; idx < sizeof(wData); idx++)
					{
	        			if(wData[idx][weather_type] == gWeatherType)
	        			{
							weather_array[array_tracker][weatherid] = wData[idx][weatherid];
							weather_array[array_tracker][weather_type] = wData[idx][weather_type];
							array_tracker++;
						}
					}

					random_weather = random(array_tracker);
					SetWeatherEx(weather_array[random_weather][weatherid], weather_array[random_weather][weather_type], gWeatherType); // Set weather on a delay with message for forcasting.
					gWeatherType = WEATHER_TYPE_CLOUDY;
					printf("[DEBUG] Weather changing from type 'FOG' to type 'CLOUDY' (ID: %d).", weather_array[array_tracker][weatherid]);

				}
			}
		}
		
		new string[128];

		if(gTimeHours < 23)
	  	{
	   		gTimeHours++;
		   	format(string, sizeof(string), "* The time is now: {51A8FF}%d:00", gTimeHours);
		   	SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
		}
		else
		{
			gTimeHours = 0; // Set midnight after 23 (11 pm)
			format(string, sizeof(string), "* The time is now: {51A8FF}%d:00", gTimeHours);
			SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
		}
	}
	
	for(new idx; idx < PLAYERS; idx++) // Set every players time. Global time only allows us to set the Hour, it is less innacurate.
	{
	    SetPlayerTime(idx, gTimeHours, gTimeMinutes);
	}
	
}


public OnGameModeExit()
{
	return 1;
}

stock ResetPlayerData(playerid) // Just resets the pData array for that ID back to default to avoid any 'bugs'.
{
	printf("ResetPlayerData called for playerid %d", playerid);
    pData[playerid][pDied] = 0;
    pData[playerid][pSpawned] = 0;
	pData[playerid][pAccount] = 0;
	pData[playerid][pMoney] = 0;
	pData[playerid][pSkin] = 0;
	pData[playerid][pMentalState] = 0;
	pData[playerid][pMentalStateTracker] = 0;
	pData[playerid][pColour] = CHAT_COLOUR_NORMAL;
	return 1;
}

stock LoadPlayerDataFromFile(playerid)
{
	new string[MAX_PLAYER_NAME+4], player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	format(string, sizeof(string), "accounts/%s.ini", player_name); // Get player name and format the path we are looking to open.
	
	new File:UserFile = fopen(string, io_read);
	
	printf("Load player file called for %s, attempting to open...", player_name);

	if(UserFile) // If the file exists, continue - otherwise crash
	{
	    printf("Player %s's file exists and is opened successfully, reading...", player_name);
	    
	    new key[256], val[256], data[256];
	    while(fread(UserFile, data, sizeof(data)))
	    {
	        key = ini_GetKey(data);
        	if(strcmp(key, "skin", true) == 0) { val = ini_GetValue(data); pData[playerid][pSkin] = strval(val); printf("Key - Skin: %d", pData[playerid][pSkin]); }
	        if(strcmp(key, "money", true) == 0) { val = ini_GetValue(data); pData[playerid][pMoney] = strval(val); printf("Key - Money: %d", pData[playerid][pMoney]); }
	        if(strcmp(key, "mental_state", true) == 0) { val = ini_GetValue(data); pData[playerid][pMentalState] = strval(val); printf("Key - Mental_state: %d", pData[playerid][pMentalState]); }
		} // end while
		
		print(" ");
		fclose(UserFile); // Close the file after we're done.
		pData[playerid][pAccount] = 1; // Player does have an account saved.
		
		printf("File now closed, data read complete. Account status = %d", pData[playerid][pAccount]);
	}
	else
	{
	    printf("Player %s's file does not exist, could not open file.", player_name);
	    pData[playerid][pAccount] = 0; // Player does not have an account saved.
	}

	return 1;
}

stock SavePlayerDataToFile(playerid)
{
    new string[MAX_PLAYER_NAME+4], player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	format(string, sizeof(string), "accounts/%s.ini", player_name); // Get player name and format the path we are looking to open.

	new File:UserFile = fopen(string, io_write);

	printf("Save player file called for %s, attempting to open...", player_name);

	if(!UserFile)
	{
	    UserFile = fopen(string, io_readwrite); // Create the file if it does not already exist.
	    printf("Player %s's file does not exists, assuming first time - creating file...", player_name);
	}
	
	if(UserFile) // If the file exists, continue - otherwise crash
	{
	    printf("Player %s's file exists and is opened successfully, saving...", player_name);

	    new var[32];
	    
	    format(var, 32, "Skin=%d\n", GetPlayerSkin(playerid)); fwrite(UserFile, var); printf("Saving key Skin = %d",GetPlayerSkin(playerid));
    	format(var, 32, "Money=%d\n", GetPlayerMoney(playerid)); fwrite(UserFile, var); printf("Saving key Money = %d",GetPlayerMoney(playerid));
    	format(var, 32, "Mental_State=%d\n", pData[playerid][pMentalState]); fwrite(UserFile, var); printf("Saving key Mental_State = %d",pData[playerid][pMentalState]);
		fclose(UserFile);
		
		printf("Player %s's stats now saved to file, read complete and file closed.", player_name);
		pData[playerid][pAccount] = 1;
	}
	else
	{
		printf("Player %s's file does not exist, could not open file.", player_name);
		pData[playerid][pAccount] = 0;
	}
	
	return 1;
}

stock SetPlayerDataToPlayer(playerid) // Set the player data according to their pData array filled by the file loader
{
	printf("SetPlayerDataToPlayer called, account status = %d", pData[playerid][pAccount]);

	if(pData[playerid][pAccount]) // Player has data imported from a file
	{
	    print("SetPlayerDataToPlayer called, Account status is true, setting data...");
	    printf("Skin is being set to %d..", pData[playerid][pSkin]);
		SetPlayerSkin(playerid, pData[playerid][pSkin]);
		SetPlayerMoney(playerid, pData[playerid][pMoney]);
		SetPlayerMentalState(playerid, pData[playerid][pMentalState]);
		SetPlayerColor(playerid, GetPlayerColourFromMentalState(playerid));
	 	GetChatColourFromMentalState(playerid, pData[playerid][pColour], 8);
		pData[playerid][pMentalStateTracker] = 0; // reset the tracker.
		printf("playerid (%d)'s chat colour: '%s', mental state = (%d)", playerid, pData[playerid][pColour], pData[playerid][pMentalState]);
	}
	else
	{
	    print("SetPlayerDataToPlayer called, Account status is false, setting data not from the array.");
	    SetPlayerSkin(playerid, 299); // Default skin Claude for now.
	    SetPlayerMoney(playerid, 2000); // 2k dollars starting cash
	    SetPlayerColor(playerid, BLIP_COLOUR_NORMAL);
	    pData[playerid][pColour] = CHAT_COLOUR_NORMAL;
	}

	return 1;
}

stock SetPlayerMentalState(playerid, value) // 0-100
{
	if(value <= 100 && value >= 0) // Check if valid..
	{
	    pData[playerid][pMentalState] = value;
	    
	    if(value <= 19)
		{
		    pData[playerid][pColour] = CHAT_COLOUR_NORMAL;
		    SetPlayerColor(playerid, BLIP_COLOUR_NORMAL);
		}
		else if(value <= 39 && value > 19)
		{
		    pData[playerid][pColour] = CHAT_COLOUR_UNSTABLE;
		    SetPlayerColor(playerid, BLIP_COLOUR_UNSTABLE);
		}
		else if(value <= 59 && value > 39)
		{
			pData[playerid][pColour] = CHAT_COLOUR_DERANGED;
			SetPlayerColor(playerid, BLIP_COLOUR_DERANGED);
		}
		else if(value <= 79 && value > 59)
		{
	 		pData[playerid][pColour] = CHAT_COLOUR_MANIAC;
	 		SetPlayerColor(playerid, BLIP_COLOUR_MANIAC);
		}
		else
		{
		    pData[playerid][pColour] = CHAT_COLOUR_PSYCHO;
		    SetPlayerColor(playerid, BLIP_COLOUR_PSYCHO);
		}
	}
	
	return 1;
	
}

stock GetPlayerColourFromMentalState(playerid)
{
	new mental_state = pData[playerid][pMentalState];
	
	if(mental_state <= 19)
	{
	    return BLIP_COLOUR_NORMAL;
	}
	else if(mental_state <= 39 && mental_state > 19)
	{
	    return BLIP_COLOUR_UNSTABLE;
	}
	else if(mental_state <= 59 && mental_state > 39)
	{
		return BLIP_COLOUR_DERANGED;
	}
	else if(mental_state <= 79 && mental_state > 59)
	{
 		return BLIP_COLOUR_MANIAC;
	}
	else
	{
	    return BLIP_COLOUR_PSYCHO;
	}
}

stock GetChatColourFromMentalState(playerid, string[], len)
{
	new mental_state = pData[playerid][pMentalState];

	if(mental_state <= 19)
	{
	    format(string, len, "%s", CHAT_COLOUR_NORMAL);
	}
	else if(mental_state <= 39 && mental_state > 19)
	{
	    format(string, len, "%s", CHAT_COLOUR_UNSTABLE);
	}
	else if(mental_state <= 59 && mental_state > 39)
	{
		format(string, len, "%s", CHAT_COLOUR_DERANGED);
	}
	else if(mental_state <= 79 && mental_state > 59)
	{
 		format(string, len, "%s", CHAT_COLOUR_MANIAC);
	}
	else
	{
	    format(string, len, "%s", CHAT_COLOUR_PSYCHO);
	}
}

stock SetPlayerMoney(playerid, amount)
{
	GivePlayerMoney(playerid, -GetPlayerMoney(playerid));
	GivePlayerMoney(playerid, amount);
	return 1;
}

stock SendWelcomeMessage(playerid)
{
	for(new idx = 0; idx < 10; idx++) // 10 chat lines as standard.
	{
	    SendClientMessage(playerid, 0xFFFFFFFF, " "); // Blank message
	}
	
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	
	new string[128], player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	
	if(pData[playerid][pAccount] == 1)
	{
		format(string, sizeof(string), "{FFFFFF}Welcome back to the server {FFFF6C}%s{FFFFFF}!", player_name);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, string);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, "Your data has automatically been restored from the last time you were here.");
	}
	else
	{
		format(string, sizeof(string), "{FFFFFF}Welcome to the server {FFFF6C}%s{FFFFFF}!", player_name);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, string);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, "Your stats will be automatically saved without any input from you.");
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, "They will also be restored automatically next time you connect!");
	}
	
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, "Type {FFFF6C}/cmds {FFFFFF}for a list of commands.");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, "Enjoy your time here and {FF8080}don't be a dick{ffffff}!");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	
	return 1;
}

	
public OnPlayerConnect(playerid)
{
	print("OPC! - Gamemode.!");
    RemoveMapObjectsForPlayer(playerid); // It's important to remove the objects for NPCs too as they take the path that was otherwise filled with objects

    if(IsPlayerNPC(playerid)) return 1; // we dont deal with NPCs in here
    
    CreateTextDrawsForPlayer(playerid); // Create any text draws we need for the session
    LoadPlayerDataFromFile(playerid);
    
	pData[playerid][pDied] = 0;
	pData[playerid][pSpawned] = 0; // Important to have this set to 0 to avoid saving buggy values.
	
	SetSpawnInfo(playerid, -1, pData[playerid][pSkin], 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
 	SpawnPlayer(playerid);
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(IsPlayerNPC(playerid)) return 1; // we dont deal with NPCs in here
    
    RemoveTextDrawsForPlayer(playerid); // Create any text draws we need for the session
    
	if(pData[playerid][pSpawned]) // only create save data file if the player was properly spawned.
	{
	    SavePlayerDataToFile(playerid);
	    
	    new string[128], player_name[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	    format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Left.", pData[playerid][pColour], player_name);
	    SendClientMessageToAllConnected(playerid, string);
	}
	
	ResetPlayerData(playerid);
	printf("OnPlayerDisconnect called, pAccount = %d", pData[playerid][pAccount]);
	        
	return 1;
}

forward SetPlayerSitting(playerid);
public SetPlayerSitting(playerid)
{
	ApplyAnimation(playerid, "PED", "SEAT_IDLE", 4.0, 1, 0, 0, 1, gSpawnAnimationLength, 1);
	return 1;
}

forward StopPlayerSitting(playerid);
public StopPlayerSitting(playerid)
{
	ApplyAnimation(playerid, "PED", "SEAT_UP", 4.0, 0, 0, 0, 0, 0, 1); // SPAWN_ANIMATION_LENGTH_EXTRA
	SetTimerEx("StopPlayerSmoking", 1000, false, "i", playerid);
	return 1;
}

forward SetPlayerSmoking(playerid);
public SetPlayerSmoking(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	ApplyAnimation(playerid, "GANGS", "SMKCIG_PRTL", 4.0, 1, 0, 0, 1, gSpawnAnimationLength, 1); // smoke cig
	return 1;
}

forward StopPlayerSmoking(playerid);
public StopPlayerSmoking(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ClearAnimations(playerid, 1);
	TogglePlayerControllable(playerid, true);
	pData[playerid][pDied] = 0; // Reset the variable for next time, in the case he died.
	return 1;
}



forward MovePlayerToSpawn(playerid);
public MovePlayerToSpawn(playerid) // Move the player to the spawn and start the screen fade.
{
	new idx = random(SPAWN_LOCATION_COUNT); // choose a random location to spawn.
	printf("MovePlayerToSpawn called, spawn index chosen: %d", idx);
	new
	    Float:x = gSpawnLocations[idx][spawn_x],
	    Float:y = gSpawnLocations[idx][spawn_y],
	    Float:z = gSpawnLocations[idx][spawn_z],
	    Float:r = gSpawnLocations[idx][spawn_r];
	
    SetPlayerWeather(playerid, 12);
	TogglePlayerControllable(playerid, false);
	
    SetPlayerScreenColour(playerid, SCREEN_COLOUR_BLACK); // Set players screen to black before the fade-in
    SetPlayerPos(playerid, x, y, z); 
	SetPlayerFacingAngle(playerid, r);
	
	FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, 4000, 45); // Fade the players screen slowly back into the game to reveal him leaving donut shop smoking..
	SetPlayerCameraPos(playerid, x, y, z+400); // Set camera in the air.
	SetPlayerCameraLookAt(playerid, x, y, z, CAMERA_CUT); // Set camera lookat spawn.
	
	SetTimerEx("CameraZoom_1", SPAWN_CAM_ZOOM_INITIAL, false, "ifffi", playerid, x, y, z, idx);
	
	return 1;
}

forward CameraZoom_1(playerid, Float:x, Float:y, Float:z, index);
public CameraZoom_1(playerid, Float:x, Float:y, Float:z, index)
{
    SetPlayerScreenColour(playerid, SCREEN_COLOUR_BLACK);
    FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, 2000, 45);
	SetPlayerCameraPos(playerid, x, y, z+300);
	SetPlayerCameraLookAt(playerid, x, y, z, CAMERA_CUT);
	PlayerPlaySound(playerid, 30800, x, y, z+300);

	SetTimerEx("CameraZoom_2", SPAWN_CAM_ZOOM_1, false, "ifffi", playerid, x, y, z, index);
	
	return 1;
}

forward CameraZoom_2(playerid, Float:x, Float:y, Float:z, index);
public CameraZoom_2(playerid, Float:x, Float:y, Float:z, index)
{
    SetPlayerScreenColour(playerid, SCREEN_COLOUR_BLACK);
    FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, 2000, 45);
	SetPlayerCameraPos(playerid, x, y, z+200);
	SetPlayerCameraLookAt(playerid, x, y, z, CAMERA_CUT);
	PlayerPlaySound(playerid, 30800, x, y, z+200);
	
	if(gSpawnLocations[index][spawn_action] == SPAWN_SITTING)
	{
	    SetPlayerSitting(playerid);
	}
	else if(gSpawnLocations[index][spawn_action] == SPAWN_SMOKING)
	{
	    SetPlayerSmoking(playerid);
	}

	SetTimerEx("CameraZoom_3", SPAWN_CAM_ZOOM_2, false, "ifffi", playerid, x, y, z, index);

	return 1;
}

forward CameraZoom_3(playerid, Float:x, Float:y, Float:z, index);
public CameraZoom_3(playerid, Float:x, Float:y, Float:z, index)
{
	new
	    Float:cax = gSpawnLocations[index][spawn_cam_x],
	    Float:cay = gSpawnLocations[index][spawn_cam_y],
	    Float:caz = gSpawnLocations[index][spawn_cam_z];
	    
	SetPlayerScreenColour(playerid, SCREEN_COLOUR_BLACK);
    FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, 2000, 45);
	SetPlayerCameraPos(playerid, cax, cay, caz);
	SetPlayerCameraLookAt(playerid, x, y, z, CAMERA_CUT);
	PlayerPlaySound(playerid, 30800, cax, cay, caz);

	SetTimerEx("CameraZoom_Spawn", SPAWN_CAM_ZOOM_3, false, "ii", playerid, index);

	return 1;
}
forward CameraZoom_Spawn(playerid, index);
public CameraZoom_Spawn(playerid, index)
{
    SetPlayerScreenColour(playerid, SCREEN_COLOUR_BLACK);
    FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, 2000, 45);
	SetCameraBehindPlayer(playerid);
	pData[playerid][pSpawned] = 1; // Allow creation of file if player disconnects.

	if(gSpawnLocations[index][spawn_action] == SPAWN_SITTING)
	{
	    SetTimerEx("StopPlayerSitting", SPAWN_ANIMATION_LENGTH_EXTRA, false, "i", playerid);
	}
	else // This applies to NONE as well, same thing. stops everything.
	{
	    SetTimerEx("StopPlayerSmoking", SPAWN_ANIMATION_LENGTH_EXTRA, false, "i", playerid);
	}

	
	return 1;
}

/*forward Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2);
public Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower(floatabs(floatsub(x, x2)),2)+floatpower(floatabs(floatsub(y, y2)),2)+floatpower(floatabs(floatsub(z, z2)),2));
}*/

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1; // we dont deal with NPCs in here
	
	print("OnPlayerSpawn called");
	if(pData[playerid][pDied] != 1) // Player did not just die - this is basically the OnPlayerConnect
	{
	    new string[128], player_name[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	    format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Joined.", pData[playerid][pColour], player_name);
	    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
	    
	    SendWelcomeMessage(playerid);
	    SetPlayerDataToPlayer(playerid);
		MovePlayerToSpawn(playerid); // Move player to spawn, start the fade & set the camera position initially
	}
	else// Player died, send to the hospital.
	{
	    new Float:hospital_distance = 100000000.0; // large so always goes true
	    new Float:distance_tracker = 0.0;
	    new idx_tracker = 0;
	    new Float:death_x = pData[playerid][dx], Float:death_y = pData[playerid][dy], Float:death_z = pData[playerid][dz]; // Assign to a float var rather than search an array every time it loops
	    
	    for(new idx; idx < 8; idx++) // There is only 8 Hospitals in the game as standard
	    {
	        distance_tracker = GetDistBetweenTwoPoints(death_x, death_y, death_z, HospitalData[idx][hx], HospitalData[idx][hy], HospitalData[idx][hz]);
	        
			if(hospital_distance > distance_tracker) // Found a closer hospital and is not the first loop.
			{
				hospital_distance = distance_tracker;
				idx_tracker = idx; // stores the closest hospital's index in the array.
			}
		}
		
		//SetPlayerScreenColour(playerid, SCREEN_COLOUR_BLACK);
		
		SetSpawnInfo(playerid, -1, pData[playerid][pSkin], HospitalData[idx_tracker][hx], HospitalData[idx_tracker][hy], HospitalData[idx_tracker][hz],  HospitalData[idx_tracker][hr], 0, 0, 0, 0, 0, 0);
		SetPlayerPos(playerid, HospitalData[idx_tracker][hx], HospitalData[idx_tracker][hy], HospitalData[idx_tracker][hz]);
		SetPlayerFacingAngle(playerid, HospitalData[idx_tracker][hr]);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, false);
		
    	FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, 6000, 45);
   	    SetTimerEx("StopPlayerSmoking", 6000, false, "i", playerid); // Allows player to move again and removes any animations. same length as fade.
		
	}
	
	return 1;
}

forward SpawnPlayerAfterDeath(playerid);
public SpawnPlayerAfterDeath(playerid)
{
	print("SpawnPlayerAfterDeath() called");
	SetSpawnInfo(playerid, -1, pData[playerid][pSkin], 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}

stock GetPlayerNameEx(playerid)
{
	new player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	return player_name;
}

stock IncreasePlayerMentalState(playerid, killerid) // Function used to increase a players mental state when killing another player
{
    pData[killerid][pMentalStateTracker]++;
    
    if(pData[killerid][pMentalStateTracker] > 3)
    {
        new string[128];
    	format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF} Is on a killing spree!", pData[killerid][pColour], GetPlayerNameEx(killerid));
		SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
		ShowPlayerDialogBox(playerid, DIALOG_BOX_MENTAL_STATE);
	}

	new mental_state = pData[playerid][pMentalState]; // The KILLED PLAYERS mental state.

     // Apply more mental state if you kill a more innocent person.
	if(mental_state <= 19) { pData[killerid][pMentalState]+= 5; }
	else if(mental_state <= 39 && mental_state > 19) { pData[killerid][pMentalState]+= 4; }
	else if(mental_state <= 59 && mental_state > 39) { pData[killerid][pMentalState]+= 3; }
	else if(mental_state <= 79 && mental_state > 59) { pData[killerid][pMentalState]+= 2; }
	
	print("IncreasePlayerMentalState called");
	return pData[killerid][pMentalState];
}

stock SendDeathClientMessage(playerid, killerid, reason)
{
	new string[128], player_name[MAX_PLAYER_NAME];
	format(player_name, MAX_PLAYER_NAME, "%s", GetPlayerNameEx(playerid));
	
	if(killerid != INVALID_PLAYER_ID)
	{
	    if(IsPlayerNPC(killerid))
	    {
	        format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Died.", pData[playerid][pColour], player_name);
		}
		else
		{
		    format(string, 128, "{FFFFFF}* {%s}%s {8D8D8D}Killed {%s}%s.", pData[killerid][pColour], GetPlayerNameEx(killerid), pData[playerid][pColour], player_name);
		}
	}
	else
	{
		if(reason == WEAPON_VEHICLE) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Was run over.", pData[playerid][pColour], player_name); }
	    else if(reason == WEAPON_DROWN) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Drowned.", pData[playerid][pColour], player_name); }
	    else if(reason == WEAPON_COLLISION) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Fell to their death.", pData[playerid][pColour], player_name); }
	    else if(reason == 51) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Exploded.", pData[playerid][pColour], player_name); }
		else if(reason == 50) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Was chopped to peices by helicopter blades.", pData[playerid][pColour], player_name); }
	 	else if(reason == 255) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Committed suicide.", pData[playerid][pColour], player_name); }
	  	else { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Died.", pData[playerid][pColour], player_name); }
	}
    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
    print("SendDeathClientMessage called");
    return 1;
}
	    
public OnPlayerDeath(playerid, killerid, reason)
{
	if(pData[playerid][pDied] != 1) // This is here to avoid the class selection GUI. Annoying but has to be done.
	{
	    new Float:px, Float:py, Float:pz;
		GetPlayerPos(playerid, px, py, pz); // Store the death coordinates for OnPlayerSpawn hospital selection
		pData[playerid][dx] = px, pData[playerid][dy] = py, pData[playerid][dz] = pz;
	    FadePlayerScreenColour(playerid, SCREEN_COLOUR_BLACK, 2400, 45); // Fade screen to black before class selection nonsense.
		SetTimerEx("SpawnPlayerAfterDeath", 3000, 0, "d", playerid); // 3000 seconds is roughly 200-300 ms longer than the class but should be faded by then.
		pData[playerid][pDied] = 1;
		
		if(killerid != INVALID_PLAYER_ID) // Was killed by a valid player
		{
		    SendDeathClientMessage(playerid, killerid, reason);
	    	IncreasePlayerMentalState(playerid, killerid);
		}
		else
		{
		    SendDeathClientMessage(playerid, INVALID_PLAYER_ID, reason);
		}
	}

	print("OnPlayerDeath called");
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

stock GetAllConnectedPlayers()
{
	new count = 0;
	
	for(new idx = 0; idx < PLAYERS; idx++)
	{
	    if(isPlayerConnected(idx))
	    {
	        count++;
		}
	}
	
	return count;
}

stock SendClientMessageToAllConnected(colour, const string[])
{
	for(new idx = 0; idx < PLAYERS; idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && pData[idx][pSpawned]) // Player is connected, not an NPC and has passed the spawn sequence.
	    {
	        SendClientMessage(idx, colour, string);
		}
	}

	return 1;
}


stock SendChatMessageToAllConnected(playerid, colour, string[])
{
	new player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	new text[128];
	format(text, 128, "{%s}%s {8D8D8D}[ALL] {FFFFFF}%s", pData[playerid][pColour], player_name, string);
	
	for(new idx = 0; idx < PLAYERS; idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && pData[idx][pSpawned]) // Player is connected, not an NPC and has passed the spawn sequence.
	    {
	        SendClientMessage(idx, colour, text);
		}
	}
	
	return 1;
}
	
forward UnfreezePlayer(playerid);
public UnfreezePlayer(playerid)
{
	TogglePlayerControllable(playerid, true);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	SendChatMessageToAllConnected(playerid, CHAT_COLOUR_WHITE, text);
	return 0; // Block normal text. Only scripted text we can control!
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new idx;
	new cmd[257];
	cmd = strtok(cmdtext, idx);

	if(!strcmp("/cmds", cmdtext, true)) {
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, "{FFFF6C}Useful commands{FFFFFF}:");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, "{8D8D8D}Teleports: {FFFFFF}/lsap, /sfap, /lvap, /vm, /chilliad");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, "{8D8D8D}Player: {FFFFFF}/stats, /kill");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, "{FF8080}Admin/debug commands{FFFFFF}:");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, "/time, /weather, /v, /save <comment>");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    return 1;
	}
	
	if(!strcmp("/stats", cmdtext, true)) {
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");

		new string[128];
		format(string, sizeof(string), "{FFFFFF}Player stats for {FFFF6C}%s{FFFFFF}:", GetPlayerNameEx(playerid));
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, string);
		
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    
	    format(string, sizeof(string), "{FFFFFF}Money: {FFFF6C}%d{FFFFFF}, SkinID: {FFFF6C}%d{FFFFFF}, Mental State: {%s}%d{FFFFFF}/100", pData[playerid][pMoney], pData[playerid][pSkin], pData[playerid][pColour], pData[playerid][pMentalState]);
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, string);
	    
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	    return 1;
	}
	
	if(!strcmp("/lsap", cmdtext, true)) {
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
	        SetVehiclePos(vehicleid, 1960.3511,-2248.1643,13.5469);
	        SetVehicleZAngle(vehicleid,179.0888);
	        return 1;
		}
		else {
		    SetPlayerPos(playerid, 1960.3511,-2248.1643,13.5469);
		    SetPlayerFacingAngle(playerid, 180.6789);
			return 1;
		}
	}
	
	if(!strcmp("/lvap", cmdtext, true)) {
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
	        SetVehiclePos(vehicleid, 1283.7458,1271.2754,10.8203);
	        SetVehicleZAngle(vehicleid,321.2141);
	        return 1;
		}
		else {
		    SetPlayerPos(playerid, 1318.8770,1257.8359,10.8203);
		    SetPlayerFacingAngle(playerid, 0.0);
			return 1;
		}
	}
	
	if(!strcmp("/sfap", cmdtext, true)) {
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
	        SetVehiclePos(vehicleid, -1219.0249,43.9976,14.1388);
	        SetVehicleZAngle(vehicleid,135.5626);
	        return 1;
		}
		else {
		    SetPlayerPos(playerid, -1261.2521,39.6852,14.1390);
		    SetPlayerFacingAngle(playerid, 222.0);
			return 1;
		}
	}
	
	if(!strcmp("/vm", cmdtext, true)) {
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
	        SetVehiclePos(vehicleid, 394.3755,2564.4768,16.4242);
	        SetVehicleZAngle(vehicleid,175.9714);
	        return 1;
		}
		else {
		    SetPlayerPos(playerid, 403.4544,2536.1899,16.5456);
		    SetPlayerFacingAngle(playerid, 142.7578);
			return 1;
		}
	}
	
	if(!strcmp("/sfaps", cmdtext, true)) {
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(vehicleid  && vehicleid != INVALID_VEHICLE_ID) {
	        SendClientMessage(playerid, CHAT_COLOUR_WHITE, "{FFFFFF}* You cannot take your vehicle with you to this location.");
	        return 1;
		}
		else {
		    SetPlayerPos(playerid, -1887.5553,-364.9149,38.2422);
		    SetPlayerFacingAngle(playerid, 184.4757);
			return 1;
		}
	}
	
	if(!strcmp("/chilliad", cmdtext, true)) {
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(vehicleid && vehicleid != INVALID_VEHICLE_ID) {
	        SendClientMessage(playerid, CHAT_COLOUR_WHITE, "{FFFFFF}* You cannot take your vehicle with you to this location.");
	        return 1;
		}
		else {
		    SetPlayerPos(playerid, -2454.3311,-1591.5286,490.5536);
		    SetPlayerFacingAngle(playerid, 288.6606);
		    TogglePlayerControllable(playerid, false);
		    SetTimerEx("UnfreezePlayer", 1000, 0, "d", playerid);
			return 1;
		}
	}

	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	
	if(strcmp(cmd, "/ms", true) == 0)
	{
		new tmp[256];
		tmp = strtok(cmdtext, idx);
		new val = strval(tmp); // value after /ms
		
		if(val >= 0 && val <= 100)
		{
		    SetPlayerMentalState(playerid, val);
		    new string[128];
		    format(string, sizeof(string), "Mental state set to %d. Reading back as %d, colour: %s", val, pData[playerid][pMentalState], pData[playerid][pColour]);
		    SendClientMessage(playerid, 0xFFFFFFFF, string);
		}
		else
		{
 			SendClientMessage(playerid, 0xFFFFFFFF, "Error: valid mental state value is from 0-100");
		}
	}
	
	if(strcmp(cmd, "/col", true) == 0)
	{

		new string[128];
		format(string, sizeof(string), "Your colour is currently: '%s', it looks like {%s}this{FFFFFF}.", pData[playerid][pColour], pData[playerid][pColour]);
		SendClientMessage(playerid, 0xFFFFFFFF, string);
		format(string, sizeof(string), "Your mental state is currently: %d", pData[playerid][pMentalState]);
		SendClientMessage(playerid, 0xFFFFFFFF, string);
		return 1;
	}
	
	if(strcmp(cmd, "/savedata", true) == 0)
	{

		SavePlayerDataToFile(playerid);
		SendClientMessage(playerid, 0xFFFFFFFF, "Send save data command.");
		return 1;
	} // ShowPlayerDialogBox(playerid, DIALOG_BOX_MENTAL_STATE);
	
	if(strcmp(cmd, "/db", true) == 0)
	{
        ShowPlayerDialogBox(playerid, DIALOG_BOX_MENTAL_STATE);
		return 1;
	}
	
	if(strcmp(cmd, "/hdb", true) == 0)
	{
 		HidePlayerDialogBox(playerid, DIALOG_BOX_MENTAL_STATE);
		return 1;
	}
	
	if(strcmp(cmd, "/msti", true) == 0)
	{
        pData[playerid][pMentalStateTracker] = 6;
        if(pData[playerid][pMentalStateTracker] > 3)
	    {
	        new player_name[MAX_PLAYER_NAME], string[128];
	        GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	        
	        format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF} Is on a killing spree!", pData[playerid][pColour], player_name);
			SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
			ShowPlayerDialogBox(playerid, DIALOG_BOX_MENTAL_STATE);
		}
		return 1;
	}
	
	if(strcmp(cmd, "/mstd", true) == 0)
	{
        pData[playerid][pMentalStateTracker] = 0;
		return 1;
	}
	
	if(strcmp(cmd, "/kill", true) == 0)
	{
        SetPlayerHealth(playerid, 0.0);
		return 1;
	}

	if(strcmp(cmd, "/time", true) == 0)
	{
		new tmp[256];
		tmp = strtok(cmdtext, idx);
		new val = strval(tmp); // value after /time
		
		if(val <= 23) // 0-23 is supported hour.
		{
		    gTimeHours = val;
			gTimeMinutes = 0;
			
		    for(new i; i < PLAYERS; i++)
		    {
		        SetPlayerTime(i, val, 0); // 0 minutes. on the hour.
			}
			
			new player_name[MAX_PLAYER_NAME], string[128];
			GetPlayerName(playerid, player_name, sizeof(player_name));
			
			format(string, sizeof(string), "Debug: %s has set the time to %d:00", player_name, val);
			SendClientMessageToAll(0xFFFFFFFF, string);
		}
		else
		{
		    SendClientMessage(playerid, 0xFFFFFFFF, "Error: valid time in hours is from 0-23");
		}
		
		return 1;
	}
	
	return 0;
}

public OnPlayerRequestClass(playerid, classid)
{
	printf("OnPlayerRequestClass called, pAccount = %d", pData[playerid][pAccount]);
	//TogglePlayerSpectating(playerid, true);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    printf("OnPlayerRequestSpawn called, status = %d", pData[playerid][pAccount]);
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

stock strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

// Testing Y_Commands

YCMD:ent(playerid, params[], help) 
{
	new entranceid;
	if(sscanf(params, "i", entranceid)) {
		return SendClientMessage(playerid, CHAT_COLOUR_WHITE, "* Params: /ent <entrance id>");
	}
	if(entranceid > MAX_ENTRANCES || entranceid < 0) {
		return SendClientMessage(playerid, CHAT_COLOUR_WHITE, "* Error: Invalid entrance ID.");
	}

	SetPlayerPos(playerid, gEntData[entranceid][ex], gEntData[entranceid][ey], gEntData[entranceid][ez]);
	SetPlayerFacingAngle(playerid, gEntData[entranceid][er]);
	SetPlayerInterior(playerid, gEntData[entranceid][e_interior]);

	new str[128];
	format(str, 128, "* Teleported to entrance ID %d.", entranceid);
	SendClientMessage(playerid, CHAT_COLOUR_PALE_DARK_GREEN, str);
	return 1;
}
