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
#include <gamemaster>

#define PLUGIN "CSMW2:TDM HUD"
#define VERSION "1.0"
#define AUTHOR "Mellowzy"

#define TASKID 1337

//events
#define RANGERWIN "MW/rangerwin.wav"
#define RANGERLOSE "MW/rangerdefeat.wav"
#define OPFORWIN "MW/opforwin.wav"
#define OPFORLOSE "MW/opfordefeat.wav"

#define POINT_TO_WIN 50
#define TASK_ROUNDTIME 122
new bool:g_RoundEnd
new g_iRoundtime
new g_FreezeTime
new TKills,CTKills, t_win,t_lose,ct_win,ct_lose
new Time,bool:g_NewRound,bool:RoundStart
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("DeathMsg", "Event_Death", "a")
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	set_task(0.1, "tdm_scoreboard", _,_,_,"b")
	md_init()
	register_event( "SendAudio" , "twin" , "a" , "2=%!MRAD_terwin" );
	register_event( "SendAudio" , "ctwin" , "a" , "2=%!MRAD_ctwin" );
	register_message(get_user_msgid("TextMsg"), "hook_textmsg")
	register_message(get_user_msgid("RoundTime"), "msg_roundtime")
	
	register_logevent("EVENT_CTWIN", 6, "3=CTs_Win", "3=All_Hostages_Rescued")
	register_logevent("EVENT_TWIN", 6, "3=Terrorists_Win", "3=Target_Bombed")
	register_event("ResetHUD", "OnResetHUD", "b")
	set_task(1.07, "Show_Roundtime", TASK_ROUNDTIME,_,_,"b")
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn",1)
}
public plugin_precache()
{
	precache_sound(RANGERWIN)
	precache_sound(RANGERLOSE)
	precache_sound(OPFORWIN)
	precache_sound(OPFORLOSE)
	precache_sound("MW/newroundopfor.wav")//tdm
	precache_sound("MW/newroundranger.wav")
	server_cmd("mp_freezetime 7")
	server_cmd("mp_roundtime 10")
}
public md_init()
{
	md_loadimage("gfx/test/screen.png")
}
public OnResetHUD(id)
{
	if(!g_NewRound)
		return PLUGIN_CONTINUE
	if(task_exists(TASKID))
		remove_task(TASKID)
	
	Time = get_cvar_num("mp_freezetime")
	set_task(1.0, "countdown",TASKID,_,_,"a",Time)
	
	return PLUGIN_HANDLED
}
public PlayerSpawn(id){
	if(!is_user_alive(id)) return
	cek_team_status(id)
}
public cek_team_status(id)
{
	if(!is_user_alive(id)) return
	if(!g_NewRound) return
	if(get_user_team(id) == 1)
	{
		PlaySound(id, "MW/newroundopfor.wav")
	}
	if(get_user_team(id) == 2){
		PlaySound(id, "MW/newroundranger.wav")
	}
	
	client_cmd(id, "volume 1.0")
}	
public countdown()
{
	if(!g_NewRound)
		return
		
	Time --
	if(Time <= 0)
	{
		Time = 0
		g_NewRound = false;
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
public Event_Death()
{	
	new Attacker = read_data(1)
	new Victim = read_data(2)
	
	if(Attacker == Victim || !is_user_connected(Attacker)) return
	
	new team = get_user_team(Attacker)
	if(team == 1)
	{
		TKills++;
			
	}
	if(team == 2)
	{
		CTKills++

	}
	
	check_condition()
	
}
public check_condition()
{
	if(TKills == POINT_TO_WIN && TKills > CTKills )
	{
		GM_TerminateRound(5.0, WINSTATUS_TERRORIST)
		set_task(5.0,"reset_all_score")
		twin()
		EVENT_TWIN(0)
	}
	if(TKills == POINT_TO_WIN && TKills > CTKills && g_RoundEnd)
	{
		GM_TerminateRound(5.0, WINSTATUS_TERRORIST)
		set_task(5.0,"reset_all_score")
		twin()
		EVENT_TWIN(0)
	}
	if(CTKills == POINT_TO_WIN && CTKills > TKills)
	{
		GM_TerminateRound(5.0, WINSTATUS_CT)
		set_task(5.0,"reset_all_score")
		ctwin()
		EVENT_CTWIN(0)
	}
	if(CTKills == POINT_TO_WIN && CTKills > TKills && g_RoundEnd)
	{
		GM_TerminateRound(5.0, WINSTATUS_CT)
		set_task(5.0,"reset_all_score")
		ctwin()
		EVENT_CTWIN(0)
	}
	if(TKills == CTKills && g_RoundEnd)
	{
		GM_TerminateRound(5.0, WINSTATUS_DRAW)
		set_task(5.0,"reset_all_score")
	}
}
public reset_all_score()
{
	for(new a=0;a<get_maxplayers();a++)
	{
		if(!is_user_connected(a))
			continue;
		
		set_user_frags(a,0)
		cs_set_user_deaths(a,0,true)
	}
}
public tdm_scoreboard()
{
	new g_scoreboard[32]
	format(g_scoreboard, 31, "%d^n%d", CTKills,TKills)
	md_drawtext(0, 0, g_scoreboard, 0.15, 0.9, 0, 0, 255,255,255,255, 0.0, 2.0, 0.0, ALIGN_NORMAL)
}
public draw_score2()
{
	static Time;Time = get_cvar_num("mp_freezetime")
	md_drawtext(0, 2, "TEAM DEATHMATCH", 0.15, 0.879, 0, 0, 255,162,68,255, 0.0, 0.0, float(Time), ALIGN_NORMAL)
}
public draw_score3()
{
	new score[32]
	format(score, 31, "MAX KILLS : %d", POINT_TO_WIN)
	md_drawtext(0, 2, score, 0.15, 0.879, 0, 0, 255,255,255,255, 0.0, 2.0, 0.0, ALIGN_NORMAL)
	set_task(3.0, "draw_score2")
}
public client_PreThink(id)
{
	if(!is_user_connected(id)) return;
	if(!RoundStart) return
	state_score(id)
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
			if(TKills == CTKills){
				md_drawtext(a, 2, "TIE", 0.15, 0.879, 0, 0, 255,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(TKills > CTKills){
				md_drawtext(a, 2, "WINNING", 0.15, 0.879, 0, 0, 0,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(TKills < CTKills){
				md_drawtext(a, 2, "LOSING", 0.15, 0.879, 0, 0, 255,0,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
		}
		if(get_user_team(att) == 2){
			if(CTKills == TKills){
				md_drawtext(a, 2, "TIE", 0.15, 0.879, 0, 0, 255,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(CTKills > TKills){
				md_drawtext(a, 2, "WINNING", 0.15, 0.879, 0, 0, 0,255,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
			if(CTKills < TKills){
				md_drawtext(a, 2, "LOSING", 0.15, 0.879, 0, 0, 255,0,0,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
			}
		}
	}
}		
public Event_NewRound()
{
	//reset all point
	TKills = 0
	CTKills = 0;
	g_FreezeTime = 1
	g_RoundEnd = false
	g_NewRound = true;
	RoundStart = false;
	reset_all_score()
	//emit_sound(0, CHAN_AUTO, "MW/newroundopfor.wav", VOL_NORM,ATTN_NORM,SND_CHANGE_VOL,PITCH_NORM)
	set_all_froze(false)
	new players[32],num,a;
	get_players(players,num,"gh")
	for(a=0;a<num;a++)
	{
		a = players[a];
		if(!is_user_connected(a)) continue;
		remove_scanner(a)
	}
	md_removedrawing(0, 1, 22)
	draw_score2()
	showimage()
	//client_cmd(0, "volume 0.5")
	
}
public showimage()
{
	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	static Time;Time = get_cvar_num("mp_freezetime")
	
	md_drawimage(0, 21, 0, "gfx/test/screen.png", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 0.2, float(Time) - 1.0, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}
public showimage2()
{
	new g_screenSize[2]
	g_screenSize[0] = md_getscreenwidth()
	g_screenSize[1] = md_getscreenheight()
	
	md_drawimage(0, 22, 0, "gfx/test/screen.png", 0.0, 0.0, 0, 0, 255,255,255,255, 0.0, 0.2, 0.0, ALIGN_NORMAL, g_screenSize[0], g_screenSize[1])
}
public client_connect(id)g_FreezeTime = 1
public client_putinserver(id)g_FreezeTime = 1
public client_disconnected(id)g_FreezeTime = 1
public Event_RoundStart(id)
{
	g_NewRound = false;
	RoundStart = true;
	g_FreezeTime = 0
	client_cmd(id, "volume 0.35")
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
		check_condition()
		for(new i = 0;i<get_maxplayers();i++)
		{
			md_removedrawing(i, 0, 9)
		}
		
		g_RoundEnd = true
		
		if(task_exists(TASK_ROUNDTIME))remove_task(TASK_ROUNDTIME)
		return
	}
	
	new timeround[256]
	format(timeround,100, "%d:%02d", minutes, sec)
	new players[32],num,i
	get_players(players,num,"gh")
	for(i = 0; i <= num; i++)
	{
		i = players[i];
		md_drawtext(i, 9, timeround, 0.07, 0.8, 0, 0, 255,255,255,255, 0.0, 0.0, 0.0, ALIGN_NORMAL)
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
}

public hook_textmsg()
{
	new szMsg[22]
	get_msg_arg_string(2, szMsg, sizeof szMsg)
	new i;
	for(i = 1; i<= get_playersnum(0);i++)
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
stock PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(id, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(id, "spk ^"%s^"", sound)
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