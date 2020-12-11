#define _DEBUG 1

#include <YSI\YSI_Coding\y_hooks>

#define DIALOG_BOX_MENTAL_STATE 2
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

new PlayerText:Dialogbox_MentalState[MAX_PLAYERS][1];

hook OnPlayerConnect(playerid) {

	CreateTextDrawsForPlayer(playerid);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {

	 RemoveTextDrawsForPlayer(playerid); // Create any text draws we need for the session

	 return 1;
}

hook OnPlayerDeath(playerid, killerid, reason) {

	if(killerid != INVALID_PLAYER_ID) // Was killed by a valid player
	{
	    SendDeathClientMessage(playerid, killerid, reason);
    	IncreasePlayerMentalState(playerid, killerid);
	}
	else
	{
	    SendDeathClientMessage(playerid, INVALID_PLAYER_ID, reason);
	}

	return 1;
}

hook OnPlayerText(playerid, text[])
{
	SendChatMessageToAllConnected(playerid, CHAT_COLOUR_WHITE, text);
	return 0; // Block normal text. Only scripted text we can control!
}

stock SendChatMessageToAllConnected(playerid, colour, string[])
{
	new player_name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, player_name, MAX_PLAYER_NAME);
	new text[128];
	format(text, 128, "{%s}%s {8D8D8D}[ALL] {FFFFFF}%s", pData[playerid][Colour], player_name, string);
	
	for(new idx = 0; idx < GetMaxPlayers(); idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && pData[idx][LoggedIn]) // Player is connected, not an NPC and has passed the spawn sequence.
	    {
	        SendClientMessage(idx, colour, text);
		}
	}
	
	return 1;
}

forward PlayerMentalStateUpdate();
public PlayerMentalStateUpdate()
{
	for(new idx = 0; idx < GetMaxPlayers(); idx++)
	{
	    if(IsPlayerConnected(idx) && !IsPlayerNPC(idx) && pData[idx][LoggedIn]) // Player is connected, not an NPC and is passed the spawn sequence.
	    {
	        new mental_state = pData[idx][MentalState];
	        
			if(mental_state)
			{
				pData[idx][MentalState]--;
				mental_state = pData[idx][MentalState];
				printf("Debug: ID %d's mental state is now %d.", idx, mental_state);
				
				if(mental_state <= 19)
				{
				    if(strcmp(pData[idx][Colour], CHAT_COLOUR_NORMAL, true) == 1)
				    {
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, " * Your mental state lowered changed to Normal.");
					}
					SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 39 && mental_state > 19)
				{
				    if(strcmp(pData[idx][Colour], CHAT_COLOUR_UNSTABLE, true) == 1)
				    {
				        new string[128];
				        format(string, sizeof(string), "* Your mental state has changed to {%s} Unstable.", CHAT_COLOUR_UNSTABLE);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
					}
					
				    SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 59 && mental_state > 39)
				{
				    if(strcmp(pData[idx][Colour], CHAT_COLOUR_DERANGED, true) == 1)
				    {
				        new string[128];
				        format(string, sizeof(string), "* Your mental state has changed to {%s} Deranged.", CHAT_COLOUR_DERANGED);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
					}
					SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 79 && mental_state > 59)
				{
				    if(strcmp(pData[idx][Colour], CHAT_COLOUR_MANIAC, true) == 1)
				    {
				        new string[128];
				        format(string, sizeof(string), "* Your mental state has changed to {%s} Maniac.", CHAT_COLOUR_MANIAC);
				        SendClientMessage(idx, CHAT_COLOUR_WHITE, string);
					}
				    SetPlayerMentalState(idx, mental_state);
				}
				else if(mental_state <= 100 && mental_state > 79)
				{
				    if(strcmp(pData[idx][Colour], CHAT_COLOUR_PSYCHO, true) == 1)
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

stock SetPlayerMentalState(playerid, value) // 0-100
{
	P:1("[J_MentalState]: SetPlayerMentalState(%d, %d)", playerid, value);

	if(value <= 100 && value >= 0) // Check if valid..
	{
	    pData[playerid][MentalState] = value;

	    if(value <= 19)
		{
		    pData[playerid][Colour] = CHAT_COLOUR_NORMAL;
		    SetPlayerColor(playerid, BLIP_COLOUR_NORMAL);
		}
		else if(value <= 39 && value > 19)
		{
		    pData[playerid][Colour] = CHAT_COLOUR_UNSTABLE;
		    SetPlayerColor(playerid, BLIP_COLOUR_UNSTABLE);
		}
		else if(value <= 59 && value > 39)
		{
			pData[playerid][Colour] = CHAT_COLOUR_DERANGED;
			SetPlayerColor(playerid, BLIP_COLOUR_DERANGED);
		}
		else if(value <= 79 && value > 59)
		{
	 		pData[playerid][Colour] = CHAT_COLOUR_MANIAC;
	 		SetPlayerColor(playerid, BLIP_COLOUR_MANIAC);
		}
		else
		{
		    pData[playerid][Colour] = CHAT_COLOUR_PSYCHO;
		    SetPlayerColor(playerid, BLIP_COLOUR_PSYCHO);
		}

		P:1("[J_MentalState]: pData[%d][MentalState] = %d, pData[%d][Colour] = %s", playerid, pData[playerid][MentalState], pData[playerid][Colour]);
	}
	
	return 1;
	
}

stock GetPlayerColourFromMentalState(playerid)
{
	new mental_state = pData[playerid][MentalState];
	
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
	new mental_state = pData[playerid][MentalState];

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

stock IncreasePlayerMentalState(playerid, killerid) // Function used to increase a players mental state when killing another player
{
    pData[killerid][MentalStateTracker]++;
    
    if(pData[killerid][MentalStateTracker] > 3)
    {
        new string[128];
    	format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF} Is on a killing spree!", pData[killerid][Colour], GetPlayerNameEx(killerid));
		SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
		ShowPlayerDialogBox(playerid, DIALOG_BOX_MENTAL_STATE);
	}

	new mental_state = pData[playerid][MentalState]; // The KILLED PLAYERS mental state.

     // Apply more mental state if you kill a more innocent person.
	if(mental_state <= 19) { pData[killerid][MentalState]+= 5; }
	else if(mental_state <= 39 && mental_state > 19) { pData[killerid][MentalState]+= 4; }
	else if(mental_state <= 59 && mental_state > 39) { pData[killerid][MentalState]+= 3; }
	else if(mental_state <= 79 && mental_state > 59) { pData[killerid][MentalState]+= 2; }
	
	print("IncreasePlayerMentalState called");
	return pData[killerid][MentalState];
}

stock SendDeathClientMessage(playerid, killerid, reason)
{
	new string[128], player_name[MAX_PLAYER_NAME];
	format(player_name, MAX_PLAYER_NAME, "%s", GetPlayerNameEx(playerid));
	
	if(killerid != INVALID_PLAYER_ID)
	{
	    if(IsPlayerNPC(killerid))
	    {
	        format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Died.", pData[playerid][Colour], player_name);
		}
		else
		{
		    format(string, 128, "{FFFFFF}* {%s}%s {8D8D8D}Killed {%s}%s.", pData[killerid][Colour], GetPlayerNameEx(killerid), pData[playerid][Colour], player_name);
		}
	}
	else
	{
		if(reason == WEAPON_VEHICLE) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Was run over.", pData[playerid][Colour], player_name); }
	    else if(reason == WEAPON_DROWN) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Drowned.", pData[playerid][Colour], player_name); }
	    else if(reason == WEAPON_COLLISION) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Fell to their death.", pData[playerid][Colour], player_name); }
	    else if(reason == 51) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Exploded.", pData[playerid][Colour], player_name); }
		else if(reason == 50) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Was chopped to peices by helicopter blades.", pData[playerid][Colour], player_name); }
	 	else if(reason == 255) { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Committed suicide.", pData[playerid][Colour], player_name); }
	  	else { format(string, 128, "{FFFFFF}* {%s}%s {FFFFFF}Died.", pData[playerid][Colour], player_name); }
	}
    SendClientMessageToAllConnected(CHAT_COLOUR_WHITE, string);
    print("SendDeathClientMessage called");
    return 1;
}