
#include <YSI\YSI_Coding\y_hooks>

#define CLASS_MALE 0
#define CLASS_FEMALE 1

enum E_CLASS_DATA {
	Class_Skin,
	Class_Sex,
	Class_ID
}

#define J_MAX_CLASSES 4
new gClasses[J_MAX_CLASSES][E_CLASS_DATA] = {
	{60, CLASS_MALE, -1},
	{59, CLASS_MALE, -1},
	{191, CLASS_FEMALE, -1},
	{193, CLASS_FEMALE, -1}

};


hook OnGameModeInit() {

	for(new i; i < J_MAX_CLASSES; i++) {
		gClasses[i][Class_ID] = Class_Add(gClasses[i][Class_Skin], 0.0, 0.0, 0.0, 0.0);
	}

	return 1;
}

hook OnPlayerConnect(playerid) {
	Class_DisableSelection(playerid); // Disable Class Selection until we know what to do
	return 1;
}

hook OnPlayerRequestClass(playerid, classid) {
	if(pData[playerid][SkinSelection]) {
		Streamer_UpdateEx(playerid, 254.8, 83.1, 1002.4, -1, 6, STREAMER_TYPE_OBJECT, -1, 0);
		Streamer_Update(playerid);
	}
	return 1;
}

hook OnPlayerSpawn(playerid) {
	if(pData[playerid][SkinSelection]) {
		pData[playerid][SkinSelection] = 0;
	}
	return 1;
}

hook OnPlayerRequestSpawn(playerid) {
	pData[playerid][Skin] = GetPlayerSkin(playerid);
	FadeScreenToBlack(playerid, 1000, 25);
	P:1("OnPlayerRequestSpawn() Reported skin (%d), pdata skin (%d)", GetPlayerSkin(playerid), pData[playerid][Skin]);
	return 1;
}

SendPlayerToClassSelection(playerid) {
	Class_ReturnToSelection(playerid);
	FadeScreenToTransparent(playerid, 2000, 50);

	// LSPD Interior skin selection
	SetPlayerInterior(playerid, 6);
	SetPlayerPos(playerid,  254.8, 83.1, 1002.4);
	SetPlayerCameraPos(playerid, 254.7, 89.3, 1002.4);
	SetPlayerCameraLookAt(playerid, 254.8, 83.1, 1002.4);
	pData[playerid][SkinSelection] = 1;
	return 1;
}