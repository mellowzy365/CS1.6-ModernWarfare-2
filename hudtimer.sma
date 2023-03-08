#include <amxmodx>
#include <amxmisc>

/* Special thanks to Blizzard for dhudmessae stock. */

new round;
new timestring[31]

public plugin_init()
{
	register_plugin("dHUD Top message", "1.0", "Noobish")
	register_event("HLTV", "roundstart", "a", "1=0", "2=0");
	register_event("TextMsg", "restartround", "a", "2=#Game_will_restart_in");
	set_task(1.0, "hudclient", 0, _, _, "b") 
	register_cvar( "sv_hudmsgver", "1.0" ); 
}

public hudclient()
{	
	new timeleft = get_timeleft() 
	get_time("%H:%M",timestring,8)
    	
	set_dhudmessage(128, 128, 128, -1.0, 0.02, 0, 0.1, 0.9, 0.1, 0.1)
	show_dhudmessage(0, "[Round: %d | %d:%02d]", round, timeleft / 60, timeleft % 60);			
}
public restartround()
{
	round = 0;	
}
public roundstart()
{
	round += 1;	
}