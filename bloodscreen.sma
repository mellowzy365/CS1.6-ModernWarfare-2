#include <amxmodx>
#include <hamsandwich>
#include <metadrawer>

//special thanks to <veco> for redfadeonlowhp


public plugin_init() {
	register_plugin("COD Bloodscreen and Hurt Sound", "1.0", "facelockmo@gmail.com")
	register_event("Health","healthcheck","be")
	RegisterHam(Ham_Killed, "player", "fwd_PlayerDeath");
	md_init()
}

public plugin_precache()
{	
	precache_generic("gfx/bloodscreen/bloodlvl1.tga")
	precache_generic("gfx/bloodscreen/bloodlvl2.tga")
	precache_generic("gfx/bloodscreen/bloodlvl3.tga")
	precache_generic("gfx/bloodscreen/bloodlvl4.tga")
	precache_generic("gfx/bloodscreen/bloodlvl5.tga")
	precache_sound("player/pl_better.wav");
	precache_sound("player/pl_hurt_1.wav");
	precache_sound("player/pl_hurt_2.wav");
	precache_sound("player/pl_hurt_3.wav");
	precache_sound("player/heartbeat.wav");
}
public md_init()
{
	md_loadimage("gfx/bloodscreen/bloodlvl1.tga")
	md_loadimage("gfx/bloodscreen/bloodlvl2.tga")
	md_loadimage("gfx/bloodscreen/bloodlvl3.tga")
	md_loadimage("gfx/bloodscreen/bloodlvl4.tga")
	md_loadimage("gfx/bloodscreen/bloodlvl5.tga")
}
public healthcheck(id)
{
	new iHealth = get_user_health(id)
	if(is_user_alive(id))
			{
				if (iHealth == 100 )
					{
						clearblood(id)
						client_cmd(id, "spk sound/player/pl_better.wav");
					}
				if (iHealth >= 84 && iHealth <= 99)
					{
						bloodlvl1(id)
						client_cmd(id, "spk sound/player/pl_hurt_2.wav");					
					}
				if (iHealth >= 63 && iHealth <= 83)
					{
						bloodlvl2(id)
						client_cmd(id, "spk sound/player/pl_hurt_1.wav");					
					}
				if (iHealth >= 42 && iHealth <= 62)
					{
						bloodlvl3(id)
						client_cmd(id, "spk sound/player/pl_hurt_3.wav");					
					}
				if (iHealth >= 21 && iHealth <= 41)
					{
						bloodlvl4(id)
						client_cmd(id, "spk sound/player/pl_hurt_2.wav");
					}
				if (iHealth >= 1 && iHealth <= 20)
					{
						bloodlvl5(id)
						client_cmd(id, "spk sound/player/pl_hurt_1.wav");
					}
			}
}

public fwd_PlayerDeath(id)
{
	clearblood(id)
}
	
public clearblood(id)
{
	md_removedrawing(id,1,1)
}


bloodlvl1(id)
{
	//native acg_drawtga(id, const szTGA[], red, green, blue, alpha, Float:x, Float:y, center, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, bfullscreen, align, channel)

	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	md_drawimage(id, 1, 0, "gfx/bloodscreen/bloodlvl1.tga", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 1.0, 1.5, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}

bloodlvl2(id)
{
	//native acg_drawtga(id, const szTGA[], red, green, blue, alpha, Float:x, Float:y, center, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, bfullscreen, align, channel)

	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	md_drawimage(id, 1, 0, "gfx/bloodscreen/bloodlvl2.tga", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 1.0, 1.5, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}

bloodlvl3(id)
{
	//native acg_drawtga(id, const szTGA[], red, green, blue, alpha, Float:x, Float:y, center, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, bfullscreen, align, channel)

	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	md_drawimage(id, 1, 0, "gfx/bloodscreen/bloodlvl3.tga", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 1.0, 1.5, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}

bloodlvl4(id)
{
	//native acg_drawtga(id, const szTGA[], red, green, blue, alpha, Float:x, Float:y, center, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, bfullscreen, align, channel)

	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	md_drawimage(id, 1, 0, "gfx/bloodscreen/bloodlvl4.tga", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 1.0, 1.5, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}

bloodlvl5(id)
{
	//native acg_drawtga(id, const szTGA[], red, green, blue, alpha, Float:x, Float:y, center, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, bfullscreen, align, channel)

	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	md_drawimage(id, 1, 0, "gfx/bloodscreen/bloodlvl5.tga", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 1.0, 1.5, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}
