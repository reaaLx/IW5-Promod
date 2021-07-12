// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
    level.splitscreen = issplitscreen();
    level.ps3 = getdvar( "ps3Game" ) == "true";
    level.xenon = getdvar( "xenonGame" ) == "true";
    level.console = level.ps3 || level.xenon;
    level.onlinegame = getdvarint( "onlinegame" );
    level.rankedmatch = !level.onlinegame || !getdvarint( "xblive_privatematch" );
    level.script = tolower( getdvar( "mapname" ) );
    level.gameType = tolower( getdvar( "g_gametype" ) );
    level.otherTeam["allies"] = "axis";
    level.otherTeam["axis"] = "allies";
    level.teamBased = 0;
    level.objectiveBased = 0;
    level.endGameOnTimeLimit = 1;
    level.showingFinalKillcam = 0;
    level.tiSpawnDelay = getdvarint( "scr_tispawndelay" );

    if ( !isdefined( level.tweakablesInitialized ) )
        maps\mp\gametypes\_tweakables::init();

    precachestring( &"MP_HALFTIME" );
    precachestring( &"MP_OVERTIME" );
    precachestring( &"MP_ROUNDEND" );
    precachestring( &"MP_INTERMISSION" );
    precachestring( &"MP_SWITCHING_SIDES" );
    precachestring( &"MP_FRIENDLY_FIRE_WILL_NOT" );
    precachestring( &"PLATFORM_REVIVE" );
    precachestring( &"MP_OBITUARY_NEUTRAL" );
    precachestring( &"MP_OBITUARY_FRIENDLY" );
    precachestring( &"MP_OBITUARY_ENEMY" );

    if ( level.splitscreen )
        precachestring( &"MP_ENDED_GAME" );
    else
        precachestring( &"MP_HOST_ENDED_GAME" );

    level.halftimeType = "halftime";
    level.halftimeSubCaption = &"MP_SWITCHING_SIDES";
    level.lastStatusTime = 0;
    level.wasWinning = "none";
    level.lastSlowProcessFrame = 0;
    level.placement["allies"] = [];
    level.placement["axis"] = [];
    level.placement["all"] = [];
    level.postRoundTime = 5.0;
    level.playersLookingForSafeSpawn = [];
    registerDvars();
    precachemodel( "vehicle_mig29_desert" );
    precachemodel( "projectile_cbu97_clusterbomb" );
    precachemodel( "tag_origin" );
    level.fx_airstrike_afterburner = loadfx( "fire/jet_afterburner" );
    level.fx_airstrike_contrail = loadfx( "smoke/jet_contrail" );

    if ( maps\mp\_utility::matchMakingGame() )
    {
        mapLeaderboard = " LB_MAP_" + getdvar( "ui_mapname" );
        gamemodeLeaderboard = " LB_GM_" + level.gameType;

        if ( getdvarint( "g_hardcore" ) )
            gamemodeLeaderboard += "_HC";

        precacheleaderboards( "LB_GB_TOTALXP_AT LB_GB_TOTALXP_LT LB_GB_WINS_AT LB_GB_WINS_LT LB_GB_KILLS_AT LB_GB_KILLS_LT LB_GB_ACCURACY_AT LB_ACCOLADES" + gamemodeLeaderboard + mapLeaderboard );
    }

    level.teamCount["allies"] = 0;
    level.teamCount["axis"] = 0;
    level.teamCount["spectator"] = 0;
    level.aliveCount["allies"] = 0;
    level.aliveCount["axis"] = 0;
    level.aliveCount["spectator"] = 0;
    level.livesCount["allies"] = 0;
    level.livesCount["axis"] = 0;
    level.oneLeftTime = [];
    level.hasSpawned["allies"] = 0;
    level.hasSpawned["axis"] = 0;
}

registerDvars()
{
    makedvarserverinfo( "ui_bomb_timer", 0 );
    makedvarserverinfo( "ui_nuke_end_milliseconds", 0 );
    makedvarserverinfo( "ui_danger_team", "" );
    makedvarserverinfo( "ui_inhostmigration", 0 );
    makedvarserverinfo( "ui_override_halftime", 0 );
    makedvarserverinfo( "camera_thirdPerson", getdvarint( "scr_thirdPerson" ) );
}

SetupCallbacks()
{
    level.onXPEvent = ::onXPEvent;
    level.getSpawnPoint = ::blank;
    level.onSpawnPlayer = ::blank;
    level.onRespawnDelay = ::blank;
    level.onTimeLimit = maps\mp\gametypes\_gamelogic::default_onTimeLimit;
    level.onHalfTime = maps\mp\gametypes\_gamelogic::default_onHalfTime;
    level.onDeadEvent = maps\mp\gametypes\_gamelogic::default_onDeadEvent;
    level.onOneLeftEvent = maps\mp\gametypes\_gamelogic::default_onOneLeftEvent;
    level.onPrecacheGameType = ::blank;
    level.onStartGameType = ::blank;
    level.onPlayerKilled = ::blank;
    level.autoassign = maps\mp\gametypes\_menus::menuAutoAssign;
    level.spectator = maps\mp\gametypes\_menus::menuSpectator;
    level.class = maps\mp\gametypes\_menus::menuClass;
    level.allies = maps\mp\gametypes\_menus::menuAllies;
    level.axis = maps\mp\gametypes\_menus::menuAxis;
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{

}

testMenu()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 10.0;
        notifyData = spawnstruct();
        notifyData.titleText = &"MP_CHALLENGE_COMPLETED";
        notifyData.notifyText = "wheee";
        notifyData.sound = "mp_challenge_complete";
        thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
    }
}

testShock()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 3.0;
        numShots = randomint( 6 );

        for ( i = 0; i < numShots; i++ )
        {
            iprintlnbold( numShots );
            self shellshock( "frag_grenade_mp", 0.2 );
            wait 0.1;
        }
    }
}

onXPEvent( event )
{
    thread maps\mp\gametypes\_rank::giveRankXP( event );
}

fakeLag()
{
    self endon( "disconnect" );
    self.fakeLag = randomintrange( 50, 150 );

    for (;;)
    {
        self setclientdvar( "fakelag_target", self.fakeLag );
        wait(randomfloatrange( 5.0, 15.0 ));
    }
}

debugline( start, end )
{
    for ( i = 0; i < 50; i++ )
        //line( start, end );
        wait 0.05;
}
