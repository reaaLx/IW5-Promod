// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

FACTION_REF_COL 					= 0;
FACTION_NAME_COL 					= 1;
FACTION_SHORT_NAME_COL 				= 1;
FACTION_WIN_GAME_COL 				= 3; 
FACTION_WIN_ROUND_COL 				= 4;
FACTION_MISSION_ACCOMPLISHED_COL 	= 5;
FACTION_ELIMINATED_COL 				= 6;
FACTION_FORFEITED_COL 				= 7;
FACTION_ICON_COL 					= 8;
FACTION_HUD_ICON_COL 				= 9;
FACTION_VOICE_PREFIX_COL 			= 10;
FACTION_SPAWN_MUSIC_COL 			= 11;
FACTION_WIN_MUSIC_COL 				= 12;
FACTION_COLOR_R_COL 				= 13;
FACTION_COLOR_G_COL 				= 14;
FACTION_COLOR_B_COL 				= 15;

onForfeit( team )
{
    if ( isdefined( level.forfeitInProgress ) )
        return;

    level endon( "abort_forfeit" );
    level thread forfeitWaitforAbort();
    level.forfeitInProgress = 1;

    if ( !level.teamBased && level.players.size > 1 )
        wait 10;

    level.forfeit_aborted = 0;
    forfeit_delay = 20.0;
    matchForfeitTimer( forfeit_delay );
    endReason = &"";

    if ( !isdefined( team ) )
    {
        level.finalKillCam_winner = "none";
        endReason = game["strings"]["players_forfeited"];
        winner = level.players[0];
    }
    else if ( team == "allies" )
    {
        level.finalKillCam_winner = "axis";
        endReason = game["strings"]["allies_forfeited"];
        winner = "axis";
    }
    else if ( team == "axis" )
    {
        level.finalKillCam_winner = "allies";
        endReason = game["strings"]["axis_forfeited"];
        winner = "allies";
    }
    else
    {
        level.finalKillCam_winner = "none";
        winner = "tie";
    }

    level.forcedEnd = 1;

    if ( isplayer( winner ) )
        logstring( "forfeit, win: " + winner getxuid() + "(" + winner.name + ")" );
    else
        logstring( "forfeit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

    thread endGame( winner, endReason );
}

forfeitWaitforAbort()
{
    level endon( "game_ended" );
    level waittill( "abort_forfeit" );
    level.forfeit_aborted = 1;

    if ( isdefined( level.matchForfeitTimer ) )
        level.matchForfeitTimer maps\mp\gametypes\_hud_util::destroyElem();

    if ( isdefined( level.matchForfeitText ) )
        level.matchForfeitText maps\mp\gametypes\_hud_util::destroyElem();
}

matchForfeitTimer_Internal( countTime, matchForfeitTimer )
{
    waittillframeend;
    level endon( "match_forfeit_timer_beginning" );

    while ( countTime > 0 && !level.gameEnded && !level.forfeit_aborted && !level.inGracePeriod )
    {
        matchForfeitTimer thread maps\mp\gametypes\_hud::fontPulse( level );
        wait(matchForfeitTimer.inFrames * 0.05);
        matchForfeitTimer setvalue( countTime );
        countTime--;
        wait(1 - matchForfeitTimer.inFrames * 0.05);
    }
}

matchForfeitTimer( duration )
{
    level notify( "match_forfeit_timer_beginning" );
    matchForfeitText = maps\mp\gametypes\_hud_util::createServerFontString( "objective", 1.5 );
    matchForfeitText maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, -40 );
    matchForfeitText.sort = 1001;
    matchForfeitText settext( game["strings"]["opponent_forfeiting_in"] );
    matchForfeitText.foreground = 0;
    matchForfeitText.hidewheninmenu = 1;
    matchForfeitTimer = maps\mp\gametypes\_hud_util::createServerFontString( "hudbig", 1 );
    matchForfeitTimer maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, 0 );
    matchForfeitTimer.sort = 1001;
    matchForfeitTimer.color = ( 1, 1, 0 );
    matchForfeitTimer.foreground = 0;
    matchForfeitTimer.hidewheninmenu = 1;
    matchForfeitTimer maps\mp\gametypes\_hud::fontPulseInit();
    countTime = int( duration );
    level.matchForfeitTimer = matchForfeitTimer;
    level.matchForfeitText = matchForfeitText;
    matchForfeitTimer_Internal( countTime, matchForfeitTimer );
    matchForfeitTimer maps\mp\gametypes\_hud_util::destroyElem();
    matchForfeitText maps\mp\gametypes\_hud_util::destroyElem();
}

default_onDeadEvent( team )
{
    level.finalKillCam_winner = "none";

    if ( team == "allies" )
    {
        iprintln( game["strings"]["allies_eliminated"] );
        logstring( "team eliminated, win: opfor, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
        level.finalKillCam_winner = "axis";
        thread endGame( "axis", game["strings"]["allies_eliminated"] );
    }
    else if ( team == "axis" )
    {
        iprintln( game["strings"]["axis_eliminated"] );
        logstring( "team eliminated, win: allies, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
        level.finalKillCam_winner = "allies";
        thread endGame( "allies", game["strings"]["axis_eliminated"] );
    }
    else
    {
        logstring( "tie, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
        level.finalKillCam_winner = "none";

        if ( level.teamBased )
            thread endGame( "tie", game["strings"]["tie"] );
        else
            thread endGame( undefined, game["strings"]["tie"] );
    }
}

default_onOneLeftEvent( team )
{
    if ( level.teamBased )
    {
        lastPlayer = maps\mp\_utility::getLastLivingPlayer( team );
        lastPlayer thread giveLastOnTeamWarning();
    }
    else
    {
        lastPlayer = maps\mp\_utility::getLastLivingPlayer();
        logstring( "last one alive, win: " + lastPlayer.name );
        level.finalKillCam_winner = "none";
        thread endGame( lastPlayer, &"MP_ENEMIES_ELIMINATED" );
    }

    return 1;
}

default_onTimeLimit()
{
    winner = undefined;
    level.finalKillCam_winner = "none";

    if ( level.teamBased )
    {
        if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
            winner = "tie";
        else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
        {
            level.finalKillCam_winner = "axis";
            winner = "axis";
        }
        else
        {
            level.finalKillCam_winner = "allies";
            winner = "allies";
        }

        logstring( "time limit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
    }
    else
    {
        winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();

        if ( isdefined( winner ) )
            logstring( "time limit, win: " + winner.name );
        else
            logstring( "time limit, tie" );
    }

    thread endGame( winner, game["strings"]["time_limit_reached"] );
}

default_onHalfTime()
{
    winner = undefined;
    level.finalKillCam_winner = "none";
    thread endGame( "halftime", game["strings"]["time_limit_reached"] );
}

forceEnd()
{
    if ( level.hostForcedEnd || level.forcedEnd )
        return;

    winner = undefined;
    level.finalKillCam_winner = "none";

    if ( level.teamBased )
    {
        if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
            winner = "tie";
        else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
        {
            level.finalKillCam_winner = "axis";
            winner = "axis";
        }
        else
        {
            level.finalKillCam_winner = "allies";
            winner = "allies";
        }

        logstring( "host ended game, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
    }
    else
    {
        winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();

        if ( isdefined( winner ) )
            logstring( "host ended game, win: " + winner.name );
        else
            logstring( "host ended game, tie" );
    }

    level.forcedEnd = 1;
    level.hostForcedEnd = 1;

    if ( level.splitscreen )
        endString = &"MP_ENDED_GAME";
    else
        endString = &"MP_HOST_ENDED_GAME";

    thread endGame( winner, endString );
}

onScoreLimit()
{
    scoreText = game["strings"]["score_limit_reached"];
    winner = undefined;
    level.finalKillCam_winner = "none";

    if ( level.teamBased )
    {
        if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
            winner = "tie";
        else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
        {
            winner = "axis";
            level.finalKillCam_winner = "axis";
        }
        else
        {
            winner = "allies";
            level.finalKillCam_winner = "allies";
        }

        logstring( "scorelimit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
    }
    else
    {
        winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();

        if ( isdefined( winner ) )
            logstring( "scorelimit, win: " + winner.name );
        else
            logstring( "scorelimit, tie" );
    }

    thread endGame( winner, scoreText );
    return 1;
}

updateGameEvents()
{
    if ( maps\mp\_utility::matchMakingGame() && !level.inGracePeriod )
    {
        if ( level.teamBased )
        {
            if ( level.teamCount["allies"] < 1 && level.teamCount["axis"] > 0 && game["state"] == "playing" )
            {
                thread onForfeit( "allies" );
                return;
            }

            if ( level.teamCount["axis"] < 1 && level.teamCount["allies"] > 0 && game["state"] == "playing" )
            {
                thread onForfeit( "axis" );
                return;
            }

            if ( level.teamCount["axis"] > 0 && level.teamCount["allies"] > 0 )
            {
                level.forfeitInProgress = undefined;
                level notify( "abort_forfeit" );
            }
        }
        else
        {
            if ( level.teamCount["allies"] + level.teamCount["axis"] == 1 && level.maxPlayerCount > 1 )
            {
                thread onForfeit();
                return;
            }

            if ( level.teamCount["axis"] + level.teamCount["allies"] > 1 )
            {
                level.forfeitInProgress = undefined;
                level notify( "abort_forfeit" );
            }
        }
    }

    if ( !maps\mp\_utility::getGametypeNumLives() && ( !isdefined( level.disableSpawning ) || !level.disableSpawning ) )
        return;

    if ( !maps\mp\_utility::gameHasStarted() )
        return;

    if ( level.inGracePeriod )
        return;

    if ( level.teamBased )
    {
        livesCount["allies"] = level.livesCount["allies"];
        livesCount["axis"] = level.livesCount["axis"];

        if ( isdefined( level.disableSpawning ) && level.disableSpawning )
        {
            livesCount["allies"] = 0;
            livesCount["axis"] = 0;
        }

        if ( !level.aliveCount["allies"] && !level.aliveCount["axis"] && !livesCount["allies"] && !livesCount["axis"] )
            return [[ level.onDeadEvent ]]( "all" );

        if ( !level.aliveCount["allies"] && !livesCount["allies"] )
            return [[ level.onDeadEvent ]]( "allies" );

        if ( !level.aliveCount["axis"] && !livesCount["axis"] )
            return [[ level.onDeadEvent ]]( "axis" );

        if ( level.aliveCount["allies"] == 1 && !livesCount["allies"] )
        {
            if ( !isdefined( level.oneLeftTime["allies"] ) )
            {
                level.oneLeftTime["allies"] = gettime();
                return [[ level.onOneLeftEvent ]]( "allies" );
            }
        }

        if ( level.aliveCount["axis"] == 1 && !livesCount["axis"] )
        {
            if ( !isdefined( level.oneLeftTime["axis"] ) )
            {
                level.oneLeftTime["axis"] = gettime();
                return [[ level.onOneLeftEvent ]]( "axis" );
                return;
            }

            return;
        }
    }
    else
    {
        if ( !level.aliveCount["allies"] && !level.aliveCount["axis"] && ( !level.livesCount["allies"] && !level.livesCount["axis"] ) )
            return [[ level.onDeadEvent ]]( "all" );

        livePlayers = maps\mp\_utility::getPotentialLivingPlayers();

        if ( livePlayers.size == 1 )
            return [[ level.onOneLeftEvent ]]( "all" );
    }
}

waittillFinalKillcamDone()
{
    if ( !isdefined( level.finalKillCam_winner ) )
        return 0;

    level waittill( "final_killcam_done" );
    return 1;
}

timeLimitClock_Intermission( waitTime )
{
    setgameendtime( gettime() + int( waitTime * 1000 ) );
    clockObject = spawn( "script_origin", ( 0, 0, 0 ) );
    clockObject hide();

    if ( waitTime >= 10.0 )
        wait(waitTime - 10.0);

    for (;;)
    {
        clockObject playsound( "ui_mp_timer_countdown" );
        wait 1.0;
    }
}

waitForPlayers( maxTime )
{
    endTime = gettime() + maxTime * 1000 - 200;

    if ( level.teamBased )
    {
        while ( ( !level.hasSpawned["axis"] || !level.hasSpawned["allies"] ) && gettime() < endTime )
            wait 0.05;
    }
    else
    {
        while ( level.maxPlayerCount < 2 && gettime() < endTime )
            wait 0.05;
    }
}

prematchPeriod()
{
    level endon( "game_ended" );

    if ( level.prematchPeriod > 0 )
    {
        if ( level.console )
        {
            thread matchStartTimer( "match_starting_in", level.prematchPeriod );
            wait(level.prematchPeriod);
        }
        else
            matchStartTimerPC();
    }
    else
        matchStartTimerSkip();

    for ( index = 0; index < level.players.size; index++ )
    {
        level.players[index] maps\mp\_utility::freezeControlsWrapper( 0 );
        level.players[index] enableweapons();
        hintMessage = maps\mp\_utility::getObjectiveHintText( level.players[index].pers["team"] );

        if ( !isdefined( hintMessage ) || !level.players[index].hasSpawned )
            continue;

        level.players[index] setclientdvar( "scr_objectiveText", hintMessage );
        level.players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
    }

    if ( game["state"] != "playing" )
        return;
}

gracePeriod()
{
    level endon( "game_ended" );

    while ( level.inGracePeriod > 0 )
    {
        wait 1.0;
        level.inGracePeriod--;
    }

    level notify( "grace_period_ending" );
    wait 0.05;
    maps\mp\_utility::gameFlagSet( "graceperiod_done" );
    level.inGracePeriod = 0;

    if ( game["state"] != "playing" )
        return;

    if ( maps\mp\_utility::getGametypeNumLives() )
    {
        players = level.players;

        for ( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if ( !player.hasSpawned && player.sessionteam != "spectator" && !isalive( player ) )
                player.statusicon = "hud_status_dead";
        }
    }

    level thread updateGameEvents();
}

updateWinStats( winner )
{
    if ( !winner maps\mp\_utility::rankingEnabled() )
        return;

    winner maps\mp\gametypes\_persistence::statAdd( "losses", -1 );
    winner maps\mp\gametypes\_persistence::statAdd( "wins", 1 );
    winner maps\mp\_utility::updatePersRatio( "winLossRatio", "wins", "losses" );
    winner maps\mp\gametypes\_persistence::statAdd( "currentWinStreak", 1 );
    cur_win_streak = winner maps\mp\gametypes\_persistence::statGet( "currentWinStreak" );

    if ( cur_win_streak > winner maps\mp\gametypes\_persistence::statGet( "winStreak" ) )
        winner maps\mp\gametypes\_persistence::statSet( "winStreak", cur_win_streak );

    winner maps\mp\gametypes\_persistence::statSetChild( "round", "win", 1 );
    winner maps\mp\gametypes\_persistence::statSetChild( "round", "loss", 0 );
}

updateLossStats( loser )
{
    if ( !loser maps\mp\_utility::rankingEnabled() )
        return;

    loser maps\mp\gametypes\_persistence::statAdd( "losses", 1 );
    loser maps\mp\_utility::updatePersRatio( "winLossRatio", "wins", "losses" );
    loser maps\mp\gametypes\_persistence::statSetChild( "round", "loss", 1 );
}

updateTieStats( loser )
{
    if ( !loser maps\mp\_utility::rankingEnabled() )
        return;

    loser maps\mp\gametypes\_persistence::statAdd( "losses", -1 );
    loser maps\mp\gametypes\_persistence::statAdd( "ties", 1 );
    loser maps\mp\_utility::updatePersRatio( "winLossRatio", "wins", "losses" );
    loser maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
}

updateWinLossStats( winner )
{
    if ( maps\mp\_utility::privateMatch() )
        return;

    if ( !maps\mp\_utility::wasLastRound() )
        return;

    players = level.players;

    if ( !isdefined( winner ) || isdefined( winner ) && isstring( winner ) && winner == "tie" )
    {
        foreach ( player in level.players )
        {
            if ( isdefined( player.connectedPostGame ) )
                continue;

            if ( level.hostForcedEnd && player ishost() )
            {
                player maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
                continue;
            }

            updateTieStats( player );
        }
    }
    else if ( isplayer( winner ) )
    {
        if ( level.hostForcedEnd && winner ishost() )
        {
            winner maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
            return;
        }

        updateWinStats( winner );
    }
    else if ( isstring( winner ) )
    {
        foreach ( player in level.players )
        {
            if ( isdefined( player.connectedPostGame ) )
                continue;

            if ( level.hostForcedEnd && player ishost() )
            {
                player maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
                continue;
            }

            if ( winner == "tie" )
            {
                updateTieStats( player );
                continue;
            }

            if ( player.pers["team"] == winner )
            {
                updateWinStats( player );
                continue;
            }

            player maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
        }
    }
}

freezePlayerForRoundEnd( delay )
{
    self endon( "disconnect" );
    maps\mp\_utility::clearLowerMessages();

    if ( !isdefined( delay ) )
        delay = 0.05;

    self closepopupmenu();
    self closeingamemenu();
    wait(delay);
    maps\mp\_utility::freezeControlsWrapper( 1 );
}

updateMatchBonusScores( winner )
{
    if ( !game["timePassed"] )
        return;

    if ( !maps\mp\_utility::matchMakingGame() )
        return;

    if ( !maps\mp\_utility::getTimeLimit() || level.forcedEnd )
    {
        gameLength = maps\mp\_utility::getTimePassed() / 1000;
        gameLength = min( gameLength, 1200 );
    }
    else
        gameLength = maps\mp\_utility::getTimeLimit() * 60;

    if ( level.teamBased )
    {
        if ( winner == "allies" )
        {
            winningTeam = "allies";
            losingTeam = "axis";
        }
        else if ( winner == "axis" )
        {
            winningTeam = "axis";
            losingTeam = "allies";
        }
        else
        {
            winningTeam = "tie";
            losingTeam = "tie";
        }

        if ( winningTeam != "tie" )
        {
            winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "win" );
            loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "loss" );
            setwinningteam( winningTeam );
        }
        else
        {
            winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
            loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
        }

        foreach ( player in level.players )
        {
            if ( isdefined( player.connectedPostGame ) )
                continue;

            if ( !player maps\mp\_utility::rankingEnabled() )
                continue;

            if ( player.timePlayed["total"] < 1 || player.pers["participation"] < 1 )
            {
                player thread maps\mp\gametypes\_rank::endGameUpdate();
                continue;
            }

            if ( level.hostForcedEnd && player ishost() )
                continue;

            spm = player maps\mp\gametypes\_rank::getSPM();

            if ( winningTeam == "tie" )
            {
                playerScore = int( winnerScale * ( gameLength / 60 * spm ) * player.timePlayed["total"] / gameLength );
                player thread giveMatchBonus( "tie", playerScore );
                player.matchBonus = playerScore;
                continue;
            }

            if ( isdefined( player.pers["team"] ) && player.pers["team"] == winningTeam )
            {
                playerScore = int( winnerScale * ( gameLength / 60 * spm ) * player.timePlayed["total"] / gameLength );
                player thread giveMatchBonus( "win", playerScore );
                player.matchBonus = playerScore;
                continue;
            }

            if ( isdefined( player.pers["team"] ) && player.pers["team"] == losingTeam )
            {
                playerScore = int( loserScale * ( gameLength / 60 * spm ) * player.timePlayed["total"] / gameLength );
                player thread giveMatchBonus( "loss", playerScore );
                player.matchBonus = playerScore;
            }
        }
    }
    else
    {
        if ( isdefined( winner ) )
        {
            winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "win" );
            loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "loss" );
        }
        else
        {
            winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
            loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
        }

        foreach ( player in level.players )
        {
            if ( isdefined( player.connectedPostGame ) )
                continue;

            if ( player.timePlayed["total"] < 1 || player.pers["participation"] < 1 )
            {
                player thread maps\mp\gametypes\_rank::endGameUpdate();
                continue;
            }

            spm = player maps\mp\gametypes\_rank::getSPM();
            isWinner = 0;

            for ( pIdx = 0; pIdx < min( level.placement["all"].size, 3 ); pIdx++ )
            {
                if ( level.placement["all"][pIdx] != player )
                    continue;

                isWinner = 1;
            }

            if ( isWinner )
            {
                playerScore = int( winnerScale * ( gameLength / 60 * spm ) * player.timePlayed["total"] / gameLength );
                player thread giveMatchBonus( "win", playerScore );
                player.matchBonus = playerScore;
                continue;
            }

            playerScore = int( loserScale * ( gameLength / 60 * spm ) * player.timePlayed["total"] / gameLength );
            player thread giveMatchBonus( "loss", playerScore );
            player.matchBonus = playerScore;
        }
    }
}

giveMatchBonus( scoreType, score )
{
    self endon( "disconnect" );
    level waittill( "give_match_bonus" );
    maps\mp\gametypes\_rank::giveRankXP( scoreType, score );
    maps\mp\gametypes\_rank::endGameUpdate();
}

setXenonRanks( winner )
{
	players = level.players;

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score) || !isdefined(player.pers["team"]) )
			continue;

	}

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score) || !isdefined(player.pers["team"]) )
			continue;		
		
		setPlayerTeamRank( player, player.clientid, player.score - 5 * player.deaths );
	}
}

checkTimeLimit( prevTimePassed )
{
    if ( isdefined( level.timeLimitOverride ) && level.timeLimitOverride )
        return;

    if ( game["state"] != "playing" )
    {
        setgameendtime( 0 );
        return;
    }

    if ( maps\mp\_utility::getTimeLimit() <= 0 )
    {
        if ( isdefined( level.startTime ) )
            setgameendtime( level.startTime );
        else
            setgameendtime( 0 );

        return;
    }

    if ( !maps\mp\_utility::gameFlag( "prematch_done" ) )
    {
        setgameendtime( 0 );
        return;
    }

    if ( !isdefined( level.startTime ) )
        return;

    timeLeft = getTimeRemaining();
    setgameendtime( gettime() + int( timeLeft ) );

    if ( timeLeft > 0 )
    {
        if ( maps\mp\_utility::getHalfTime() && checkHalfTime( prevTimePassed ) )
            [[ level.onHalfTime ]]();

        return;
    }

    [[ level.onTimeLimit ]]();
}

checkHalfTime( prevTimePassed )
{
    if ( !level.teamBased )
        return 0;

    if ( maps\mp\_utility::getTimeLimit() )
    {
        halfTime = maps\mp\_utility::getTimeLimit() * 60 * 1000 * 0.5;

        if ( maps\mp\_utility::getTimePassed() >= halfTime && prevTimePassed < halfTime && prevTimePassed > 0 )
        {
            game["roundMillisecondsAlreadyPassed"] = maps\mp\_utility::getTimePassed();
            return 1;
        }
    }

    return 0;
}

getTimeRemaining()
{
    return maps\mp\_utility::getTimeLimit() * 60 * 1000 - maps\mp\_utility::getTimePassed();
}

checkTeamScoreLimitSoon( team )
{
    if ( maps\mp\_utility::getWatchedDvar( "scorelimit" ) <= 0 || maps\mp\_utility::isObjectiveBased() )
        return;

    if ( isdefined( level.scoreLimitOverride ) && level.scoreLimitOverride )
        return;

    if ( level.gameType == "conf" || level.gameType == "jugg" )
        return;

    if ( !level.teamBased )
        return;

    if ( maps\mp\_utility::getTimePassed() < 60000 )
        return;

    timeLeft = estimatedTimeTillScoreLimit( team );

    if ( timeLeft < 2 )
        level notify( "match_ending_soon",  "score"  );
}

checkPlayerScoreLimitSoon()
{
    if ( maps\mp\_utility::getWatchedDvar( "scorelimit" ) <= 0 || maps\mp\_utility::isObjectiveBased() )
        return;

    if ( level.teamBased )
        return;

    if ( maps\mp\_utility::getTimePassed() < 60000 )
        return;

    timeLeft = estimatedTimeTillScoreLimit();

    if ( timeLeft < 2 )
        level notify( "match_ending_soon",  "score"  );
}

checkScoreLimit()
{
    if ( maps\mp\_utility::isObjectiveBased() )
        return 0;

    if ( isdefined( level.scoreLimitOverride ) && level.scoreLimitOverride )
        return 0;

    if ( game["state"] != "playing" )
        return 0;

    if ( maps\mp\_utility::getWatchedDvar( "scorelimit" ) <= 0 )
        return 0;

    if ( level.teamBased )
    {
        if ( game["teamScores"]["allies"] < maps\mp\_utility::getWatchedDvar( "scorelimit" ) && game["teamScores"]["axis"] < maps\mp\_utility::getWatchedDvar( "scorelimit" ) )
            return 0;
    }
    else
    {
        if ( !isplayer( self ) )
            return 0;

        if ( self.score < maps\mp\_utility::getWatchedDvar( "scorelimit" ) )
            return 0;
    }

    return onScoreLimit();
}

updateGametypeDvars()
{
    level endon( "game_ended" );

    while ( game["state"] == "playing" )
    {
        if ( isdefined( level.startTime ) )
        {
            if ( getTimeRemaining() < 3000 )
            {
                wait 0.1;
                continue;
            }
        }

        wait 1;
    }
}

matchStartTimerPC()
{
    thread matchStartTimer( "waiting_for_teams", level.prematchPeriod + level.prematchPeriodEnd );
    waitForPlayers( level.prematchPeriod );

    if ( level.prematchPeriodEnd > 0 )
        matchStartTimer( "match_starting_in", level.prematchPeriodEnd );
}

matchStartTimer_Internal( countTime, matchStartTimer )
{
    waittillframeend;
    visionsetnaked( "mpIntro", 0 );
    level endon( "match_start_timer_beginning" );

    while ( countTime > 0 && !level.gameEnded )
    {
        matchStartTimer thread maps\mp\gametypes\_hud::fontPulse( level );
        wait(matchStartTimer.inFrames * 0.05);
        matchStartTimer setvalue( countTime );

        if ( countTime == 0 )
            visionsetnaked( "", 0 );

        countTime--;
        wait(1 - matchStartTimer.inFrames * 0.05);
    }
}

matchStartTimer( type, duration )
{
    level notify( "match_start_timer_beginning" );
    matchStartText = maps\mp\gametypes\_hud_util::createServerFontString( "objective", 1.5 );
    matchStartText maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, -40 );
    matchStartText.sort = 1001;
    matchStartText settext( game["strings"]["waiting_for_teams"] );
    matchStartText.foreground = 0;
    matchStartText.hidewheninmenu = 1;
    matchStartText settext( game["strings"][type] );
    matchStartTimer = maps\mp\gametypes\_hud_util::createServerFontString( "hudbig", 1 );
    matchStartTimer maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, 0 );
    matchStartTimer.sort = 1001;
    matchStartTimer.color = ( 1, 1, 0 );
    matchStartTimer.foreground = 0;
    matchStartTimer.hidewheninmenu = 1;
    matchStartTimer maps\mp\gametypes\_hud::fontPulseInit();
    countTime = int( duration );

    if ( countTime >= 2 )
    {
        matchStartTimer_Internal( countTime, matchStartTimer );
        visionsetnaked( "", 3.0 );
    }
    else
    {
        visionsetnaked( "mpIntro", 0 );
        visionsetnaked( "", 1.0 );
    }

    matchStartTimer maps\mp\gametypes\_hud_util::destroyElem();
    matchStartText maps\mp\gametypes\_hud_util::destroyElem();
}

matchStartTimerSkip()
{
    visionsetnaked( "", 0 );
}

onRoundSwitch()
{
    if ( !isdefined( game["switchedsides"] ) )
        game["switchedsides"] = 0;

    if ( game["roundsWon"]["allies"] == maps\mp\_utility::getWatchedDvar( "winlimit" ) - 1 && game["roundsWon"]["axis"] == maps\mp\_utility::getWatchedDvar( "winlimit" ) - 1 )
    {
        aheadTeam = getBetterTeam();

        if ( aheadTeam != game["defenders"] )
            game["switchedsides"] = !game["switchedsides"];
        else
            level.halftimeSubCaption = "";

        level.halftimeType = "overtime";
    }
    else
    {
        level.halftimeType = "halftime";
        game["switchedsides"] = !game["switchedsides"];
    }
}

checkRoundSwitch()
{
    if ( !level.teamBased )
        return 0;

    if ( !isdefined( level.roundSwitch ) || !level.roundSwitch )
        return 0;

    if ( game["roundsPlayed"] % level.roundSwitch == 0 )
    {
        onRoundSwitch();
        return 1;
    }

    return 0;
}

timeUntilRoundEnd()
{
    if ( level.gameEnded )
    {
        timePassed = ( gettime() - level.gameEndTime ) / 1000;
        timeRemaining = level.postRoundTime - timePassed;

        if ( timeRemaining < 0 )
            return 0;

        return timeRemaining;
    }

    if ( maps\mp\_utility::getTimeLimit() <= 0 )
        return undefined;

    if ( !isdefined( level.startTime ) )
        return undefined;

    tl = maps\mp\_utility::getTimeLimit();
    timePassed = ( gettime() - level.startTime ) / 1000;
    timeRemaining = maps\mp\_utility::getTimeLimit() * 60 - timePassed;

    if ( isdefined( level.timePaused ) )
        timeRemaining += level.timePaused;

    return timeRemaining + level.postRoundTime;
}

freeGameplayHudElems()
{
    if ( isdefined( self.perkicon ) )
    {
        if ( isdefined( self.perkicon[0] ) )
        {
            self.perkicon[0] maps\mp\gametypes\_hud_util::destroyElem();
            self.perkname[0] maps\mp\gametypes\_hud_util::destroyElem();
        }

        if ( isdefined( self.perkicon[1] ) )
        {
            self.perkicon[1] maps\mp\gametypes\_hud_util::destroyElem();
            self.perkname[1] maps\mp\gametypes\_hud_util::destroyElem();
        }

        if ( isdefined( self.perkicon[2] ) )
        {
            self.perkicon[2] maps\mp\gametypes\_hud_util::destroyElem();
            self.perkname[2] maps\mp\gametypes\_hud_util::destroyElem();
        }
    }

    self notify( "perks_hidden" );
    self.lowerMessage maps\mp\gametypes\_hud_util::destroyElem();
    self.lowerTimer maps\mp\gametypes\_hud_util::destroyElem();

    if ( isdefined( self.proxBar ) )
        self.proxBar maps\mp\gametypes\_hud_util::destroyElem();

    if ( isdefined( self.proxBarText ) )
        self.proxBarText maps\mp\gametypes\_hud_util::destroyElem();
}

getHostPlayer()
{
    players = getentarray( "player", "classname" );

    for ( index = 0; index < players.size; index++ )
    {
        if ( players[index] ishost() )
            return players[index];
    }
}

hostIdledOut()
{
    hostPlayer = getHostPlayer();

    if ( isdefined( hostPlayer ) && !hostPlayer.hasSpawned && !isdefined( hostPlayer.selectedClass ) )
        return 1;

    return 0;
}

roundEndWait( defaultDelay, matchBonus )
{
    notifiesDone = 0;

    while ( !notifiesDone )
    {
        players = level.players;
        notifiesDone = 1;

        foreach ( player in players )
        {
            if ( !isdefined( player.doingSplash ) )
                continue;

            if ( !player maps\mp\gametypes\_hud_message::isDoingSplash() )
                continue;

            notifiesDone = 0;
        }

        wait 0.5;
    }

    if ( !matchBonus )
    {
        wait(defaultDelay);
        level notify( "round_end_finished" );
        return;
    }

    wait(defaultDelay / 2);
    level notify( "give_match_bonus" );
    wait(defaultDelay / 2);
    notifiesDone = 0;

    while ( !notifiesDone )
    {
        players = level.players;
        notifiesDone = 1;

        foreach ( player in players )
        {
            if ( !isdefined( player.doingSplash ) )
                continue;

            if ( !player maps\mp\gametypes\_hud_message::isDoingSplash() )
                continue;

            notifiesDone = 0;
        }

        wait 0.5;
    }

    level notify( "round_end_finished" );
}

roundEndDoF( time )
{
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

Callback_StartGameType()
{
    maps\mp\_load::main();
    maps\mp\_utility::levelFlagInit( "round_over", 0 );
    maps\mp\_utility::levelFlagInit( "game_over", 0 );
    maps\mp\_utility::levelFlagInit( "block_notifies", 0 );
    level.prematchPeriod = 0;
    level.prematchPeriodEnd = 0;
    level.postGameNotifies = 0;
    level.intermission = 0;
    makedvarserverinfo( "cg_thirdPersonAngle", 356 );
    makedvarserverinfo( "scr_gameended", 0 );

    if ( !isdefined( game["gamestarted"] ) )
    {
        game["clientid"] = 0;
        alliesCharSet = getmapcustom( "allieschar" );

        if ( !isdefined( alliesCharSet ) || alliesCharSet == "" )
        {
            if ( !isdefined( game["allies"] ) )
                alliesCharSet = "sas_urban";
            else
                alliesCharSet = game["allies"];
        }

        axisCharSet = getmapcustom( "axischar" );

        if ( !isdefined( axisCharSet ) || axisCharSet == "" )
        {
            if ( !isdefined( game["axis"] ) )
                axisCharSet = "opforce_henchmen";
            else
                axisCharSet = game["axis"];
        }

        game["allies"] = alliesCharSet;
        game["axis"] = axisCharSet;

        if ( !isdefined( game["attackers"] ) || !isdefined( game["defenders"] ) )
            thread common_scripts\utility::error( "No attackers or defenders team defined in level .gsc." );

        if ( !isdefined( game["attackers"] ) )
            game["attackers"] = "allies";

        if ( !isdefined( game["defenders"] ) )
            game["defenders"] = "axis";

        if ( !isdefined( game["state"] ) )
            game["state"] = "playing";

        precachestatusicon( "hud_status_dead" );
        precachestatusicon( "hud_status_connecting" );
        precachestring( &"MPUI_REVIVING" );
        precachestring( &"MPUI_BEING_REVIVED" );
        precacherumble( "damage_heavy" );
        precacheshader( "white" );
        precacheshader( "black" );
        game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";

        if ( level.teamBased )
        {
            game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
            game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
        }
        else
        {
            game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_MORE_PLAYERS";
            game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
        }

        game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
        game["strings"]["match_resuming_in"] = &"MP_MATCH_RESUMING_IN";
        game["strings"]["waiting_for_players"] = &"MP_WAITING_FOR_PLAYERS";
        game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
        game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
        game["strings"]["waiting_to_safespawn"] = &"MP_WAITING_TO_SAFESPAWN";
        game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
        game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";
        game["strings"]["last_stand"] = &"MPUI_LAST_STAND";
        game["strings"]["final_stand"] = &"MPUI_FINAL_STAND";
        game["strings"]["c4_death"] = &"MPUI_C4_DEATH";
        game["strings"]["cowards_way"] = &"PLATFORM_COWARDS_WAY_OUT";
        game["strings"]["tie"] = &"MP_MATCH_TIE";
        game["strings"]["round_draw"] = &"MP_ROUND_DRAW";
        game["strings"]["grabbed_flag"] = &"MP_GRABBED_FLAG_FIRST";
        game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
        game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
        game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
        game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
        game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";
        game["strings"]["S.A.S Win"] = &"SAS_WIN";
        game["strings"]["Spetsnaz Win"] = &"SPETSNAZ_WIN";
        game["colors"]["blue"] = ( 0.25, 0.25, 0.75 );
        game["colors"]["red"] = ( 0.75, 0.25, 0.25 );
        game["colors"]["white"] = ( 1, 1, 1 );
        game["colors"]["black"] = ( 0, 0, 0 );
        game["colors"]["green"] = ( 0.25, 0.75, 0.25 );
        game["colors"]["yellow"] = ( 0.65, 0.65, 0 );
        game["colors"]["orange"] = ( 1, 0.45, 0 );
        game["strings"]["allies_eliminated"] = maps\mp\gametypes\_teams::getTeamEliminatedString( "allies" );
        game["strings"]["allies_forfeited"] = maps\mp\gametypes\_teams::getTeamForfeitedString( "allies" );
        game["strings"]["allies_name"] = maps\mp\gametypes\_teams::getTeamName( "allies" );
        game["icons"]["allies"] = maps\mp\gametypes\_teams::getTeamIcon( "allies" );
        game["colors"]["allies"] = maps\mp\gametypes\_teams::getTeamColor( "allies" );
        game["strings"]["axis_eliminated"] = maps\mp\gametypes\_teams::getTeamEliminatedString( "axis" );
        game["strings"]["axis_forfeited"] = maps\mp\gametypes\_teams::getTeamForfeitedString( "axis" );
        game["strings"]["axis_name"] = maps\mp\gametypes\_teams::getTeamName( "axis" );
        game["icons"]["axis"] = maps\mp\gametypes\_teams::getTeamIcon( "axis" );
        game["colors"]["axis"] = maps\mp\gametypes\_teams::getTeamColor( "axis" );

        if ( game["colors"]["allies"] == ( 0, 0, 0 ) )
            game["colors"]["allies"] = ( 0.5, 0.5, 0.5 );

        if ( game["colors"]["axis"] == ( 0, 0, 0 ) )
            game["colors"]["axis"] = ( 0.5, 0.5, 0.5 );

        [[ level.onPrecacheGameType ]]();

        if ( level.console )
        {
            if ( !level.splitscreen )
                level.prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "graceperiod" );
        }
        else
        {
            level.prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "playerwaittime" );
            level.prematchPeriodEnd = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );
        }
    }
    else if ( level.console )
    {
        if ( !level.splitscreen )
            level.prematchPeriod = 5;
    }
    else
    {
        level.prematchPeriod = 5;
        level.prematchPeriodEnd = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );
    }

    if ( !isdefined( game["status"] ) )
        game["status"] = "normal";

    makedvarserverinfo( "ui_overtime", game["status"] == "overtime" );

    if ( game["status"] != "overtime" && game["status"] != "halftime" )
    {
        game["teamScores"]["allies"] = 0;
        game["teamScores"]["axis"] = 0;
    }

    if ( !isdefined( game["timePassed"] ) )
        game["timePassed"] = 0;

    if ( !isdefined( game["roundsPlayed"] ) )
        game["roundsPlayed"] = 0;

    if ( !isdefined( game["roundsWon"] ) )
        game["roundsWon"] = [];

    if ( level.teamBased )
    {
        if ( !isdefined( game["roundsWon"]["axis"] ) )
            game["roundsWon"]["axis"] = 0;

        if ( !isdefined( game["roundsWon"]["allies"] ) )
            game["roundsWon"]["allies"] = 0;
    }

    level.gameEnded = 0;
    level.forcedEnd = 0;
    level.hostForcedEnd = 0;
    level.hardcoreMode = getdvarint( "g_hardcore" );

    if ( level.hardcoreMode )
        logstring( "game mode: hardcore" );

    level.dieHardMode = getdvarint( "scr_diehard" );

    if ( !level.teamBased )
        level.dieHardMode = 0;

    if ( level.dieHardMode )
        logstring( "game mode: diehard" );

    level.killstreakRewards = getdvarint( "scr_game_hardpoints" );
    level.useStartSpawn = 1;
    level.objectivePointsMod = 1;

    if ( maps\mp\_utility::matchMakingGame() )
        level.maxAllowedTeamKills = 2;
    else
        level.maxAllowedTeamKills = -1;

    thread maps\mp\gametypes\_persistence::init();
    thread maps\mp\gametypes\_menus::init();
    thread maps\mp\gametypes\_hud::init();
    thread maps\mp\gametypes\_serversettings::init();
    thread maps\mp\gametypes\_teams::init();
    thread maps\mp\gametypes\_weapons::init();
    thread maps\mp\gametypes\_killcam::init();
    thread maps\mp\gametypes\_shellshock::init();
    thread maps\mp\gametypes\_deathicons::init();
    thread maps\mp\gametypes\_damagefeedback::init();
    thread maps\mp\gametypes\_healthoverlay::init();
    thread maps\mp\gametypes\_spectating::init();
    thread maps\mp\gametypes\_objpoints::init();
    thread maps\mp\gametypes\_gameobjects::init();
    thread maps\mp\gametypes\_spawnlogic::init();
    thread maps\mp\gametypes\_battlechatter_mp::init();
    thread maps\mp\gametypes\_music_and_dialog::init();
    thread maps\mp\_matchdata::init();
    thread maps\mp\_awards::init();
    thread maps\mp\_skill::init();
    thread maps\mp\_areas::init();
    thread maps\mp\killstreaks\_killstreaks::init();
    thread maps\mp\perks\_perks::init();
    thread maps\mp\_events::init();
    thread maps\mp\_defcon::init();
    thread maps\mp\_matchevents::init();
    thread maps\mp\gametypes\_damage::initFinalKillCam();

    if ( level.teamBased )
        thread maps\mp\gametypes\_friendicons::init();

    thread maps\mp\gametypes\_hud_message::init();

    if ( !level.console )
        thread maps\mp\gametypes\_quickmessages::init();

    foreach ( locString in game["strings"] )
        precachestring( locString );

    foreach ( icon in game["icons"] )
        precacheshader( icon );

    game["gamestarted"] = 1;
    level.maxPlayerCount = 0;
    level.waveDelay["allies"] = 0;
    level.waveDelay["axis"] = 0;
    level.lastWave["allies"] = 0;
    level.lastWave["axis"] = 0;
    level.wavePlayerSpawnIndex["allies"] = 0;
    level.wavePlayerSpawnIndex["axis"] = 0;
    level.alivePlayers["allies"] = [];
    level.alivePlayers["axis"] = [];
    level.activePlayers = [];
    makedvarserverinfo( "ui_scorelimit", 0 );
    makedvarserverinfo( "ui_allow_classchange", getdvar( "ui_allow_classchange" ) );
    makedvarserverinfo( "ui_allow_teamchange", 1 );
    setdvar( "ui_allow_teamchange", 1 );

    if ( maps\mp\_utility::getGametypeNumLives() )
        setdvar( "g_deadChat", 0 );
    else
        setdvar( "g_deadChat", 1 );

    waveDelay = getdvarint( "scr_" + level.gameType + "_waverespawndelay" );

    if ( waveDelay )
    {
        level.waveDelay["allies"] = waveDelay;
        level.waveDelay["axis"] = waveDelay;
        level.lastWave["allies"] = 0;
        level.lastWave["axis"] = 0;
        level thread waveSpawnTimer();
    }

    maps\mp\_utility::gameFlagInit( "prematch_done", 0 );
    level.gracePeriod = 15;
    level.inGracePeriod = level.gracePeriod;
    maps\mp\_utility::gameFlagInit( "graceperiod_done", 0 );
    level.roundEndDelay = 4;
    level.halftimeRoundEndDelay = 4;
    level.noRagdollEnts = getentarray( "noragdoll", "targetname" );

    if ( level.teamBased )
    {
        maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
        maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );
    }
    else
        thread maps\mp\gametypes\_gamescore::initialDMScoreUpdate();

    thread updateUIScoreLimit();
    level notify( "update_scorelimit" );
    [[ level.onStartGameType ]]();
    thread startGame();
    level thread maps\mp\_utility::updateWatchedDvars();
    level thread timeLimitThread();
    level thread maps\mp\gametypes\_damage::doFinalKillcam();
}

Callback_CodeEndGame()
{
    endparty();

    if ( !level.gameEnded )
        level thread forceEnd();
}

timeLimitThread()
{
    level endon( "game_ended" );
    prevTimePassed = maps\mp\_utility::getTimePassed();

    while ( game["state"] == "playing" )
    {
        thread checkTimeLimit( prevTimePassed );
        prevTimePassed = maps\mp\_utility::getTimePassed();

        if ( isdefined( level.startTime ) )
        {
            if ( getTimeRemaining() < 3000 )
            {
                wait 0.1;
                continue;
            }
        }

        wait 1;
    }
}

updateUIScoreLimit()
{
    for (;;)
    {
        level common_scripts\utility::waittill_either( "update_scorelimit", "update_winlimit" );

        if ( !maps\mp\_utility::isRoundBased() || !maps\mp\_utility::isObjectiveBased() )
        {
            setdvar( "ui_scorelimit", maps\mp\_utility::getWatchedDvar( "scorelimit" ) );
            thread checkScoreLimit();
            continue;
        }

        setdvar( "ui_scorelimit", maps\mp\_utility::getWatchedDvar( "winlimit" ) );
    }
}

playTickingSound()
{
    self endon( "death" );
    self endon( "stop_ticking" );
    level endon( "game_ended" );
    time = level.bombTimer;

    for (;;)
    {
        self playsound( "ui_mp_suitcasebomb_timer" );

        if ( time > 10 )
        {
            time -= 1;
            wait 1;
        }
        else if ( time > 4 )
        {
            time -= 0.5;
            wait 0.5;
        }
        else if ( time > 1 )
        {
            time -= 0.4;
            wait 0.4;
        }
        else
        {
            time -= 0.3;
            wait 0.3;
        }

        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
    }
}

stopTickingSound()
{
    self notify( "stop_ticking" );
}

timeLimitClock()
{
    level endon( "game_ended" );
    wait 0.05;
    clockObject = spawn( "script_origin", ( 0, 0, 0 ) );
    clockObject hide();

    while ( game["state"] == "playing" )
    {
        if ( !level.timerStopped && maps\mp\_utility::getTimeLimit() )
        {
            timeLeft = getTimeRemaining() / 1000;
            timeLeftInt = int( timeLeft + 0.5 );

            if ( maps\mp\_utility::getHalfTime() && timeLeftInt > maps\mp\_utility::getTimeLimit() * 60 * 0.5 )
                timeLeftInt -= int( maps\mp\_utility::getTimeLimit() * 60 * 0.5 );

            if ( timeLeftInt >= 30 && timeLeftInt <= 60 )
                level notify( "match_ending_soon",  "time"  );

            if ( timeLeftInt <= 10 || timeLeftInt <= 30 && timeLeftInt % 2 == 0 )
            {
                level notify( "match_ending_very_soon" );

                if ( timeLeftInt == 0 )
                    break;

                clockObject playsound( "ui_mp_timer_countdown" );
            }

            if ( timeLeft - floor( timeLeft ) >= 0.05 )
                wait(timeLeft - floor( timeLeft ));
        }

        wait 1.0;
    }
}

gameTimer()
{
    level endon( "game_ended" );
    level waittill( "prematch_over" );
    level.startTime = gettime();
    level.discardTime = 0;

    if ( isdefined( game["roundMillisecondsAlreadyPassed"] ) )
    {
        level.startTime = level.startTime - game["roundMillisecondsAlreadyPassed"];
        game["roundMillisecondsAlreadyPassed"] = undefined;
    }

    prevtime = gettime();

    while ( game["state"] == "playing" )
    {
        if ( !level.timerStopped )
            game["timePassed"] += gettime() - prevtime;

        prevtime = gettime();
        wait 1.0;
    }
}

UpdateTimerPausedness()
{
    shouldBeStopped = level.timerStoppedForGameMode || isdefined( level.hostMigrationTimer );

    if ( !maps\mp\_utility::gameFlag( "prematch_done" ) )
        shouldBeStopped = 0;

    if ( !level.timerStopped && shouldBeStopped )
    {
        level.timerStopped = 1;
        level.timerPauseTime = gettime();
    }
    else if ( level.timerStopped && !shouldBeStopped )
    {
        level.timerStopped = 0;
        level.discardTime = level.discardTime + gettime() - level.timerPauseTime;
    }
}

pauseTimer()
{
    level.timerStoppedForGameMode = 1;
    UpdateTimerPausedness();
}

resumeTimer()
{
    level.timerStoppedForGameMode = 0;
    UpdateTimerPausedness();
}

startGame()
{
    thread gameTimer();
    level.timerStopped = 0;
    level.timerStoppedForGameMode = 0;
    thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();
    prematchPeriod();
    maps\mp\_utility::gameFlagSet( "prematch_done" );
    level notify( "prematch_over" );
    UpdateTimerPausedness();
    thread timeLimitClock();
    thread gracePeriod();
    thread maps\mp\gametypes\_missions::roundBegin();
}

waveSpawnTimer()
{
    level endon( "game_ended" );

    while ( game["state"] == "playing" )
    {
        time = gettime();

        if ( time - level.lastWave["allies"] > level.waveDelay["allies"] * 1000 )
        {
            level notify( "wave_respawn_allies" );
            level.lastWave["allies"] = time;
            level.wavePlayerSpawnIndex["allies"] = 0;
        }

        if ( time - level.lastWave["axis"] > level.waveDelay["axis"] * 1000 )
        {
            level notify( "wave_respawn_axis" );
            level.lastWave["axis"] = time;
            level.wavePlayerSpawnIndex["axis"] = 0;
        }

        wait 0.05;
    }
}

getBetterTeam()
{
    kills["allies"] = 0;
    kills["axis"] = 0;
    deaths["allies"] = 0;
    deaths["axis"] = 0;

    foreach ( player in level.players )
    {
        team = player.pers["team"];

        if ( isdefined( team ) && ( team == "allies" || team == "axis" ) )
        {
            kills[team] += player.kills;
            deaths[team] += player.deaths;
        }
    }

    if ( kills["allies"] > kills["axis"] )
        return "allies";
    else if ( kills["axis"] > kills["allies"] )
        return "axis";

    if ( deaths["allies"] < deaths["axis"] )
        return "allies";
    else if ( deaths["axis"] < deaths["allies"] )
        return "axis";

    if ( randomint( 2 ) == 0 )
        return "allies";

    return "axis";
}

rankedMatchUpdates( winner )
{
    if ( maps\mp\_utility::matchMakingGame() )
    {
        setXenonRanks();

        if ( hostIdledOut() )
        {
            level.hostForcedEnd = 1;
            logstring( "host idled out" );
            endlobby();
        }

        updateMatchBonusScores( winner );
    }

    updateWinLossStats( winner );
}

displayRoundEnd( winner, endReasonText )
{
    foreach ( player in level.players )
    {
        if ( isdefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
            continue;

        if ( level.teamBased )
        {
            player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, 1, endReasonText );
            continue;
        }

        player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
    }

    if ( !maps\mp\_utility::wasLastRound() )
        level notify( "round_win", winner );

    if ( maps\mp\_utility::wasLastRound() )
        roundEndWait( level.roundEndDelay, 0 );
    else
        roundEndWait( level.roundEndDelay, 1 );
}

displayGameEnd( winner, endReasonText )
{
    foreach ( player in level.players )
    {
        if ( isdefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
            continue;

        if ( level.teamBased )
        {
            player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, 0, endReasonText );
            continue;
        }

        player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
    }

    level notify( "game_win", winner );
    roundEndWait( level.postRoundTime, 1 );
}

displayRoundSwitch()
{
    switchType = level.halftimeType;

    if ( switchType == "halftime" )
    {
        if ( maps\mp\_utility::getWatchedDvar( "roundlimit" ) )
        {
            if ( game["roundsPlayed"] * 2 == maps\mp\_utility::getWatchedDvar( "roundlimit" ) )
                switchType = "halftime";
            else
                switchType = "intermission";
        }
        else if ( maps\mp\_utility::getWatchedDvar( "winlimit" ) )
        {
            if ( game["roundsPlayed"] == maps\mp\_utility::getWatchedDvar( "winlimit" ) - 1 )
                switchType = "halftime";
            else
                switchType = "intermission";
        }
        else
            switchType = "intermission";
    }

    level notify( "round_switch",  switchType );

    foreach ( player in level.players )
    {
        if ( isdefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
            continue;

        player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, 1, level.halftimeSubCaption );
    }

    roundEndWait( level.halftimeRoundEndDelay, 0 );
}

endGameOvertime( winner, endReasonText )
{
    visionsetnaked( "mpOutro", 0.5 );
    setdvar( "scr_gameended", 3 );

    foreach ( player in level.players )
    {
        player thread freezePlayerForRoundEnd( 0 );
        player thread roundEndDoF( 4.0 );
        player freeGameplayHudElems();
        player setclientdvars( "cg_everyoneHearsEveryone", 1 );
        player setclientdvars( "cg_drawSpectatorMessages", 0, "g_compassShowEnemies", 0 );

        if ( player.pers["team"] == "spectator" )
            player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
    }

    level notify( "round_switch",  "overtime"  );

    foreach ( player in level.players )
    {
        if ( isdefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
            continue;

        if ( level.teamBased )
        {
            player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, 0, endReasonText );
            continue;
        }

        player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
    }

    roundEndWait( level.roundEndDelay, 0 );

    if ( isdefined( level.finalKillCam_winner ) )
    {
        level.finalKillCam_timeGameEnded[level.finalKillCam_winner] = maps\mp\_utility::getSecondsPassed();

        foreach ( player in level.players )
            player notify( "reset_outcome" );

        level notify( "game_cleanup" );
        waittillFinalKillcamDone();
    }

    game["status"] = "overtime";
    level notify( "restarting" );
    game["state"] = "playing";
    map_restart( 1 );
}

endGameHalfTime()
{
    visionsetnaked( "mpOutro", 0.5 );
    setdvar( "scr_gameended", 2 );
    game["switchedsides"] = !game["switchedsides"];

    foreach ( player in level.players )
    {
        player thread freezePlayerForRoundEnd( 0 );
        player thread roundEndDoF( 4.0 );
        player freeGameplayHudElems();
        player setclientdvars( "cg_everyoneHearsEveryone", 1 );
        player setclientdvars( "cg_drawSpectatorMessages", 0, "g_compassShowEnemies", 0 );

        if ( player.pers["team"] == "spectator" )
            player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
    }

    foreach ( player in level.players )
        player.pers["stats"] = player.stats;

    level notify( "round_switch",  "halftime"  );

    foreach ( player in level.players )
    {
        if ( isdefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
            continue;

        player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( "halftime", 1, level.halftimeSubCaption );
    }

    roundEndWait( level.roundEndDelay, 0 );

    if ( isdefined( level.finalKillCam_winner ) )
    {
        level.finalKillCam_timeGameEnded[level.finalKillCam_winner] = maps\mp\_utility::getSecondsPassed();

        foreach ( player in level.players )
            player notify( "reset_outcome" );

        level notify( "game_cleanup" );
        waittillFinalKillcamDone();
    }

    game["status"] = "halftime";
    level notify( "restarting" );
    game["state"] = "playing";
    map_restart( 1 );
}

endGame( winner, endReasonText, nukeDetonated )
{
    if ( !isdefined( nukeDetonated ) )
        nukeDetonated = 0;

    if ( game["state"] == "postgame" || level.gameEnded && ( !isdefined( level.gtnw ) || !level.gtnw ) )
        return;

    game["state"] = "postgame";
    level.gameEndTime = gettime();
    level.gameEnded = 1;
    level.inGracePeriod = 0;
    level notify( "game_ended",  winner  );
    maps\mp\_utility::levelFlagSet( "game_over" );
    maps\mp\_utility::levelFlagSet( "block_notifies" );
    common_scripts\utility::waitframe();
    setgameendtime( 0 );
    gameLength = getmatchdata( "gameLength" );
    gameLength += int( maps\mp\_utility::getSecondsPassed() );
    setmatchdata( "gameLength", gameLength );
    maps\mp\gametypes\_playerlogic::printPredictedSpawnpointCorrectness();

    if ( isdefined( winner ) && isstring( winner ) && winner == "overtime" )
    {
        level.finalKillCam_winner = "none";
        endGameOvertime( winner, endReasonText );
        return;
    }

    if ( isdefined( winner ) && isstring( winner ) && winner == "halftime" )
    {
        level.finalKillCam_winner = "none";
        endGameHalfTime();
        return;
    }

    if ( isdefined( level.finalKillCam_winner ) )
        level.finalKillCam_timeGameEnded[level.finalKillCam_winner] = maps\mp\_utility::getSecondsPassed();

    game["roundsPlayed"]++;

    if ( level.teamBased )
    {
        if ( winner == "axis" || winner == "allies" )
            game["roundsWon"][winner]++;

        maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
        maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );
    }
    else if ( isdefined( winner ) && isplayer( winner ) )
        game["roundsWon"][winner.guid]++;

    maps\mp\gametypes\_gamescore::updatePlacement();
    rankedMatchUpdates( winner );

    foreach ( player in level.players )
    {
        player setclientdvar( "ui_opensummary", 1 );

        if ( maps\mp\_utility::wasOnlyRound() || maps\mp\_utility::wasLastRound() )
            player maps\mp\killstreaks\_killstreaks::clearKillstreaks();
    }

    setdvar( "g_deadChat", 1 );
    setdvar( "ui_allow_teamchange", 0 );

    foreach ( player in level.players )
    {
        player thread freezePlayerForRoundEnd( 1.0 );
        player thread roundEndDoF( 4.0 );
        player freeGameplayHudElems();
        player setclientdvars( "cg_everyoneHearsEveryone", 1 );
        player setclientdvars( "cg_drawSpectatorMessages", 0, "g_compassShowEnemies", 0, "cg_fovScale", 1 );

        if ( player.pers["team"] == "spectator" )
            player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
    }

    if ( !nukeDetonated )
        visionsetnaked( "mpOutro", 0.5 );

    if ( !maps\mp\_utility::wasOnlyRound() && !nukeDetonated )
    {
        setdvar( "scr_gameended", 2 );
        displayRoundEnd( winner, endReasonText );

        if ( isdefined( level.finalKillCam_winner ) )
        {
            foreach ( player in level.players )
                player notify( "reset_outcome" );

            level notify( "game_cleanup" );
            waittillFinalKillcamDone();
        }

        if ( !maps\mp\_utility::wasLastRound() )
        {
            maps\mp\_utility::levelFlagClear( "block_notifies" );

            if ( checkRoundSwitch() )
                displayRoundSwitch();

            foreach ( player in level.players )
                player.pers["stats"] = player.stats;

            level notify( "restarting" );
            game["state"] = "playing";
            map_restart( 1 );
            return;
        }

        if ( !level.forcedEnd )
            endReasonText = updateEndReasonText( winner );
    }

    if ( endReasonText == game["strings"]["time_limit_reached"] )
        setdvar( "scr_gameended", 3 );
    else
    {
        switch ( level.gameType )
        {
            case "koth":
            case "sab":
            case "sd":
            case "dom":
            case "ctf":
            case "conf":
                setdvar( "scr_gameended", 4 );
                break;
            default:
                setdvar( "scr_gameended", 1 );
                break;
        }
    }

    if ( !isdefined( game["clientMatchDataDef"] ) )
    {
        game["clientMatchDataDef"] = "mp/clientmatchdata.def";
        setclientmatchdatadef( game["clientMatchDataDef"] );
    }

    maps\mp\gametypes\_missions::roundEnd( winner );
    displayGameEnd( winner, endReasonText );

    if ( isdefined( level.finalKillCam_winner ) && maps\mp\_utility::wasOnlyRound() )
    {
        foreach ( player in level.players )
            player notify( "reset_outcome" );

        level notify( "game_cleanup" );
        waittillFinalKillcamDone();
    }

    maps\mp\_utility::levelFlagClear( "block_notifies" );
    level.intermission = 1;
    level notify( "spawning_intermission" );

    foreach ( player in level.players )
    {
        player closepopupmenu();
        player closeingamemenu();
        player notify( "reset_outcome" );
        player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
    }

    processLobbyData();
    wait 1.0;
    checkForPersonalBests();

    if ( level.teamBased )
    {
        if ( winner == "axis" || winner == "allies" )
            setmatchdata( "victor", winner );
        else
            setmatchdata( "victor", "none" );

        setmatchdata( "alliesScore", getteamscore( "allies" ) );
        setmatchdata( "axisScore", getteamscore( "axis" ) );
    }
    else
        setmatchdata( "victor", "none" );

    setmatchdata( "host", level.sendMatchData );
    sendmatchdata();

    foreach ( player in level.players )
        player.pers["stats"] = player.stats;

    if ( !nukeDetonated && !level.postGameNotifies )
    {
        if ( !maps\mp\_utility::wasOnlyRound() )
            wait 6.0;
        else
            wait 3.0;
    }
    else
        wait(min( 10.0, 4.0 + level.postGameNotifies ));

    level notify( "exitLevel_called" );
    exitlevel( 0 );
}

updateEndReasonText( winner )
{
    if ( !level.teamBased )
        return 1;

    if ( maps\mp\_utility::hitRoundLimit() )
        return &"MP_ROUND_LIMIT_REACHED";

    if ( maps\mp\_utility::hitWinLimit() )
        return &"MP_SCORE_LIMIT_REACHED";

    if ( winner == "axis" )
        return &"SPETSNAZ_WIN";
    else
        return &"SAS_WIN";
}

estimatedTimeTillScoreLimit( team )
{
    scorePerMinute = getScorePerMinute( team );
    scoreRemaining = getScorePerRemaining( team );
    estimatedTimeLeft = 999999;

    if ( scorePerMinute )
        estimatedTimeLeft = scoreRemaining / scorePerMinute;

    return estimatedTimeLeft;
}

getScorePerMinute( team )
{
    scoreLimit = maps\mp\_utility::getWatchedDvar( "scorelimit" );
    timeLimit = maps\mp\_utility::getTimeLimit();
    minutesPassed = maps\mp\_utility::getTimePassed() / 60000 + 0.0001;

    if ( isplayer( self ) )
        scorePerMinute = self.score / minutesPassed;
    else
        scorePerMinute = getteamscore( team ) / minutesPassed;

    return scorePerMinute;
}

getScorePerRemaining( team )
{
    scoreLimit = maps\mp\_utility::getWatchedDvar( "scorelimit" );

    if ( isplayer( self ) )
        scoreRemaining = scoreLimit - self.score;
    else
        scoreRemaining = scoreLimit - getteamscore( team );

    return scoreRemaining;
}

giveLastOnTeamWarning()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    maps\mp\_utility::waitTillRecoveredHealth( 3 );
    otherTeam = maps\mp\_utility::getOtherTeam( self.pers["team"] );
    thread maps\mp\_utility::teamPlayerCardSplash( "callout_lastteammemberalive", self, self.pers["team"] );
    thread maps\mp\_utility::teamPlayerCardSplash( "callout_lastenemyalive", self, otherTeam );
    level notify( "last_alive",  self  );
}

processLobbyData()
{
    curPlayer = 0;

    foreach ( player in level.players )
    {
        if ( !isdefined( player ) )
            continue;

        player.clientMatchDataId = curPlayer;
        curPlayer++;

        if ( level.ps3 && player.name.size > level.MaxNameLength )
        {
            playerName = "";

            for ( i = 0; i < level.MaxNameLength - 3; i++ )
                playerName += player.name[i];

            playerName += "...";
        }
        else
            playerName = player.name;

        setclientmatchdata( "players", player.clientMatchDataId, "xuid", playerName );
    }

    maps\mp\_awards::assignAwards();
    maps\mp\gametypes\_scoreboard::processLobbyScoreboards();
    sendclientmatchdata();
}

trackLeaderBoardDeathStats( sWeapon, sMeansOfDeath )
{
    thread threadedSetWeaponStatByName( sWeapon, 1, "deaths" );
}

trackAttackerLeaderBoardDeathStats( sWeapon, sMeansOfDeath )
{
    if ( isdefined( self ) && isplayer( self ) )
    {
        if ( sMeansOfDeath != "MOD_FALLING" )
        {
            if ( sMeansOfDeath == "MOD_MELEE" && !issubstr( sWeapon, "riotshield" ) )
                return;

            thread threadedSetWeaponStatByName( sWeapon, 1, "kills" );
        }

        if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
            thread threadedSetWeaponStatByName( sWeapon, 1, "headShots" );
    }
}

setWeaponStat( name, incValue, statName )
{
    if ( !incValue )
        return;

    weaponClass = maps\mp\_utility::getWeaponClass( name );

    if ( maps\mp\_utility::isKillstreakWeapon( name ) || weaponClass == "killstreak" || weaponClass == "deathstreak" || weaponClass == "other" )
        return;

    if ( maps\mp\_utility::isEnvironmentWeapon( name ) )
        return;

    if ( weaponClass == "weapon_grenade" || weaponClass == "weapon_riot" || weaponClass == "weapon_explosive" )
    {
        weaponName = maps\mp\_utility::strip_suffix( name, "_mp" );
        maps\mp\gametypes\_persistence::incrementWeaponStat( weaponName, statName, incValue );
        maps\mp\_matchdata::logWeaponStat( weaponName, statName, incValue );
        return;
    }

    if ( statName != "deaths" )
        name = self getcurrentweapon();

    if ( maps\mp\_utility::isKillstreakWeapon( name ) || weaponClass == "killstreak" || weaponClass == "deathstreak" || weaponClass == "other" )
        return;

    if ( !isdefined( self.trackingWeaponName ) )
        self.trackingWeaponName = name;

    if ( name != self.trackingWeaponName )
    {
        maps\mp\gametypes\_persistence::updateWeaponBufferedStats();
        self.trackingWeaponName = name;
    }

    switch ( statName )
    {
        case "shots":
            self.trackingWeaponShots++;
            break;
        case "hits":
            self.trackingWeaponHits++;
            break;
        case "headShots":
            self.trackingWeaponHeadShots++;
            self.trackingWeaponHits++;
            break;
        case "kills":
            self.trackingWeaponKills++;
            break;
    }

    if ( statName == "deaths" )
    {
        tmp = name;
        tokens = strtok( name, "_" );
        altAttachment = undefined;

        if ( tokens[0] == "iw5" )
            weaponName = tokens[0] + "_" + tokens[1];
        else if ( tokens[0] == "alt" )
            weaponName = tokens[1] + "_" + tokens[2];
        else
            weaponName = tokens[0];

        if ( !maps\mp\_utility::isCACPrimaryWeapon( weaponName ) && !maps\mp\_utility::isCACSecondaryWeapon( weaponName ) )
            return;

        if ( tokens[0] == "alt" )
        {
            weaponName = tokens[1] + "_" + tokens[2];

            foreach ( token in tokens )
            {
                if ( token == "gl" || token == "gp25" || token == "m320" )
                {
                    altAttachment = "gl";
                    break;
                }

                if ( token == "shotgun" )
                {
                    altAttachment = "shotgun";
                    break;
                }
            }
        }

        if ( isdefined( altAttachment ) && ( altAttachment == "gl" || altAttachment == "shotgun" ) )
        {
            maps\mp\gametypes\_persistence::incrementAttachmentStat( altAttachment, statName, incValue );
            maps\mp\_matchdata::logAttachmentStat( altAttachment, statName, incValue );
            return;
        }

        maps\mp\gametypes\_persistence::incrementWeaponStat( weaponName, statName, incValue );
        maps\mp\_matchdata::logWeaponStat( weaponName, "deaths", incValue );

        if ( tokens[0] != "none" )
        {
            for ( i = 0; i < tokens.size; i++ )
            {
                if ( tokens[i] == "alt" )
                {
                    i += 2;
                    continue;
                }

                if ( tokens[i] == "iw5" )
                {
                    i += 1;
                    continue;
                }

                if ( tokens[i] == "mp" )
                    continue;

                if ( issubstr( tokens[i], "camo" ) )
                    continue;

                if ( issubstr( tokens[i], "scope" ) && !issubstr( tokens[i], "vz" ) )
                    continue;

                if ( issubstr( tokens[i], "scope" ) && issubstr( tokens[i], "vz" ) )
                    tokens[i] = "vzscope";

                tokens[i] = maps\mp\_utility::validateAttachment( tokens[i] );

                if ( i == 0 && ( tokens[i] != "iw5" && tokens[i] != "alt" ) )
                    continue;

                maps\mp\gametypes\_persistence::incrementAttachmentStat( tokens[i], statName, incValue );
                maps\mp\_matchdata::logAttachmentStat( tokens[i], statName, incValue );
            }
        }
    }
}

setInflictorStat( eInflictor, eAttacker, sWeapon )
{
    if ( !isdefined( eAttacker ) )
        return;

    if ( !isdefined( eInflictor ) )
    {
        eAttacker setWeaponStat( sWeapon, 1, "hits" );
        return;
    }

    if ( !isdefined( eInflictor.playerAffectedArray ) )
        eInflictor.playerAffectedArray = [];

    foundNewPlayer = 1;

    for ( i = 0; i < eInflictor.playerAffectedArray.size; i++ )
    {
        if ( eInflictor.playerAffectedArray[i] == self )
        {
            foundNewPlayer = 0;
            break;
        }
    }

    if ( foundNewPlayer )
    {
        eInflictor.playerAffectedArray[eInflictor.playerAffectedArray.size] = self;
        eAttacker setWeaponStat( sWeapon, 1, "hits" );
    }
}

threadedSetWeaponStatByName( name, incValue, statName )
{
    self endon( "disconnect" );
    waittillframeend;
    setWeaponStat( name, incValue, statName );
}

checkForPersonalBests()
{
    foreach ( player in level.players )
    {
        if ( !isdefined( player ) )
            continue;

        if ( player maps\mp\_utility::rankingEnabled() )
        {
            roundKills = player getplayerdata( "round", "kills" );
            roundDeaths = player getplayerdata( "round", "deaths" );
            roundXP = player.pers["summary"]["xp"];
            bestKills = player getplayerdata( "bestKills" );
            mostDeaths = player getplayerdata( "mostDeaths" );
            mostXp = player getplayerdata( "mostXp" );

            if ( roundKills > bestKills )
                player setplayerdata( "bestKills", roundKills );

            if ( roundXP > mostXp )
                player setplayerdata( "mostXp", roundXP );

            if ( roundDeaths > mostDeaths )
                player setplayerdata( "mostDeaths", roundDeaths );

            player checkForBestWeapon();
            player maps\mp\_matchdata::logPlayerXP( roundXP, "totalXp" );
            player maps\mp\_matchdata::logPlayerXP( player.pers["summary"]["score"], "scoreXp" );
            player maps\mp\_matchdata::logPlayerXP( player.pers["summary"]["challenge"], "challengeXp" );
            player maps\mp\_matchdata::logPlayerXP( player.pers["summary"]["match"], "matchXp" );
            player maps\mp\_matchdata::logPlayerXP( player.pers["summary"]["misc"], "miscXp" );
        }

        if ( isdefined( player.pers["confirmed"] ) )
            player maps\mp\_matchdata::logKillsConfirmed();

        if ( isdefined( player.pers["denied"] ) )
            player maps\mp\_matchdata::logKillsDenied();
    }
}

checkForBestWeapon()
{
    baseWeaponList = maps\mp\_matchdata::buildBaseWeaponList();

    for ( i = 0; i < baseWeaponList.size; i++ )
    {
        weaponName = baseWeaponList[i];
        tokens = strtok( weaponName, "_" );

        if ( tokens[0] == "iw5" )
            weaponName = tokens[0] + "_" + tokens[1];

        if ( tokens[0] == "alt" )
            weaponName = tokens[1] + "_" + tokens[2];

        weaponClass = maps\mp\_utility::getWeaponClass( weaponName );

        if ( !maps\mp\_utility::isKillstreakWeapon( weaponName ) && weaponClass != "killstreak" && weaponClass != "deathstreak" && weaponClass != "other" )
        {
            bestWeaponKills = self getplayerdata( "bestWeapon", "kills" );
            weaponKills = getmatchdata( "players", self.clientid, "weaponStats", weaponName, "kills" );

            if ( weaponKills > bestWeaponKills )
            {
                self setplayerdata( "bestWeapon", "kills", weaponKills );
                weaponShots = getmatchdata( "players", self.clientid, "weaponStats", weaponName, "shots" );
                weaponHeadShots = getmatchdata( "players", self.clientid, "weaponStats", weaponName, "headShots" );
                weaponHits = getmatchdata( "players", self.clientid, "weaponStats", weaponName, "hits" );
                weaponDeaths = getmatchdata( "players", self.clientid, "weaponStats", weaponName, "deaths" );
                weaponXP = getmatchdata( "players", self.clientid, "weaponStats", weaponName, "XP" );
                self setplayerdata( "bestWeapon", "shots", weaponShots );
                self setplayerdata( "bestWeapon", "headShots", weaponHeadShots );
                self setplayerdata( "bestWeapon", "hits", weaponHits );
                self setplayerdata( "bestWeapon", "deaths", weaponDeaths );
                self setplayerdata( "bestWeaponXP", weaponXP );
                self setplayerdata( "bestWeaponIndex", i );
            }
        }
    }
}
