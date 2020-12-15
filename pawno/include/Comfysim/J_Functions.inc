/*
	Functions used throughout the Comfysim scripts will be stored here as a central repository / include.

	This needs to be <included> below <streamer> as this script redefines CreateDynamicObject()
*/

// Constants

// Screen Fading
#define SCREEN_FADE_DEFAULT_INTERVAL 2000	// Default interval of all screen fades unless specified
#define SCREEN_FADE_DEFAULT_CHANGES 50 	// Higher the number, smoother the fade.

// MapLoader / Object / Vehicles
#define MAX_VEHICLE_COMPONENTS 14
#define MAX_REMOVED_OBJECTS 300

enum E_VEHICLE_DATA {
	vehicle_id, colour1, colour2
}

enum E_REMOVED_OBJECTS_DATA {
	rm_modelid, rm_lodmodel,
	Float:rmx, Float:rmy, Float:rmz, Float:rm_radius
}

forward Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2);
public Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower(floatabs(floatsub(x, x2)),2)+floatpower(floatabs(floatsub(y, y2)),2)+floatpower(floatabs(floatsub(z, z2)),2));
}

SendClientMessageToAllConnected(colour, const string[])
{
	for(new idx = 0; idx < GetMaxPlayers(); idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && IsPlayerLoggedIn(idx)) // Player is connected, not an NPC and has passed the spawn sequence.
	    {
	        SendClientMessage(idx, colour, string);
		}
	}

	return 1;
}

GetPlayerFile(playerid) {
	new fileToRead[MAX_PLAYER_FILE_LEN];
	format(fileToRead, MAX_PLAYER_FILE_LEN, "/Comfysim/Accounts/%s.ini", GetPlayerNameEx(playerid));
	P:1("[J_Functions]: GetPlayerFile(%d): '%s'", playerid, fileToRead);
	return fileToRead;
}

SendPlayerToHospital(playerid) {

	P:1("SendPlayerToHospital(%d)", playerid);
	new 
		Float:distance_tracker, Float:hospital_distance = 1000000.0, idx,
		Float:x =  pData[playerid][death_x], Float:y =  pData[playerid][death_y], Float:z =  pData[playerid][death_z]
	;

	for(new i; i < 8; i++) {
		distance_tracker = GetDistBetweenTwoPoints(x, y, z, HospitalData[i][hx], HospitalData[i][hy], HospitalData[i][hz]);

		P:1("SendPlayerToHospital(%d): idx (%d), distance_tracker (%f), hospital_distance (%f)", playerid, idx, distance_tracker, hospital_distance);
		if(hospital_distance > distance_tracker) {
			hospital_distance = distance_tracker;
			idx = i;
		}
	}

	P:1("SendPlayerToHospital(%d): Idx (%d), x, y, z (%f, %f, %f)", playerid, idx, x, y, z);
	HideWastedTextdraw(playerid);
	SetPlayerPos(playerid, HospitalData[idx][hx], HospitalData[idx][hy], HospitalData[idx][hz]);
	SetPlayerFacingAngle(playerid, HospitalData[idx][hr]);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, false);
	Bit_Vet(pDied, playerid);
	FadeScreenToTransparent(playerid, 3000, 125);
	SetTimerEx("StopAllAnimationsAndUnfreeze", 2000, false, "i", playerid);
	return 1;
}

stock GetPlayerNameEx(playerid) {
	new player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	return player_name;
}

//Currently unused, but will be needed perhaps in the future.
stock GetPlayerIpEx(playerid) {
	new player_ip[16];
	GetPlayerIp(playerid, player_ip, 16);
	return player_ip;
}

SendWelcomeMessage(playerid)
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
	
	if(IsPlayerRegistered(playerid))
	{
		format(string, sizeof(string), "{FFFFFF}Welcome back to the server {FFFF6C}%s{FFFFFF}!", player_name);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, string);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	}
	else
	{
		format(string, sizeof(string), "{FFFFFF}Welcome to the server {FFFF6C}%s{FFFFFF}!", player_name);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, string);
		SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	}
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, "Type {FFFF6C}/cmds {FFFFFF}for a list of commands.");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, "Enjoy your time here and {FF8080}don't be a dick{ffffff}!");
	SendClientMessage(playerid, CHAT_COLOUR_WHITE, " ");
	
	return 1;
}


forward SetScreenToBlack(playerid);
public SetScreenToBlack(playerid) {
	P:1("SetScreenToBlack(%d)", playerid);
	SetPlayerScreenColor(playerid, 0x000000FF); // Black
	return 1;
}

forward FadeToBlack(playerid);
public FadeToBlack(playerid) {
	FadeScreenToBlack(playerid);
	return 1;
}
FadeScreenToBlack(playerid, interval=SCREEN_FADE_DEFAULT_INTERVAL, changes=SCREEN_FADE_DEFAULT_CHANGES) {
	P:1("FadeScreenToBlack(%d)", playerid);
	Bit_Let(pScreenBlack, playerid); // Screen is black.
	FadePlayerScreenColour(playerid, 0x000000FF, interval, changes); // Black
	return 1;
}

FadeScreenToTransparent(playerid, interval=SCREEN_FADE_DEFAULT_INTERVAL, changes=SCREEN_FADE_DEFAULT_CHANGES) {
	P:1("FadeScreenToTransparent(%d)", playerid);
	Bit_Vet(pScreenBlack, playerid); // Screen is not black.
	FadePlayerScreenColour(playerid, 0x00000000, interval, changes); // Transparent
	return 1;
}

IsPlayersScreenBlack(playerid) {
	return Bit_Get(pScreenBlack, playerid);
}

IsPlayersScreenTransparent(playerid) {
	return !IsPlayersScreenBlack(playerid); // Inverse of IsBlack
}


IsPlayerInClassSelection(playerid) {
	return Bit_Get(pClassSelection, playerid);
}

IsPlayerLoggedIn(playerid) {
	return Bit_Get(pLoggedIn, playerid);
}

stock IsPlayerSpawned(playerid) {
	return Bit_Get(pSpawned, playerid);
}

HasPlayerJustDied(playerid) {
	return Bit_Get(pDied, playerid);
}

IsPlayerRegistering(playerid) {
	return Bit_Get(pRegistering, playerid);
}

IsPlayerLoggingIn(playerid) {
	return Bit_Get(pLoggingIn, playerid);
}

IsPlayerRegistered(playerid) {
	new
		fileToRead[MAX_PLAYER_FILE_LEN], 
		File:file
	;

	format(fileToRead, MAX_PLAYER_FILE_LEN, "Comfysim/Accounts/%s.ini", GetPlayerNameEx(playerid));
	file = fopen(fileToRead, io_read);

	if(!file) {
		P:1("IsPlayerRegistered(%d): No file found for player, returning false.");
		return 0;
	}

	P:1("IsPlayerRegistered(%d): File found for the player, returning true.");
	return 1;
}
