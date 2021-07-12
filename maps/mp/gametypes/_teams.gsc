// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;

FACTION_REF_COL 					= 0;
FACTION_NAME_COL 					= 1;
FACTION_SHORT_NAME_COL 				= 2;
FACTION_ELIMINATED_COL 				= 3;
FACTION_FORFEITED_COL 				= 4;
FACTION_ICON_COL 					= 5;
FACTION_HUD_ICON_COL 				= 6;
FACTION_VOICE_PREFIX_COL 			= 7;
FACTION_SPAWN_MUSIC_COL 			= 8;
FACTION_WIN_MUSIC_COL 				= 9;
FACTION_FLAG_MODEL_COL 				= 10;
FACTION_FLAG_CARRY_MODEL_COL 		= 11;
FACTION_FLAG_ICON_COL 				= 12;
FACTION_FLAG_FX_COL 				= 13;
FACTION_COLOR_R_COL 				= 14;
FACTION_COLOR_G_COL 				= 15;
FACTION_COLOR_B_COL 				= 16;
FACTION_HEAD_ICON_COL 				= 17;
FACTION_CRATE_MODEL_COL 			= 18;
FACTION_DEPLOY_MODEL_COL 			= 19;
init()
{
    initScoreBoard();
    level.teamBalance = getdvarint( "scr_teambalance" );
    level.maxClients = getdvarint( "sv_maxclients" );
    level._effect["thermal_beacon"] = loadfx( "misc/thermal_beacon_inverted" );
    effect = level._effect["thermal_beacon"];
    precachefxteamthermal( effect, "J_Spine4" );
    setPlayerModels();
    level.freeplayers = [];

    if ( level.teamBased )
    {
        level thread onPlayerConnect();
        level thread updateTeamBalance();
        wait 0.15;
        level thread updatePlayerTimes();
    }
    else
    {
        level thread onFreePlayerConnect();
        wait 0.15;
        level thread updateFreePlayerTimes();
    }
}

initScoreBoard()
{
    setdvar( "g_TeamName_Allies", getTeamShortName( "allies" ) );
    setdvar( "g_TeamIcon_Allies", getTeamIcon( "allies" ) );
    setdvar( "g_TeamIcon_MyAllies", getTeamIcon( "allies" ) );
    setdvar( "g_TeamIcon_EnemyAllies", getTeamIcon( "allies" ) );
    scoreColor = getTeamColor( "allies" );
    setdvar( "g_ScoresColor_Allies", scoreColor[0] + " " + scoreColor[1] + " " + scoreColor[2] );
    setdvar( "g_TeamName_Axis", getTeamShortName( "axis" ) );
    setdvar( "g_TeamIcon_Axis", getTeamIcon( "axis" ) );
    setdvar( "g_TeamIcon_MyAxis", getTeamIcon( "axis" ) );
    setdvar( "g_TeamIcon_EnemyAxis", getTeamIcon( "axis" ) );
    scoreColor = getTeamColor( "axis" );
    setdvar( "g_ScoresColor_Axis", scoreColor[0] + " " + scoreColor[1] + " " + scoreColor[2] );
    setdvar( "g_ScoresColor_Spectator", ".25 .25 .25" );
    setdvar( "g_ScoresColor_Free", ".76 .78 .10" );
    setdvar( "g_teamTitleColor_MyTeam", ".6 .8 .6" );
    setdvar( "g_teamTitleColor_EnemyTeam", "1 .45 .5" );
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player );
        player thread onJoinedTeam();
        player thread onJoinedSpectators();
        player thread onPlayerSpawned();
        player thread trackPlayedTime();
    }
}

onFreePlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player );
        player thread trackFreePlayedTime();
    }
}

onJoinedTeam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );
        updateTeamTime();
    }
}

onJoinedSpectators()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_spectators" );
        self.pers["teamTime"] = undefined;
    }
}

trackPlayedTime()
{
    self endon( "disconnect" );
    self.timePlayed["allies"] = 0;
    self.timePlayed["axis"] = 0;
    self.timePlayed["free"] = 0;
    self.timePlayed["other"] = 0;
    self.timePlayed["total"] = 0;
    maps\mp\_utility::gameFlagWait( "prematch_done" );

    for (;;)
    {
        if ( game["state"] == "playing" )
        {
            if ( self.sessionteam == "allies" )
            {
                self.timePlayed["allies"]++;
                self.timePlayed["total"]++;
            }
            else if ( self.sessionteam == "axis" )
            {
                self.timePlayed["axis"]++;
                self.timePlayed["total"]++;
            }
            else if ( self.sessionteam == "spectator" )
                self.timePlayed["other"]++;
        }

        wait 1.0;
    }
}

updatePlayerTimes()
{
    if ( !level.rankedmatch )
        return;

    level endon( "game_ended" );

    for (;;)
    {
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

        foreach ( player in level.players )
            player updatePlayedTime();

        wait 1.0;
    }
}

updatePlayedTime()
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    if ( self.timePlayed["allies"] )
    {
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedAllies", self.timePlayed["allies"] );
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["allies"] );
        maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["allies"] );

        if ( !self.prestigeDoubleXp )
        {
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 0, self.timePlayed["allies"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 1, self.timePlayed["allies"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 2, self.timePlayed["allies"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] );
        }

        maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "challengeXPMultiplierTimePlayed", 0, self.timePlayed["allies"], self.bufferedChildStatsMax["challengeXPMaxMultiplierTimePlayed"][0] );
        maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "weaponXPMultiplierTimePlayed", 0, self.timePlayed["allies"], self.bufferedChildStatsMax["weaponXPMaxMultiplierTimePlayed"][0] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleXpTimePlayed", self.timePlayed["allies"], self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleWeaponXpTimePlayed", self.timePlayed["allies"], self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] );
    }

    if ( self.timePlayed["axis"] )
    {
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOpfor", self.timePlayed["axis"] );
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["axis"] );
        maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["axis"] );

        if ( !self.prestigeDoubleXp )
        {
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 0, self.timePlayed["axis"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 1, self.timePlayed["axis"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 2, self.timePlayed["axis"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] );
        }

        maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "challengeXPMultiplierTimePlayed", 0, self.timePlayed["axis"], self.bufferedChildStatsMax["challengeXPMaxMultiplierTimePlayed"][0] );
        maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "weaponXPMultiplierTimePlayed", 0, self.timePlayed["axis"], self.bufferedChildStatsMax["weaponXPMaxMultiplierTimePlayed"][0] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleXpTimePlayed", self.timePlayed["axis"], self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleWeaponXpTimePlayed", self.timePlayed["axis"], self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] );
    }

    if ( self.timePlayed["other"] )
    {
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOther", self.timePlayed["other"] );
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["other"] );
        maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["other"] );

        if ( !self.prestigeDoubleXp )
        {
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 0, self.timePlayed["other"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 1, self.timePlayed["other"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 2, self.timePlayed["other"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] );
        }

        maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "challengeXPMultiplierTimePlayed", 0, self.timePlayed["other"], self.bufferedChildStatsMax["challengeXPMaxMultiplierTimePlayed"][0] );
        maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "weaponXPMultiplierTimePlayed", 0, self.timePlayed["other"], self.bufferedChildStatsMax["weaponXPMaxMultiplierTimePlayed"][0] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleXpTimePlayed", self.timePlayed["other"], self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleWeaponXpTimePlayed", self.timePlayed["other"], self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] );
    }

    if ( game["state"] == "postgame" )
        return;

    self.timePlayed["allies"] = 0;
    self.timePlayed["axis"] = 0;
    self.timePlayed["other"] = 0;
}

updateTeamTime()
{
    if ( game["state"] != "playing" )
        return;

    self.pers["teamTime"] = gettime();
}

updateTeamBalanceDvar()
{
    for (;;)
    {
        teambalance = getdvarint( "scr_teambalance" );

        if ( level.teamBalance != teambalance )
            level.teamBalance = getdvarint( "scr_teambalance" );

        wait 1;
    }
}

updateTeamBalance()
{
    level.teamLimit = level.maxClients / 2;
    level thread updateTeamBalanceDvar();
    wait 0.15;

    if ( level.teamBalance && maps\mp\_utility::isRoundBased() )
    {
        if ( isdefined( game["BalanceTeamsNextRound"] ) )
            iprintlnbold( &"MP_AUTOBALANCE_NEXT_ROUND" );

        level waittill( "restarting" );

        if ( isdefined( game["BalanceTeamsNextRound"] ) )
        {
            level balanceTeams();
            game["BalanceTeamsNextRound"] = undefined;
        }
        else if ( !getTeamBalance() )
            game["BalanceTeamsNextRound"] = 1;
    }
    else
    {
        level endon( "game_ended" );

        for (;;)
        {
            if ( level.teamBalance )
            {
                if ( !getTeamBalance() )
                {
                    iprintlnbold( &"MP_AUTOBALANCE_SECONDS", 15 );
                    wait 15.0;

                    if ( !getTeamBalance() )
                        level balanceTeams();
                }

                wait 59.0;
            }

            wait 1.0;
        }
    }
}

getTeamBalance()
{
    level.team["allies"] = 0;
    level.team["axis"] = 0;
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "allies" )
        {
            level.team["allies"]++;
            continue;
        }

        if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "axis" )
            level.team["axis"]++;
    }

    if ( level.team["allies"] > level.team["axis"] + level.teamBalance || level.team["axis"] > level.team["allies"] + level.teamBalance )
        return 0;
    else
        return 1;
}

balanceTeams()
{
    iprintlnbold( game["strings"]["autobalance"] );
    AlliedPlayers = [];
    AxisPlayers = [];
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isdefined( players[i].pers["teamTime"] ) )
            continue;

        if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "allies" )
        {
            AlliedPlayers[AlliedPlayers.size] = players[i];
            continue;
        }

        if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "axis" )
            AxisPlayers[AxisPlayers.size] = players[i];
    }

    MostRecent = undefined;

    while ( AlliedPlayers.size > AxisPlayers.size + 1 || AxisPlayers.size > AlliedPlayers.size + 1 )
    {
        if ( AlliedPlayers.size > AxisPlayers.size + 1 )
        {
            for ( j = 0; j < AlliedPlayers.size; j++ )
            {
                if ( isdefined( AlliedPlayers[j].dont_auto_balance ) )
                    continue;

                if ( !isdefined( MostRecent ) )
                {
                    MostRecent = AlliedPlayers[j];
                    continue;
                }

                if ( AlliedPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"] )
                    MostRecent = AlliedPlayers[j];
            }

            MostRecent [[ level.axis ]]();
        }
        else if ( AxisPlayers.size > AlliedPlayers.size + 1 )
        {
            for ( j = 0; j < AxisPlayers.size; j++ )
            {
                if ( isdefined( AxisPlayers[j].dont_auto_balance ) )
                    continue;

                if ( !isdefined( MostRecent ) )
                {
                    MostRecent = AxisPlayers[j];
                    continue;
                }

                if ( AxisPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"] )
                    MostRecent = AxisPlayers[j];
            }

            MostRecent [[ level.allies ]]();
        }

        MostRecent = undefined;
        AlliedPlayers = [];
        AxisPlayers = [];
        players = level.players;

        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "allies" )
            {
                AlliedPlayers[AlliedPlayers.size] = players[i];
                continue;
            }

            if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "axis" )
                AxisPlayers[AxisPlayers.size] = players[i];
        }
    }
}

setGhillieModels( env )
{
    level.environment = env;

    switch ( env )
    {
        case "desert":
            mptype\mptype_ally_ghillie_desert::precache();
            mptype\mptype_opforce_ghillie_desert::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_desert::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_desert::main;
            break;
        case "arctic":
            mptype\mptype_ally_ghillie_arctic::precache();
            mptype\mptype_opforce_ghillie_arctic::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_arctic::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_arctic::main;
            break;
        case "urban":
            mptype\mptype_ally_ghillie_urban::precache();
            mptype\mptype_opforce_ghillie_urban::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_urban::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_urban::main;
            break;
        case "forest":
            mptype\mptype_ally_ghillie_forest::precache();
            mptype\mptype_opforce_ghillie_forest::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_forest::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_forest::main;
            break;
        case "forest_militia":
            mptype\mptype_ally_ghillie_forest::precache();
            mptype\mptype_opforce_ghillie_militia::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_forest::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_militia::main;
            break;
        case "desert_militia":
            mptype\mptype_ally_ghillie_desert::precache();
            mptype\mptype_opforce_ghillie_militia::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_desert::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_militia::main;
            break;
        case "arctic_militia":
            mptype\mptype_ally_ghillie_arctic::precache();
            mptype\mptype_opforce_ghillie_militia::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_arctic::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_militia::main;
            break;
        case "urban_militia":
            mptype\mptype_ally_ghillie_urban::precache();
            mptype\mptype_opforce_ghillie_militia::precache();
            game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_urban::main;
            game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_militia::main;
            break;
        default:
            break;
    }
}

setTeamModels( team, charSet )
{
    switch ( charSet )
    {
        case "delta_multicam":
            mptype\mptype_delta_multicam_assault::precache();
            mptype\mptype_delta_multicam_lmg::precache();
            mptype\mptype_delta_multicam_smg::precache();
            mptype\mptype_delta_multicam_shotgun::precache();
            mptype\mptype_delta_multicam_sniper::precache();
            mptype\mptype_delta_multicam_riot::precache();
            mptype\mptype_ally_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_delta_multicam_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_delta_multicam_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_delta_multicam_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_delta_multicam_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_delta_multicam_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_delta_multicam_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_ally_juggernaut::main;
            break;
        case "sas_urban":
            mptype\mptype_sas_urban_assault::precache();
            mptype\mptype_sas_urban_lmg::precache();
            mptype\mptype_sas_urban_shotgun::precache();
            mptype\mptype_sas_urban_smg::precache();
            mptype\mptype_sas_urban_sniper::precache();
            mptype\mptype_ally_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_sas_urban_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_sas_urban_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_sas_urban_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_sas_urban_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_sas_urban_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_sas_urban_smg::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_ally_juggernaut::main;
            break;
        case "gign_paris":
            mptype\mptype_gign_paris_assault::precache();
            mptype\mptype_gign_paris_lmg::precache();
            mptype\mptype_gign_paris_shotgun::precache();
            mptype\mptype_gign_paris_smg::precache();
            mptype\mptype_gign_paris_sniper::precache();
            mptype\mptype_gign_paris_riot::precache();
            mptype\mptype_ally_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_gign_paris_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_gign_paris_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_gign_paris_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_gign_paris_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_gign_paris_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_gign_paris_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_ally_juggernaut::main;
            break;
        case "pmc_africa":
            mptype\mptype_pmc_africa_assault::precache();
            mptype\mptype_pmc_africa_lmg::precache();
            mptype\mptype_pmc_africa_smg::precache();
            mptype\mptype_pmc_africa_shotgun::precache();
            mptype\mptype_pmc_africa_sniper::precache();
            mptype\mptype_pmc_africa_riot::precache();
            mptype\mptype_ally_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_pmc_africa_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_pmc_africa_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_pmc_africa_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_pmc_africa_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_pmc_africa_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_pmc_africa_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_ally_juggernaut::main;
            break;
        case "opforce_air":
            mptype\mptype_opforce_air_assault::precache();
            mptype\mptype_opforce_air_lmg::precache();
            mptype\mptype_opforce_air_shotgun::precache();
            mptype\mptype_opforce_air_smg::precache();
            mptype\mptype_opforce_air_sniper::precache();
            mptype\mptype_opforce_air_riot::precache();
            mptype\mptype_opforce_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_air_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_opforce_air_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_air_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_air_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_opforce_air_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_opforce_air_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_opforce_juggernaut::main;
            break;
        case "opforce_snow":
            mptype\mptype_opforce_snow_assault::precache();
            mptype\mptype_opforce_snow_lmg::precache();
            mptype\mptype_opforce_snow_shotgun::precache();
            mptype\mptype_opforce_snow_smg::precache();
            mptype\mptype_opforce_snow_sniper::precache();
            mptype\mptype_opforce_snow_riot::precache();
            mptype\mptype_opforce_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_snow_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_opforce_snow_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_snow_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_snow_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_opforce_snow_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_opforce_snow_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_opforce_juggernaut::main;
            break;
        case "opforce_urban":
            mptype\mptype_opforce_urban_assault::precache();
            mptype\mptype_opforce_urban_lmg::precache();
            mptype\mptype_opforce_urban_shotgun::precache();
            mptype\mptype_opforce_urban_smg::precache();
            mptype\mptype_opforce_urban_sniper::precache();
            mptype\mptype_opforce_urban_riot::precache();
            mptype\mptype_opforce_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_urban_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_opforce_urban_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_urban_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_urban_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_opforce_urban_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_opforce_urban_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_opforce_juggernaut::main;
            break;
        case "opforce_woodland":
            mptype\mptype_opforce_woodland_assault::precache();
            mptype\mptype_opforce_woodland_lmg::precache();
            mptype\mptype_opforce_woodland_shotgun::precache();
            mptype\mptype_opforce_woodland_smg::precache();
            mptype\mptype_opforce_woodland_sniper::precache();
            mptype\mptype_opforce_woodland_riot::precache();
            mptype\mptype_opforce_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_woodland_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_opforce_woodland_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_woodland_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_woodland_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_opforce_woodland_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_opforce_woodland_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_opforce_juggernaut::main;
            break;
        case "opforce_africa":
            mptype\mptype_opforce_africa_assault::precache();
            mptype\mptype_opforce_africa_lmg::precache();
            mptype\mptype_opforce_africa_shotgun::precache();
            mptype\mptype_opforce_africa_smg::precache();
            mptype\mptype_opforce_africa_sniper::precache();
            mptype\mptype_opforce_africa_riot::precache();
            mptype\mptype_opforce_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_africa_lmg::main;
            game[team + "_model"]["LMG"] = mptype\mptype_opforce_africa_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_africa_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_africa_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_opforce_africa_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_opforce_africa_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_opforce_juggernaut::main;
            break;
        case "opforce_henchmen":
            mptype\mptype_opforce_henchmen_assault::precache();
            mptype\mptype_opforce_henchmen_lmg::precache();
            mptype\mptype_opforce_henchmen_shotgun::precache();
            mptype\mptype_opforce_henchmen_smg::precache();
            mptype\mptype_opforce_henchmen_sniper::precache();
            mptype\mptype_opforce_henchmen_riot::precache();
            mptype\mptype_opforce_juggernaut::precache();
            game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_henchmen_sniper::main;
            game[team + "_model"]["LMG"] = mptype\mptype_opforce_henchmen_lmg::main;
            game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_henchmen_assault::main;
            game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_henchmen_shotgun::main;
            game[team + "_model"]["SMG"] = mptype\mptype_opforce_henchmen_smg::main;
            game[team + "_model"]["RIOT"] = mptype\mptype_opforce_henchmen_riot::main;
            game[team + "_model"]["JUGGERNAUT"] = mptype\mptype_opforce_juggernaut::main;
            break;
    }
}

setPlayerModels()
{
    setTeamModels( "allies", game["allies"] );
    setTeamModels( "axis", game["axis"] );
    setGhillieModels( getmapcustom( "environment" ) );
}

playerModelForWeapon( weapon, secondary )
{
    team = self.team;

    if ( isdefined( game[team + "_model"][weapon] ) )
    {
        [[ game[team + "_model"][weapon] ]]();
        return;
    }

    weaponClass = tablelookup( "mp/statstable.csv", 4, weapon, 2 );

    switch ( weaponClass )
    {
        case "weapon_smg":
            [[ game[team + "_model"]["SMG"] ]]();
            break;
        case "weapon_assault":
            [[ game[team + "_model"]["ASSAULT"] ]]();
            break;
        case "weapon_sniper":
            if ( level.environment != "" && self isitemunlocked( "ghillie_" + level.environment ) && game[team] != "opforce_africa" )
                [[ game[team + "_model"]["SNIPER"] ]]();
            else
                [[ game[team + "_model"]["SNIPER"] ]]();

            break;
        case "weapon_lmg":
            [[ game[team + "_model"]["LMG"] ]]();
            break;
        case "weapon_riot":
            [[ game[team + "_model"]["RIOT"] ]]();
            break;
        case "weapon_shotgun":
            [[ game[team + "_model"]["SHOTGUN"] ]]();
            break;
        default:
            [[ game[team + "_model"]["ASSAULT"] ]]();
            break;
    }
    /*
    if ( maps\mp\_utility::isJuggernaut() )
        [[ game[team + "_model"]["JUGGERNAUT"] ]]();
    */
}

CountPlayers()
{
    players = level.players;
    allies = 0;
    axis = 0;

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] == self )
            continue;

        if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "allies" )
        {
            allies++;
            continue;
        }

        if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == "axis" )
            axis++;
    }

    players["allies"] = allies;
    players["axis"] = axis;
    return players;
}

trackFreePlayedTime()
{
    self endon( "disconnect" );
    self.timePlayed["allies"] = 0;
    self.timePlayed["axis"] = 0;
    self.timePlayed["other"] = 0;
    self.timePlayed["total"] = 0;

    for (;;)
    {
        if ( game["state"] == "playing" )
        {
            if ( isdefined( self.pers["team"] ) && self.pers["team"] == "allies" && self.sessionteam != "spectator" )
            {
                self.timePlayed["allies"]++;
                self.timePlayed["total"]++;
            }
            else if ( isdefined( self.pers["team"] ) && self.pers["team"] == "axis" && self.sessionteam != "spectator" )
            {
                self.timePlayed["axis"]++;
                self.timePlayed["total"]++;
            }
            else
                self.timePlayed["other"]++;
        }

        wait 1.0;
    }
}

updateFreePlayerTimes()
{
    if ( !level.rankedmatch )
        return;

    nextToUpdate = 0;

    for (;;)
    {
        nextToUpdate++;

        if ( nextToUpdate >= level.players.size )
            nextToUpdate = 0;

        if ( isdefined( level.players[nextToUpdate] ) )
            level.players[nextToUpdate] updateFreePlayedTime();

        wait 1.0;
    }
}

updateFreePlayedTime()
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    if ( self.timePlayed["allies"] )
    {
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedAllies", self.timePlayed["allies"] );
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["allies"] );
        maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["allies"] );

        if ( !self.prestigeDoubleXp )
        {
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 0, self.timePlayed["allies"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 1, self.timePlayed["allies"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 2, self.timePlayed["allies"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] );
        }

        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleXpTimePlayed", self.timePlayed["allies"], self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleWeaponXpTimePlayed", self.timePlayed["allies"], self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] );
    }

    if ( self.timePlayed["axis"] )
    {
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOpfor", self.timePlayed["axis"] );
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["axis"] );
        maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["axis"] );

        if ( !self.prestigeDoubleXp )
        {
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 0, self.timePlayed["axis"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 1, self.timePlayed["axis"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 2, self.timePlayed["axis"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] );
        }

        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleXpTimePlayed", self.timePlayed["axis"], self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleWeaponXpTimePlayed", self.timePlayed["axis"], self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] );
    }

    if ( self.timePlayed["other"] )
    {
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOther", self.timePlayed["other"] );
        maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["other"] );
        maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["other"] );

        if ( !self.prestigeDoubleXp )
        {
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 0, self.timePlayed["other"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 1, self.timePlayed["other"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] );
            maps\mp\gametypes\_persistence::statAddChildBufferedWithMax( "xpMultiplierTimePlayed", 2, self.timePlayed["other"], self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] );
        }

        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleXpTimePlayed", self.timePlayed["other"], self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] );
        maps\mp\gametypes\_persistence::statAddBufferedWithMax( "prestigeDoubleWeaponXpTimePlayed", self.timePlayed["other"], self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] );
    }

    if ( game["state"] == "postgame" )
        return;

    self.timePlayed["allies"] = 0;
    self.timePlayed["axis"] = 0;
    self.timePlayed["other"] = 0;
}

getJoinTeamPermissions( team )
{
    teamcount = 0;
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
            teamcount++;
    }

    if ( teamcount < level.teamLimit )
        return 1;
    else
        return 0;
}

onPlayerSpawned()
{
    level endon( "game_ended" );

    for (;;)
        self waittill( "spawned_player" );
}

getTeamName( teamRef )
{
    return tablelookupistring( "mp/factionTable.csv", 0, game[teamRef], FACTION_NAME_COL );
}

getTeamShortName( teamRef )
{
    return tablelookupistring( "mp/factionTable.csv", 0, game[teamRef], FACTION_SHORT_NAME_COL );
}

getTeamForfeitedString( teamRef )
{
    return tablelookupistring( "mp/factionTable.csv", 0, game[teamRef], FACTION_FORFEITED_COL );
}

getTeamEliminatedString( teamRef )
{
    return tablelookupistring( "mp/factionTable.csv", 0, game[teamRef], FACTION_ELIMINATED_COL );
}

getTeamIcon( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_ICON_COL );
}

getTeamHudIcon( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_HUD_ICON_COL );
}

getTeamHeadIcon( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_HEAD_ICON_COL );
}

getTeamVoicePrefix( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_VOICE_PREFIX_COL );
}

getTeamSpawnMusic( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_SPAWN_MUSIC_COL );
}

getTeamWinMusic( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_WIN_MUSIC_COL );
}

getTeamFlagModel( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_FLAG_MODEL_COL );
}

getTeamFlagCarryModel( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_FLAG_CARRY_MODEL_COL );
}

getTeamFlagIcon( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_FLAG_ICON_COL );
}

getTeamFlagFX( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_FLAG_FX_COL );
}

getTeamColor( teamRef )
{
    return ( maps\mp\_utility::stringToFloat( tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_COLOR_R_COL ) ), 
    maps\mp\_utility::stringToFloat( tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_COLOR_G_COL ) ), 
    maps\mp\_utility::stringToFloat( tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_COLOR_B_COL ) ) );
}

getTeamCrateModel( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_CRATE_MODEL_COL );
}

getTeamDeployModel( teamRef )
{
    return tablelookup( "mp/factionTable.csv", 0, game[teamRef], FACTION_DEPLOY_MODEL_COL );
}
