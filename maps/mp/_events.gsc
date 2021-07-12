// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
init()
{
    maps\mp\gametypes\_rank::registerScoreInfo("headshot", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("kill", 5);
    maps\mp\gametypes\_rank::registerScoreInfo("execution", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("avenger", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("defender", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("posthumous", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("revenge", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("double", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("triple", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("multi", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("buzzkill", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("firstblood", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("comeback", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("longshot", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("assistedsuicide", 0);
    maps\mp\gametypes\_rank::registerScoreInfo("knifethrow", 0);
    
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "damage", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "heavy_damage", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "damaged", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "kill", 5 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "killed", 0 );
	
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "healed", 0);
	
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "headshot", 5 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "melee", 5 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "backstab", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "longshot", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "assistedsuicide", 0);
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "defender", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "avenger", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "execution", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "comeback", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "revenge", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "buzzkill", 0 );	
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "double", 0 );	
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "triple", 0 );	
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "multi", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "assist", 3 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "firstBlood", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "capture", 0);
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "assistedCapture", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "plant", 0);
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "defuse", 0);
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "vehicleDestroyed", 0 );

	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "3streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "4streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "5streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "6streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "7streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "8streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "9streak", 0 );
	maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "10streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo("regen", 0);
    precacheShader("crosshair_red");
    level.numKills = 0;
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player );
        player.killedPlayers = [];
        player.killedPlayersCurrent = [];
        player.killedBy = [];
        player.lastKilledBy = undefined;
        player.greatestUniquePlayerKills = 0;
        player.recentKillCount = 0;
        player.lastKillTime = 0;
        player.damagedPlayers = [];
        player thread monitorCrateJacking();
        player thread monitorObjectives();
        player thread monitorHealed();
    }
}

damagedPlayer(victim, damage, weapon) {}

killedPlayer( killId, victim, weapon, meansOfDeath )
{
    victimGuid = victim.guid;
    myGuid = self.guid;
    curTime = gettime();
    thread updateRecentKills( killId );
    self.lastKillTime = gettime();
    self.lastKilledPlayer = victim;
    self.modifiers = [];
    level.numKills++;
    self.damagedPlayers[victimGuid] = undefined;

    if ( !maps\mp\_utility::isKillstreakWeapon( weapon ) && !maps\mp\_utility::_hasPerk( "specialty_explosivebullets" ) )
    {
        if ( weapon == "none" )
            return 0;

        if ( isdefined( self.pers["copyCatLoadout"] ) && isdefined( self.pers["copyCatLoadout"]["owner"] ) )
        {
            if ( victim == self.pers["copyCatLoadout"]["owner"] )
                self.modifiers["clonekill"] = 1;
        }

        if ( victim.attackers.size == 1 && !isdefined( victim.attackers[victim.guid] ) )
        {
            weaponClass = maps\mp\_utility::getWeaponClass( weapon );

            if ( weaponClass == "weapon_sniper" && meansOfDeath != "MOD_MELEE" && gettime() == victim.attackerData[self.guid].firstTimeDamaged )
            {
                self.modifiers["oneshotkill"] = 1;
                thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_ONE_SHOT_KILL" );
            }
        }

        if ( isdefined( victim.throwingGrenade ) && victim.throwingGrenade == "frag_grenade_mp" )
            self.modifiers["cooking"] = 1;

        if ( isdefined( self.assistedSuicide ) && self.assistedSuicide )
            assistedSuicide( killId, weapon, meansOfDeath );

        if ( level.numKills == 1 )
            firstBlood( killId, weapon, meansOfDeath );

        if ( self.pers["cur_death_streak"] > 3 )
            comeBack( killId, weapon, meansOfDeath );

        if ( meansOfDeath == "MOD_HEAD_SHOT" )
        {
            if ( isdefined( victim.laststand ) )
                execution( killId, weapon, meansOfDeath );
            else
                headShot( killId, weapon, meansOfDeath );
        }

        if ( isdefined( self.wasTI ) && self.wasTI && gettime() - self.spawnTime <= 5000 )
            self.modifiers["jackintheboxkill"] = 1;

        if ( !isalive( self ) && self.deathtime + 800 < gettime() )
            postDeathKill( killId );

        fakeAvenge = 0;

        if ( level.teamBased && curTime - victim.lastKillTime < 500 )
        {
            if ( victim.lastKilledPlayer != self )
                avengedPlayer( killId, weapon, meansOfDeath );
        }

        foreach ( guid, damageTime in victim.damagedPlayers )
        {
            if ( guid == self.guid )
                continue;

            if ( level.teamBased && curTime - damageTime < 500 )
                defendedPlayer( killId, weapon, meansOfDeath );
        }

        if ( isdefined( victim.attackerPosition ) )
            attackerPosition = victim.attackerPosition;
        else
            attackerPosition = self.origin;

		if( isLongShot( self, weapon, meansOfDeath, attackerPosition, victim ) )
		    thread longshot( killId, weapon, meansOfDeath );

        if ( victim.pers["cur_kill_streak"] > 0 && isdefined( victim.killstreaks[victim.pers["cur_kill_streak"] + 1] ) )
            buzzKill( killId, victim, weapon, meansOfDeath );

        thread checkMatchDataKills( killId, victim, weapon, meansOfDeath );
    }

    if ( !isdefined( self.killedPlayers[victimGuid] ) )
        self.killedPlayers[victimGuid] = 0;

    if ( !isdefined( self.killedPlayersCurrent[victimGuid] ) )
        self.killedPlayersCurrent[victimGuid] = 0;

    if ( !isdefined( victim.killedBy[myGuid] ) )
        victim.killedBy[myGuid] = 0;

    self.killedPlayers[victimGuid]++;

    if ( self.killedPlayers[victimGuid] > self.greatestUniquePlayerKills )
        maps\mp\_utility::setPlayerStat( "killedsameplayer", self.killedPlayers[victimGuid] );

    self.killedPlayersCurrent[victimGuid]++;
    victim.killedBy[myGuid]++;
    victim.lastKilledBy = self;
}

isLongShot( attacker, weapon, meansOfDeath, attackerPosition, victim )
{
    if ( isalive( attacker ) && !attacker maps\mp\_utility::isUsingRemote() && ( meansOfDeath == "MOD_RIFLE_BULLET" || meansOfDeath == "MOD_PISTOL_BULLET" || meansOfDeath == "MOD_HEAD_SHOT" ) && !maps\mp\_utility::isKillstreakWeapon( weapon ) && !isdefined( attacker.assistedSuicide ) )
    {
        weaponClass = maps\mp\_utility::getWeaponClass( weapon );

        switch ( WeaponClass )
        {
            case "weapon_pistol":
                weapDist = 800;
                break;
            case "weapon_smg":
            case "weapon_machine_pistol":
                weapDist = 1200;
                break;
            case "weapon_assault":
            case "weapon_lmg":
                weapDist = 1500;
                break;
            case "weapon_sniper":
                weapDist = 2000;
                break;
            case "weapon_shotgun":
                weapDist = 500;
                break;
            case "weapon_projectile":
            default:
                weapDist = 1536;
                break;
        }

        if ( distance( attackerPosition, victim.origin ) > weapDist )
        {
            if ( attacker isitemunlocked( "specialty_holdbreath" ) && attacker maps\mp\_utility::_hasPerk( "specialty_holdbreath" ) )
                attacker maps\mp\gametypes\_missions::processChallenge( "ch_longdistance" );

            return 1;
        }
    }

    return 0;
}

checkMatchDataKills( killId, victim, weapon, meansOfDeath )
{
    weaponClass = maps\mp\_utility::getWeaponClass( weapon );
    alreadyUsed = 0;
    thread camperCheck();

    if ( isdefined( self.lastKilledBy ) && self.lastKilledBy == victim )
    {
        self.lastKilledBy = undefined;
        revenge( killId );
        playfx( level._effect["money"], victim gettagorigin( "j_spine4" ) );
    }

    if ( victim.iDFlags & level.iDFLAGS_PENETRATION )
        maps\mp\_utility::incPlayerStat( "bulletpenkills", 1 );

    if ( self.pers["rank"] < victim.pers["rank"] )
        maps\mp\_utility::incPlayerStat( "higherrankkills", 1 );

    if ( self.pers["rank"] > victim.pers["rank"] )
        maps\mp\_utility::incPlayerStat( "lowerrankkills", 1 );

    if ( isdefined( self.inFinalStand ) && self.inFinalStand )
        maps\mp\_utility::incPlayerStat( "laststandkills", 1 );

    if ( isdefined( victim.inFinalStand ) && victim.inFinalStand )
        maps\mp\_utility::incPlayerStat( "laststanderkills", 1 );

    if ( self getcurrentweapon() != self.primaryWeapon && self getcurrentweapon() != self.secondaryWeapon )
        maps\mp\_utility::incPlayerStat( "otherweaponkills", 1 );

    timeAlive = gettime() - victim.spawnTime;

    if ( !maps\mp\_utility::matchMakingGame() )
        victim maps\mp\_utility::setPlayerStatIfLower( "shortestlife", timeAlive );

    victim maps\mp\_utility::setPlayerStatIfGreater( "longestlife", timeAlive );

    if ( meansOfDeath != "MOD_MELEE" )
    {
        switch ( weaponClass )
        {
            case "weapon_smg":
            case "weapon_assault":
            case "weapon_sniper":
            case "weapon_lmg":
            case "weapon_shotgun":
            case "weapon_projectile":
            case "weapon_pistol":
                checkMatchDataWeaponKills( victim, weapon, meansOfDeath, weaponClass );
                break;
            case "weapon_grenade":
            case "weapon_explosive":
                checkMatchDataEquipmentKills( victim, weapon, meansOfDeath );
                break;
            default:
                break;
        }
    }
}

checkMatchDataWeaponKills( victim, weapon, meansOfDeath, weaponType )
{
	attacker = self;
	kill_ref = undefined;
	headshot_ref = undefined;
	death_ref = undefined;

	switch( weaponType )
	{
		case "weapon_pistol":
			kill_ref = "pistolkills";
			headshot_ref = "pistolheadshots";
			break;	
		case "weapon_smg":
			kill_ref = "smgkills";
			headshot_ref = "smgheadshots";
			break;
		case "weapon_assault":
			kill_ref = "arkills";
			headshot_ref = "arheadshots";
			break;
		case "weapon_projectile":
			if ( weaponClass( weapon ) == "rocketlauncher" )
				kill_ref = "rocketkills";
			break;
		case "weapon_sniper":
			kill_ref = "sniperkills";
			headshot_ref = "sniperheadshots";
			break;
		case "weapon_shotgun":
			kill_ref = "shotgunkills";
			headshot_ref = "shotgunheadshots";
			death_ref = "shotgundeaths";
			break;
		case "weapon_lmg":
			kill_ref = "lmgkills";
			headshot_ref = "lmgheadshots";
			break;
		default:
			break;
	}

    if ( isdefined( kill_ref ) )
        attacker maps\mp\_utility::incPlayerStat( kill_ref, 1 );

    if ( isdefined( headshot_ref ) && meansOfDeath == "MOD_HEAD_SHOT" )
        attacker maps\mp\_utility::incPlayerStat( headshot_ref, 1 );

    if ( isdefined( death_ref ) && !maps\mp\_utility::matchMakingGame() )
        victim maps\mp\_utility::incPlayerStat( death_ref, 1 );

    if ( attacker playerads() > 0.5 )
    {
        attacker maps\mp\_utility::incPlayerStat( "adskills", 1 );

        if ( weaponType == "weapon_sniper" || issubstr( weapon, "acog" ) )
            attacker maps\mp\_utility::incPlayerStat( "scopedkills", 1 );

        if ( issubstr( weapon, "thermal" ) )
            attacker maps\mp\_utility::incPlayerStat( "thermalkills", 1 );
    }
    else
        attacker maps\mp\_utility::incPlayerStat( "hipfirekills", 1 );
}

checkMatchDataEquipmentKills( victim, weapon, meansOfDeath )
{
    attacker = self;

    switch ( weapon )
    {
        case "frag_grenade_mp":
            attacker maps\mp\_utility::incPlayerStat( "fragkills", 1 );
            attacker maps\mp\_utility::incPlayerStat( "grenadekills", 1 );
            isEquipment = 1;
            break;
        case "c4_mp":
            attacker maps\mp\_utility::incPlayerStat( "c4kills", 1 );
            isEquipment = 1;
            break;
        case "semtex_mp":
            attacker maps\mp\_utility::incPlayerStat( "semtexkills", 1 );
            attacker maps\mp\_utility::incPlayerStat( "grenadekills", 1 );
            isEquipment = 1;
            break;
        case "claymore_mp":
            attacker maps\mp\_utility::incPlayerStat( "claymorekills", 1 );
            isEquipment = 1;
            break;
        case "throwingknife_mp":
            attacker maps\mp\_utility::incPlayerStat( "throwingknifekills", 1 );
            thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_KNIFETHROW" );
            isEquipment = 1;
            break;
        default:
            isEquipment = 0;
            break;
    }

    if ( isEquipment )
        attacker maps\mp\_utility::incPlayerStat( "equipmentkills", 1 );
}

camperCheck()
{
    self.lastKillWasCamping = 0;

    if ( !isdefined( self.lastKillLocation ) )
    {
        self.lastKillLocation = self.origin;
        self.lastCampKillTime = gettime();
        return;
    }

    if ( distance( self.lastKillLocation, self.origin ) < 512 && gettime() - self.lastCampKillTime > 5000 )
    {
        maps\mp\_utility::incPlayerStat( "mostcamperkills", 1 );
        self.lastKillWasCamping = 1;
    }

    self.lastKillLocation = self.origin;
    self.lastCampKillTime = gettime();
}

consolation( killId )
{

}

proximityAssist( killId )
{
    self.modifiers["proximityAssist"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_PROXIMITYASSIST" );
    thread maps\mp\gametypes\_rank::giveRankXP( "proximityassist" );
}

proximityKill( killId )
{
    self.modifiers["proximityKill"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_PROXIMITYKILL" );
    thread maps\mp\gametypes\_rank::giveRankXP( "proximitykill" );
}

longshot( killId, weapon, meansOfDeath )
{
    self.modifiers["longshot"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_LONGSHOT" );
    thread maps\mp\gametypes\_rank::giveRankXP( "longshot", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "longshot" );
    maps\mp\_utility::incPlayerStat( "longshots", 1 );
    thread maps\mp\_matchdata::logKillEvent( killId, "longshot" );
}

execution( killId, weapon, meansOfDeath )
{
    self.modifiers["execution"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_EXECUTION" );
    thread maps\mp\gametypes\_rank::giveRankXP( "execution", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "execution" );
    thread maps\mp\_matchdata::logKillEvent( killId, "execution" );
}

headShot( killId, weapon, meansOfDeath )
{
    self.modifiers["headshot"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_HEADSHOT" );
    thread maps\mp\gametypes\_rank::giveRankXP( "headshot", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "headshot" );
    thread maps\mp\_matchdata::logKillEvent( killId, "headshot" );
}

avengedPlayer( killId, weapon, meansOfDeath )
{
    self.modifiers["avenger"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_AVENGER" );
    thread maps\mp\gametypes\_rank::giveRankXP( "avenger", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "avenger" );
    thread maps\mp\_matchdata::logKillEvent( killId, "avenger" );
    maps\mp\_utility::incPlayerStat( "avengekills", 1 );
}

assistedSuicide( killId, weapon, meansOfDeath )
{
    self.modifiers["assistedsuicide"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_ASSISTEDSUICIDE" );
    thread maps\mp\gametypes\_rank::giveRankXP( "assistedsuicide", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "assistedsuicide" );
    thread maps\mp\_matchdata::logKillEvent( killId, "assistedsuicide" );
}

defendedPlayer( killId, weapon, meansOfDeath )
{
    self.modifiers["defender"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DEFENDER" );
    thread maps\mp\gametypes\_rank::giveRankXP( "defender", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "defender" );
    thread maps\mp\_matchdata::logKillEvent( killId, "defender" );
    maps\mp\_utility::incPlayerStat( "rescues", 1 );
}

postDeathKill( killId )
{
    self.modifiers["posthumous"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_POSTHUMOUS" );
    thread maps\mp\gametypes\_rank::giveRankXP( "posthumous" );
    thread maps\mp\_matchdata::logKillEvent( killId, "posthumous" );
}

backStab( killId )
{
    self iprintlnbold( "backstab" );
}

revenge( killId )
{
    self.modifiers["revenge"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_REVENGE" );
    thread maps\mp\gametypes\_rank::giveRankXP( "revenge" );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "revenge" );
    thread maps\mp\_matchdata::logKillEvent( killId, "revenge" );
    //maps\mp\_utility::incPlayerStat( "revengekills", 1 );
}

multiKill( killId, killCount )
{
    if ( killCount == 2 )
    {
        //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DOUBLEKILL" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "double" );
    }
    else if ( killCount == 3 )
    {
        //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_TRIPLEKILL" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "triple" );
        //thread maps\mp\_utility::teamPlayerCardSplash( "callout_3xkill", self );
    }
    else
    {
        //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_MULTIKILL" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "multi" );
        //thread maps\mp\_utility::teamPlayerCardSplash( "callout_3xpluskill", self );
    }

    thread maps\mp\_matchdata::logMultiKill( killId, killCount );
    maps\mp\_utility::setPlayerStatIfGreater( "multikill", killCount );
    maps\mp\_utility::incPlayerStat( "mostmultikills", 1 );
}

firstBlood( killId, weapon, meansOfDeath )
{
    self.modifiers["firstblood"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_FIRSTBLOOD" );
    thread maps\mp\gametypes\_rank::giveRankXP( "firstblood", undefined, weapon, meansOfDeath );
    thread maps\mp\_matchdata::logKillEvent( killId, "firstblood" );
    
    //maps\mp\killstreaks\_killstreaks::giveAdrenaline( "firstBlood" );
    //thread maps\mp\_utility::teamPlayerCardSplash( "callout_firstblood", self );
}

winningShot( killId )
{

}

buzzKill( killId, victim, weapon, meansOfDeath )
{
    self.modifiers["buzzkill"] = victim.pers["cur_kill_streak"];
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_BUZZKILL" );
    thread maps\mp\gametypes\_rank::giveRankXP( "buzzkill", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "buzzkill" );
    thread maps\mp\_matchdata::logKillEvent( killId, "buzzkill" );
}

comeBack( killId, weapon, meansOfDeath )
{
    self.modifiers["comeback"] = 1;
    //thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_COMEBACK" );
    thread maps\mp\gametypes\_rank::giveRankXP( "comeback", undefined, weapon, meansOfDeath );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "comeback" );
    thread maps\mp\_matchdata::logKillEvent( killId, "comeback" );
    //maps\mp\_utility::incPlayerStat( "comebacks", 1 );
}

disconnected()
{
    myGuid = self.guid;

    for ( entry = 0; entry < level.players.size; entry++ )
    {
        if ( isdefined( level.players[entry].killedPlayers[myGuid] ) )
            level.players[entry].killedPlayers[myGuid] = undefined;

        if ( isdefined( level.players[entry].killedPlayersCurrent[myGuid] ) )
            level.players[entry].killedPlayersCurrent[myGuid] = undefined;

        if ( isdefined( level.players[entry].killedBy[myGuid] ) )
            level.players[entry].killedBy[myGuid] = undefined;
    }
}

monitorHealed()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "healed" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "healed" );
    }
}

updateRecentKills( killId )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self notify( "updateRecentKills" );
    self endon( "updateRecentKills" );
    self.recentKillCount++;
    wait 1.0;

    if ( self.recentKillCount > 1 )
        multiKill( killId, self.recentKillCount );

    self.recentKillCount = 0;
}

monitorCrateJacking()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "hijacker", crateType, owner );
        thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_HIJACKER" );
        thread maps\mp\gametypes\_rank::giveRankXP( "hijacker", 100 );
        splashName = "hijacked_airdrop";
        challengeName = "ch_hijacker";

        switch ( crateType )
        {
            case "sentry":
                splashName = "hijacked_sentry";
                break;
            case "remote_tank":
                splashName = "hijacked_remote_tank";
                break;
            case "mega":
            case "emergency_airdrop":
                splashName = "hijacked_emergency_airdrop";
                challengeName = "ch_newjack";
                break;
            default:
                break;
        }

        if ( isdefined( owner ) )
            owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( splashName, self );

        self notify( "process", challengeName );
    }
}

monitorObjectives()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "objective",  objType );

        if ( objType == "captured" )
        {
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "capture" );

            if ( isdefined( self.laststand ) && self.laststand )
            {
                thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "heroic", 100 );
                thread maps\mp\gametypes\_rank::giveRankXP( "reviver", 100 );
            }
        }

        if ( objType == "assistedCapture" )
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "assistedCapture" );

        if ( objType == "plant" )
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "plant" );

        if ( objType == "defuse" )
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "defuse" );
    }
}
