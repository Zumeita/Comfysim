/*
	Black screen fade upon spawn
	OnPlayerSpawn is blocked by Y_Classes after OnPlayerDeath due to the disabling of Class Selection ?


*/

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
#include <YSI\YSI_Data\y_bit>
#include <sscanf2>

#include <dini2>
#include <samp_bcrypt>
#include <streamer>
#include <screen-colour-fader>

#define SCREEN_COLOUR_BLACK 0x000000FF
#define SCREEN_COLOUR_TRANSPARENT 0x00000000
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
#undef MAX_PLAYER_NAME
#define MAX_PLAYER_NAME 25 // This includes the +1
#define MAX_PLAYER_FILE_LEN (55)
#define SPAWN_SEQ_FADE_INTERVAL 6000 // The first step of spawn sequence interval. How long to be far in the air for?
#define SPAWN_SEQ_STOP_ANI_INTERVAL 1000 // Making this more than SCREEN_FADE_INTERVAL will cause a to-black fade once spawned!
#define MAX_SPAWN_LOCATIONS 11

new gStr[256]; // Global string. Eventually spit to 'Small' 'Medium and 'Large.'

enum E_PLAYER_DATA {
	Login_Attempts,
	SpawnIdx,
	SpawnSequence,
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

new BitArray:pRegistering<MAX_PLAYERS>;	// Is the player at the Register dialog?
new	BitArray:pLoggingIn<MAX_PLAYERS>; 	// Is the player at the Login dialog?
new	BitArray:pLoggedIn<MAX_PLAYERS>;		// Is the player Logged in?
new	BitArray:pClassSelection<MAX_PLAYERS>; // Is the player in the class selection screen?
new	BitArray:pSpawned<MAX_PLAYERS>;		// Is the player Spawned?
new	BitArray:pScreenBlack<MAX_PLAYERS>;	// Is the players' screen black?
new	BitArray:pDied<MAX_PLAYERS>;			// Has the player just died?
new	BitArray:pEasyWayOut<MAX_PLAYERS>;	// Has the player just killed himself using /kill, no other method?

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
new gSpawnLocations[MAX_SPAWN_LOCATIONS][SPAWN_SETTINGS] = {
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
#include "Comfysim\J_Weather.inc" // Controls Weather & Time.
#include "Comfysim\J_MentalState.inc"
#include "Comfysim\J_Functions.inc" // Central repository for all useful functions created for / used by the ComfySim scripts.
#include "Comfysim\J_Entrances.inc" // Loads dynamic entrances such as Gates and interiors.
#include "Comfysim\J_Commands.inc" // Contains all commands.
#include "Comfysim\J_Class_Selection.inc"
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

public OnPlayerConnect(playerid) {

	PlayerPlaySound(playerid, 35451, 0.0, 0.0, 0.0); // Follow the train CJ!
	P:1("OnPlayerConnect(%d)", playerid);
	if(IsPlayerNPC(playerid)) { // Ignore NPCs, let them straight in.
		return 1;
	}

	//SetScreenToBlack(playerid);
	SetTimerEx("AfterPlayerConnect", 1000, false, "d", playerid); // This is only to give time for the disable selection to run and become spectating, before doing any position moving - otherwise it gets stuck. SAMP Bug.
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	if(!IsPlayerInClassSelection(playerid)) {
		Class_DisableSelection(playerid); // Disable Class Selection until we know what to do

	}

	return 1;
}
forward AfterPlayerConnect(playerid);
public AfterPlayerConnect(playerid) {

	P:1("AfterPlayerConnect(%d)", playerid);

	if(IsPlayerNPC(playerid)) { // Ignore NPCs, let them straight in.
		return 1;
	}

	SendWelcomeMessage(playerid);
	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, false);
	SetInitialConnectPosition(playerid);

	// First thing's first - I need to know if they have an account on the server or not.
	if(IsPlayerRegistered(playerid)) {
		P:1("OnPlayerConnect(%d): Player is Registered", playerid);
		// Ok , they already have an account with the server, load the player data fist (This includes the IP address!) and then check the IP to force login if they do not match.
		INI_ParseFile(GetPlayerFile(playerid), "LoadPlayerStatsFromFile_Data", .bExtra = true, .extra = playerid);
		SetPlayerMentalState(playerid, pData[playerid][MentalState]);

		new ip_address[16];
		format(ip_address, 16, "%s", GetPlayerIpEx(playerid));

		if(!(strcmp(ip_address, pData[playerid][LastIP]))) { // IP Address is a match, spawn them in with no interruptions .
			P:1("OnPlayerConnect(%d): IP Address matches", playerid);
			StartPlayerSpawnSequence(playerid); // This also fades the screen to Black
			return 1;
		}
		P:1("OnPlayerConnect(%d): IP Address does not match", playerid);
		RequestPlayerLogin(playerid); // IP Address was not a match, so let's ask them to log in.
		return 1;
	}
	P:1("OnPlayerConnect(%d): Not Registered", playerid);
	RequestPlayerRegister(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {

	P:1("OnPlayerDisconnect(%d)", playerid);
	if(IsPlayerNPC(playerid)) {
		return 1;
	}

	if(IsPlayerLoggedIn(playerid)) { // Only save stats if the player has logged in.
		SavePlayerStatsToFile(playerid);
	}

	pData[playerid] = pDataReset; // Reset everything to false/zero/default val.
	pData[playerid][SpawnIdx] = -1; // -1 is the no spawn fade value
	// Reset the bit checks all to 0/false.
	Bit_Vet(pRegistering, playerid);
	Bit_Vet(pLoggingIn, playerid);
	Bit_Vet(pLoggedIn, playerid);
	Bit_Vet(pClassSelection, playerid);
	Bit_Vet(pSpawned, playerid);
	Bit_Vet(pScreenBlack, playerid);
	Bit_Vet(pDied, playerid);
	Bit_Vet(pEasyWayOut, playerid);
	return 1;
}


public OnPlayerSpawn(playerid) {

	P:1("OnPlayerSpawn(%d)", playerid);
	if(IsPlayerNPC(playerid)) { 
		return 1; 
	}

	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	P:1("OnPlayerRequestSpawn(%d)", playerid);

	if(IsPlayerInClassSelection(playerid)) {
		pData[playerid][Skin] = GetPlayerSkin(playerid);
		FadeScreenToBlack(playerid); // Pick this up OnScreenFade, IsPlayerInClassSelection is true
	}

	return 0; // Set the skin & start the fade but DO NOT allow the player to spawn (Avoids flying guy)
}

public OnPlayerDeath(playerid, killerid, reason) {

	P:1("OnPlayerDeath(%d)", playerid);
	if(IsPlayerNPC(playerid)) { 
		return 1; 
	}

	GetPlayerPos(playerid, pData[playerid][death_x], pData[playerid][death_y], pData[playerid][death_z]); // Get this first just to make sure it's saved before the position automatically changes by SAMP
	Bit_Let(pDied, playerid);

	if(killerid != INVALID_PLAYER_ID) {
		ShowKilledByTextdraw(playerid, killerid);
	}
	else if(Bit_Get(pEasyWayOut, playerid)) {
		ShowWastedTextdraw(playerid, 1); // Easy way out
	}
	else {
		ShowWastedTextdraw(playerid, 0); // Committed Suicide
	}

	FadeScreenToBlack(playerid, 3500, 100);

	return 1;
}

public OnScreenColourFadeComplete(playerid) {

	if(HasPlayerJustDied(playerid)) {
		SpawnPlayer(playerid);
		SendPlayerToHospital(playerid);
		return 1;
	}

	if(pData[playerid][SpawnIdx] != -1) { // Player has entered the spawn sequence, it is 0-4
		if(IsPlayersScreenTransparent(playerid)) { // If this is true, the players screen is currently blacked out.
			P:1("OnScreenColourFadeComplete(%d): Spawn sequence, transparent", playerid);
			SetTimerEx("FadeToBlack", SCREEN_FADE_DEFAULT_INTERVAL, false, "d", playerid); // Fade back to Black after some time already defined.
			return 1;
		}
		if(IsPlayersScreenBlack(playerid)) { // Timer above has finished running, and the screen is now black.
			P:1("OnScreenColourFadeComplete(%d): Spawn sequence, black", playerid);
			NextSpawnSequence(playerid, pData[playerid][SpawnSequence]); // Screen is faded to Transparent last.
		}
	}

	if(IsPlayerRegistering(playerid) && !IsPlayerInClassSelection(playerid)) { // Player has just been asked to register, let's show him the dialog after fading to transparent.
		P:1("OnScreenColourFadeComplete(%d): Registering", playerid);
		format(gStr, sizeof(gStr), "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\nPlease enter a password below to create an account.\nPassword must be between {FFFF6C}%d {FFFFFF}and {FFFF6C}%d {FFFFFF}characters in length.", PASSWORD_MIN_LEN, PASSWORD_MAX_LEN);
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", gStr, "Register", "Quit");
		//Bit_Vet(pRegistering, playerid); // Turn this off now so the fade out once responding to the dialog doesnt spawn this dialog again..
		return 1;
	}

	if(IsPlayerLoggingIn(playerid) && IsPlayerLoggedIn(playerid)) { // Player has successfully entered their password. Logged in is set between the password being verified as True and the screen fade, so these will both be true.
		P:1("OnScreenColourFadeComplete(%d): Logging In", playerid);
		Bit_Vet(pLoggingIn, playerid); 	// Player is no longer LOGGING in.
		StartPlayerSpawnSequence(playerid);
		return 1;
	}

	if(IsPlayerInClassSelection(playerid)) {
		if(IsPlayersScreenBlack(playerid)) {
			if(IsPlayerRegistering(playerid)) { // Coming from RegisterPlayer()
				P:1("OnScreenColourFadeComplete(%d): Class Selection, Black screen & Registering", playerid);
				SendPlayerToClassSelection(playerid); // Send to class selection - force reselection and set coords, interior, etc. Fades to Transparent.
				Bit_Vet(pRegistering, playerid); // No longer registering.
				return 1;
			}
			// Not registering, but IS in class selection, so it's time to start the spawn sequence.
			P:1("OnScreenColourFadeComplete(%d): Class Selection, Not registering", playerid);

			SpawnPlayer(playerid);
			Class_DisableReselection(playerid);
			Bit_Vet(pClassSelection, playerid);
			SetTimerEx("OnClassSelectionComplete", 1000, false, "d", playerid);
			return 1;
		}
	}
	return 1;
}

forward OnClassSelectionComplete(playerid);
public OnClassSelectionComplete(playerid) { // This callback exists due to a 500ms timer between 'spawning' from Class selection and the black screen
	StartPlayerSpawnSequence(playerid);
	return 1;
}

forward LoadPlayerStatsFromFile_Data(playerid, name[], value[]);
public LoadPlayerStatsFromFile_Data(playerid, name[], value[]) {

	P:1("LoadPlayerStatsFromFile_Data(%d, '%s', '%s')", playerid, name, value);
	INI_String("LastIP", pData[playerid][LastIP]);
	INI_String("Password", pData[playerid][Password_Hash]);
	INI_Int("Skin", pData[playerid][Skin]);
	INI_Int("Money", pData[playerid][Money]);
	INI_Int("Mental_State", pData[playerid][MentalState]);

	return 1;
}

forward SavePlayerStatsToFile(playerid);
public SavePlayerStatsToFile(playerid) {

	P:1("SavePlayerStatsToFile(%d)", playerid);
	new INI:file = INI_Open(GetPlayerFile(playerid));

	INI_SetTag(file, "Data");
	INI_WriteInt(file, "Skin", GetPlayerSkin(playerid));
	INI_WriteInt(file, "Money", GetPlayerMoney(playerid));
	INI_WriteInt(file, "Mental_State", pData[playerid][MentalState]);

	INI_Close(file);
	return 1;
}

forward SaveAllPlayerStats();
public SaveAllPlayerStats() {
	P:1("SaveAllPlayerStats() Called");
	for(new i; i < GetMaxPlayers(); i++) {
		if(IsPlayerConnected(i) && !IsPlayerNPC(i) && IsPlayerLoggedIn(i)) {
			SavePlayerStatsToFile(i);
		}
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	P:1("OnDIalogResponse(%d, %d)", playerid, dialogid);
	if(IsPlayerNPC(playerid)) {
		return 0;
	}

	switch(dialogid) {
		case DIALOG_REGISTER: {
			if(!response) { Kick(playerid); return 0; } // Kick player if he presses the Quit button..

			if(!(strlen(inputtext) >= PASSWORD_MIN_LEN && strlen(inputtext) <= PASSWORD_MAX_LEN)) {
				format(gStr, sizeof(gStr), "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\nPlease enter a password below to create an account.\n{FF8080}ERROR{FFFFFF}: Password must be between {FFFF6C}%d {FFFFFF}and {FFFF6C}%d {FFFFFF}characters in length.", PASSWORD_MIN_LEN, PASSWORD_MAX_LEN);
				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", gStr, "Register", "Quit");
				return 0;
			}
			bcrypt_hash(playerid, "OnPlayerRegister", inputtext, 4); // Hash the inputtext (Passsword) and then call function 'RegisterPlayer'
			return 0;
		}

		case DIALOG_LOGIN: {
			if(!response) { Kick(playerid); return 0; } // Kick player if he presses the Quit button..
			bcrypt_verify(playerid, "OnPasswordChecked", inputtext, pData[playerid][Password_Hash]);
			return 0;
		}
	}


	return 0;
}

forward OnPasswordChecked(playerid, bool:success);
public OnPasswordChecked(playerid, bool:success) {

	P:1("OnPasswordChecked(%d, %d)", playerid, success);
	switch(success) {
		case false: {
			pData[playerid][Login_Attempts]++;
			if(pData[playerid][Login_Attempts] <= MAX_LOGIN_ATTEMPTS) {
				format(gStr, sizeof(gStr), "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\n{FF8080}ERROR{FFFFFF}: Password incorrect, please try again. Attempt {FFFF6C}%d{FFFFFF} of {FFFF6C}%d", pData[playerid][Login_Attempts], MAX_LOGIN_ATTEMPTS);
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", gStr, "Login", "Exit");
				return 1;
			}
			SendClientMessage(playerid, 0xFFFFFFFF, "ERROR: Password incorrect, no more attempts.");
			Kick(playerid);
		}
		case true: {
			new INI:file = INI_Open(GetPlayerFile(playerid));
			INI_WriteString(file, "LastIP", GetPlayerIpEx(playerid));
			Bit_Let(pLoggedIn, playerid);
			FadeScreenToBlack(playerid); // Pick up the spawn sequencing from OnScreenFade
		}
	}

	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid) {

	P:1("OnPlayerRegister(%d)", playerid);
	new fileToWrite[MAX_PLAYER_FILE_LEN];
	format(fileToWrite, MAX_PLAYER_FILE_LEN, "Comfysim/Accounts/%s.ini", GetPlayerNameEx(playerid));
	new INI:file = INI_Open(fileToWrite);

	if(file == INI_NO_FILE) {
		SendClientMessage(playerid, 0xFFFFFFFF, "ERROR: There was a problem creating your account. :(");
		Kick(playerid);
		return 1;
	}

	bcrypt_get_hash(pData[playerid][Password_Hash]);
	SetupRegisterFileTemplate(playerid, file);
	Bit_Let(pClassSelection, playerid); // Player is now in the class selection screen
	FadeScreenToBlack(playerid); // Pick this up in OnScreenFade, pRegistering is still true.
	return 1;
}

forward StartPlayerSpawnSequence(playerid);
public StartPlayerSpawnSequence(playerid) {
	P:1("StartPlayerSpawnSequence(%d)", playerid);
	new
		idx = random(MAX_SPAWN_LOCATIONS),
		Float:x = gSpawnLocations[idx][spawn_x],
		Float:y = gSpawnLocations[idx][spawn_y],
		Float:z = gSpawnLocations[idx][spawn_z]
	;

	pData[playerid][SpawnIdx] = idx;
	pData[playerid][SpawnSequence] = 1;
	FadeScreenToTransparent(playerid); // This is the timer as well!
	SetPlayerSkin(playerid, pData[playerid][Skin]);
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, gSpawnLocations[idx][spawn_r]);
	SetPlayerCameraPos(playerid, x, y, z+400);
	SetPlayerCameraLookAt(playerid, x, y, z);
	StartSpawnAnimation(playerid);
	PlaySpawnSequenceSound(playerid);
	return 1;
}

forward NextSpawnSequence(playerid, sequence);
public NextSpawnSequence(playerid, sequence) {
	P:1("NextSpawnSequence(%d, %d)", playerid, sequence);
	PlaySpawnSequenceSound(playerid);

	new idx = pData[playerid][SpawnIdx];
	if(sequence != 4) { // 4 is the last sequence
		new Float:x, Float:y, Float:z;

		if(sequence != 3) { // 3 Is a different camera angle
			x = gSpawnLocations[idx][spawn_x];
			y = gSpawnLocations[idx][spawn_y];
			z = gSpawnLocations[idx][spawn_z];

			if(sequence == 1) { z+= 200; }
			else { z+= 100; }
			
			SetPlayerCameraPos(playerid, x, y, z); // height is sequence ID * 100!
			SetPlayerCameraLookAt(playerid, x, y, gSpawnLocations[idx][spawn_z]); // Don't use the adjusted Z coordinate
			FadeScreenToTransparent(playerid); // This is also setting a timer for the next sequence
			pData[playerid][SpawnSequence]++;
			return 1;
		}

		x = gSpawnLocations[idx][spawn_cam_x];
		y = gSpawnLocations[idx][spawn_cam_y];
		z = gSpawnLocations[idx][spawn_cam_z];

		SetPlayerCameraPos(playerid, x, y, z);
		SetPlayerCameraLookAt(playerid, gSpawnLocations[idx][spawn_x], gSpawnLocations[idx][spawn_y], gSpawnLocations[idx][spawn_z]);
		FadeScreenToTransparent(playerid); // This is also setting a timer for the next sequence
		pData[playerid][SpawnSequence]++;
		return 1;
	}
	
	FadeScreenToTransparent(playerid);
	SetCameraBehindPlayer(playerid);
	SetTimerEx("StopSpawnAnimation", SPAWN_SEQ_STOP_ANI_INTERVAL, false, "d", playerid); // SpawnIdx is set to 0 after this is called, otherwise animation is not ended correctly.
	Bit_Let(pSpawned, playerid); // Player is spawned.
	Bit_Let(pLoggedIn, playerid);
	pData[playerid][SpawnSequence] = 0;
	return 1;
}


// Functons related to Spawn/Register/Login/Class Selection parts of the script

SetInitialConnectPosition(playerid) {
	P:1("SetInitialConnectPosition(%d)", playerid);
	//Class_DisableSelection(playerid); // Disable Class Selection until we know what to do
	SetPlayerPos(playerid, 1947.0, -846.09, 0.0);
	SetPlayerCameraPos(playerid, 1947.0, -846.09, 129.4);
	SetPlayerCameraLookAt(playerid, 1499.5, -1228.9, 81.7);
}

RequestPlayerLogin(playerid) {
	P:1("RequestPlayerLogin(%d)", playerid);
	Bit_Let(pLoggingIn, playerid); // Set this to true, allows onScreenFade to show dialog
	FadeScreenToTransparent(playerid);
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "{FFFFFF}Welcome to {FFFF6C}Comfysim{FFFFFF}!\nYour current IP Address does not match the one we have on file for you.\nPlease login so we can confirm your identity and update your IP Address for future logins.", "Login", "Exit");
	return 1;
}

RequestPlayerRegister(playerid) {
	P:1("RequestPlayerRegister(%d)", playerid);
	Bit_Let(pRegistering, playerid); // Set this to true, allows OnScreenFade to show dialog .
	FadeScreenToTransparent(playerid);
	return 1;
}

SendPlayerToClassSelection(playerid) {
	P:1("SendPlayerToClassSelection(%d)", playerid);
	Class_ReturnToSelection(playerid);
	FadeScreenToTransparent(playerid);

	// LSPD Interior skin selection
	SetPlayerInterior(playerid, 6);
	SetPlayerPos(playerid,  254.8, 83.1, 1002.4);
	SetPlayerCameraPos(playerid, 254.7, 89.3, 1002.4);
	SetPlayerCameraLookAt(playerid, 254.8, 83.1, 1002.4);
	return 1;
}

PlaySpawnSequenceSound(playerid) {
	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
	return 1;
}

SetupRegisterFileTemplate(playerid, INI:File) {
	P:1("SetupRegisterFileTemplate(%d)", playerid);
	INI_SetTag(File, "Data");
	INI_WriteString(File, "Password", pData[playerid][Password_Hash]);
	INI_WriteString(File, "LastIP", GetPlayerIpEx(playerid));
	INI_WriteInt(File, "Skin", 0);
	INI_WriteInt(File, "Money", 0);
	INI_WriteInt(File, "Mental_State", 0);
	INI_Close(File);
	SetPlayerMentalState(playerid, pData[playerid][MentalState]); // So chat colour sets correctly.
	return 1;
}

StartSpawnAnimation(playerid) {
	P:1("StartSpawnAnimation(%d)", playerid);
	switch(gSpawnLocations[pData[playerid][SpawnIdx]][spawn_action]) {
		case SPAWN_SITTING: {
			ApplyAnimation(playerid, "PED", "SEAT_IDLE", 4.0, 1, 0, 0, 1, 25000, 1);
		}
		case SPAWN_SMOKING: {
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
			ApplyAnimation(playerid, "GANGS", "SMKCIG_PRTL", 4.0, 1, 0, 0, 1, 25000, 1); // smoke cig
		}

	}
}

forward StopSpawnAnimation(playerid);
public StopSpawnAnimation(playerid) {
	P:1("StopSpawnAnimation(%d)", playerid);
	switch(gSpawnLocations[pData[playerid][SpawnIdx]][spawn_action]) {
		case SPAWN_SITTING: {
			P:1("StopSpawnAnimation(%d): SPAWN_SITTING: Applying animation..");
			ApplyAnimation(playerid, "PED", "SEAT_UP", 4.0, 0, 0, 0, 0, 0, 1);
			SetTimerEx("StopAllAnimationsAndUnfreeze", 1500, false, "d", playerid);
		}
		case SPAWN_SMOKING: {
			P:1("StopSpawnAnimation(%d): SPAWN_SMOKING: Applying animation..");
			StopAllAnimationsAndUnfreeze(playerid);
		}
	}

	pData[playerid][SpawnIdx] = -1;

	return 1;
}

forward  StopAllAnimationsAndUnfreeze(playerid);
public StopAllAnimationsAndUnfreeze(playerid) {
	P:1("StopAllAnimationsAndUnfreeze(%d)", playerid);
	ClearAnimations(playerid, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	TogglePlayerControllable(playerid, true);
	return 1;
}