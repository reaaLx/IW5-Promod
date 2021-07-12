// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

TimeUntilWaveSpawn( minimumWait )
{
    if ( !self.hasSpawned )
        return 0;

    earliestSpawnTime = gettime() + minimumWait * 1000;
    lastWaveTime = level.lastWave[self.pers["team"]];
    waveDelay = level.waveDelay[self.pers["team"]] * 1000;
    numWavesPassedEarliestSpawnTime = (earliestSpawnTime - lastWaveTime) / waveDelay;
    numWaves = ceil( numWavesPassedEarliestSpawnTime );
    timeOfSpawn = lastWaveTime + numWaves * waveDelay;

    if ( isdefined( self.respawnTimerStartTime ) )
    {
        timeAlreadyPassed = ( gettime() - self.respawnTimerStartTime ) / 1000.0;

        if ( self.respawnTimerStartTime < lastWaveTime )
            return 0;
    }

    if ( isdefined( self.waveSpawnIndex ) )
        timeOfSpawn += 50 * self.waveSpawnIndex;

    return ( timeOfSpawn - gettime() ) / 1000;
}

TeamKillDelay()
{
    teamKills = self.pers["teamkills"];

    if ( level.maxAllowedTeamKills < 0 || teamKills <= level.maxAllowedTeamKills )
        return 0;

    exceeded = teamKills - level.maxAllowedTeamKills;
    return maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillspawndelay" ) * exceeded;
}

TimeUntilSpawn( includeTeamkillDelay )
{
    if ( level.inGracePeriod && !self.hasSpawned || level.gameEnded )
        return 0;

    if (isDefined(level.rdyup) && level.rdyup)
        return 0;

    if (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "strat")
        return 0;

    respawnDelay = 0;

    if ( self.hasSpawned )
    {
        result = self [[ level.onRespawnDelay ]]();

        if ( isdefined( result ) )
            respawnDelay = result;
        else
            respawnDelay = getdvarint( "scr_" + level.gameType + "_playerrespawndelay" );

        if ( includeTeamkillDelay && isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
            respawnDelay += TeamKillDelay();

        if ( isdefined( self.respawnTimerStartTime ) )
        {
            timeAlreadyPassed = ( gettime() - self.respawnTimerStartTime ) / 1000.0;
            respawnDelay -= timeAlreadyPassed;

            if ( respawnDelay < 0 )
                respawnDelay = 0;
        }

        if ( isdefined( self.setSpawnpoint ) )
            respawnDelay += level.tiSpawnDelay;
    }

    waveBased = getdvarint( "scr_" + level.gameType + "_waverespawndelay" ) > 0;

    if ( waveBased )
        return TimeUntilWaveSpawn( respawnDelay );

    return respawnDelay;
}

maySpawn()
{

    if (isDefined(level.rdyup) && level.rdyup)
        return true;

    if (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "strat")
        return true;

    if ( maps\mp\_utility::getGametypeNumLives() || isdefined( level.disableSpawning ) )
    {
        if ( isdefined( level.disableSpawning ) && level.disableSpawning )
            return 0;

        if ( isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
            return 0;

        if ( !self.pers["lives"] && maps\mp\_utility::gameHasStarted() )
            return 0;
        else if ( maps\mp\_utility::gameHasStarted() )
        {
            if ( !level.inGracePeriod && !self.hasSpawned )
                return 0;
        }
    }

    return 1;
}

spawnClient()
{
    if ( isdefined( self.addToTeam ) )
    {
        maps\mp\gametypes\_menus::addToTeam( self.addToTeam );
        self.addToTeam = undefined;
    }

    if ( !maySpawn() )
    {
        currentorigin = self.origin;
        currentangles = self.angles;
        self notify( "attempted_spawn" );

        if ( isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
        {
            self.pers["teamkills"] = max( self.pers["teamkills"] - 1, 0 );
            maps\mp\_utility::setLowerMessage( "friendly_fire", &"MP_FRIENDLY_FIRE_WILL_NOT" );

            if ( !self.hasSpawned && self.pers["teamkills"] <= level.maxAllowedTeamKills )
                self.pers["teamKillPunish"] = 0;
        }
        else if ( maps\mp\_utility::isRoundBased() && !maps\mp\_utility::isLastRound() )
        {
            maps\mp\_utility::setLowerMessage( "spawn_info", game["strings"]["spawn_next_round"] );
            thread removeSpawnMessageShortly( 3.0 );
        }

        if ( self.sessionstate != "spectator" )
            currentorigin += ( 0, 0, 60 );

        thread spawnSpectator( currentorigin, currentangles );
        return;
    }

    if ( self.waitingToSpawn )
        return;

    self.waitingToSpawn = 1;
    waitAndSpawnClient();

    if ( isdefined( self ) )
        self.waitingToSpawn = 0;
}

waitAndSpawnClient()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );
    level endon( "game_ended" );
    self notify( "attempted_spawn" );
    spawnedAsSpectator = 0;

    if ( isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
    {
        teamKillDelay = TeamKillDelay();

        if ( teamKillDelay > 0 )
        {
            maps\mp\_utility::setLowerMessage( "friendly_fire", &"MP_FRIENDLY_FIRE_WILL_NOT", teamKillDelay, 1, 1 );
            thread respawn_asSpectator( self.origin + ( 0, 0, 60 ), self.angles );
            spawnedAsSpectator = 1;
            wait(teamKillDelay);
            maps\mp\_utility::clearLowerMessage( "friendly_fire" );
            self.respawnTimerStartTime = gettime();
        }

        self.pers["teamKillPunish"] = 0;
    }
    else if ( TeamKillDelay() )
        self.pers["teamkills"] = max( self.pers["teamkills"] - 1, 0 );

    if ( maps\mp\_utility::isUsingRemote() )
    {
        self.spawningAfterRemoteDeath = 1;
        self waittill( "stopped_using_remote" );
    }

    if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
    {
        self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
        level.wavePlayerSpawnIndex[self.team]++;
    }

    timeUntilSpawn = TimeUntilSpawn( 0 );
    thread predictAboutToSpawnPlayerOverTime( timeUntilSpawn );

    if ( timeUntilSpawn > 0 )
    {
        maps\mp\_utility::setLowerMessage( "spawn_info", game["strings"]["waiting_to_spawn"], timeUntilSpawn, 1, 1 );

        if ( !spawnedAsSpectator )
            thread respawn_asSpectator( self.origin + ( 0, 0, 60 ), self.angles );

        spawnedAsSpectator = 1;
        maps\mp\_utility::waitForTimeOrNotify( timeUntilSpawn, "force_spawn" );
        self notify( "stop_wait_safe_spawn_button" );
    }

    waveBased = getdvarint( "scr_" + level.gameType + "_waverespawndelay" ) > 0;

    if ( maps\mp\gametypes\_tweakables::getTweakableValue( "player", "forcerespawn" ) == 0 && self.hasSpawned && !waveBased && !self.wantSafeSpawn )
    {
        maps\mp\_utility::setLowerMessage( "spawn_info", game["strings"]["press_to_spawn"], undefined, undefined, undefined, undefined, undefined, undefined, 1 );

        if ( !spawnedAsSpectator )
            thread respawn_asSpectator( self.origin + ( 0, 0, 60 ), self.angles );

        spawnedAsSpectator = 1;
        waitRespawnButton();
    }

    self.waitingToSpawn = 0;
    maps\mp\_utility::clearLowerMessage( "spawn_info" );
    self.waveSpawnIndex = undefined;
    thread spawnPlayer();
}

waitRespawnButton()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );

    for (;;)
    {
        if ( self usebuttonpressed() )
            break;

        wait 0.05;
    }
}

removeSpawnMessageShortly( delay )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    waittillframeend;
    self endon( "end_respawn" );
    wait(delay);
    maps\mp\_utility::clearLowerMessage( "spawn_info" );
}

lastStandRespawnPlayer()
{
    self laststandrevive();

    if ( maps\mp\_utility::_hasPerk( "specialty_finalstand" ) && !level.dieHardMode )
        maps\mp\_utility::_unsetPerk( "specialty_finalstand" );

    if ( level.dieHardMode )
        self.headicon = "";

    self setstance( "crouch" );
    self.revived = 1;
    self notify( "revive" );

    if ( isdefined( self.standardmaxHealth ) )
        self.maxHealth = self.standardmaxHealth;

    self.health = self.maxHealth;
    common_scripts\utility::_enableUsability();

    if ( game["state"] == "postgame" )
        maps\mp\gametypes\_gamelogic::freezePlayerForRoundEnd();
}

getDeathSpawnPoint()
{
    spawnpoint = spawn( "script_origin", self.origin );
    spawnpoint hide();
    spawnpoint.angles = self.angles;
    return spawnpoint;
}

showSpawnNotifies()
{
    if ( isdefined( game["defcon"] ) )
        thread maps\mp\gametypes\_hud_message::defconSplashNotify( game["defcon"], 0 );

    if ( maps\mp\_utility::isRested() )
        thread maps\mp\gametypes\_hud_message::splashNotify( "rested" );
}

predictAboutToSpawnPlayerOverTime( preduration )
{
    self endon( "disconnect" );
    self endon( "spawned" );
    self endon( "used_predicted_spawnpoint" );
    self notify( "predicting_about_to_spawn_player" );
    self endon( "predicting_about_to_spawn_player" );

    if ( preduration <= 0 )
        return;

    if ( preduration > 1.0 )
        wait(preduration - 1.0);

    predictAboutToSpawnPlayer();
    self predictstreampos( self.predictedSpawnPoint.origin + ( 0, 0, 60 ), self.predictedSpawnPoint.angles );
    self.predictedSpawnPointTime = gettime();

    for ( i = 0; i < 30; i++ )
    {
        wait 0.4;
        prevPredictedSpawnPoint = self.predictedSpawnPoint;
        predictAboutToSpawnPlayer();

        if ( self.predictedSpawnPoint != prevPredictedSpawnPoint )
        {
            self predictstreampos( self.predictedSpawnPoint.origin + ( 0, 0, 60 ), self.predictedSpawnPoint.angles );
            self.predictedSpawnPointTime = gettime();
        }
    }
}

predictAboutToSpawnPlayer()
{
    if ( TimeUntilSpawn( 1 ) > 1.0 )
    {
        spawnpointname = "mp_global_intermission";
        spawnpoints = getentarray( spawnpointname, "classname" );
        self.predictedSpawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnpoints );
        return;
    }

    if ( isdefined( self.setSpawnpoint ) )
    {
        self.predictedSpawnPoint = self.setSpawnpoint;
        return;
    }

    spawnPoint = self [[ level.getSpawnPoint ]]();
    self.predictedSpawnPoint = spawnPoint;
}

checkPredictedSpawnpointCorrectness( spawnpointorigin )
{
    self notify( "used_predicted_spawnpoint" );
    self.predictedSpawnPoint = undefined;
}

percentage( a, b )
{
    return a + " (" + int( a / b * 100 ) + "%)";
}

printPredictedSpawnpointCorrectness()
{

}

getSpawnOrigin( spawnpoint )
{
    if ( !positionwouldtelefrag( spawnpoint.origin ) )
        return spawnpoint.origin;

    if ( !isdefined( spawnpoint.alternates ) )
        return spawnpoint.origin;

    foreach ( alternate in spawnpoint.alternates )
    {
        if ( !positionwouldtelefrag( alternate ) )
            return alternate;
    }

    return spawnpoint.origin;
}

tiValidationCheck()
{
    if ( !isdefined( self.setSpawnpoint ) )
        return 0;

    carePackages = getentarray( "care_package", "targetname" );

    foreach ( package in carePackages )
    {
        if ( distance( package.origin, self.setSpawnpoint.playerSpawnPos ) > 64 )
            continue;

        if ( isdefined( package.owner ) )
            maps\mp\gametypes\_hud_message::playerCardSplashNotify( "destroyed_insertion", package.owner );

        maps\mp\perks\_perkfunctions::deleteTI( self.setSpawnpoint );
        return 0;
    }

    return 1;
}

spawnPlayer()
{
    self endon( "disconnect" );
    self endon( "joined_spectators" );
    self notify( "spawned" );
    self notify( "end_respawn" );

    if ( isdefined( self.setSpawnpoint ) && ( isdefined( self.setSpawnpoint.notti ) || tiValidationCheck() ) )
    {
        spawnPoint = self.setSpawnpoint;

        if ( !isdefined( self.setSpawnpoint.notti ) )
        {
            self playlocalsound( "tactical_spawn" );

            if ( level.teamBased )
                self playsoundtoteam( "tactical_spawn", level.otherTeam[self.team] );
            else
                self playsound( "tactical_spawn" );
        }

        foreach ( empKillStreak in level.ugvs )
        {
            if ( distancesquared( empKillStreak.origin, spawnPoint.playerSpawnPos ) < 1024 )
                empKillStreak notify( "damage",  5000, empKillStreak.owner, ( 0, 0, 0 ), ( 0, 0, 0 ), "MOD_EXPLOSIVE", "", "", "", undefined, "killstreak_emp_mp" );
        }

        spawnOrigin = self.setSpawnpoint.playerSpawnPos;
        spawnAngles = self.setSpawnpoint.angles;

        if ( isdefined( self.setSpawnpoint.enemyTrigger ) )
            self.setSpawnpoint.enemyTrigger delete();

        self.setSpawnpoint delete();
        spawnPoint = undefined;
    }
    else
    {
        spawnPoint = self [[ level.getSpawnPoint ]]();
        spawnOrigin = spawnPoint.origin;
        spawnAngles = spawnpoint.angles;
    }

    setSpawnVariables();
    hadSpawned = self.hasSpawned;
    self.fauxDead = undefined;

    //if ( !killcamState )
    //{
        self.killsThisLife = [];
        updateSessionState( "playing", "" );
        maps\mp\_utility::ClearKillcamState();
        self.cancelKillcam = 1;
        self openmenu( "killedby_card_hide" );
        self.maxHealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );
        self.health = self.maxHealth;
        self.friendlydamage = undefined;
        self.hasSpawned = 1;
        self.spawnTime = gettime();
        self.wasTI = !isdefined( spawnPoint );
        self.afk = 0;
        self.damagedPlayers = [];
        self.killStreakScaler = 1;
        self.xpScaler = 1;
        self.objectiveScaler = 1;
        self.clampedHealth = undefined;
        self.shieldDamage = 0;
        self.shieldBulletHits = 0;
        self.recentShieldXP = 0;
    //}

    self.moveSpeedScaler = 1;
    self.inLastStand = 0;
    self.laststand = undefined;
    self.inFinalStand = undefined;
    self.inC4Death = undefined;
    self.disabledWeapon = 0;
    self.disabledWeaponSwitch = 0;
    self.disabledOffhandWeapons = 0;
    common_scripts\utility::resetUsability();

    /*if ( !avoidKillstreak )
    {
        self.avoidKillstreakOnSpawnTimer = 5.0;

        if ( self.pers["lives"] == maps\mp\_utility::getGametypeNumLives() )
            addToLivesCount();

        if ( self.pers["lives"] )
            self.pers["lives"]--;

        addToAliveCount();

        if ( !hadSpawned || maps\mp\_utility::gameHasStarted() || maps\mp\_utility::gameHasStarted() && level.inGracePeriod && self.hasDoneCombat )
            removeFromLivesCount();

        if ( !self.wasAliveAtMatchStart )
        {
            acceptablePassedTime = 20;

            if ( maps\mp\_utility::getTimeLimit() > 0 && acceptablePassedTime < maps\mp\_utility::getTimeLimit() * 60 / 4 )
                acceptablePassedTime = maps\mp\_utility::getTimeLimit() * 60 / 4;

            if ( level.inGracePeriod || maps\mp\_utility::getTimePassed() < acceptablePassedTime * 1000 )
                self.wasAliveAtMatchStart = 1;
        }
    }*/

	self.avoidKillstreakOnSpawnTimer = 5.0;

	if ( self.pers["lives"] == getGametypeNumLives() )
	{
		maps\mp\gametypes\_playerlogic::addToLivesCount();
	}
	
	if ( self.pers["lives"] )
		self.pers["lives"]--;

	self maps\mp\gametypes\_playerlogic::addToAliveCount();

	if ( !hadSpawned || gameHasStarted() || (gameHasStarted() && level.inGracePeriod && self.hasDoneCombat) )
		self maps\mp\gametypes\_playerlogic::removeFromLivesCount();

	if ( !self.wasAliveAtMatchStart )
	{
		acceptablePassedTime = 20;
		if ( getTimeLimit() > 0 && acceptablePassedTime < getTimeLimit() * 60 / 4 )
			acceptablePassedTime = getTimeLimit() * 60 / 4;
		
		if ( level.inGracePeriod || getTimePassed() < acceptablePassedTime * 1000 )
			self.wasAliveAtMatchStart = true;
	}
	

    self setclientdvar( "cg_thirdPerson", "0" );
    self setdepthoffield( 0, 0, 512, 512, 4, 0 );
    self setclientdvar( "cg_fov", "65" );

    if ( isdefined( spawnPoint ) )
    {
        maps\mp\gametypes\_spawnlogic::finalizeSpawnpointChoice( spawnpoint );
        spawnOrigin = getSpawnOrigin( spawnpoint );
        spawnAngles = spawnpoint.angles;
    }
    else
        self.lastspawntime = gettime();

    self.spawnPos = spawnOrigin;
    self spawn( spawnOrigin, spawnAngles );

    /*
    if ( var_0 && isdefined( self.faux_spawn_stance ) )
    {
        self setstance( self.faux_spawn_stance );
        self.faux_spawn_stance = undefined;
    }
    */
    [[ level.onSpawnPlayer ]]();

    if ( isdefined( spawnPoint ) )
        checkPredictedSpawnpointCorrectness( spawnPoint.origin );

    //if ( !var_0 )
        maps\mp\gametypes\_missions::playerSpawned();

    maps\mp\gametypes\_class::setClass( self.class );
    maps\mp\gametypes\_class::giveLoadout( self.team, self.class );

    if ( getdvarint( "camera_thirdPerson" ) )
        maps\mp\_utility::setThirdPersonDOF( 1 );

    if (!gameFlag("prematch_done") && ((game["PROMOD_MATCH_MODE"] != "strat" && game["PROMOD_MATCH_MODE"] != "match" && !level.allowReadyUp) || level.gametype != "sd"))
        self freezeControlsWrapper(true);
    else
        self freezeControlsWrapper(false);

    if ( !maps\mp\_utility::gameFlag( "prematch_done" ) )
        maps\mp\_utility::freezeControlsWrapper( 1 );
    else
        maps\mp\_utility::freezeControlsWrapper( 0 );

    if ( !maps\mp\_utility::gameFlag( "prematch_done" ) || !hadSpawned && game["state"] == "playing" )
    {
        self setclientdvar( "scr_objectiveText", maps\mp\_utility::getObjectiveHintText( self.pers["team"] ) );
        team = self.pers["team"];

        if ( game["status"] == "overtime" )
            thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"]["overtime"], game["strings"]["overtime_hint"], undefined, ( 1, 0, 0 ), "mp_last_stand" );
        else if ( maps\mp\_utility::getIntProperty( "useRelativeTeamColors", 0 ) )
            thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team] + "_blue", game["colors"]["blue"] );
        else
            thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team] );

        thread showSpawnNotifies();
    }

    if ( maps\mp\_utility::getIntProperty( "scr_showperksonspawn", 1 ) == 1 && game["state"] != "postgame" )
    {
        self openmenu( "perk_display" );
        thread hidePerksAfterTime( 4.0 );
        thread hidePerksOnDeath();
    }

    waittillframeend;
    self.spawningAfterRemoteDeath = undefined;
    self notify( "spawned_player" );
    level notify( "player_spawned",  self  );

    if ( game["state"] == "postgame" )
        maps\mp\gametypes\_gamelogic::freezePlayerForRoundEnd();
}

hidePerksAfterTime( delay )
{
    self endon( "disconnect" );
    self endon( "perks_hidden" );
    wait(delay);
    self openmenu( "perk_hide" );
    self notify( "perks_hidden" );
}

hidePerksOnDeath()
{
    self endon( "disconnect" );
    self endon( "perks_hidden" );
    self waittill( "death" );
    self openmenu( "perk_hide" );
    self notify( "perks_hidden" );
}

hidePerksOnKill()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "perks_hidden" );
    self waittill( "killed_player" );
    self openmenu( "perk_hide" );
    self notify( "perks_hidden" );
}

spawnSpectator( origin, angles )
{
    self notify( "spawned" );
    self notify( "end_respawn" );
    self notify( "joined_spectators" );
    in_spawnSpectator( origin, angles );
}

respawn_asSpectator( origin, angles )
{
    in_spawnSpectator( origin, angles );
}

in_spawnSpectator( origin, angles )
{
    setSpawnVariables();

    if ( isdefined( self.pers["team"] ) && self.pers["team"] == "spectator" && !level.gameEnded )
        maps\mp\_utility::clearLowerMessage( "spawn_info" );

    self.sessionstate = "spectator";
    maps\mp\_utility::ClearKillcamState();
    self.friendlydamage = undefined;

    if ( isdefined( self.pers["team"] ) && self.pers["team"] == "spectator" )
        self.statusicon = "";
    else
        self.statusicon = "hud_status_dead";

    maps\mp\gametypes\_spectating::setSpectatePermissions();
    onSpawnSpectator( origin, angles );

    if ( level.teamBased && !level.splitscreen && !self issplitscreenplayer() )
        self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

getPlayerFromClientNum( clientNum )
{
    if ( clientNum < 0 )
        return undefined;

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i] getentitynumber() == clientNum )
            return level.players[i];
    }

    return undefined;
}

onSpawnSpectator( origin, angles )
{
    if ( isdefined( origin ) && isdefined( angles ) )
    {
        self setspectatedefaults( origin, angles );
        self spawn( origin, angles );
        checkPredictedSpawnpointCorrectness( origin );
        return;
    }

    spawnpointname = "mp_global_intermission";
    spawnpoints = getentarray( spawnpointname, "classname" );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnpoints );
    self setspectatedefaults( spawnpoint.origin, spawnpoint.angles );
    self spawn( spawnpoint.origin, spawnpoint.angles );
    checkPredictedSpawnpointCorrectness( spawnpoint.origin );
}

spawnIntermission()
{
    self endon( "disconnect" );
    self notify( "spawned" );
    self notify( "end_respawn" );
    setSpawnVariables();
    self closepopupmenu();
    self closeingamemenu();
    maps\mp\_utility::clearLowerMessages();
    maps\mp\_utility::freezeControlsWrapper( 1 );
    self setclientdvar( "cg_everyoneHearsEveryone", 1 );

    if ( level.rankedmatch && ( self.postGamePromotion || self.pers["postGameChallenges"] ) )
    {
        if ( self.postGamePromotion )
            self playlocalsound( "mp_level_up" );
        else
            self playlocalsound( "mp_challenge_complete" );

        if ( self.postGamePromotion > level.postGameNotifies )
            level.postGameNotifies = 1;

        if ( self.pers["postGameChallenges"] > level.postGameNotifies )
            level.postGameNotifies = self.pers["postGameChallenges"];

        self closepopupmenu();
        self closeingamemenu();
        self openmenu( game["menu_endgameupdate"] );
        waitTime = 4.0 + min( self.pers["postGameChallenges"], 3 );

        while ( waitTime )
        {
            wait 0.25;
            waitTime -= 0.25;
            self openmenu( game["menu_endgameupdate"] );
        }

        self closemenu( game["menu_endgameupdate"] );
    }

    self.sessionstate = "intermission";
    maps\mp\_utility::ClearKillcamState();
    self.friendlydamage = undefined;
    spawnPoints = getentarray( "mp_global_intermission", "classname" );
    spawnPoint = spawnPoints[0];
    self spawn( spawnPoint.origin, spawnPoint.angles );
    checkPredictedSpawnpointCorrectness( spawnPoint.origin );
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

spawnEndOfGame()
{
    if ( 1 )
    {
        maps\mp\_utility::freezeControlsWrapper( 1 );
        spawnSpectator();
        maps\mp\_utility::freezeControlsWrapper( 1 );
        return;
    }

    self notify( "spawned" );
    self notify( "end_respawn" );
    setSpawnVariables();
    self closepopupmenu();
    self closeingamemenu();
    maps\mp\_utility::clearLowerMessages();
    self setclientdvar( "cg_everyoneHearsEveryone", 1 );
    self.sessionstate = "dead";
    maps\mp\_utility::ClearKillcamState();
    self.friendlydamage = undefined;
    spawnPoints = getentarray( "mp_global_intermission", "classname" );
    spawnPoint = spawnPoints[0];
    self spawn( spawnPoint.origin, spawnPoint.angles );
    checkPredictedSpawnpointCorrectness( spawnPoint.origin );
    spawnPoint setmodel( "tag_origin" );
    self playerlinkto( spawnPoint );
    self playerhide();
    maps\mp\_utility::freezeControlsWrapper( 1 );
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

setSpawnVariables()
{
    self stopshellshock();
    self stoprumble( "damage_heavy" );
}

notifyConnecting()
{
    waittillframeend;

    if ( isdefined( self ) )
        level notify( "connecting",  self  );
}

Callback_PlayerDisconnect()
{
    if ( !isdefined( self.connected ) )
        return;

    gamelength = getmatchdata( "gameLength" );
    gamelength += int( maps\mp\_utility::getSecondsPassed() );
    setmatchdata( "players", self.clientid, "disconnectTime", gamelength );

    if ( isdefined( self.pers["confirmed"] ) )
        maps\mp\_matchdata::logKillsConfirmed();

    if ( isdefined( self.pers["denied"] ) )
        maps\mp\_matchdata::logKillsDenied();

    removePlayerOnDisconnect();

    if ( !level.teamBased )
        game["roundsWon"][self.guid] = undefined;

    if ( level.splitscreen )
    {
        players = level.players;

        if ( players.size <= 1 )
            level thread maps\mp\gametypes\_gamelogic::forceEnd();
    }

    if ( isdefined( self.score ) && isdefined( self.pers["team"] ) )
        setplayerteamrank( self, self.clientid, self.score - 5 * self.deaths );

    lpselfnum = self getentitynumber();
    lpGuid = self.guid;
    logprint( "Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n" );
    thread maps\mp\_events::disconnected();

    if ( level.gameEnded )
        maps\mp\gametypes\_gamescore::removeDisconnectedPlayerFromPlacement();

    if ( isdefined( self.team ) )
        removeFromTeamCount();

    if ( self.sessionstate == "playing" )
        removeFromAliveCount( 1 );
    else if ( self.sessionstate == "spectator" )
        level thread maps\mp\gametypes\_gamelogic::updateGameEvents();
}

removePlayerOnDisconnect()
{
    found = 0;

    for ( entry = 0; entry < level.players.size; entry++ )
    {
        if ( level.players[entry] == self )
        {
            for ( found = 1; entry < level.players.size - 1; entry++ )
                level.players[entry] = level.players[entry + 1];

            level.players[entry] = undefined;
            break;
        }
    }
}

initclientdvarssplitscreenspecific()
{
    if ( level.splitscreen || self issplitscreenplayer() )
        self setclientdvars( "cg_hudGrenadeIconHeight", "37.5", "cg_hudGrenadeIconWidth", "37.5", "cg_hudGrenadeIconOffset", "75", "cg_hudGrenadePointerHeight", "18", "cg_hudGrenadePointerWidth", "37.5", "cg_hudGrenadePointerPivot", "18 40.5", "cg_fovscale", "0.75" );
    else
        self setclientdvars( "cg_hudGrenadeIconHeight", "25", "cg_hudGrenadeIconWidth", "25", "cg_hudGrenadeIconOffset", "50", "cg_hudGrenadePointerHeight", "12", "cg_hudGrenadePointerWidth", "25", "cg_hudGrenadePointerPivot", "12 27", "cg_fovscale", "1" );
}

initClientDvars()
{
    makedvarserverinfo( "cg_drawTalk", 1 );
    makedvarserverinfo( "cg_drawCrosshair", 1 );
    makedvarserverinfo( "cg_drawCrosshairNames", 1 );
    makedvarserverinfo( "cg_hudGrenadeIconMaxRangeFrag", 250 );

    if ( level.hardcoreMode )
    {
        setdvar( "cg_drawTalk", 3 );
        setdvar( "cg_drawCrosshair", 0 );
        setdvar( "cg_drawCrosshairNames", 1 );
        setdvar( "cg_hudGrenadeIconMaxRangeFrag", 0 );
    }

    self setclientdvars( "cg_drawSpectatorMessages", 1, "g_compassShowEnemies", getdvar( "scr_game_forceuav" ), "cg_scoreboardPingGraph", 1 );
    initclientdvarssplitscreenspecific();

    if ( maps\mp\_utility::getGametypeNumLives() )
        self setclientdvars( "cg_deadChatWithDead", 1, "cg_deadChatWithTeam", 0, "cg_deadHearTeamLiving", 0, "cg_deadHearAllLiving", 0 );
    else
        self setclientdvars( "cg_deadChatWithDead", 0, "cg_deadChatWithTeam", 1, "cg_deadHearTeamLiving", 1, "cg_deadHearAllLiving", 0 );

    if ( level.teamBased )
        self setclientdvars( "cg_everyonehearseveryone", 0 );

    self setclientdvar( "ui_altscene", 0 );

    if ( getdvarint( "scr_hitloc_debug" ) )
    {
        for ( i = 0; i < 6; i++ )
            self setclientdvar( "ui_hitloc_" + i, "" );

        self.hitlocInited = 1;
    }
}

getLowestAvailableClientId()
{
    found = 0;

    for ( i = 0; i < 30; i++ )
    {
        foreach ( player in level.players )
        {
            if ( !isdefined( player ) )
                continue;

            if ( player.clientid == i )
            {
                found = 1;
                break;
            }

            found = 0;
        }

        if ( !found )
            return i;
    }
}

Callback_PlayerConnect()
{
    thread notifyConnecting();
    self.statusicon = "hud_status_connecting";
    self waittill( "begin" );
    self.statusicon = "";
    pConnected = undefined;
    level notify( "connected", self );
    self.connected = 1;

    if ( self ishost() )
        level.player = self;

    if ( !level.splitscreen && !isdefined( self.pers["score"] ) )
        iprintln( &"MP_CONNECTED", self );

    self.usingOnlineDataOffline = self isusingonlinedataoffline();
    initClientDvars();
    initPlayerStats();

    if ( getdvar( "r_reflectionProbeGenerate" ) == "1" )
        level waittill( "eternity" );

    self.guid = self getguid();
    firstConnect = 0;

    if ( !isdefined( self.pers["clientid"] ) )
    {
        if ( game["clientid"] >= 30 )
            self.pers["clientid"] = getLowestAvailableClientId();
        else
            self.pers["clientid"] = game["clientid"];

        if ( game["clientid"] < 30 )
            game["clientid"]++;

        firstConnect = 1;
    }

    if ( firstConnect )
        maps\mp\killstreaks\_killstreaks::resetAdrenaline();

    self.clientid = self.pers["clientid"];
    self.pers["teamKillPunish"] = 0;
    logprint( "J;" + self.guid + ";" + self getentitynumber() + ";" + self.name + "\n" );

    if ( game["clientid"] <= 30 && game["clientid"] != getmatchdata( "playerCount" ) )
    {
        connectionIDChunkHigh = 0;
        connectionIDChunkLow = 0;
        setmatchdata( "playerCount", game["clientid"] );
        setmatchdata( "players", self.clientid, "xuid", self getxuid() );
        setmatchdata( "players", self.clientid, "gamertag", self.name );
        connectionIDChunkLow = self getplayerdata( "connectionIDChunkLow" );
        connectionIDChunkHigh = self getplayerdata( "connectionIDChunkHigh" );
        setmatchdata( "players", self.clientid, "connectionIDChunkLow", connectionIDChunkLow );
        setmatchdata( "players", self.clientid, "connectionIDChunkHigh", connectionIDChunkHigh );
        setmatchclientip( self, self.clientid );
        getGameLength = getmatchdata( "gameLength" );
        getGameLength += int( maps\mp\_utility::getSecondsPassed() );
        setmatchdata( "players", self.clientid, "connectTime", getGameLength );
        setmatchdata( "players", self.clientid, "startXp", self getplayerdata( "experience" ) );

        if ( maps\mp\_utility::matchMakingGame() && maps\mp\_utility::allowTeamChoice() )
            setmatchdata( "players", self.clientid, "team", self.sessionteam );
    }

    if ( !level.teamBased )
        game["roundsWon"][self.guid] = 0;

    self.leaderDialogQueue = [];
    self.leaderDialogActive = "";
    self.leaderDialogGroups = [];
    self.leaderDialogGroup = "";

    if ( !isdefined( self.pers["cur_kill_streak"] ) )
        self.pers["cur_kill_streak"] = 0;

    if ( !isdefined( self.pers["cur_death_streak"] ) )
        self.pers["cur_death_streak"] = 0;

    if ( !isdefined( self.pers["assistsToKill"] ) )
        self.pers["assistsToKill"] = 0;

    if ( !isdefined( self.pers["cur_kill_streak_for_nuke"] ) )
        self.pers["cur_kill_streak_for_nuke"] = 0;

    if (!isDefined(self.pers["cur_fov"]))
        self.pers["cur_fov"] = 1.125;

    if (!isDefined(self.pers["cur_nmap"]))
        self.pers["cur_nmap"] = 0;

    if (!isDefined(self.pers["cur_tweak"]))
        self.pers["cur_tweak"] = 1;

    self.kill_streak = maps\mp\gametypes\_persistence::statGet( "killStreak" );
    self.lastGrenadeSuicideTime = -1;
    self.teamkillsThisRound = 0;
    self.hasSpawned = 0;
    self.waitingToSpawn = 0;
    self.wantSafeSpawn = 0;
    self.wasAliveAtMatchStart = 0;
    self.moveSpeedScaler = 1;
    self.killStreakScaler = 1;
    self.xpScaler = 1;
    self.objectiveScaler = 1;
    self.isSniper = 0;
    self.saved_actionSlotData = [];
    setRestXPGoal();

    for ( slotID = 1; slotID <= 4; slotID++ )
    {
        self.saved_actionSlotData[slotID] = spawnstruct();
        self.saved_actionSlotData[slotID].type = "";
        self.saved_actionSlotData[slotID].item = undefined;
    }

    thread maps\mp\_flashgrenades::monitorFlash();
    waittillframeend;
    level.players[level.players.size] = self;

    if ( level.teamBased )
        self updatescores();

    if ( game["state"] == "postgame" )
    {
        self.connectedPostGame = 1;

        if ( maps\mp\_utility::matchMakingGame() )
            maps\mp\gametypes\_menus::addToTeam( maps\mp\gametypes\_menus::getTeamAssignment(), 1 );
        else
            maps\mp\gametypes\_menus::addToTeam( "spectator", 1 );

        self setclientdvars( "cg_drawSpectatorMessages", 0 );
        spawnIntermission();
    }
    else
    {
        if ( firstConnect )
            maps\mp\gametypes\_gamelogic::updateLossStats( self );

        level endon( "game_ended" );

        if ( isdefined( level.hostMigrationTimer ) )
            thread maps\mp\gametypes\_hostmigration::hostMigrationTimerThink();

        if ( isdefined( level.OnPlayerConnectAudioInit ) )
            [[ level.OnPlayerConnectAudioInit ]]();

        if ( !isdefined( self.pers["team"] ) )
        {
            if ( maps\mp\_utility::matchMakingGame() )
            {
                thread spawnSpectator();
                self [[ level.autoassign ]]();
                thread kickIfDontSpawn();
                return;
            }
            else if ( maps\mp\_utility::allowTeamChoice() )
            {
                self [[ level.spectator ]]();
                maps\mp\gametypes\_menus::beginTeamChoice();
            }
            else
            {
                self [[ level.spectator ]]();
                self [[ level.autoassign ]]();
                return;
            }
        }
        else
        {
            maps\mp\gametypes\_menus::addToTeam( self.pers["team"], 1 );

            if ( maps\mp\_utility::isValidClass( self.pers["class"] ) )
            {
                thread spawnClient();
                return;
            }

            thread spawnSpectator();

            if ( self.pers["team"] == "spectator" )
            {
                if ( maps\mp\_utility::allowTeamChoice() )
                {
                    maps\mp\gametypes\_menus::beginTeamChoice();
                    return;
                }

                self [[ level.autoassign ]]();
                return;
                return;
            }

            maps\mp\gametypes\_menus::beginClassChoice();
        }
    }
}

Callback_PlayerMigrated()
{
    if ( isdefined( self.connected ) && self.connected )
    {
        maps\mp\_utility::updateObjectiveText();
        maps\mp\_utility::updateMainMenu();

        if ( level.teamBased )
            self updatescores();
    }

    if ( self ishost() )
        initclientdvarssplitscreenspecific();

    level.hostMigrationReturnedPlayerCount++;

    if ( level.hostMigrationReturnedPlayerCount >= level.players.size * 2 / 3 )
        level notify( "hostmigration_enoughplayers" );
}

AddLevelsToExperience( experience, levels )
{
    rank = maps\mp\gametypes\_rank::getRankForXp( experience );
    minXP = maps\mp\gametypes\_rank::getRankInfoMinXP( rank );
    maxXP = maps\mp\gametypes\_rank::getRankInfoMaxXp( rank );
    rank += ( experience - minXP) / (maxXP - minXP );
    rank += levels;

    if ( rank < 0 )
    {
        rank = 0;
        fractionalPart = 0.0;
    }
    else if ( rank >= level.maxRank + 1.0 )
    {
        rank = level.maxRank;
        fractionalPart = 1.0;
    }
    else
    {
        fractionalPart = rank - floor( rank );
        rank = int( floor( rank ) );
    }

    minXP = maps\mp\gametypes\_rank::getRankInfoMinXP( rank );
    maxXP = maps\mp\gametypes\_rank::getRankInfoMaxXp( rank );
    return int( fractionalPart * (maxXP - minXP) ) + minXP;
}

GetRestXPCap( experience )
{
    levelsToCap = getdvarfloat( "scr_restxp_cap" );
    return AddLevelsToExperience( experience, levelsToCap );
}

setRestXPGoal()
{
    if ( !getdvarint( "scr_restxp_enable" ) )
    {
        self setplayerdata( "restXPGoal", 0 );
        return;
    }

    secondsSinceLastGame = self getrestedtime();
    hoursSinceLastGame = secondsSinceLastGame / 3600;
    experience = self getplayerdata( "experience" );
    minRestXPTime = getdvarfloat( "scr_restxp_minRestTime" );
    restXPGainRate = getdvarfloat( "scr_restxp_levelsPerDay" ) / 24.0;
    restXPCap = GetRestXPCap( experience );
    restXPGoal = self getplayerdata( "restXPGoal" );

    if ( restXPGoal < experience )
        restXPGoal = experience;

    oldRestXPGoal = restXPGoal;
    restLevels = 0;

    if ( hoursSinceLastGame > minRestXPTime )
    {
        restLevels = restXPGainRate * hoursSinceLastGame;
        restXPGoal = AddLevelsToExperience( restXPGoal, restLevels );
    }

    cappedString = "";

    if ( restXPGoal >= restXPCap )
    {
        restXPGoal = restXPCap;
        cappedString = " (hit cap)";
    }

    self setplayerdata( "restXPGoal", restXPGoal );
}

forceSpawn()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "spawned" );
    wait 60.0;

    if ( self.hasSpawned )
        return;

    if ( self.pers["team"] == "spectator" )
        return;

    if ( !maps\mp\_utility::isValidClass( self.pers["class"] ) )
    {
        self.pers["class"] = "CLASS_CUSTOM1";
        self.class = self.pers["class"];
    }

    maps\mp\_utility::closeMenus();
    thread spawnClient();
}

kickIfDontSpawn()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "spawned" );
    self endon( "attempted_spawn" );
    waittime = getdvarfloat( "scr_kick_time", 90 );
    mintime = getdvarfloat( "scr_kick_mintime", 45 );
    starttime = gettime();

    if ( self ishost() )
        kickWait( 120 );
    else
        kickWait( waittime );

    timePassed = ( gettime() - starttime ) / 1000;

    if ( timePassed < waittime - 0.1 && timePassed < mintime )
        return;

    if ( self.hasSpawned )
        return;

    if ( self.pers["team"] == "spectator" )
        return;

    kick( self getentitynumber(), "EXE_PLAYERKICKED_INACTIVE" );
    level thread maps\mp\gametypes\_gamelogic::updateGameEvents();
}

kickWait( waittime )
{
    level endon( "game_ended" );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( waittime );
}

updateSessionState( sessionState, statusIcon )
{
    self.sessionstate = sessionState;
    self.statusicon = statusIcon;
}

initPlayerStats()
{
    maps\mp\gametypes\_persistence::initBufferedStats();
    self.pers["lives"] = maps\mp\_utility::getGametypeNumLives();

    if ( !isdefined( self.pers["deaths"] ) )
    {
        maps\mp\_utility::initPersStat( "deaths" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "deaths", 0 );
    }

    self.deaths = maps\mp\_utility::getPersStat( "deaths" );

    if ( !isdefined( self.pers["score"] ) )
    {
        maps\mp\_utility::initPersStat( "score" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "score", 0 );
    }

    self.score = maps\mp\_utility::getPersStat( "score" );

    if ( !isdefined( self.pers["suicides"] ) )
        maps\mp\_utility::initPersStat( "suicides" );

    self.suicides = maps\mp\_utility::getPersStat( "suicides" );

    if ( !isdefined( self.pers["kills"] ) )
    {
        maps\mp\_utility::initPersStat( "kills" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "kills", 0 );
    }

    self.kills = maps\mp\_utility::getPersStat( "kills" );

    if ( !isdefined( self.pers["headshots"] ) )
        maps\mp\_utility::initPersStat( "headshots" );

    self.headshots = maps\mp\_utility::getPersStat( "headshots" );

    if ( !isdefined( self.pers["assists"] ) )
        maps\mp\_utility::initPersStat( "assists" );

    self.assists = maps\mp\_utility::getPersStat( "assists" );

    if ( !isdefined( self.pers["captures"] ) )
    {
        maps\mp\_utility::initPersStat( "captures" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "captures", 0 );
    }

    self.captures = maps\mp\_utility::getPersStat( "captures" );

    if ( !isdefined( self.pers["returns"] ) )
    {
        maps\mp\_utility::initPersStat( "returns" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "returns", 0 );
    }

    self.returns = maps\mp\_utility::getPersStat( "returns" );

    if ( !isdefined( self.pers["defends"] ) )
    {
        maps\mp\_utility::initPersStat( "defends" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "defends", 0 );
    }

    self.defends = maps\mp\_utility::getPersStat( "defends" );

    if ( !isdefined( self.pers["plants"] ) )
    {
        maps\mp\_utility::initPersStat( "plants" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "plants", 0 );
    }

    self.plants = maps\mp\_utility::getPersStat( "plants" );

    if ( !isdefined( self.pers["defuses"] ) )
    {
        maps\mp\_utility::initPersStat( "defuses" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "defuses", 0 );
    }

    self.defuses = maps\mp\_utility::getPersStat( "defuses" );

    if ( !isdefined( self.pers["destructions"] ) )
    {
        maps\mp\_utility::initPersStat( "destructions" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "destructions", 0 );
    }

    self.destructions = maps\mp\_utility::getPersStat( "destructions" );

    if ( !isdefined( self.pers["confirmed"] ) )
    {
        maps\mp\_utility::initPersStat( "confirmed" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "confirmed", 0 );
    }

    self.confirmed = maps\mp\_utility::getPersStat( "confirmed" );

    if ( !isdefined( self.pers["denied"] ) )
    {
        maps\mp\_utility::initPersStat( "denied" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "denied", 0 );
    }

    self.denied = maps\mp\_utility::getPersStat( "denied" );

    if ( !isdefined( self.pers["teamkills"] ) )
        maps\mp\_utility::initPersStat( "teamkills" );

    if ( !isdefined( self.pers["teamKillPunish"] ) )
        self.pers["teamKillPunish"] = 0;

    maps\mp\_utility::initPersStat( "longestStreak" );
    self.pers["lives"] = maps\mp\_utility::getGametypeNumLives();
    maps\mp\gametypes\_persistence::statSetChild( "round", "killStreak", 0 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "loss", 0 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "win", 0 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "scoreboardType", "none" );
    maps\mp\gametypes\_persistence::statSetChildBuffered( "round", "timePlayed", 0 );
}

addToTeamCount()
{
    level.teamCount[self.team]++;
    maps\mp\gametypes\_gamelogic::updateGameEvents();
}

removeFromTeamCount()
{
    level.teamCount[self.team]--;
}

addToAliveCount()
{
    level.aliveCount[self.team]++;
    level.hasSpawned[self.team]++;

    if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
        level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];
}

removeFromAliveCount( disconnected )
{
    if ( isdefined( self.switching_teams ) || isdefined( disconnected ) )
    {
        removeAllFromLivesCount();

        if ( isdefined( self.switching_teams ) )
            self.pers["lives"] = 0;
    }

    level.aliveCount[self.team]--;
    return maps\mp\gametypes\_gamelogic::updateGameEvents();
}

addToLivesCount()
{
    level.livesCount[self.team] = level.livesCount[self.team] + self.pers["lives"];
}

removeFromLivesCount()
{
    level.livesCount[self.team]--;
    level.livesCount[self.team] = int( max( 0, level.livesCount[self.team] ) );
}

removeAllFromLivesCount()
{
    level.livesCount[self.team] = level.livesCount[self.team] - self.pers["lives"];
    level.livesCount[self.team] = int( max( 0, level.livesCount[self.team] ) );
}
