#include <amxmodx>
#include <fakemeta>
#include <metadrawer>

#define NORTH	0
#define WEST	90
#define SOUTH	180
#define EAST	270

new VERSION[]="0.2"

new gHudSyncInfo, gHudSyncInfo2

//Short Names
new const g_DirNames[4][] = { "N", "E", "S", "W" }
new DirSymbol[32] = "----<>----"

new g_pcvar_compass, g_pcvar_method
new g_Method, g_Active

public plugin_init() {
	register_plugin("Compass", VERSION, "Tirant")
	
	g_pcvar_compass = register_cvar("amx_compass", "1");
	g_Active = get_pcvar_num(g_pcvar_compass)
	g_pcvar_method = register_cvar("amx_compass_method", "2");
	g_Method = get_pcvar_num(g_pcvar_method)
	
	register_forward(FM_PlayerPreThink, "fw_Player_PreThink")
	
	gHudSyncInfo = CreateHudSyncObj();
	gHudSyncInfo2 = CreateHudSyncObj();
	
	//font
	md_loadfontfile("gfx/test/BankGothic Md BT Medium.ttf")
	
	for(new i = 0; i < 256;i++)
	{
		md_initfont(i, "BankGothic Md BT", 22, FS_NONE | FS_ANTIALIAS)
	}
}

public fw_Player_PreThink(id)
{
	//It would be better to grab is_user_alive when spawn and death with g_isAlive[id] = true, false
	if (is_user_alive(id) && g_Active)
	{
		new Float:fAngles[3], iAngles[3]
		pev(id, pev_angles, fAngles)
		
		FVecIVec(fAngles,iAngles)
		iAngles[1] %= 360
		
		new Float:fHudCoordinates
	
		{
			new iFakeAngle = iAngles[1] % 90
			new Float:fFakeHudAngle = (float(iFakeAngle) / 100.0) + 0.49
			if (iFakeAngle>45) fFakeHudAngle += 0.05
			if (fFakeHudAngle >= 0.95) fFakeHudAngle -= 0.95
			else if (fFakeHudAngle <= 0.05) fFakeHudAngle += 0.05
			
			
			new DirName[32]
			
			if (iFakeAngle == 0)
			{
				fHudCoordinates = -1.0
				
				switch(iAngles[1])
				{
					case NORTH: format(DirName, 31, "%s",  g_DirNames[0])
					case WEST: format(DirName, 31, "%s", g_DirNames[3])
					case SOUTH: format(DirName, 31, "%s", g_DirNames[2])
					case EAST: format(DirName, 31, "%s", g_DirNames[1])
				}
			}
			else
			{
				fHudCoordinates = fFakeHudAngle
				
				switch(g_Method)
				{
					case 1: format(DirName, 31, "%d", iAngles[1])
					case 2:
					{
						if (NORTH < iAngles[1] < WEST || iAngles[1] > EAST)
						{
							if (NORTH < iAngles[1] < WEST)
							{
								iAngles[1] %= 90
								format(DirName, 31, "%s", g_DirNames[0])
							}
							else if (iAngles[1] > EAST)
							{
								iAngles[1] = (90 - (iAngles[1] % 90))
								format(DirName, 31, "%s", g_DirNames[0])
							}
						}
						else
						{
							if (SOUTH > iAngles[1] > WEST)
							{
								iAngles[1] = (90 - (iAngles[1] % 90))
								format(DirName, 31, "%s", g_DirNames[2])
							}
							else if (SOUTH < iAngles[1] < EAST)
							{
								iAngles[1] %= 90
								format(DirName, 31, "%s", g_DirNames[2])
							}
						}
					}
				}
			}
			
			if (g_Method)
			{
				//set_hudmessage(255, 0, 0, -1.0, 0.9, 0, 0.0, 3.0, 0.0, 0.0);
				//ShowSyncHudMsg(id, gHudSyncInfo2, "%s", DirName);
				md_drawtext(id, 6, DirName, 0.9, 0.83, 0, 0, 200,200,200,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
		}
		
		//set_hudmessage(255, 255, 255, fHudCoordinates, 0.9, 0, 0.0, 3.0, 0.0, 0.0);
		//ShowSyncHudMsg(id, gHudSyncInfo, "^n%s", DirSymbol);
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
