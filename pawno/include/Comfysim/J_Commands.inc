

YCMD:kill(playerid, params[], help) {
	SetPlayerHealth(playerid, 0);
	pData[playerid][EasyWayOut] = 1;
	return 1;
}

YCMD:s(playerid, params[], help) {
	new 
		val = strval(params),
		Float:x, Float:y, Float:z
	;
	GetPlayerPos(playerid, x, y, z);

	if(val) {
		PlayerPlaySound(playerid, val, x, y, z);
	}
}

YCMD:ent(playerid, params[], help) 
{
	if(IsPlayerAdmin(playerid)) {

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
	}
	else 
	{
		SendClientMessage(playerid, CHAT_COLOUR_PALE_RED, "ERROR: You are not an admin!");
		return 0;
	}
	return 1;
}

YCMD:time(playerid, params[], help) 
{
	new val = strval(params);

	if(val <= 23) // 0-23 is supported hour.
	{
	    gTimeHours = val;
		gTimeMinutes = 0;
		
	    for(new i; i < GetMaxPlayers(); i++)
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

