/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <xs>
#include <metadrawer>

#define PLUGIN "CSMW2:NORMAL HUD"
#define VERSION "1.0"
#define AUTHOR "Mellowzy"

//events
#define RANGERWIN "MW/rangerwin.wav"
#define RANGERLOSE "MW/rangerdefeat.wav"
#define OPFORWIN "MW/opforwin.wav"
#define OPFORLOSE "MW/opfordefeat.wav"

#define TASKID 1337
#define TASK_ROUNDTIME 122
new g_iRoundtime
new g_FreezeTime
new Players[ 32 ];
new playerCount, i, player, CTscore, Tscore,bool:RoundStart
new Time;

new string[ 32 ];

//new team;
new Float:flGameTime, Float:flOldTerGameTime; 
new t_win,t_lose,ct_win,ct_lose

new TPoints, CTPoints
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	register_event("TeamScore", "Team_Score", "a")
	register_event( "SendAudio" , "twin" , "a" , "2=%!MRAD_terwin" );
	register_event( "SendAudio" , "ctwin" , "a" , "2=%!MRAD_ctwin" );
	register_message(get_user_msgid("TextMsg"), "hook_textmsg")
	register_message(get_user_msgid("RoundTime"), "msg_roundtime")
	md_init()
	register_logevent("EVENT_CTWIN", 6, "3=CTs_Win", "3=All_Hostages_Rescued")
	register_logevent("EVENT_TWIN", 6, "3=Terrorists_Win", "3=Target_Bombed")
	register_logevent("Event_PlantBomb", 3, "2=Planted_The_Bomb")
	register_logevent("Event_Defuse", 3, "2=Defused_The_Bomb")
	register_logevent("EVENT_CTWIN", 3, "2=Defused_The_Bomb")
	
	RegisterHam(Ham_Player_PreThink, "player", "Ham_PlayerPreThink")
	
	register_event("ResetHUD", "OnResetHUD", "b")

	set_task(0.1, "team_score",_,_,_,"b")
	set_task(1.07, "Show_Roundtime", TASK_ROUNDTIME,_,_,"b")
}

public plugin_precache()
{
	precache_sound(RANGERWIN)
	precache_sound(RANGERLOSE)
	precache_sound(OPFORWIN)
	precache_sound(OPFORLOSE)
	precache_generic("sound/MW/start2.wav")//snd
	server_cmd("mp_freezetime 4")
	server_cmd("sv_noroundend 0")
	server_cmd("mp_roundtime 3")
}
public msg_roundtime()
{
	g_iRoundtime = get_msg_arg_int(1)
}
public Show_Roundtime()
{
	if(g_FreezeTime)
	{
		md_removedrawing(0, 0, 9)
		return
	}
	
	--g_iRoundtime
	
	static sec,minutes;
	minutes = (g_iRoundtime / 60)
	sec = (g_iRoundtime % 60)
	
	if(minutes == 0 && sec == 0)
	{
		remove_task(TASK_ROUNDTIME)
		for(new i = 0;i<get_maxplayers();i++)
		{
			md_removedrawing(i, 0, 9)
		}
		return
	}
	
	new timeround[256]
	format(timeround,100, "%02d:%02d", minutes, sec)
	new players[32],num,i
	get_players(players,num,"gh")
	for(i = 0; i <= num; i++)
	{
		i = players[i];
		md_drawtext(i, 9, timeround, 0.07, 0.8, 0, 0, 255,255,255,255, 0.0, 0.2, 0.0, ALIGN_NORMAL)
	}
}
public md_init()
{
	md_loadimage("gfx/test/screen.png")
}
public client_connect(id)g_FreezeTime = 1
public client_putinserver(id)g_FreezeTime = 1
public client_disconnected(id)g_FreezeTime = 1
public event_newround()
{
	for(new i = 1; i<= get_maxplayers();i++)
	{
		remove_mddraw(i)
	}
	
	new players[32],num,a;
	get_players(players,num,"gh")
	for(a=0;a<num;a++)
	{
		a = players[a];
		if(!is_user_connected(a)) continue;
		remove_scanner(a)
	}
	
	RoundStart = false;
	draw_score2()
	showimage()
	g_FreezeTime = 1
	
	set_all_froze(false)
	md_removedrawing(0, 1, 22)
	
	PlaySound2(0,"sound/MW/start2.wav")
	client_cmd(0, "volume 0.5")
	
}
public showimage()
{
	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	static Time;Time = get_cvar_num("mp_freezetime")
	
	md_drawimage(0, 21, 0, "gfx/test/screen.png", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 0.2, float(Time), ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}
public showimage2()
{
	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	
	md_drawimage(0, 22, 0, "gfx/test/screen.png", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 0.2, 0.0, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}
public OnResetHUD(id)
{
	if(task_exists(TASKID))
		remove_task(TASKID)
	
	Time = get_cvar_num("mp_freezetime")
	set_task(1.0, "countdown",TASKID,_,_,"a",Time)
	
	return PLUGIN_HANDLED
}
public Event_RoundStart(id)
{
	RoundStart = true;
	g_FreezeTime = 0
}
public client_PreThink(id)
{
	if(!is_user_connected(id)) return;
	if(!RoundStart) return
	state_score(id)
}
public Ham_PlayerPreThink(id)
{
	if(!is_user_connected(id))
		return
	user_money_display(id)
}
public user_money_display(id)
{
	if(!is_user_connected(id)) return
	
	new iMoney = cs_get_user_money(id)
	new mmsg[256]
	format(mmsg, 100, "$ %d", iMoney)
	md_drawtext(id, 11, mmsg, 0.012, 0.26, 0, 0, 255,255,255,255, 0.0, 0.0, 2.0, ALIGN_NORMAL)
}
public state_score(att) //show score condition TIE, WINNING, LOSING
{
	new players[32],num,a;
	get_players(players,num,"gh")
	for(a=0;a<num;a++){
		a = players[a]
		if(!is_user_connected(a)) continue;
		if(get_user_team(att) != get_user_team(a))continue;
		if(get_user_team(att) == 1){
			if(TPoints == CTPoints){
				md_drawtext(a, 2, "TIE", 0.15, 0.879, 0, 0, 255,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(TPoints > CTPoints){
				md_drawtext(a, 2, "WINNING", 0.15, 0.879, 0, 0, 0,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(TPoints < CTPoints){
				md_drawtext(a, 2, "LOSING", 0.15, 0.879, 0, 0, 255,0,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
		}
		if(get_user_team(att) == 2){
			if(CTPoints == TPoints){
				md_drawtext(a, 2, "TIE", 0.15, 0.879, 0, 0, 255,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(CTPoints > TPoints){
				md_drawtext(a, 2, "WINNING", 0.15, 0.879, 0, 0, 0,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(CTPoints < TPoints){
				md_drawtext(a, 2, "LOSING", 0.15, 0.879, 0, 0, 255,0,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
		}
	}
}		
public countdown()
{
	Time --
	if(Time <= 0)
	{
		Time = 0
		return
	}
	new msg[32]
	format(msg, 31, "Match Begins in : %d", Time)
	new player[32],num,a;
	get_players(player,num,"gh")
	for(a=0;a<num;a++)
	{
		a = player[a];
		if(!is_user_connected(a))
			continue;
		
		md_drawtext(a, 12, msg, 0.4, 0.4, 0, 0, 255,255,255,255, 0.0, 0.0, 1.5, ALIGN_NORMAL)
	}
}
public msgHideHealth()
{
	set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | (1<<3))
}
public Team_Score()
{
	new team[32];
	read_data(1, team, 31);
	if(equal(team, "CT"))
	{
		CTPoints = read_data(2)
	}else if(equal(team, "CT")){
		TPoints = read_data(2)
	}
}
public twin()
{
	new i;
	for(i = 1 ; i <= get_playersnum(0);i++)
	{
		client_cmd( i, "spk %s", OPFORWIN );
	}
	t_win = 1
	ct_win = 0
	TPoints++
	check_condition_to_dissconnect()
}
public ctwin()
{
	new i;
	for(i = 1 ; i <= get_playersnum(0);i++)
	{
		client_cmd( i, "spk %s", RANGERWIN );
	}
	ct_win = 1
	t_win = 0
	CTPoints++
	check_condition_to_dissconnect()
}
check_condition_to_dissconnect()
{
	if(TPoints >=  7 || CTPoints >= 7)
		set_task(5.0, "server_disconnect")
}
public Event_PlantBomb()
{
	new players[32],num,a;
	get_players(players, num, "gh")
	for(a=0;a<num;a++)
	{
		if(!is_user_connected(a)) continue;
		md_drawtext(a, 14, "BOMB PLANTED", 0.4, 0.4, 0, 0, 255,255,255,255, 0.0, 0.5, 1.5, ALIGN_NORMAL)
	}
}
public Event_Defuse()
{
	new players[32],num,a;
	get_players(players, num, "gh")
	for(a=0;a<num;a++)
	{
		if(!is_user_connected(a)) continue;
		md_drawtext(a, 14, "BOMB DEFUSED", 0.4, 0.4, 0, 0, 255,255,255,255, 0.0, 0.5, 1.5, ALIGN_NORMAL)
	}
}
public server_disconnect() server_cmd("disconnect")

public hook_textmsg()
{
	new szMsg[22]
	get_msg_arg_string(2, szMsg, sizeof szMsg)
	new i;
	for(i = 0; i<get_maxplayers();i++)
	{
		if(t_win)
		{
			set_msg_arg_string(2, "")
		}
		if(t_lose)
		{
			set_msg_arg_string(2, "")
		}
		
		if(ct_win)
		{
			set_msg_arg_string(2, "")
		}
		if(ct_lose)
		{
			set_msg_arg_string(2, "")
		}
	}
	
	for(new a=0;a<get_maxplayers();a++)
	{			
		if(equal(szMsg, "#Planted_The_Bomb")){
			set_msg_arg_string(2, "")
		}
		if(equal(szMsg, "#Defused_The_Bomb")){
			set_msg_arg_string(2, "")
		}
	}
}  
public EVENT_CTWIN(id)
{
	set_all_froze(true)
	showimage2()
	md_drawimage(id, 8, 0, "gfx/roundend/opforlogo.tga", 0.35, 0.35, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
	md_drawimage(id, 9, 0, "gfx/roundend/rangerlogo.tga", 0.53, 0.35, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
	md_drawimage(id, 10, 0, "gfx/roundend/defeat.tga", 0.35, 0.2, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
	md_drawimage(id, 11, 0, "gfx/roundend/victory.tga", 0.54, 0.2, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)

}
public EVENT_TWIN(id)
{
	set_all_froze(true)
	showimage2()
	md_drawimage(id, 8, 0, "gfx/roundend/opforlogo.tga", 0.35, 0.35, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
	md_drawimage(id, 9, 0, "gfx/roundend/rangerlogo.tga", 0.53, 0.35, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
	md_drawimage(id, 10, 0, "gfx/roundend/victory.tga", 0.35, 0.2, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
	md_drawimage(id, 11, 0, "gfx/roundend/defeat.tga", 0.54, 0.2, 0, 0, 255,255,255,255, 0.0, 0.5, 3.0, ALIGN_NORMAL)
}
public remove_mddraw(id)
{
	md_removedrawing(id, 0, 8)
	md_removedrawing(id, 0, 9)
	md_removedrawing(id, 0, 10)
	md_removedrawing(id, 0, 11)
}
public PlaySound()
{
	get_players( Players, playerCount, "c" );
	for (i=1; i<=playerCount; i++) 
	{
		player = Players[ i ];
		
		if( Tscore > CTscore )
		{
			if( cs_get_user_team( player ) == CS_TEAM_T )
				client_cmd( player, "spk %s", OPFORWIN );
			else if( cs_get_user_team( player ) == CS_TEAM_CT )
				client_cmd( player, "spk %s", OPFORLOSE );
		}
		else if( CTscore > Tscore )
		{
			if( cs_get_user_team( player ) == CS_TEAM_CT )
				client_cmd( player, "spk %s", RANGERWIN );
			else if( cs_get_user_team( player ) == CS_TEAM_T )
				client_cmd( player, "spk %s", RANGERLOSE );
		}
		else if( Tscore == CTscore )
			client_print(player, print_center, "DRAW")
			//client_cmd( player, "spk %s", "sound/WinSound.wav" );
	}
}
stock PlaySound2(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(id, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(id, "spk ^"%s^"", sound)
}
public EndOfRound()
{
	read_data( 2, string, 31 );
	
	flGameTime = get_gametime();
	
	if( flGameTime > flOldTerGameTime )
	{
		flOldTerGameTime = flGameTime;
		
		if( equali( string, "%!MRAD_terwin" ) )
			Tscore++;
		else if( equali( string, "%!MRAD_ctwin" ) )
			CTscore++;
	}
}

public team_score()
{
	new g_scoreboard[32]
	format(g_scoreboard, 31, "%d^n%d", CTPoints,TPoints)
	md_drawtext(0, 0, g_scoreboard, 0.15, 0.9, 0, 0, 255,255,255,255, 0.0, 2.0, 0.0, ALIGN_NORMAL)
}
public draw_score2()
{
	static Time;Time = get_cvar_num("mp_freezetime")
	md_drawtext(0, 2, "SEARCH & DESTROY", 0.15, 0.879, 0, 0, 255,162,68,255, 0.0, 0.0, float(Time), ALIGN_NORMAL)
}
set_all_froze(bool:freeze)
{
	for(new a=0;a<get_maxplayers();a++)
	{
		if(!is_user_connected(a)) continue;
		if(freeze)
		{
			set_pev(a, pev_takedamage, DAMAGE_NO)
			set_pev(a, pev_flags, pev(a, pev_flags) | FL_FROZEN);
		}else{
			set_pev(a, pev_takedamage, DAMAGE_YES)
			set_pev(a, pev_flags, pev(a, pev_flags) & ~FL_FROZEN);
		}
	}
}
public remove_scanner(id)
{
	for(new i = 0; i < 32;i++)
	{
		md_removedrawing(id, 5, i)
	}
	return;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
