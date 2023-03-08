/* AMX Mod script.
*
* Weapon Menu
*  by Mattcook & xeroblood
*
* Description: Gives clients weapons via a menu.
*
* Command:
* amx_weaponmenu
*  or
* weaponmenu
*
* Example:
* bind "f" "amx_weaponmenu"
*
* Info: Weapon Menu is a re-make of my plugin Admin Weapon which gives players in the server weapons for free.
* With Weapon Menu you can give any gun to any player in the server via a menu instead of the console commands.
*
* Credit:
* xeroblood (Thank You soo much for all the help you have given me with the menu, and the plugin in general)
* F1del1ty (Thanks for the great idea of this plugin)
*
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>

// This is ONLY Required to Compile for AMX Mod X v1.0
// Comment or Remove to compile for AMX 0.9.9
#include <fun>


// Max Values for Building Menus
#define MAX_PLAYERS     32
#define MAX_WEAPONS     24
#define MAX_AMMO        11
#define MAX_ITEMS        8
#define MAX_DISPLAY      8

// Menu Type Indexes
#define MT_PISTOL        0
#define MT_SHOTGUN       1
#define MT_SMG           2
#define MT_RIFLE         3
#define MT_MACHINE       4
#define MT_PAMMO         5
#define MT_SAMMO         6
#define MT_EQUIP         7
#define MT_EXTRA         8

// Array Index Offsets for Pin-pointing correct weapon
#define OFFSET_SHOTGUN   6
#define OFFSET_SMG       8
#define OFFSET_RIFLE    13
#define OFFSET_MACHINE  23

// Max Menu Options for Each Menu
// (Machine Gun Menu is Only 1 Option, so no array needed for it)
#define MO_MAX_MAIN      9
#define MO_MAX_PISTOL    6
#define MO_MAX_SHOTGUN   2
#define MO_MAX_SMG       5
#define MO_MAX_RIFLE    10
#define MO_MAX_EQUIP     8
#define MO_MAX_EXTRA    14


// Main Menu Text
new g_szMainMenuTxt[MO_MAX_MAIN][] = {
"Pistols",
"Shotguns",
"SMGs",
"Rifles",
"Machine Guns",
"Primary Ammo",
"Secondary Ammo",
"Equipment",
"Extras Menu"
}

// Pistols Menu Text
new g_szPistolMenuTxt[MO_MAX_PISTOL][] = {
".45 USP",
"Glock18C",
"Deagle",
"P228 Compact",
"Colt Phyton Akimbo",
"M9"
}

//Shotguns Section
new g_szShotgunMenuTxt[MO_MAX_SHOTGUN][] = {
"Spass 12",
"Striker"
}

//SMG Section
new g_szSmgMenuTxt[MO_MAX_SMG][] = {
"MP5K",
"TMP",
"P90",
"Mini Uzi",
"Vector"
}

//Rifles Section
new g_szRifleMenuTxt[MO_MAX_RIFLE][] = {
"Famas",
"Remington ACR",
"AK47 Red Dot Sight",
"M4A1",
"Aug HBAR Thermal",
"Intervenion",
"Barret M82",
"M14 EBR",
"WA2000",
"Tar-21"
}

//Machine Guns Section
new g_szMachineMenuTxt[] = "RPD Red Dot Sight"

//Equipment Section
new g_szEquipMenuTxt[MO_MAX_EQUIP][] = {
"Kevlar",
"Kevlar + Helmet",
"Flashbang Grenade",
"HE Grenade",
"Smoke Grenade",
"Defusal Kit",
"Nighvision Goggles",
"Shield"
}

//Extras Section
new g_szExtraMenuTxt[MO_MAX_EXTRA][] = {
"All Weapons",
"M3 Set",
"MP5k Set",
"Famas Set",
"Tar21 Set",
"Scar-H Set",
"AK47 Set",
"Remington ACR Set",
"Aug HBAR Set",
"Rpd Set",
"Interevention Set",
"AutoSniper Set",
"Barret M82 Set",
"Nades Set"
}

// Names of Weapons for give_item() native
new g_szWeaponList[MAX_WEAPONS][] = {
  "weapon_usp", "weapon_glock18", "weapon_deagle", "weapon_p228", "weapon_elite",
  "weapon_fiveseven", "weapon_m3", "weapon_xm1014", "weapon_mp5navy", "weapon_tmp",
  "weapon_p90", "weapon_mac10", "weapon_ump45", "weapon_famas", "weapon_sg552",
  "weapon_ak47", "weapon_m4a1", "weapon_aug", "weapon_scout", "weapon_awp",
  "weapon_g3sg1", "weapon_sg550", "weapon_galil", "weapon_m249"
}

// Names of Equipment Items for give_item() native
new g_szItemsList[MAX_ITEMS][] = {
  "item_kevlar", "item_assaultsuit", "weapon_flashbang", "weapon_hegrenade",
  "weapon_smokegrenade", "item_thighpack", "item_nvgs", "weapon_shield"
}

// Names of Ammo Packs for give_item() native
new g_szAmmoList[MAX_AMMO][] = {
  "ammo_45acp", "ammo_9mm", "ammo_50ae", "ammo_357sig",
  "ammo_57mm", "ammo_buckshot", "ammo_556nato", "ammo_762nato",
  "ammo_338magnum", "ammo_308", "ammo_556natobox"
}

new g_nWeaponData[MAX_WEAPONS][2] = {
  { 0, 8 }, { 1, 8 }, { 2, 5 }, { 3, 6 }, { 1, 4 },
  { 4, 4 }, { 5, 4 }, { 5, 4 }, { 1, 4 }, { 1, 4 },
  { 4, 4 }, { 0, 6 }, { 0, 6 }, { 6, 3 }, { 6, 3 },
  { 7, 3 }, { 6, 3 }, { 6, 3 }, { 7, 3 }, { 8, 3 },
  { 7, 3 }, { 6, 3 }, { 9, 3 }, { 10, 7 }
}

// Tracks what page in menu you're on in Multi-Page Menus (Like Rifles and Players Menu)
// Multiple players may open menu at same time, so we keep an array of MAX_PLAYERS (32)
// to track each individual's menu page.
// Player IDs range from 1-32 but our Array ranges from 0-31 so we minus 1 from PlayerID
// when we use this array.  Example: g_nMenuPosition[ id - 1 ]
new g_nMenuPosition[MAX_PLAYERS]

// We use this to track what menu the user is actually in so we can determine which menu
// to display next.  Different Menu types are: Main, Pistols, Shotguns, SMGs, Rifles, etc..
new g_nMenuType[MAX_PLAYERS]

// Tracks which option in the menu was chosen
new g_nMenuOption[MAX_PLAYERS]


// The following are used for the Players Menu to Track Player Chosen
new g_nMenuPlayers[MAX_PLAYERS][MAX_PLAYERS]
new g_nMenuPlayersNum[MAX_PLAYERS]


public plugin_init()
{
    register_plugin( "Weapon Menu", "1.0", "Mattcook & xeroblood" )

    register_clcmd( "buy", "ShowWeaponMenu", ADMIN_MENU, "Shows The Weapon Menu" )
    register_clcmd( "weaponmenu", "ShowWeaponMenu", ADMIN_MENU, "Shows The Weapon Menu" )

    register_cvar( "sv_weaponmenu_smoke", "1" ) // Give Smoke Nades?  (1 = Yes, 0 = No)
    register_cvar( "sv_weaponmenu_state", "1" ) // Weapon Menu Return State
                                                // 0 = Exit Menu After Give-Item
                                                // 1 = Return to Players Menu
                                                // 2 = Return to Weapons Menu

    register_menucmd( register_menuid("Weapons Menu:"),      1023, "MainMenuCmd" )
    register_menucmd( register_menuid("Pistols Menu:"),      1023, "RegularMenuCmd" )
    register_menucmd( register_menuid("Shotguns Menu:"),     1023, "RegularMenuCmd" )
    register_menucmd( register_menuid("SMGs Menu:"),         1023, "RegularMenuCmd" )
    register_menucmd( register_menuid("Rifles Menu:"),       1023, "RifleMenuCmd" )
    register_menucmd( register_menuid("Machine Guns Menu:"), 1023, "RegularMenuCmd" )
    register_menucmd( register_menuid("Equipment Menu:"),    1023, "RegularMenuCmd" )
    register_menucmd( register_menuid("Extras Menu:"),       1023, "ExtraMenuCmd" )
    register_menucmd( register_menuid("Players Menu:"),      1023, "PlayerMenuCmd" )

    return PLUGIN_CONTINUE
}

public plugin_precache()
{
	server_cmd("bind t weaponmenu");
}

public ShowWeaponMenu( id, lvl, cid )
{
    if( cmd_access( id, lvl, cid, 0 ) )
    {
        g_nMenuPosition[id-1] = 0
        ShowMainMenu( id )
    }
    return PLUGIN_HANDLED
}

///////////////////////////////////////////////////////////////////////////////////////////
//
//      Menu Handling Code Below
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Handles Menu Menu
public MainMenuCmd( id, key )
{
    // Track which Menu Type was chosen
    g_nMenuType[id-1] = key

    switch( key )
    {
        case 0: ShowPistolMenu( id )
        case 1: ShowShotgunMenu( id )
        case 2: ShowSmgMenu( id )
        case 3: ShowRifleMenu( id, g_nMenuPosition[id-1] = 0 )
        case 4: ShowMachineMenu( id )
        case 5: ShowPlayerMenu( id, g_nMenuPosition[id-1] = 0 )
        case 6: ShowPlayerMenu( id, g_nMenuPosition[id-1] = 0 )
        case 7: ShowEquipMenu( id )
        case 8: ShowExtraMenu( id, g_nMenuPosition[id-1] = 0 )
        default: { /* Do Nothing Here (Exit Option) */ }
    }
    return PLUGIN_HANDLED
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Handles all Weapon Menus Except Multi-Page ones like Rifles Menu
public RegularMenuCmd( id, key )
{
    // Track which Option was chosen
    g_nMenuOption[id-1] = key

    switch( key )
    {
        case 9:
        {
            // User Chose to go Back to Previous Menu
            ShowMainMenu( id )
        }
        default: ShowPlayerMenu( id, g_nMenuPosition[id-1] = 0 )
    }
    return PLUGIN_HANDLED
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Handles Multi-Page Rifles Menu
public RifleMenuCmd( id, key )
{
    // Track which Option was chosen
    g_nMenuOption[id-1] = g_nMenuPosition[id-1] * MAX_DISPLAY + key

    switch( key )
    {
        case 8:
        {
            // User Selected "More..." Option
            ShowRifleMenu( id, ++g_nMenuPosition[id-1] )
        }
        case 9:
        {
            // User Chose to go Back to Previous Menu
            if( g_nMenuPosition[id-1] )
            {
                ShowRifleMenu( id, --g_nMenuPosition[id-1] )
            }else
            {
                ShowMainMenu( id )
            }
        }
        default: ShowPlayerMenu( id, g_nMenuPosition[id-1] = 0 )
    }
    return PLUGIN_HANDLED
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Handles Multi-Page Players Menu
public PlayerMenuCmd( id, key )
{
    switch( key )
    {
        case 8:
        {
            // User Selected "More..." Option
            ShowPlayerMenu( id, ++g_nMenuPosition[id-1] )
        }
        case 9:
        {
            // User Chose to go Back to Previous Menu
            if( g_nMenuPosition[id-1] )
            {
                ShowPlayerMenu( id, --g_nMenuPosition[id-1] )
            }else
            {
                ShowMainMenu( id )
            }
        }
        default:
        {
            // Find which Player was chosen
            new nPlayerID = g_nMenuPlayers[id-1][g_nMenuPosition[id-1] * MAX_DISPLAY + key]

            // Give Player Selected Item
            GiveMenuItem( id, nPlayerID )

            // Check which Menu to Re-Open (if any)
            switch( clamp(get_cvar_num("sv_weaponmenu_state"), 0, 2) )
            {
                case 1: ShowPlayerMenu( id, g_nMenuPosition[id-1] ) // Players Menu (At Last Position)
                case 2: ShowMainMenu( id ) // Weapons Menu
            }
        }
    }
    return PLUGIN_HANDLED
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Handles Multi-Page Extras Menu
public ExtraMenuCmd( id, key )
{
    // Track which Option was chosen
    g_nMenuOption[id-1] = g_nMenuPosition[id-1] * MAX_DISPLAY + key

    switch( key )
    {
        case 8:
        {
            // User Selected "More..." Option
            ShowExtraMenu( id, ++g_nMenuPosition[id-1] )
        }
        case 9:
        {
            // User Chose to go Back to Previous Menu
            if( g_nMenuPosition[id-1] )
            {
                ShowExtraMenu( id, --g_nMenuPosition[id-1] )
            }else
            {
                ShowMainMenu( id )
            }
        }
        default: ShowPlayerMenu( id, g_nMenuPosition[id-1] = 0 )
    }
    return PLUGIN_HANDLED
}
//
///////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////
//
//      Menu Building Code Below
//
///////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////
// Build Main Menu Section
public ShowMainMenu( id )
{
    new i, nLen, nKeys = (1<<9)
    new szMenuBody[256]

    nLen = format( szMenuBody, 255, "\yWeapons Menu:\w^n" )
    for( i = 0; i < MO_MAX_MAIN; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", (i+1), g_szMainMenuTxt[i] )
    }
    format( szMenuBody[nLen], (255-nLen), "^n0. Exit" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Pistol Menu Section
public ShowPistolMenu( id )
{
    new i, nLen, nKeys = (1<<9)
    new szMenuBody[256]

    nLen = format( szMenuBody, 255, "\yPistols Menu:\w^n" )
    for( i = 0; i < MO_MAX_PISTOL; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", (i+1), g_szPistolMenuTxt[i] )
    }
    format( szMenuBody[nLen], (255-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Shotgun Menu Section
public ShowShotgunMenu( id )
{
    new i, nLen, nKeys = (1<<9)
    new szMenuBody[256]

    nLen = format( szMenuBody, 255, "\yShotguns Menu:\w^n" )
    for( i = 0; i < MO_MAX_SHOTGUN; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", (i+1), g_szShotgunMenuTxt[i] )
    }
    format( szMenuBody[nLen], (255-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build SMG Menu Section
public ShowSmgMenu( id )
{
    new i, nLen, nKeys = (1<<9)
    new szMenuBody[2256]

    nLen = format( szMenuBody, 255, "\ySMGs Menu:\w^n" )
    for( i = 0; i < MO_MAX_SMG; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", (i+1), g_szSmgMenuTxt[i] )
    }
    format( szMenuBody[nLen], (255-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Rifle Menu Section
public ShowRifleMenu( id, pos )
{
    if( pos < 0 ) return

    new i, j = 0, nStart, nEnd, nLen, nKeys = (1<<9)
    new szMenuBody[512]

    nStart = pos * MAX_DISPLAY

    if( nStart >= MO_MAX_RIFLE )
        nStart = pos = g_nMenuPosition[id-1] = 0

    nLen = format( szMenuBody, 511, "\yRifles Menu:\R%d/2^n\w^n", pos + 1 )

    nEnd = nStart + MAX_DISPLAY
    if( nEnd > MO_MAX_RIFLE ) nEnd = MO_MAX_RIFLE

    for( i = nStart; i < nEnd; i++ )
    {
        nKeys |= (1<<j++)
        nLen += format( szMenuBody[nLen], (511-nLen), "%d. %s^n", j, g_szRifleMenuTxt[i] )
    }

    if( nEnd != MO_MAX_RIFLE )
    {
        format( szMenuBody[nLen], (511-nLen), "^n9. More...^n0. Back" )
        nKeys |= (1<<8)
    }
    else format( szMenuBody[nLen], (511-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Machine Gun Menu Section
public ShowMachineMenu( id )
{
    new nLen, nKeys = (1<<0|1<<9)
    new szMenuBody[256]

    nLen = format( szMenuBody, 255, "\yMachine Guns Menu:\w^n" )
    nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", 1, g_szMachineMenuTxt )
    format( szMenuBody[nLen], (255-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Equipment Menu Section
public ShowEquipMenu( id )
{
    new i, nLen, nKeys = (1<<9)
    new szMenuBody[256]

    nLen = format( szMenuBody, 255, "\yEquipment Menu:\w^n" )
    for( i = 0; i < MO_MAX_EQUIP; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", (i+1), g_szEquipMenuTxt[i] )
    }
    format( szMenuBody[nLen], (255-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Extras Menu Section
/*
public ShowExtraMenu( id )
{
    new i, nLen, nKeys = (1<<9)
    new szMenuBody[256]

    nLen = format( szMenuBody, 255, "\yExtras Menu:\w^n" )
    for( i = 0; i < MO_MAX_EXTRA; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (255-nLen), "%d. %s^n", (i+1), g_szExtraMenuTxt[i] )
    }
    format( szMenuBody[nLen], (255-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}*/

public ShowExtraMenu( id, pos )
{
    if( pos < 0 ) return

    new i, j = 0, nStart, nEnd, nLen, nKeys = (1<<9)
    new szMenuBody[512]

    nStart = pos * MAX_DISPLAY

    if( nStart >= MO_MAX_EXTRA )
        nStart = pos = g_nMenuPosition[id-1] = 0

    nLen = format( szMenuBody, 511, "\yExtras Menu:\R%d/2^n\w^n", pos + 1 )

    nEnd = nStart + MAX_DISPLAY
    if( nEnd > MO_MAX_EXTRA ) nEnd = MO_MAX_EXTRA

    for( i = nStart; i < nEnd; i++ )
    {
        nKeys |= (1<<j++)
        nLen += format( szMenuBody[nLen], (511-nLen), "%d. %s^n", j, g_szExtraMenuTxt[i] )
    }

    if( nEnd != MO_MAX_EXTRA )
    {
        format( szMenuBody[nLen], (511-nLen), "^n9. More...^n0. Back" )
        nKeys |= (1<<8)
    }
    else format( szMenuBody[nLen], (511-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody, -1 )
    return
}

//
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Build Player Menu Section
public ShowPlayerMenu( id, pos )
{
    if( pos < 0 ) return

    get_players( g_nMenuPlayers[id-1], g_nMenuPlayersNum[id-1] )

    new i, j = 0, idx
    new szUserName[32], szMenuBody[512]
    new nStart = pos * MAX_DISPLAY

    if( nStart >= g_nMenuPlayersNum[id-1] )
        nStart = pos = g_nMenuPosition[id-1] = 0

    new nLen = format( szMenuBody, 511, "\yPlayers Menu:\R%d/%d^n\w^n", (pos+1), (g_nMenuPlayersNum[id-1] / MAX_DISPLAY + ((g_nMenuPlayersNum[id-1] % MAX_DISPLAY) ? 1 : 0 )) )
    new nEnd = nStart + MAX_DISPLAY
    new nKeys = (1<<9)

    if( nEnd > g_nMenuPlayersNum[id-1] )
        nEnd = g_nMenuPlayersNum[id-1]

    for( i = nStart; i < nEnd; i++ )
    {
        idx = g_nMenuPlayers[id-1][i]
        get_user_name( idx, szUserName, 31 )

        nKeys |= (1<<j++)
        nLen += format( szMenuBody[nLen], (511-nLen), "%d. %s^n", j, szUserName )
    }

    if( nEnd != g_nMenuPlayersNum[id-1] )
    {
        nKeys |= (1<<8)
        format( szMenuBody[nLen], (511-nLen), "^n9. More...^n0. Back" )
    }
    else format( szMenuBody[nLen], (511-nLen), "^n0. Back" )

    show_menu( id, nKeys, szMenuBody )
    return
}
//
///////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////
//
//      Weapon Giving Code Below
//
///////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////
//  Following Functions Actually Give The Items
//
stock GiveMenuItem( id, p_nPlayerID )
{
    new szUserName[32]
    get_user_name( p_nPlayerID, szUserName, 31 )

    switch( g_nMenuType[id-1] )
    {
        case MT_PISTOL:  GivePlayerWeapon( p_nPlayerID, g_nMenuOption[id-1] )
        case MT_SHOTGUN: GivePlayerWeapon( p_nPlayerID, (OFFSET_SHOTGUN + g_nMenuOption[id-1]) )
        case MT_SMG:     GivePlayerWeapon( p_nPlayerID, (OFFSET_SMG + g_nMenuOption[id-1]) )
        case MT_RIFLE:   GivePlayerWeapon( p_nPlayerID, (OFFSET_RIFLE + g_nMenuOption[id-1]) )
        case MT_MACHINE: GivePlayerWeapon( p_nPlayerID, (OFFSET_MACHINE + g_nMenuOption[id-1]) )
        case MT_PAMMO:   GivePrimaryAmmo( p_nPlayerID )
        case MT_SAMMO:   GiveSecondaryAmmo( p_nPlayerID )
        case MT_EQUIP:   GivePlayerItem( p_nPlayerID, g_nMenuOption[id-1] )
        case MT_EXTRA:   GivePlayerExtra( p_nPlayerID, g_nMenuOption[id-1] )
    }
    return
}


stock GivePlayerWeapon( id, nWeaponIdx )
{
    if( !is_user_alive(id) || (nWeaponIdx < 0) || (nWeaponIdx >= MAX_WEAPONS) )
        return // Invalid User or Weapon

    fm_give_item( id, g_szWeaponList[nWeaponIdx] )
    Stock_Drop_Slot(id, str_to_num(g_szWeaponList[nWeaponIdx]))
    for( new i = 0; i < g_nWeaponData[nWeaponIdx][1]; i++ )
        fm_give_item( id, g_szAmmoList[g_nWeaponData[nWeaponIdx][0]] )

    return
}

stock GivePlayerExtra( id, nExtraIdx )
{
    if( !is_user_alive(id) || (nExtraIdx < 0) || (nExtraIdx >= MO_MAX_EXTRA) )
        return

    new i, j
    switch( nExtraIdx )
    {
        case 0:   // Give Player All Weapons (+Ammo)
        {
            for( i = 0; i < MAX_WEAPONS; i++ )
            {
                fm_give_item( id, g_szWeaponList[i] )
                for( j = 0; j < g_nWeaponData[i][1]; j++ )
                    fm_give_item( id, g_szAmmoList[g_nWeaponData[i][0]] )
            }
        }
        case 1:   // Give Player M3 Set
        {
            GivePlayerWeapon( id, 6 )   // [6] = M3
            GivePlayerWeapon( id, 2 )   // [2] = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 2:   // Give Player MP5 Navy Set
        {
            GivePlayerWeapon( id, 8 )   // [8] = MP5 Navy
            GivePlayerWeapon( id, 2 )   // [2] = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 3:   // Give Player Clarion Set
        {
            GivePlayerWeapon( id, 13 )  // [13] = Clarion (Famas)
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 4:   // Give Player Galil Set
        {
            GivePlayerWeapon( id, 22 )  // [22] = Galil
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 5:   // Give Player M4A1 Set
        {
            GivePlayerWeapon( id, 16 )  // [16] = M4A1
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 6:   // Give Player AK47 Set
        {
            GivePlayerWeapon( id, 15 )  // [15] = AK47
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 7:   // Give Player Krieg SG552 Set
        {
            GivePlayerWeapon( id, 14 )  // [14] = Krieg SG552
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 8:   // Give Player Bullpup Set
        {
            GivePlayerWeapon( id, 17 )  // [17] = Bullpup
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 9:   // Give Player M249 Set
        {
            GivePlayerWeapon( id, 23 )  // [23] = M249
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 10:   // Give Player Scout Set
        {
            GivePlayerWeapon( id, 18 )  // [18] = Scout
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 11:   // Give Player AutoSniper Set
        {
            GivePlayerWeapon( id, 20 )    // [20] = CT AutoSniper (G3SG1)
            //GivePlayerWeapon( id, 21 )  // [21] = T AutoSniper (SG550)
            GivePlayerWeapon( id, 2 )     // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 12:   // Give Player AWP Set
        {
            GivePlayerWeapon( id, 19 )  // [19] = AWP
            GivePlayerWeapon( id, 2 )   // [2]  = Deagle
            for( i = 1; i < 6; i++ )
                GivePlayerItem( id, i ) // Kevlar, Flash/HE/Smoke Grenade, Defuse Kit
        }
        case 13:   // Give Player Nades Set
        {
            for( i = 2; i < 5; i++ )
                GivePlayerItem( id, i ) // Flash/HE/Smoke Grenades
        }
    }
    return
}

stock GivePlayerItem( id, nItemIdx )
{
    if( !is_user_alive(id) || (nItemIdx < 0) || (nItemIdx >= MAX_ITEMS) )
        return // Invalid User or Item

    if( (nItemIdx == 4) && (get_cvar_num("sv_weaponmenu_smoke") < 1) )
        return // Smoke Nades Restricted

    if( nItemIdx == 2 ) // If item is Flashbang, give it twice
        give_item( id, g_szItemsList[nItemIdx] )
    give_item( id, g_szItemsList[nItemIdx] )

    return
}

stock GivePrimaryAmmo( id )
{
    new nWeapons[32], nNum, i, j, k
    new szWeaponName[32]

    // Only give Primary Ammo for Guns Carried
    get_user_weapons( id, nWeapons, nNum )
    for( i = 0; i < nNum; i++ )
    {
        get_weaponname( nWeapons[i], szWeaponName, 31 )
        for( j = OFFSET_SHOTGUN; j < MAX_WEAPONS; j++ )
        {
            if( equali( szWeaponName, g_szWeaponList[j] ) )
            {
                for( k = 0; k < g_nWeaponData[j][1]; k++ )
                    fm_give_item( id, g_szAmmoList[g_nWeaponData[j][0]] )
            }
        }
    }
    return
}

stock GiveSecondaryAmmo( id )
{
    new nWeapons[32], nNum, i, j, k
    new szWeaponName[32]

    // Only give Secondary Ammo for Pistols Carried
    get_user_weapons( id, nWeapons, nNum )
    for( i = 0; i < nNum; i++ )
    {
        get_weaponname( nWeapons[i], szWeaponName, 31 )
        for( j = 0; j < OFFSET_SHOTGUN; j++ )
        {
            if( equali( szWeaponName, g_szWeaponList[j] ) )
            {
                for( k = 0; k < g_nWeaponData[j][1]; k++ )
                    fm_give_item( id, g_szAmmoList[g_nWeaponData[j][0]] )
            }
        }
    }
    return
}
stock Stock_Drop_Slot(id,iSlot)
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++)
	{
		const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
		
		if (iSlot == 2 && SECONDARY_WEAPONS_BIT_SUM & (1<<weapons[i]))
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
//
//
///////////////////////////////////////////////////////////////////////////////////////////
