
#include <YSI\YSI_Coding\y_hooks>

new Text:td_Wasted[4];

hook OnGameModeInit() {

	td_Wasted[0] = TextDrawCreate(279.000000, 177.000000, "wasted");
	TextDrawFont(td_Wasted[0], 3);
	TextDrawLetterSize(td_Wasted[0], 0.637499, 3.449998);
	TextDrawTextSize(td_Wasted[0], 355.500000, 13.500000);
	TextDrawSetOutline(td_Wasted[0], 0);
	TextDrawSetShadow(td_Wasted[0], 0);
	TextDrawAlignment(td_Wasted[0], 1);
	TextDrawColor(td_Wasted[0], -1523963217);
	TextDrawBackgroundColor(td_Wasted[0], 255);
	TextDrawBoxColor(td_Wasted[0], 50);
	TextDrawUseBox(td_Wasted[0], 0);
	TextDrawSetProportional(td_Wasted[0], 1);
	TextDrawSetSelectable(td_Wasted[0], 0);

	td_Wasted[1] = TextDrawCreate(-1.000000, 166.000000, "_~n~_~n~_~n~_");
	TextDrawFont(td_Wasted[1], 1);
	TextDrawLetterSize(td_Wasted[1], 0.637499, 2.000000);
	TextDrawTextSize(td_Wasted[1], 664.000000, 14.000000);
	TextDrawSetOutline(td_Wasted[1], 1);
	TextDrawSetShadow(td_Wasted[1], 0);
	TextDrawAlignment(td_Wasted[1], 1);
	TextDrawColor(td_Wasted[1], -1);
	TextDrawBackgroundColor(td_Wasted[1], 255);
	TextDrawBoxColor(td_Wasted[1], 100);
	TextDrawUseBox(td_Wasted[1], 1);
	TextDrawSetProportional(td_Wasted[1], 1);
	TextDrawSetSelectable(td_Wasted[1], 0);

	td_Wasted[2] = TextDrawCreate(295.000000, 207.000000, "You committed suicide.");
	TextDrawFont(td_Wasted[2], 1);
	TextDrawLetterSize(td_Wasted[2], 0.162500, 1.350000);
	TextDrawTextSize(td_Wasted[2], 400.000000, 17.000000);
	TextDrawSetOutline(td_Wasted[2], 0);
	TextDrawSetShadow(td_Wasted[2], 0);
	TextDrawAlignment(td_Wasted[2], 1);
	TextDrawColor(td_Wasted[2], -81);
	TextDrawBackgroundColor(td_Wasted[2], 255);
	TextDrawBoxColor(td_Wasted[2], 50);
	TextDrawUseBox(td_Wasted[2], 0);
	TextDrawSetProportional(td_Wasted[2], 1);
	TextDrawSetSelectable(td_Wasted[2], 0);

	td_Wasted[3] = TextDrawCreate(289.000000, 207.000000, "You took the easy way out.");
	TextDrawFont(td_Wasted[3], 1);
	TextDrawLetterSize(td_Wasted[3], 0.162500, 1.350000);
	TextDrawTextSize(td_Wasted[3], 400.000000, 17.000000);
	TextDrawSetOutline(td_Wasted[3], 0);
	TextDrawSetShadow(td_Wasted[3], 0);
	TextDrawAlignment(td_Wasted[3], 1);
	TextDrawColor(td_Wasted[3], -81);
	TextDrawBackgroundColor(td_Wasted[3], 255);
	TextDrawBoxColor(td_Wasted[3], 50);
	TextDrawUseBox(td_Wasted[3], 0);
	TextDrawSetProportional(td_Wasted[3], 1);
	TextDrawSetSelectable(td_Wasted[3], 0);
	return 1;
}

hook OnPlayerConnect(playerid) {

	pData[playerid][td_Killedby] = TextDrawCreate(322.000000, 207.000000, "Nobody_killed_you");
	TextDrawFont(pData[playerid][td_Killedby], 1);
	TextDrawLetterSize(pData[playerid][td_Killedby], 0.162500, 1.350000);
	TextDrawTextSize(pData[playerid][td_Killedby], 416.000000, 17.000000);
	TextDrawSetOutline(pData[playerid][td_Killedby], 0);
	TextDrawSetShadow(pData[playerid][td_Killedby], 0);
	TextDrawAlignment(pData[playerid][td_Killedby], 2);
	TextDrawColor(pData[playerid][td_Killedby], -81);
	TextDrawBackgroundColor(pData[playerid][td_Killedby], 255);
	TextDrawBoxColor(pData[playerid][td_Killedby], 50);
	TextDrawUseBox(pData[playerid][td_Killedby], 1);
	TextDrawSetProportional(pData[playerid][td_Killedby], 1);
	TextDrawSetSelectable(pData[playerid][td_Killedby], 0);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	TextDrawDestroy(pData[playerid][td_Killedby]);

	return 1;

}

stock ShowWastedTextdraw(playerid, type) {

	TextDrawShowForPlayer(playerid, td_Wasted[0]);
	TextDrawShowForPlayer(playerid, td_Wasted[1]);
	
	if(!type) {
		TextDrawShowForPlayer(playerid, td_Wasted[2]); // Suicide
		return 1;
	}
	TextDrawShowForPlayer(playerid, td_Wasted[3]); // Easy way out
	return 1;
}

stock HideWastedTextdraw(playerid) {

	TextDrawHideForPlayer(playerid, td_Wasted[0]);
	TextDrawHideForPlayer(playerid, td_Wasted[1]);
	TextDrawHideForPlayer(playerid, td_Wasted[2]);
	TextDrawHideForPlayer(playerid, td_Wasted[3]);
	TextDrawHideForPlayer(playerid, pData[playerid][td_Killedby]);

	return 1;

}
stock ShowKilledByTextdraw(playerid, killerid) {

	new str[MAX_PLAYER_NAME+1];
	format(str, sizeof(str), "%s_killed_you", GetPlayerNameEx(killerid));
	TextDrawShowForPlayer(playerid, pData[playerid][td_Killedby]);

	return 1;

}
