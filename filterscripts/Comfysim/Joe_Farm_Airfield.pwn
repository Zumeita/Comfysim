// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>
#include <streamer>

new gObjects[91];
new gVehicles[2];

public OnFilterScriptInit()
{
    print("Loading Map: Farm Airfield");
    
	//gVehicles[0] = CreateVehicle(512,-1365.4000000,-1522.4000000,102.8000000,45.5020000,93,27,15); //Cropdust
	gVehicles[1] = CreateVehicle(513,-1352.7000000,-1497.7000000,103.3000000,78.2500000,107,-1,15); //Stunt
	
	gObjects[0] = CreateDynamicObject(1214,-1379.3000000,-1603.3000000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (3)
	gObjects[1] = CreateDynamicObject(1214,-1397.3000000,-1593.3000000,100.2500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (4)
	gObjects[2] = CreateDynamicObject(1214,-1397.3000000,-1583.3000000,100.0500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (7)
	gObjects[3] = CreateDynamicObject(1214,-1397.3000000,-1573.3000000,99.9500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (10)
	gObjects[4] = CreateDynamicObject(1214,-1397.3000000,-1563.3000000,99.9000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (11)
	gObjects[5] = CreateDynamicObject(1214,-1397.3000000,-1553.3000000,99.8500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (12)
	gObjects[6] = CreateDynamicObject(1214,-1397.3000000,-1543.3000000,99.8500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (13)
	gObjects[7] = CreateDynamicObject(1214,-1397.3000000,-1533.3000000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (14)
	gObjects[8] = CreateDynamicObject(1214,-1397.3000000,-1523.3000000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (15)
	gObjects[9] = CreateDynamicObject(1214,-1397.3000000,-1513.3000000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (16)
	gObjects[10] = CreateDynamicObject(1214,-1397.3000000,-1503.3000000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (17)
	gObjects[11] = CreateDynamicObject(1214,-1397.3000000,-1483.3000000,99.7400000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (18)
	gObjects[12] = CreateDynamicObject(1214,-1379.3000000,-1593.3000000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (23)
	gObjects[13] = CreateDynamicObject(1214,-1379.3000000,-1583.3000000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (25)
	gObjects[14] = CreateDynamicObject(1214,-1379.3000000,-1573.3000000,100.2500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (26)
	gObjects[15] = CreateDynamicObject(1214,-1379.3000000,-1563.3000000,100.2000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (27)
	gObjects[16] = CreateDynamicObject(1214,-1379.3000000,-1553.3000000,100.1500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (28)
	gObjects[17] = CreateDynamicObject(1214,-1379.3000000,-1543.3000000,100.1500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (29)
	gObjects[18] = CreateDynamicObject(1214,-1379.3000000,-1533.3000000,100.2000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (30)
	gObjects[19] = CreateDynamicObject(1214,-1379.3000000,-1523.3000000,100.1500000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (31)
	gObjects[20] = CreateDynamicObject(1214,-1379.2998000,-1513.2998000,100.1000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (32)
	gObjects[21] = CreateDynamicObject(1214,-1379.3000000,-1503.3000000,100.0000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (33)
	gObjects[22] = CreateDynamicObject(1214,-1397.2998000,-1603.2998000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (35)
	gObjects[23] = CreateDynamicObject(1214,-1397.2998000,-1613.2998000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (36)
	gObjects[24] = CreateDynamicObject(1214,-1379.2998000,-1613.2998000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (37)
	gObjects[25] = CreateDynamicObject(1214,-1392.8000000,-1613.2998000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (40)
	gObjects[26] = CreateDynamicObject(1214,-1383.8000000,-1613.2998000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (41)
	gObjects[27] = CreateDynamicObject(1214,-1388.3000000,-1613.2998000,100.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (42)
	gObjects[28] = CreateDynamicObject(1214,-1397.2998000,-1493.2998000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (43)
	gObjects[29] = CreateDynamicObject(1214,-1379.2998000,-1483.2998000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (46)
	gObjects[30] = CreateDynamicObject(1214,-1383.8998000,-1483.2998000,99.8000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (50)
	gObjects[31] = CreateDynamicObject(1214,-1392.8998000,-1483.2998000,99.7700000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (51)
	gObjects[32] = CreateDynamicObject(1214,-1388.3000000,-1483.2998000,99.7799500,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bollard) (52)
	gObjects[33] = CreateDynamicObject(3276,-1371.7000000,-1482.7000000,101.8900000,0.0000000,356.7500000,0.0000000); //object(cxreffencesld) (1)
	gObjects[34] = CreateDynamicObject(3276,-1348.7000000,-1482.7000000,103.2000000,0.0000000,356.8800000,0.0000000); //object(cxreffencesld) (4)
	gObjects[35] = CreateDynamicObject(3276,-1342.9000000,-1488.6000000,102.8000000,0.0000000,5.0000000,270.0000000); //object(cxreffencesld) (5)
	gObjects[36] = CreateDynamicObject(3276,-1346.0000000,-1499.3000000,102.3000000,0.0000000,0.0000000,238.0000000); //object(cxreffencesld) (6)
	gObjects[37] = CreateDynamicObject(3276,-1352.1000000,-1509.1000000,102.3000000,0.0000000,0.0000000,237.9970000); //object(cxreffencesld) (7)
	gObjects[38] = CreateDynamicObject(3276,-1357.7000000,-1519.2000000,102.2000000,0.0000000,0.0000000,243.9970000); //object(cxreffencesld) (8)
	gObjects[39] = CreateDynamicObject(3276,-1362.4000000,-1529.7000000,102.2000000,0.0000000,0.0000000,247.4950000); //object(cxreffencesld) (9)
	gObjects[40] = CreateDynamicObject(3276,-1383.2000000,-1482.7000000,101.6000000,0.0000000,0.5000000,0.0000000); //object(cxreffencesld) (11)
	gObjects[41] = CreateDynamicObject(3276,-1394.8000000,-1482.7000000,101.7000000,0.0000000,0.5000000,0.0000000); //object(cxreffencesld) (12)
	gObjects[42] = CreateDynamicObject(3276,-1405.5000000,-1482.7000000,101.7000000,0.0000000,359.7500000,0.0000000); //object(cxreffencesld) (13)
	gObjects[43] = CreateDynamicObject(3276,-1418.1000000,-1603.8000000,101.9000000,0.0000000,356.7470000,312.2500000); //object(cxreffencesld) (14)
	gObjects[44] = CreateDynamicObject(3276,-1411.0000000,-1612.8000000,102.2000000,0.0000000,359.9920000,304.2480000); //object(cxreffencesld) (15)
	gObjects[45] = CreateDynamicObject(3276,-1402.5000000,-1619.9000000,102.3000000,0.0000000,359.9890000,336.2440000); //object(cxreffencesld) (16)
	gObjects[46] = CreateDynamicObject(3276,-1391.4000000,-1622.4000000,102.3000000,0.0000000,359.9890000,358.2420000); //object(cxreffencesld) (17)
	gObjects[47] = CreateDynamicObject(3276,-1380.0000000,-1621.1000000,102.3000000,0.0000000,359.9890000,14.2370000); //object(cxreffencesld) (18)
	gObjects[48] = CreateDynamicObject(3276,-1368.8000000,-1618.3000000,102.3000000,0.0000000,359.9890000,14.2330000); //object(cxreffencesld) (19)
	gObjects[49] = CreateDynamicObject(3276,-1357.6000000,-1615.3000000,102.3000000,0.0000000,359.9890000,15.2330000); //object(cxreffencesld) (20)
	gObjects[50] = CreateDynamicObject(3276,-1346.4000000,-1612.3000000,102.3000000,0.0000000,359.9890000,15.2330000); //object(cxreffencesld) (21)
	gObjects[51] = CreateDynamicObject(3276,-1339.8000000,-1605.1000000,102.3000000,0.0000000,359.9890000,79.9830000); //object(cxreffencesld) (22)
	gObjects[52] = CreateDynamicObject(3276,-1339.6000000,-1593.7000000,102.2000000,0.0000000,359.9890000,97.9800000); //object(cxreffencesld) (23)
	gObjects[53] = CreateDynamicObject(3276,-1340.8000000,-1582.2000000,102.2000000,0.0000000,359.9890000,94.4760000); //object(cxreffencesld) (24)
	gObjects[54] = CreateDynamicObject(3276,-1341.5000000,-1570.7000000,102.2000000,0.0000000,359.9890000,92.7210000); //object(cxreffencesld) (25)
	gObjects[55] = CreateDynamicObject(3276,-1345.7000000,-1560.8000000,102.2000000,0.0000000,359.9890000,132.9690000); //object(cxreffencesld) (26)
	gObjects[56] = CreateDynamicObject(3276,-1353.6000000,-1552.3000000,102.2000000,0.0000000,359.9890000,132.9680000); //object(cxreffencesld) (29)
	gObjects[57] = CreateDynamicObject(3276,-1360.9000000,-1544.5000000,102.2000000,0.0000000,359.9890000,132.9680000); //object(cxreffencesld) (30)
	gObjects[58] = CreateDynamicObject(3276,-1369.4000000,-1536.9000000,102.2000000,0.0000000,359.9890000,143.7180000); //object(cxreffencesld) (31)
	gObjects[59] = CreateDynamicObject(3276,-1364.1000000,-1533.7000000,102.2000000,0.0000000,0.0000000,247.4950000); //object(cxreffencesld) (32)
	gObjects[60] = CreateDynamicObject(3261,-1369.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (1)
	gObjects[61] = CreateDynamicObject(3261,-1366.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (2)
	gObjects[62] = CreateDynamicObject(3261,-1363.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (3)
	gObjects[63] = CreateDynamicObject(3261,-1360.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (4)
	gObjects[64] = CreateDynamicObject(3261,-1357.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (5)
	gObjects[65] = CreateDynamicObject(3261,-1354.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (6)
	gObjects[66] = CreateDynamicObject(3261,-1351.8000000,-1601.5000000,101.4000000,0.0000000,0.0000000,90.0000000); //object(grasshouse) (7)
	gObjects[67] = CreateDynamicObject(3409,-1353.7000000,-1601.5000000,100.8000000,0.0000000,0.0000000,0.0000000); //object(grassplant) (1)
	gObjects[68] = CreateDynamicObject(3409,-1357.4000000,-1601.5000000,100.8000000,0.0000000,0.0000000,0.0000000); //object(grassplant) (2)
	gObjects[69] = CreateDynamicObject(3409,-1361.4000000,-1601.5000000,100.8000000,0.0000000,0.0000000,0.0000000); //object(grassplant) (3)
	gObjects[70] = CreateDynamicObject(3409,-1365.7000000,-1601.5000000,100.6000000,0.0000000,0.0000000,0.0000000); //object(grassplant) (4)
	gObjects[71] = CreateDynamicObject(3409,-1370.2000000,-1601.5000000,100.7000000,0.0000000,0.0000000,0.0000000); //object(grassplant) (5)
	gObjects[72] = CreateDynamicObject(759,-1371.5000000,-1592.5000000,101.4000000,0.0000000,0.0000000,0.0000000); //object(sm_bush_large_1) (1)
	gObjects[73] = CreateDynamicObject(759,-1368.7000000,-1592.6000000,101.4000000,0.0000000,0.0000000,270.0000000); //object(sm_bush_large_1) (2)
	gObjects[74] = CreateDynamicObject(759,-1366.2000000,-1592.5000000,101.4000000,0.0000000,0.0000000,188.0000000); //object(sm_bush_large_1) (3)
	gObjects[75] = CreateDynamicObject(759,-1363.6000000,-1592.8000000,101.4000000,0.0000000,0.0000000,100.0000000); //object(sm_bush_large_1) (5)
	gObjects[76] = CreateDynamicObject(759,-1361.0000000,-1592.8000000,101.4000000,0.0000000,0.0000000,7.9980000); //object(sm_bush_large_1) (6)
	gObjects[77] = CreateDynamicObject(759,-1358.4000000,-1592.8000000,101.4000000,0.0000000,0.0000000,87.7430000); //object(sm_bush_large_1) (7)
	gObjects[78] = CreateDynamicObject(759,-1355.9000000,-1592.6000000,101.4000000,0.0000000,0.0000000,175.7420000); //object(sm_bush_large_1) (8)
	gObjects[79] = CreateDynamicObject(759,-1353.7000000,-1592.8000000,101.4000000,0.0000000,0.0000000,277.7370000); //object(sm_bush_large_1) (9)
	gObjects[80] = CreateDynamicObject(16101,-1367.5000000,-1535.6000000,101.4000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(des_windsockpole) (1)
	gObjects[81] = CreateDynamicObject(16368,-1367.5000000,-1535.6000000,112.3000000,0.0000000,0.0000000,0.0000000, -1, -1, -1, 1000.0, 1000.0); //object(bonyrd_windsock) (1)
	gObjects[82] = CreateDynamicObject(2062,-1367.1000000,-1535.0000000,101.9000000,0.0000000,0.0000000,106.0000000); //object(cj_oildrum2) (1)
	gObjects[83] = CreateDynamicObject(2062,-1367.8000000,-1535.2000000,101.9000000,0.0000000,0.0000000,105.9960000); //object(cj_oildrum2) (2)
	gObjects[84] = CreateDynamicObject(1449,-1366.7000000,-1534.6000000,101.9000000,0.0000000,0.0000000,136.0000000); //object(dyn_crate_2) (1)
	gObjects[85] = CreateDynamicObject(1431,-1370.4000000,-1535.6000000,101.9000000,0.0000000,0.0000000,141.5000000); //object(dyn_box_pile) (1)
	gObjects[86] = CreateDynamicObject(12913,-1347.2000000,-1486.8000000,103.9000000,0.0000000,0.0000000,178.0000000); //object(sw_fueldrum03) (1)
	gObjects[87] = CreateDynamicObject(3633,-1348.5000000,-1488.7000000,102.6000000,0.0000000,0.0000000,0.0000000); //object(imoildrum4_las) (1)
	gObjects[88] = CreateDynamicObject(2062,-1348.5000000,-1489.7000000,102.7000000,0.0000000,0.0000000,105.9960000); //object(cj_oildrum2) (7)
	gObjects[89] = CreateDynamicObject(2062,-1348.7000000,-1484.1000000,102.9000000,0.0000000,0.0000000,105.9960000); //object(cj_oildrum2) (8)
	gObjects[90] = CreateDynamicObject(2062,-1348.1000000,-1484.7000000,102.9000000,0.0000000,0.0000000,222.2460000); //object(cj_oildrum2) (9)

	/*
	Objects converted: 91
	Vehicles converted: 4
	Vehicle models found: 3
	----------------------
	In the time this conversion took to finish a hummingbird could have flapped it's wings 0.14 times!
	*/


	print("Map loaded");


	return 1;
}

public OnFilterScriptExit()
{
	for(new idx; idx < sizeof(gObjects); idx++)
	{
	    if(gObjects[idx] != INVALID_OBJECT_ID)
	    {
	    	DestroyDynamicObject(gObjects[idx]);
		}
	}
	
	for(new idx; idx < sizeof(gVehicles); idx++)
	{
	    DestroyVehicle(gVehicles[idx]);
	}
	
	return 1;
}

public OnPlayerConnect(playerid)
{
    RemoveBuildingForPlayer(playerid, 791, -1368.7187, -1588.6953, 98.49219, 63.015308); // removeWorldObject (vbg_fir_copse) (1)
    RemoveBuildingForPlayer(playerid, 785, -1368.7187, -1588.6953, 98.49219, 63.015308); // removeWorldObject (vbg_fir_copse) (1) LOD
	return 1;
}

