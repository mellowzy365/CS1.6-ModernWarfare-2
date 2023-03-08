/*	Copyright © 2009, ConnorMcLeod

	Awp CrossHair is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Awp CrossHair; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Snipers Crosshairs"
#define AUTHOR "ConnorMcLeod"
#define VERSION "0.0.3"

#define MAX_PLAYERS	32

#define HasSniperCrosshair(%1)	( g_iFlags & (1<<%1) )

const WEAPONS_9MM = (1<<CSW_ELITE)|(1<<CSW_GLOCK18)|(1<<CSW_MP5NAVY)|(1<<CSW_TMP)

new g_iCurWeapon[MAX_PLAYERS+1]
new g_bInZoom[MAX_PLAYERS+1]
new g_bFake[MAX_PLAYERS+1]

new g_338magnum[MAX_PLAYERS+1]
new g_9mm[MAX_PLAYERS+1]

new gmsgCurWeapon, gmsgAmmoX

new g_iFlags

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_concmd("amx_snipers_crosshair", "AdminCommand_Crosshair", ADMIN_CFG, "amx_snipers_crosshair <flags>")

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_event("AmmoX", "Event_AmmoX", "be", "1=1", "1=10")
	register_event("SetFOV", "Event_SetFOV", "be")

	gmsgCurWeapon = get_user_msgid("CurWeapon")
	gmsgAmmoX = get_user_msgid("AmmoX")
}

public AdminCommand_Crosshair(id, level, cid)
{
	if( !cmd_access(id, level, cid, 2) )
	{
		return PLUGIN_HANDLED
	}

	new szFlags[5]
	read_argv(1, szFlags, charsmax(szFlags))

	static const iSnipersIds[] = {CSW_SCOUT, CSW_SG550, CSW_AWP, CSW_G3SG1}  
	new i, cLetter, iVal
	g_iFlags = 0

	while( (cLetter = szFlags[i++]) )
	{
		iVal = cLetter - 'a'
		if( 0 <= iVal < sizeof(iSnipersIds) )
		{
			g_iFlags |= (1<<iSnipersIds[iVal])
		}
	}

	new iPlayers[MAX_PLAYERS], iNum, iPlayer
	new iClip, iBpAmmo, iWeaponId

	get_players(iPlayers, iNum, "a")

	for(new i; i<iNum; i++)
	{
		iPlayer = iPlayers[i]
		if( g_bInZoom[iPlayer] )
		{
			continue
		}
		iWeaponId = get_user_weapon(iPlayer, iClip, iBpAmmo)
		if( HasSniperCrosshair(iWeaponId) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, gmsgCurWeapon, _, iPlayer)
			ewrite_byte(1)
			ewrite_byte(iWeaponId)
			ewrite_byte(iClip)
			emessage_end()
		}
	}

	return PLUGIN_HANDLED
}

public Event_SetFOV( id )
{
	g_bInZoom[id] = ( 0 < read_data(1) < 55 )
}

public Event_CurWeapon(id)
{
	new iCurWeapon = read_data(2)

	if( iCurWeapon == g_iCurWeapon[id] )
	{
		if( HasSniperCrosshair(iCurWeapon) )
		{
			if( g_bInZoom[id] )
			{
				return
			}
		}
		else
		{
			return
		}
	}
	else
	{
		g_iCurWeapon[id] = iCurWeapon

		if( !HasSniperCrosshair(iCurWeapon) ) 
		{
			if( WEAPONS_9MM & (1<<iCurWeapon) && g_bFake[id] )
			{
				Send_AmmoX(id, 0)
			}
			return
		}

		if( g_bInZoom[id] )
		{
			return
		}
	}

	new iWeapon
	switch( iCurWeapon )
	{
		case CSW_SG550:iWeapon = CSW_GALIL
		case CSW_AWP:iWeapon = CSW_ELITE
		default:iWeapon = CSW_AK47
	}

	message_begin(MSG_ONE_UNRELIABLE, gmsgCurWeapon, _, id)
	write_byte(1)
	write_byte(iWeapon)
	write_byte(read_data(3))
	message_end()

	if( iWeapon == CSW_ELITE && !g_bFake[id] )
	{
		Send_AmmoX(id, 1)
	}
}

public Event_AmmoX(id)
{
	if( read_data(1) == 1)
	{
		g_338magnum[id] = read_data(2)
	}
	else
	{
		g_9mm[id] = read_data(2)
	}

	if( g_iCurWeapon[id] == CSW_AWP && !g_bInZoom[id] )
	{
		Send_AmmoX(id, 1)
	}
}

Send_AmmoX(id, fake)
{
	g_bFake[id] = fake

	message_begin(MSG_ONE_UNRELIABLE, gmsgAmmoX, _, id)
	write_byte(10)
	write_byte(fake ? g_338magnum[id] : g_9mm[id])
	message_end()
}
