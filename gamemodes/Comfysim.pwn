#define _DEBUG 1
#define YSI_NO_HEAP_MALLOC

#include <a_samp>
#include <core>
#include <float>
#include <jit>
#include <YSI\YSI_Core\y_debug>
#include <YSI\YSI_Visual\y_commands>
#include <YSI\YSI_Storage\y_ini>
#include <YSI\YSI_Visual\y_classes>
#include <sscanf2>

#include <dini2>
#include <samp_bcrypt>
#include <streamer>
#include <screen-colour-fader>

#define MAX_PLAYER_FILE_LEN 44
#define SCREEN_COLOUR_BLACK 0x000000FF
#define SCREEN_COLOUR_TRANSPARENT 0x00000000
#define SPAWN_LOCATION_COUNT 11
#define SPAWN_SMOKING 0
#define SPAWN_SITTING 1
#define PASSWORD_MIN_LEN 8
#define PASSWORD_MAX_LEN 24
#define DIALOG_REGISTER 0
#define DIALOG_LOGIN 1
#define MAX_LOGIN_ATTEMPTS 3
#define CHAT_COLOUR_WHITE 0xFFFFFFFF
#define CHAT_COLOUR_PALE_YELLOW 0xFFFF6CFF
#define CHAT_COLOUR_PALE_DARK_GREEN 0x00954AFF
#define CHAT_COLOUR_PALE_RED 0xFF8080FF

enum E_PLAYER_DATA {
	Registering,				// Bool to refuse OnPlayerRequestClass () and define if the player is between registeringand spawning
	LoggingIn,					// Bool to refuse OnPlayerRequestClass () and define if the player is between logging in and spawning
	LoggedIn,					// Used to check if the player has logged in
	SkinSelection,
	JustDied, 
	Login_Attempts,
	SpawnIdx,
	Spawn_Sequence,
	EasyWayOut,

	LastIP[16],
	Password_Hash[128],
	Float:death_x, Float:death_y, Float:death_z, // Position tracker for death .
	Skin,
	Money,
	Colour[7], // Chat & Blip colour, standard is white but moves towards red when going physco like in GTA V.
	MentalState, // 0-19 = Normal, 20-39 = Unstable, 40-59 = Deranged, 60-79 = Maniac, 80-100 = Physcopath
	MentalStateTracker, // Used just to keep track of when to reduce a players mental state by 1 digit.

	Text:td_Killedby
}

new 
	pData[MAX_PLAYERS][E_PLAYER_DATA],
	pDataReset[E_PLAYER_DATA] // Dummy array to copy the enum vals.
;

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
{528.2549, -1762.5322, 14.2766, 174.8838, 489.8164, -1793.8965, 30.0, SPAWN_SMOKING}, // Beach Middl
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

enum HOSPITAL_DATA {
	Float:hx,
	Float:hy,
	Float:hz,
	Float:hr
}

new HospitalData[8][HOSPITAL_DATA] = {

	{1177.7179,-1323.4457,14.0845,269.8842}, // Los Santos All Saints
	{2032.8688,-1405.5126,17.2320,156.5682}, // Los Santos County General
	{1244.2462,331.2754,19.5547,337.4333}, // Red County Crippen Memorial Montgomer
	{1607.7214,1822.5175,10.8203,0.5218}, // Las Venturas Hospital
	{-1514.7462,2523.3435,55.8153,0.7756}, // El Quebrados Medical Center
	{-319.7820,1049.8525,20.3403,323.0506}, // Fort Carson Medical Center
	{-2653.8699,635.3766,14.4531,179.7929}, // San Fierro Medical Center
	{-2208.1658,-2286.6106,30.6250,321.7350} // Angel Pine Medical Center
};
#include "Comfysim\J_Textdraws.inc" // Includes textdraw creation so less clutter
#include "Comfysim\J_Functions.inc" // Central repository for all useful functions created for / used by the ComfySim scripts.
#include "Comfysim\J_Weather.inc" // Controls Weather & Time.
#include "Comfysim\J_Entrances.inc" // Loads dynamic entrances such as Gates and interiors.
#include "Comfysim\J_Class_Selection.inc"
#include "Comfysim\J_MentalState.inc"
#include "Comfysim\J_Commands.inc" // Contains all commands.
#include <YSI\YSI_Coding\y_hooks>

main() {
		print("Gamemode Loaded");
}


public OnGameModeInit() {

	SetGameModeText("CS v0.2.2 Alpha");
	ShowPlayerMarkers(true);
	LimitPlayerMarkerRadius(1500.0);
	ShowNameTags(true);
	SetNameTagDrawDistance(50.0);
	AllowInteriorWeapons(false);
	EnableZoneNames(true);

	SetTimer("SaveAllPlayerStats", 300000, true);
	SetTimer("PlayerMentalStateUpdate", 216000, true);

	return 1;
}

public OnGameModeExit() {
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	if(IsPlayerNPC(playerid)) { 
		return 1; 
	}

	if(!pData[playerid][SkinSelection]) {
		P:1("OnPlayerRequestClass(%d)");
		SkipClassSelection(playerid);
		P:1("OnPlayerRequestClass(%d): End of callback", playerid);
	}

	return 1;
}

public OnPlayerSpawn(playerid) {

	if(IsPlayerNPC(playerid)) { 
		return 1; 
	}

	if(pData[playerid][JustDied]) {
		P:1("OnPlayerSpawn(%d): Just died calling hospital function.", playerid);
		SendPlayerToHospital(playerid);
		return 1;
	}

	SendWelcomeMessage(playerid);

	if(pData[playerid][Registering] || pData[playerid][LoggingIn]) {
		P:1("OnPlayerSpawn(%d): Registering or Logging In", playerid);
		SetRegistrationPosition(playerid);
		return 1;
	}

	FadeScreenToBlack(playerid, 2000, 50);
	SpawnSequence(playerid, 0);

	P:1("OnPlayerSpawn(%d): End of callback", playerid);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {

	if(IsPlayerNPC(playerid)) { 
		return 1; 
	}

	P:1("OnPlayerDeath(%d): JustDied = %d, LoggingIn = %d, Registering = %d", playerid, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);

	if(killerid != INVALID_PLAYER_ID) {
		ShowKilledByTextdraw(playerid, killerid);
	}
	else if(pData[playerid][EasyWayOut]) {
		ShowWastedTextdraw(playerid, 1); // Easy way out
	}
	else {
		ShowWastedTextdraw(playerid, 0); // Committed Suicide
	}

	GetPlayerPos(playerid, pData[playerid][death_x], pData[playerid][death_y], pData[playerid][death_z]);
	pData[playerid][JustDied] = 1;
	FadeScreenToBlack(playerid, 3000, 125);

	P:1("OnPlayerDeath(%d): End of callback, JustDied set to 1 (%d).", playerid, pData[playerid][JustDied]);
	return 1;
}


public OnPlayerConnect(playerid) {

	if(IsPlayerNPC(playerid)) { 
		return 1; 
	}


	P:1("OnPlayerConnect(%d)");

	SetPlayerScreenColor(playerid, SCREEN_COLOUR_BLACK);
	SkipClassSelection(playerid);
	SetRegistrationPosition(playerid);

	if(!IsPlayerRegistered(playerid)) {
		P:1("OnPlayerConnect(%d): Player is not registered.", playerid);
		StartRegistrationForPlayer(playerid);
		return 1;
	}


	P:1("OnPlayerConnect(%d): Player is registered, player file = '%s'", playerid, GetPlayerFile(playerid));

	INI_ParseFile(GetPlayerFile(playerid), "LoadPlayerStatsFromFile_Data", .bExtra = true, .extra = playerid);
	SetPlayerMentalState(playerid, pData[playerid][MentalState]);

	if(strcmp(pData[playerid][LastIP], GetPlayerIpEx(playerid))) { // IP Address no NOT match,Login prompt. Update IP once logged in to enable auto-login.
		P:1("OnPlayerConnect(%d): IP Address does not match what is on file. (Current: %s, File: %s)", playerid, GetPlayerIpEx(playerid), pData[playerid][LastIP]);
		RequestPlayerLogin(playerid);
		return 1;
	}

	// Skip the spawn shit and spawn da player.
	pData[playerid][LoggingIn] = 1;
	//pData[playerid][LoggedIn] = 1;
	pData[playerid][Registering] = 0;

	P:1("End of OnPlayerConnect(%d)");
	SpawnSequence(playerid, 0);
	return 1;
}

forward LoadPlayerStatsFromFile_Data(playerid, name[], value[]);
public LoadPlayerStatsFromFile_Data(playerid, name[], value[]) {

	//P:1("LoadPlayerStatsFromFile(%d): JustDied = %d, LoggingIn = %d, Registering = %d", playerid, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);
	//INI_WriteString(file, "LastIP", GetPlayerIpEx(playerid)); // Write the current IP for next auto-login attempts.
	INI_String("LastIP", pData[playerid][LastIP]);
	INI_String("Password", pData[playerid][Password_Hash]);
	INI_Int("Skin", pData[playerid][Skin]);
	INI_Int("Money", pData[playerid][Money]);
	INI_Int("Mental_State", pData[playerid][MentalState]);

	//P:1("LoadPlayerStatsFromFile_Data(%d): End of function, Skin = %d", playerid, pData[playerid][Skin]);
	return 1;
}

forward SavePlayerStatsToFile(playerid);
public SavePlayerStatsToFile(playerid) {

	new INI:file = INI_Open(GetPlayerFile(playerid));

	INI_SetTag(file, "Data");
	INI_WriteInt(file, "Skin", GetPlayerSkin(playerid));
	INI_WriteInt(file, "Money", GetPlayerMoney(playerid));
	INI_WriteInt(file, "Mental_State", pData[playerid][MentalState]);
	//INI_WriteString(file, "LastIP", GetPlayerIpEx(playerid)); Saving this here results in 255.255.255.255 sometimes?

	INI_Close(file);
	return 1;
}

forward SaveAllPlayerStats();
public SaveAllPlayerStats() {
	P:1("SaveAllPlayerStats() Called");
	for(new i; i < GetMaxPlayers(); i++) {
		if(IsPlayerConnected(i) && !IsPlayerNPC(i) && !pData[i][LoggingIn] && !pData[i][Registering] && pData[i][LoggedIn]) {
			SavePlayerStatsToFile(i);
		}
	}

	return 1;
}

public OnPlayerDisconnect(playerid, reason) {

	if(IsPlayerNPC(playerid)) {
		return 1;
	}

	if(pData[playerid][LoggedIn]) {
		P:1("OnPlayerDisconnect(%d): Resetting Data...", playerid);
		SavePlayerStatsToFile(playerid);
		pData[playerid] = pDataReset;
		P:1("OnPlayerDisconnect(%d) End of callback");
	}

	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(IsPlayerNPC(playerid)) {
		return 0;
	}

	P:1("OnDialogResponse(%d, %d): JustDied = %d, LoggingIn = %d, Registering = %d", playerid, dialogid, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);

	switch(dialogid) {

		case DIALOG_REGISTER: {
			if(!response) {
				Kick(playerid);
				return 0;
			}

			if(!(strlen(inputtext) >= PASSWORD_MIN_LEN && strlen(inputtext) <= PASSWORD_MAX_LEN)) {
				P:1("OnDialogResponse(%d, %d): Password did not meet the server policy.", playerid, dialogid);
				new str[256];
				format(str, sizeof(str), "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\nPlease enter a password below to create an account.\n{FF8080}ERROR{FFFFFF}: Password must be between {FFFF6C}%d {FFFFFF}and {FFFF6C}%d {FFFFFF}characters in length.", PASSWORD_MIN_LEN, PASSWORD_MAX_LEN);
				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", str, "Register", "Quit");
				return 1;
			}

			P:1("OnDialogResponse(%d, %d): Entered password met the server policy, encrypting and then calling RegisterPlayer().", playerid, dialogid);
			bcrypt_hash(playerid, "RegisterPlayer", inputtext, 4);
			return 1;
		}

		case DIALOG_LOGIN: {
			if(!response) {
				Kick(playerid);
				return 0;
			}

			P:1("OnDialogResponse(%d, %d): Entered password, will now proceed to verify against hash under OnPasswordChecked()", playerid, dialogid);
			bcrypt_verify(playerid, "OnPasswordChecked", inputtext, pData[playerid][Password_Hash]);
			return 1;
		}
	}

	return 0;
}

forward OnPasswordChecked(playerid, bool:success);
public OnPasswordChecked(playerid, bool:success) {

	P:1("OnPasswordChecked(%d, %d): Called, will now check bool.", playerid, success);

	switch(success) {
		case false: {
			pData[playerid][Login_Attempts]++;
			if(pData[playerid][Login_Attempts] <= MAX_LOGIN_ATTEMPTS) {
				new str[256];
				format(str, sizeof(str), "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\n{FF8080}ERROR{FFFFFF}: Password incorrect, please try again. Attempt {FFFF6C}%d{FFFFFF} of {FFFF6C}%d", pData[playerid][Login_Attempts], MAX_LOGIN_ATTEMPTS);
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", str, "Login", "Exit");
				return 1;
			}
			SendClientMessage(playerid, 0xFFFFFFFF, "ERROR: Password incorrect, no more attempts.");
			Kick(playerid);
		}
		case true: {
			FadeScreenToBlack(playerid, 2000, 100);
			P:1("OnPasswordChecked(%d, %d): Password was verified successfully against the hash, will now call SpawnSequence() to spawn the player.", playerid, success);
			SpawnSequence(playerid, 0);
			pData[playerid][LoggedIn] = 1;
		}
	}

	return 1;
}

forward RegisterPlayer(playerid);
public RegisterPlayer(playerid) {

	P:1("RegisterPlayer(%d)");
	FadeScreenToBlack(playerid, 1000, 50);

	new fileToWrite[MAX_PLAYER_FILE_LEN];
	format(fileToWrite, MAX_PLAYER_FILE_LEN, "Comfysim/Accounts/%s.ini", GetPlayerNameEx(playerid));
	new INI:file = INI_Open(fileToWrite);

	if(file == INI_NO_FILE) {
		SendClientMessage(playerid, 0xFFFFFFFF, "ERROR: There was a problem creating your account. :(");
		StartRegistrationForPlayer(playerid);
		return 1;
	}

	bcrypt_get_hash(pData[playerid][Password_Hash]);
	SetupRegisterFileTemplate(playerid, file);

	//FadeScreenToBlack(playerid, 2000, 50);
	pData[playerid][Registering] = 0;
	pData[playerid][SkinSelection] = 1; // This is set to 1 so OnPlayerRequestClass() can be used.
	SendPlayerToClassSelection(playerid);
	//SpawnSequence(playerid, 0);
	P:1("RegisterPlayer(%d): End of function");

	return 1;
}

public OnScreenColourFadeComplete(playerid) {
	P:1("OnScreenColourFadeComplete(%d)");
	if(pData[playerid][LoggingIn] && !pData[playerid][SkinSelection]) {
		new idx = pData[playerid][Spawn_Sequence];

		if(!idx) {
			FadeScreenToBlack(playerid, 3000, 125);
		}
		else {
			FadeScreenToBlack(playerid, 2000, 100);
		}
	}
}

forward SpawnSequence(playerid, sequence);
public SpawnSequence(playerid, sequence) {

	//P:1("SpawnSequence(%d, %d): JustDied = %d, LoggingIn = %d, Registering = %d, Skin = %d", playerid, sequence, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering], pData[playerid][Skin]);
	new
		idx,
		Float:x, Float:y, Float:z
	;

	switch(sequence) {
		case 0: {
			idx = random(SPAWN_LOCATION_COUNT);
			x = gSpawnLocations[idx][spawn_x];
			y = gSpawnLocations[idx][spawn_y];
			z = gSpawnLocations[idx][spawn_z];
			pData[playerid][Spawn_Sequence] = 0;
			pData[playerid][SpawnIdx] = idx;
			pData[playerid][LoggingIn] = 1;
			P:1("SpawnSequence(%d, %d): Case 0.", playerid, sequence);

			//SetSpawnInfo(playerid, 0, pData[playerid][Skin], x, y, z, gSpawnLocations[idx][spawn_r], 0, 0, 0, 0, 0, 0);
			FadeScreenToTransparent(playerid, 2000, 100);
			SetPlayerInterior(playerid, 0); // Because spawn selection is in Interior #6 LSPD
			SetPlayerCameraPos(playerid, x, y, z+400); // Set camera in the air.
			SetPlayerCameraLookAt(playerid, x, y, z);
			SetPlayerSkin(playerid, pData[playerid][Skin]);
			PlayerPlaySound(playerid, 1058, x, y, z+400);
			SetTimerEx("SpawnSequence", 8000, false, "dd", playerid, 1);
		}
		case 1: {
			idx = pData[playerid][SpawnIdx];
			x = gSpawnLocations[idx][spawn_x];
			y = gSpawnLocations[idx][spawn_y];
			z = gSpawnLocations[idx][spawn_z];
			pData[playerid][Spawn_Sequence] = 1;
			P:1("SpawnSequence(%d, %d): Case 1.", playerid, sequence);

			FadeScreenToTransparent(playerid, 1000, 50);
			SetPlayerCameraPos(playerid, x, y, z+200); // Set camera in the air.
			SetPlayerCameraLookAt(playerid, x, y, z);
			SetPlayerPos(playerid,  x, y, z); 
			SetPlayerFacingAngle(playerid, gSpawnLocations[idx][spawn_r]);
			StartSpawnAnimation(playerid);
			PlayerPlaySound(playerid, 1058, x, y, z+200);
			SetTimerEx("SpawnSequence", 3000, false, "dd", playerid, 2);
		}
		case 2: {
			idx = pData[playerid][SpawnIdx];
			x = gSpawnLocations[idx][spawn_x];
			y = gSpawnLocations[idx][spawn_y];
			z = gSpawnLocations[idx][spawn_z];
			pData[playerid][Spawn_Sequence] = 2;
			P:1("SpawnSequence(%d, %d): Case 2.", playerid, sequence);

			FadeScreenToTransparent(playerid, 1000, 50);
			SetPlayerCameraPos(playerid, x, y, z+100); // Set camera in the air.
			SetPlayerCameraLookAt(playerid, x, y, z);
			PlayerPlaySound(playerid, 1058, x, y, z+100);
			SetTimerEx("SpawnSequence", 3000, false, "dd", playerid, 3);
		}
		case 3: {
			idx = pData[playerid][SpawnIdx];
			x = gSpawnLocations[idx][spawn_x];
			y = gSpawnLocations[idx][spawn_y];
			z = gSpawnLocations[idx][spawn_z];
			pData[playerid][Spawn_Sequence] = 3;
			P:1("SpawnSequence(%d, %d): Case 3.", playerid, sequence);

			FadeScreenToTransparent(playerid, 1000, 50);
			SetPlayerCameraPos(playerid, gSpawnLocations[idx][spawn_cam_x], gSpawnLocations[idx][spawn_cam_y], gSpawnLocations[idx][spawn_cam_z]); // Set camera in the air.
			SetPlayerCameraLookAt(playerid, x, y, z);
			PlayerPlaySound(playerid, 1058, gSpawnLocations[idx][spawn_cam_x], gSpawnLocations[idx][spawn_cam_y], gSpawnLocations[idx][spawn_cam_z]);
			SetTimerEx("SpawnSequence", 3000, false, "dd", playerid, 4);

		}
		case 4: {
			P:1("SpawnSequence(%d, %d): Case 4.", playerid, sequence);
			x = gSpawnLocations[idx][spawn_x];
			y = gSpawnLocations[idx][spawn_y];
			z = gSpawnLocations[idx][spawn_z];
			FadeScreenToTransparent(playerid, 4000, 200);
			SetCameraBehindPlayer(playerid);
			SetTimerEx("StopSpawnAnimation", 4000, false, "d", playerid);
			//StopSpawnAnimation(playerid);
			pData[playerid][LoggingIn] = 0;
			pData[playerid][Registering] = 0;
			pData[playerid][LoggedIn] = 1;
			SavePlayerStatsToFile(playerid);
			PlayerPlaySound(playerid, 35451, 0.0, 0.0, 0.0); // Follow the train CJ!
			P:1("SpawnSequence(%d, %d): Case 4, JustDied = %d, LoggingIn = %d, Registering = %d", playerid, sequence, pData[playerid][JustDied], pData[playerid][LoggingIn], pData[playerid][Registering]);
		}

	}


	return 1;
}

stock SetupRegisterFileTemplate(playerid, INI:File) {
	P:1("SetupRegisterFileTemplate(%d)", playerid);
	INI_SetTag(File, "Data");
	INI_WriteString(File, "Password", pData[playerid][Password_Hash]);
	INI_WriteString(File, "LastIP", GetPlayerIpEx(playerid));
	INI_WriteInt(File, "Skin", 299);
	INI_WriteInt(File, "Money", 0);
	INI_WriteInt(File, "Mental_State", 0);
	INI_Close(File);
	return 1;
}
