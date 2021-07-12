// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    game["music"]["defeat"] = "mp_defeat";
    game["music"]["victory_spectator"] = "mp_defeat";
    game["dialog"]["mission_success"] = "mission_success";
    game["dialog"]["mission_failure"] = "mission_fail";
    game["dialog"]["mission_draw"] = "draw";
    game["dialog"]["round_success"] = "encourage_win";
    game["dialog"]["round_failure"] = "encourage_lost";
    game["dialog"]["round_draw"] = "draw";
    game["dialog"]["last_alive"] = "lastalive";
    game["dialog"]["timesup"] = "timesup";
    game["dialog"]["bomb_defused"] = "bomb_defused";
    game["dialog"]["bomb_planted"] = "bomb_planted";
    level thread onPlayerConnect();
    level thread musicController();
    level thread onGameEnded();
    level thread onRoundSwitch();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player );
        player thread onPlayerSpawned();
        player thread finalKillcamMusic();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );
    self waittill( "spawned_player" );

    if ( !level.splitscreen || level.splitscreen && !isdefined( level.playedStartingMusic ) )
    {
        if ( !self issplitscreenplayer() || self issplitscreenplayerprimary() )
            self playlocalsound( game["music"]["spawn_" + self.team] );

        if ( level.splitscreen )
            level.playedStartingMusic = 1;
    }

    if ( isdefined( game["dialog"]["gametype"] ) && ( !level.splitscreen || self == level.players[0] ) )
    {
        if ( isdefined( game["dialog"]["allies_gametype"] ) && self.team == "allies" )
            maps\mp\_utility::leaderDialogOnPlayer( "allies_gametype" );
        else if ( isdefined( game["dialog"]["axis_gametype"] ) && self.team == "axis" )
            maps\mp\_utility::leaderDialogOnPlayer( "axis_gametype" );
        else if ( !self issplitscreenplayer() || self issplitscreenplayerprimary() )
            maps\mp\_utility::leaderDialogOnPlayer( "gametype" );
    }

    maps\mp\_utility::gameFlagWait( "prematch_done" );

    if ( self.team == game["attackers"] )
    {
        if ( !self issplitscreenplayer() || self issplitscreenplayerprimary() )
            maps\mp\_utility::leaderDialogOnPlayer( "offense_obj", "introboost" );
    }
    else if ( !self issplitscreenplayer() || self issplitscreenplayerprimary() )
        maps\mp\_utility::leaderDialogOnPlayer( "defense_obj", "introboost" );
}

onLastAlive()
{
    level endon( "game_ended" );
    level waittill( "last_alive",  player );

    if ( !isalive( player ) )
        return;

    player maps\mp\_utility::leaderDialogOnPlayer( "last_alive" );
}

onRoundSwitch()
{
    level waittill( "round_switch", switchType );

    switch ( switchType )
    {
        case "halftime":
            foreach ( player in level.players )
            {
                player maps\mp\_utility::leaderDialogOnPlayer( "halftime" );
            }

            break;
        case "overtime":
            foreach ( player in level.players )
            {
                player maps\mp\_utility::leaderDialogOnPlayer( "overtime" );
            }

            break;
        default:
            foreach ( player in level.players )
            {
                player maps\mp\_utility::leaderDialogOnPlayer( "side_switch" );
            }
            break;
    }
}
onGameEnded()
{
    level thread roundWinnerDialog();
    level thread gameWinnerDialog();
    level waittill( "game_win",  winner );

    if ( level.teamBased )
    {
        if ( level.splitscreen )
        {
            if ( winner == "allies" )
            {
                 maps\mp\_utility::playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
            }
            else if ( winner == "axis" )
            {
                maps\mp\_utility::playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
            }
            else
            {
                maps\mp\_utility::playSoundOnPlayers( game["music"]["nuke_music"] );
            }
        }
        else if ( winner == "allies" )
        {
            maps\mp\_utility::playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
            maps\mp\_utility::playSoundOnPlayers( game["music"]["defeat_axis"], "axis" );
        }
        else if ( winner == "axis" )
        {
            maps\mp\_utility::playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
            maps\mp\_utility::playSoundOnPlayers( game["music"]["defeat_allies"], "allies" );
        }
        else
        {
            maps\mp\_utility::playSoundOnPlayers( game["music"]["nuke_music"] );
        }
    }
    else
    {
        foreach ( player in level.players )
        {
            if ( player.pers["team"] != "allies" && player.pers["team"] != "axis" )
            {
                player playlocalsound( game["music"]["nuke_music"] );
                continue;
            }

            if ( isdefined( winner ) && isplayer( winner ) && player == winner )
            {
                player playlocalsound( game["music"]["victory_" + player.pers["team"]] );
                continue;
            }

            if ( !level.splitscreen )
                player playlocalsound( game["music"]["defeat_" + player.pers["team"]] );
        }
    }
}

roundWinnerDialog()
{
    level waittill( "round_win",  winner );
    delay = level.roundEndDelay / 4;

    if ( delay > 0 )
        wait( delay );

    if ( !isdefined( winner ) || isplayer( winner ) )
        return;

    if ( winner == "allies" )
    {
        maps\mp\_utility::leaderDialog( "round_success", "allies" );
        maps\mp\_utility::leaderDialog( "round_failure", "axis" );
    }
    else if ( winner == "axis" )
    {
        maps\mp\_utility::leaderDialog( "round_success", "axis" );
        maps\mp\_utility::leaderDialog( "round_failure", "allies" );
    }
}

gameWinnerDialog()
{
    level waittill( "game_win",  winner );
    delay = level.postRoundTime / 2;

    if ( delay > 0 )
        wait( delay );

    if ( !isdefined( winner ) || isplayer( winner ) )
        return;

    if ( winner == "allies" )
    {
        maps\mp\_utility::leaderDialog( "mission_success", "allies" );
        maps\mp\_utility::leaderDialog( "mission_failure", "axis" );
    }
    else if ( winner == "axis" )
    {
        maps\mp\_utility::leaderDialog( "mission_success", "axis" );
        maps\mp\_utility::leaderDialog( "mission_failure", "allies" );
    }
    else
        maps\mp\_utility::leaderDialog( "mission_draw" );
}

musicController()
{
    level endon( "game_ended" );

    if ( !level.hardcoreMode )
        thread suspenseMusic();

    level waittill( "match_ending_soon", reason );

    if ( maps\mp\_utility::getWatchedDvar( "roundlimit" ) == 1 || game["roundsPlayed"] == maps\mp\_utility::getWatchedDvar( "roundlimit" ) - 1 )
    {
        if ( !level.splitscreen )
        {
            if ( reason == "time" )
            {
                if ( level.teamBased )
                {
                    if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
                    {
                        if ( !level.hardcoreMode )
                        {
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["winning_allies"], "allies" );
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["losing_axis"], "axis" );
                        }

                        maps\mp\_utility::leaderDialog( "winning_time", "allies" );
                        maps\mp\_utility::leaderDialog( "losing_time", "axis" );
                    }
                    else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
                    {
                        if ( !level.hardcoreMode )
                        {
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["winning_axis"], "axis" );
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["losing_allies"], "allies" );
                        }

                        maps\mp\_utility::leaderDialog( "winning_time", "axis" );
                        maps\mp\_utility::leaderDialog( "losing_time", "allies" );
                    }
                }
                else
                {
                    if ( !level.hardcoreMode )
                        maps\mp\_utility::playSoundOnPlayers( game["music"]["losing_time"] );

                    maps\mp\_utility::leaderDialog( "timesup" );
                }
            }
            else if ( reason == "score" )
            {
                if ( level.teamBased )
                {
                    if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
                    {
                        if ( !level.hardcoreMode )
                        {
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["winning_allies"], "allies" );
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["losing_axis"], "axis" );
                        }

                        maps\mp\_utility::leaderDialog( "winning_score", "allies" );
                        maps\mp\_utility::leaderDialog( "losing_score", "axis" );
                    }
                    else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
                    {
                        if ( !level.hardcoreMode )
                        {
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["winning_axis"], "axis" );
                            maps\mp\_utility::playSoundOnPlayers( game["music"]["losing_allies"], "allies" );
                        }

                        maps\mp\_utility::leaderDialog( "winning_score", "axis" );
                        maps\mp\_utility::leaderDialog( "losing_score", "allies" );
                    }
                }
                else
                {
                    winningPlayer = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
                    losingPlayers = maps\mp\gametypes\_gamescore::getLosingPlayers();
                    excludeList[0] = winningPlayer;

                    if ( !level.hardcoreMode )
                    {
                        winningPlayer playlocalsound( game["music"]["winning_" + winningPlayer.pers["team"]] );

                        foreach ( otherPlayer in level.players )
                        {
                            if ( otherPlayer == winningPlayer )
                                continue;

                            otherPlayer playlocalsound( game["music"]["losing_" + otherPlayer.pers["team"]] );
                        }
                    }

                    winningPlayer maps\mp\_utility::leaderDialogOnPlayer( "winning_score" );
                    maps\mp\_utility::leaderDialogOnPlayers( "losing_score", losingPlayers );
                }
            }

            level waittill( "match_ending_very_soon" );
            maps\mp\_utility::leaderDialog( "timesup" );
        }
    }
    else
    {
        if ( !level.hardcoreMode )
            maps\mp\_utility::playSoundOnPlayers( game["music"]["losing_allies"] );

        maps\mp\_utility::leaderDialog( "timesup" );
    }
}

suspenseMusic()
{
    level endon( "game_ended" );
    level endon( "match_ending_soon" );
    numTracks = game["music"]["suspense"].size;
    wait 120;

    for (;;)
    {
        wait(randomfloatrange( 60, 120 ));
        maps\mp\_utility::playSoundOnPlayers( game["music"]["suspense"][randomint( numTracks )] );
    }
}

finalKillcamMusic()
{
    self waittill( "showing_final_killcam" );
}
