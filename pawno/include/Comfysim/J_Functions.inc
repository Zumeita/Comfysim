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


#include <streamer>

forward Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2);
public Float:GetDistBetweenTwoPoints(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower(floatabs(floatsub(x, x2)),2)+floatpower(floatabs(floatsub(y, y2)),2)+floatpower(floatabs(floatsub(z, z2)),2));
}

SendClientMessageToAllConnected(colour, const string[])
{
	for(new idx = 0; idx < GetMaxPlayers(); idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && !pData[idx][LoggingIn] && !pData[idx][Registering]) // Player is connected, not an NPC and has passed the spawn sequence.
	    {
	        SendClientMessage(idx, colour, string);
		}
	}

	return 1;
}

SkipClassSelection(playerid) {
	P:1("SkipClassSelection(%d): JustDied = %d, LoggingIn = %d, Registering = %d", playerid, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);
	SetSpawnInfo(playerid, 0, pData[playerid][Skin], 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	TogglePlayerControllable(playerid, false);
	P:1("SkipClassSelection(%d): End of function", playerid);
}

GetPlayerFile(playerid) {
	new fileToRead[MAX_PLAYER_FILE_LEN];
	format(fileToRead, MAX_PLAYER_FILE_LEN, "/Comfysim/Accounts/%s.ini", GetPlayerNameEx(playerid));
	return fileToRead;
}

RequestPlayerLogin(playerid) {
	P:1("RequestPlayerLogin(%d): JustDied = %d, LoggingIn = %d, Registering = %d", playerid, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);
	FadeScreenToTransparent(playerid, 200, 100);
	//pData[playerid][LoggingIn] = 1;// Set to avoid OnPlayerRequestClass()
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\nYour current IP Address does not match the one we have on file for you.\nPlease login so we can confirm your identity and update your IP Address for future logins.", "Login", "Exit");
	P:1("RequestPlayerLogin(%d): End of function.", playerid);
	return 1;
}

SendPlayerToHospital(playerid) {

	P:1("SendPlayerToHospital(%d): JustDied = %d, LoggingIn = %d, Registering = %d", playerid, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);

	new 
		Float:distance_tracker, Float:hospital_distance = 1000000.0, idx,
		Float:x =  pData[playerid][death_x], Float:y =  pData[playerid][death_y], Float:z =  pData[playerid][death_z]
	;

	for(new i; i < 8; i++) {
		distance_tracker = GetDistBetweenTwoPoints(x, y, z, HospitalData[i][hx], HospitalData[i][hy], HospitalData[i][hz]);

		if(hospital_distance > distance_tracker) {
			hospital_distance = distance_tracker;
			idx = i;
		}
	}

	HideWastedTextdraw(playerid);
	SetPlayerPos(playerid, HospitalData[idx][hx], HospitalData[idx][hy], HospitalData[idx][hz]);
	SetPlayerFacingAngle(playerid, HospitalData[idx][hr]);
	TogglePlayerControllable(playerid, false);
	pData[playerid][JustDied] = 0;
	SetTimerEx("StopSpawnAnimation", 6000, false, "i", playerid);
	P:1("SendPlayerToHospital(%d): End of function. JustDied = %d", playerid, pData[playerid][JustDied]);

	return 1;
}

FadeScreenToBlack(playerid, length, changes) {
	P:1("FadeScreenToBlack(%d, %d, %d): Called", playerid, length, changes);
	FadePlayerScreenColour(playerid, SCREEN_COLOUR_BLACK, length, changes);
	return 1;
}

FadeScreenToTransparent(playerid, length, changes) {
	P:1("FadeScreenToTransparent(%d, %d, %d): Called", playerid, length, changes);
	FadePlayerScreenColour(playerid, SCREEN_COLOUR_TRANSPARENT, length, changes);
	return 1;
}

stock StartSpawnAnimation(playerid) {
	switch(gSpawnLocations[pData[playerid][SpawnIdx]][spawn_action]) {
		case SPAWN_SITTING: {
			ApplyAnimation(playerid, "PED", "SEAT_IDLE", 4.0, 1, 0, 0, 1, 25000, 1);
			P:1("StartSpawnAnimation Sitting");
		}
		case SPAWN_SMOKING: {
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
			ApplyAnimation(playerid, "GANGS", "SMKCIG_PRTL", 4.0, 1, 0, 0, 1, 25000, 1); // smoke cig
			P:1("StartSpawnAnimation Smoking");
		}

	}
}

forward StopSpawnAnimation(playerid);
public StopSpawnAnimation(playerid) {
	switch(gSpawnLocations[pData[playerid][SpawnIdx]][spawn_action]) {
		case SPAWN_SITTING: {
			P:1("StopSpawnAnimation case SPAWN_SITTING");
			ApplyAnimation(playerid, "PED", "SEAT_UP", 4.0, 0, 0, 0, 0, 0, 1);
			SetTimerEx("StopAllAnimationsAndUnfreeze", 1500, false, "d", playerid);
			//TogglePlayerControllable(playerid, true);
		}
		case SPAWN_SMOKING: {
			StopAllAnimationsAndUnfreeze(playerid);
			P:1("StopSpawnAnimation case SPAWN_SMOKING");
		}
	}

	FadeScreenToTransparent(playerid, 2000, 100);
	pData[playerid][SpawnIdx] = 0;
	return 1;
}

forward  StopAllAnimationsAndUnfreeze(playerid);
public StopAllAnimationsAndUnfreeze(playerid) {
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ClearAnimations(playerid, 1);
	TogglePlayerControllable(playerid, true);
	return 1;
}

stock SetRegistrationPosition(playerid) {
	P:1("SetRegistrationPosition() Called");
	SetPlayerPos(playerid, 1947.0, -846.09, 0.0);
	SetPlayerCameraPos(playerid, 1947.0, -846.09, 129.4);
	SetPlayerCameraLookAt(playerid, 1499.5, -1228.9, 81.7);
	//PlayerPlaySound(playerid, 35451, 1947.0, -846.09, 129.4); // Follow the train CJ!
	return 1;
}


stock StartRegistrationForPlayer(playerid) {
	P:1("[DEBUG]: StartRegistrationForPlayer");
	//SetRegistrationPosition(playerid);
	FadeScreenToTransparent(playerid, 2500, 100);

	new str[256];
	format(str, sizeof(str), "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\nPlease enter a password below to create an account.\nPassword must be between {FFFF6C}%d {FFFFFF}and {FFFF6C}%d {FFFFFF}characters in length.", PASSWORD_MIN_LEN, PASSWORD_MAX_LEN);
	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", str, "Register", "Quit");
	pData[playerid][Registering] = 1;
	return 1;
}



// Returns 0 if no file found, 1 if a file is found.
stock IsPlayerRegistered(playerid) {
	P:1("IsplayerRegistered");
	new fileToRead[MAX_PLAYER_FILE_LEN], File:file;
	format(fileToRead, MAX_PLAYER_FILE_LEN, "Comfysim/Accounts/%s.ini", GetPlayerNameEx(playerid));
	file = fopen(fileToRead, io_read);

	if(!file) {
		P:1("IsplayerRegistered NO FILE.");
		return 0;
	}

	P:1("IsplayerRegistered FOUND FILE.");
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
	
	if(IsPlayerRegistered(playerid))
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
