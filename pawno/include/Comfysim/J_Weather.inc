#include <YSI\YSI_Coding\y_hooks>

#define MAX_AMOUNT_OF_WEATHER_TYPES 8
#define WEATHER_TYPE_CLEAR 0
#define WEATHER_TYPE_CLOUDY 1
#define WEATHER_TYPE_PRESTORM 2
#define WEATHER_TYPE_RAIN 3
#define WEATHER_TYPE_FOG 4
#define WEATHER_CHAT_COLOUR 0x51A8FFFF

enum WEATHER_DATA {
	weatherid,
	weather_type
}

new 
	wData[][WEATHER_DATA] = {
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
	},
	gTimeHours = 12,
	gTimeMinutes = 0,
	gTimeWeatherUpdate = 0, // Variable to keep track of when to update the weather
	gWeatherType = 0 // Variable to track current weather type for patterns.
;

hook OnGameModeInit() {

	SetTimer("GlobalTime", 2000, true);

	new rand = random(sizeof(wData));
	SetWeather(wData[rand][weatherid]);
	gWeatherType = wData[rand][weather_type];
	return 1;
}

SetWeatherEx(weatherID, weather_to, weather_from)
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
	
	for(new idx; idx < GetMaxPlayers(); idx++) // Set every players time. Global time only allows us to set the Hour, it is less innacurate.
	{
	    SetPlayerTime(idx, gTimeHours, gTimeMinutes);
	}
	
}