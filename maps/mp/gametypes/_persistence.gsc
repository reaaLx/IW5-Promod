// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.persistentDataInfo = [];
    maps\mp\gametypes\_class::init();
    maps\mp\gametypes\_rank::init();
    maps\mp\gametypes\_missions::init();
    maps\mp\gametypes\_playercards::init();

    promod\_promod_util::init();
    promod\_menu::init();

    level thread updateBufferedStats();
    level thread uploadGlobalStatCounters();
}

initBufferedStats()
{
    self.bufferedStats = [];
    self.bufferedStats["totalShots"] = self getplayerdata( "totalShots" );
    self.bufferedStats["accuracy"] = self getplayerdata( "accuracy" );
    self.bufferedStats["misses"] = self getplayerdata( "misses" );
    self.bufferedStats["hits"] = self getplayerdata( "hits" );
    self.bufferedStats["timePlayedAllies"] = self getplayerdata( "timePlayedAllies" );
    self.bufferedStats["timePlayedOpfor"] = self getplayerdata( "timePlayedOpfor" );
    self.bufferedStats["timePlayedOther"] = self getplayerdata( "timePlayedOther" );
    self.bufferedStats["timePlayedTotal"] = self getplayerdata( "timePlayedTotal" );
    self.bufferedChildStats = [];
    self.bufferedChildStats["round"] = [];
    self.bufferedChildStats["round"]["timePlayed"] = self getplayerdata( "round", "timePlayed" );
    self.bufferedChildStats["xpMultiplierTimePlayed"] = [];
    self.bufferedChildStats["xpMultiplierTimePlayed"][0] = self getplayerdata( "xpMultiplierTimePlayed", 0 );
    self.bufferedChildStats["xpMultiplierTimePlayed"][1] = self getplayerdata( "xpMultiplierTimePlayed", 1 );
    self.bufferedChildStats["xpMultiplierTimePlayed"][2] = self getplayerdata( "xpMultiplierTimePlayed", 2 );
    self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"] = [];
    self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][0] = self getplayerdata( "xpMaxMultiplierTimePlayed", 0 );
    self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][1] = self getplayerdata( "xpMaxMultiplierTimePlayed", 1 );
    self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][2] = self getplayerdata( "xpMaxMultiplierTimePlayed", 2 );
    self.bufferedChildStats["challengeXPMultiplierTimePlayed"] = [];
    self.bufferedChildStats["challengeXPMultiplierTimePlayed"][0] = self getplayerdata( "challengeXPMultiplierTimePlayed", 0 );
    self.bufferedChildStatsMax["challengeXPMaxMultiplierTimePlayed"] = [];
    self.bufferedChildStatsMax["challengeXPMaxMultiplierTimePlayed"][0] = self getplayerdata( "challengeXPMaxMultiplierTimePlayed", 0 );
    self.bufferedChildStats["weaponXPMultiplierTimePlayed"] = [];
    self.bufferedChildStats["weaponXPMultiplierTimePlayed"][0] = self getplayerdata( "weaponXPMultiplierTimePlayed", 0 );
    self.bufferedChildStatsMax["weaponXPMaxMultiplierTimePlayed"] = [];
    self.bufferedChildStatsMax["weaponXPMaxMultiplierTimePlayed"][0] = self getplayerdata( "weaponXPMaxMultiplierTimePlayed", 0 );
    self.bufferedStats["prestigeDoubleXp"] = self getplayerdata( "prestigeDoubleXp" );
    self.bufferedStats["prestigeDoubleXpTimePlayed"] = self getplayerdata( "prestigeDoubleXpTimePlayed" );
    self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] = self getplayerdata( "prestigeDoubleXpMaxTimePlayed" );
    self.bufferedStats["prestigeDoubleWeaponXp"] = self getplayerdata( "prestigeDoubleWeaponXp" );
    self.bufferedStats["prestigeDoubleWeaponXpTimePlayed"] = self getplayerdata( "prestigeDoubleWeaponXpTimePlayed" );
    self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] = self getplayerdata( "prestigeDoubleWeaponXpMaxTimePlayed" );
}

statGet( var_0 )
{
    return self getplayerdata( var_0 );
}

statSet( var_0, var_1 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    self setplayerdata( var_0, var_1 );
}

statAdd( var_0, var_1, var_2 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    if ( isdefined( var_2 ) )
    {
        var_3 = self getplayerdata( var_0, var_2 );
        self setplayerdata( var_0, var_2, var_1 + var_3 );
    }
    else
    {
        var_3 = self getplayerdata( var_0 );
        self setplayerdata( var_0, var_1 + var_3 );
    }
}

statGetChild( var_0, var_1 )
{
    return self getplayerdata( var_0, var_1 );
}

statSetChild( var_0, var_1, var_2 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    self setplayerdata( var_0, var_1, var_2 );
}

statAddChild( var_0, var_1, var_2 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    var_3 = self getplayerdata( var_0, var_1 );
    self setplayerdata( var_0, var_1, var_3 + var_2 );
}

statGetChildBuffered( var_0, var_1 )
{
    return self.bufferedChildStats[var_0][var_1];
}

statSetChildBuffered( var_0, var_1, var_2 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    self.bufferedChildStats[var_0][var_1] = var_2;
}

statAddChildBuffered( var_0, var_1, var_2 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    var_3 = statGetChildBuffered( var_0, var_1 );
    statSetChildBuffered( var_0, var_1, var_3 + var_2 );
}

statAddBufferedWithMax( var_0, var_1, var_2 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    var_3 = statGetBuffered( var_0 ) + var_1;

    if ( var_3 > var_2 )
        var_3 = var_2;

    if ( var_3 < statGetBuffered( var_0 ) )
        var_3 = var_2;

    statSetBuffered( var_0, var_3 );
}

statAddChildBufferedWithMax( var_0, var_1, var_2, var_3 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    var_4 = statGetChildBuffered( var_0, var_1 ) + var_2;

    if ( var_4 > var_3 )
        var_4 = var_3;

    if ( var_4 < statGetChildBuffered( var_0, var_1 ) )
        var_4 = var_3;

    statSetChildBuffered( var_0, var_1, var_4 );
}

statGetBuffered( var_0 )
{
    return self.bufferedStats[var_0];
}

statSetBuffered( var_0, var_1 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    self.bufferedStats[var_0] = var_1;
}

statAddBuffered( var_0, var_1 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    var_2 = statGetBuffered( var_0 );
    statSetBuffered( var_0, var_2 + var_1 );
}

updateBufferedStats()
{
    wait 0.15;
    var_0 = 0;

    while ( !level.gameEnded )
    {
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
        var_0++;

        if ( var_0 >= level.players.size )
            var_0 = 0;

        if ( isdefined( level.players[var_0] ) )
        {
            level.players[var_0] writeBufferedStats();
            level.players[var_0] updateWeaponBufferedStats();
        }

        wait 2.0;
    }

    foreach ( var_2 in level.players )
    {
        var_2 writeBufferedStats();
        var_2 updateWeaponBufferedStats();
    }
}

writeBufferedStats()
{
    foreach ( var_2, var_1 in self.bufferedStats )
        self setplayerdata( var_2, var_1 );

    foreach ( var_2, var_1 in self.bufferedChildStats )
    {
        foreach ( var_6, var_5 in var_1 )
            self setplayerdata( var_2, var_6, var_5 );
    }
}

incrementWeaponStat( var_0, var_1, var_2 )
{
    if ( maps\mp\_utility::isKillstreakWeapon( var_0 ) )
        return;

    if ( maps\mp\_utility::rankingEnabled() )
    {
        var_3 = self getplayerdata( "weaponStats", var_0, var_1 );
        self setplayerdata( "weaponStats", var_0, var_1, var_3 + var_2 );
    }
}

incrementAttachmentStat( var_0, var_1, var_2 )
{
    if ( maps\mp\_utility::rankingEnabled() )
    {
        var_3 = self getplayerdata( "attachmentsStats", var_0, var_1 );
        self setplayerdata( "attachmentsStats", var_0, var_1, var_3 + var_2 );
    }
}

updateWeaponBufferedStats()
{
    if ( !isdefined( self.trackingWeaponName ) )
        return;

    if ( self.trackingWeaponName == "" || self.trackingWeaponName == "none" )
        return;

    var_0 = self.trackingWeaponName;

    if ( maps\mp\_utility::isKillstreakWeapon( var_0 ) || maps\mp\_utility::isEnvironmentWeapon( var_0 ) )
        return;

    var_1 = strtok( var_0, "_" );

    if ( var_1[0] == "iw5" )
        var_1[0] = var_1[0] + "_" + var_1[1];

    if ( var_1[0] == "alt" )
    {
        foreach ( var_3 in var_1 )
        {
            if ( var_3 == "gl" || var_3 == "gp25" || var_3 == "m320" )
            {
                var_1[0] = "gl";
                break;
            }

            if ( var_3 == "shotgun" )
            {
                var_1[0] = "shotgun";
                break;
            }
        }

        if ( var_1[0] == "alt" )
            var_1[0] = var_1[1] + "_" + var_1[2];
    }

    if ( var_1[0] == "gl" || var_1[0] == "shotgun" )
    {
        if ( self.trackingWeaponShots > 0 )
        {
            incrementAttachmentStat( var_1[0], "shots", self.trackingWeaponShots );
            maps\mp\_matchdata::logAttachmentStat( var_1[0], "shots", self.trackingWeaponShots );
        }

        if ( self.trackingWeaponKills > 0 )
        {
            incrementAttachmentStat( var_1[0], "kills", self.trackingWeaponKills );
            maps\mp\_matchdata::logAttachmentStat( var_1[0], "kills", self.trackingWeaponKills );
        }

        if ( self.trackingWeaponHits > 0 )
        {
            incrementAttachmentStat( var_1[0], "hits", self.trackingWeaponHits );
            maps\mp\_matchdata::logAttachmentStat( var_1[0], "hits", self.trackingWeaponHits );
        }

        if ( self.trackingWeaponHeadShots > 0 )
        {
            incrementAttachmentStat( var_1[0], "headShots", self.trackingWeaponHeadShots );
            maps\mp\_matchdata::logAttachmentStat( var_1[0], "headShots", self.trackingWeaponHeadShots );
        }

        if ( self.trackingWeaponDeaths > 0 )
        {
            incrementAttachmentStat( var_1[0], "deaths", self.trackingWeaponDeaths );
            maps\mp\_matchdata::logAttachmentStat( var_1[0], "deaths", self.trackingWeaponDeaths );
        }

        self.trackingWeaponName = "none";
        self.trackingWeaponShots = 0;
        self.trackingWeaponKills = 0;
        self.trackingWeaponHits = 0;
        self.trackingWeaponHeadShots = 0;
        self.trackingWeaponDeaths = 0;
        return;
    }

    if ( !maps\mp\_utility::isCACPrimaryWeapon( var_1[0] ) && !maps\mp\_utility::isCACSecondaryWeapon( var_1[0] ) )
        return;

    if ( self.trackingWeaponShots > 0 )
    {
        incrementWeaponStat( var_1[0], "shots", self.trackingWeaponShots );
        maps\mp\_matchdata::logWeaponStat( var_1[0], "shots", self.trackingWeaponShots );
    }

    if ( self.trackingWeaponKills > 0 )
    {
        incrementWeaponStat( var_1[0], "kills", self.trackingWeaponKills );
        maps\mp\_matchdata::logWeaponStat( var_1[0], "kills", self.trackingWeaponKills );
    }

    if ( self.trackingWeaponHits > 0 )
    {
        incrementWeaponStat( var_1[0], "hits", self.trackingWeaponHits );
        maps\mp\_matchdata::logWeaponStat( var_1[0], "hits", self.trackingWeaponHits );
    }

    if ( self.trackingWeaponHeadShots > 0 )
    {
        incrementWeaponStat( var_1[0], "headShots", self.trackingWeaponHeadShots );
        maps\mp\_matchdata::logWeaponStat( var_1[0], "headShots", self.trackingWeaponHeadShots );
    }

    if ( self.trackingWeaponDeaths > 0 )
    {
        incrementWeaponStat( var_1[0], "deaths", self.trackingWeaponDeaths );
        maps\mp\_matchdata::logWeaponStat( var_1[0], "deaths", self.trackingWeaponDeaths );
    }

    var_1 = strtok( var_0, "_" );

    if ( var_1[0] != "none" )
    {
        for ( var_5 = 0; var_5 < var_1.size; var_5++ )
        {
            if ( var_1[var_5] == "mp" || var_1[var_5] == "scope1" || var_1[var_5] == "scope2" || var_1[var_5] == "scope3" || var_1[var_5] == "scope4" || var_1[var_5] == "scope5" || var_1[var_5] == "scope6" || var_1[var_5] == "scope7" || var_1[var_5] == "scope8" || var_1[var_5] == "scope9" || var_1[var_5] == "scope10" )
                continue;

            if ( issubstr( var_1[var_5], "camo" ) )
                continue;

            if ( issubstr( var_1[var_5], "scope" ) && !issubstr( var_1[var_5], "vz" ) )
                continue;

            if ( var_1[var_5] == "alt" )
            {
                var_5 += 2;
                continue;
            }

            if ( var_1[var_5] == "iw5" )
            {
                var_5 += 1;
                continue;
            }

            var_1[var_5] = maps\mp\_utility::validateAttachment( var_1[var_5] );

            if ( var_1[var_5] == "gl" || var_1[var_5] == "shotgun" )
                continue;

            if ( issubstr( var_1[var_5], "scope" ) && issubstr( var_1[var_5], "vz" ) )
                var_1[var_5] = "vzscope";

            if ( var_5 == 0 && ( var_1[var_5] != "iw5" && var_1[var_5] != "alt" ) )
                continue;

            if ( self.trackingWeaponShots > 0 )
            {
                incrementAttachmentStat( var_1[var_5], "shots", self.trackingWeaponShots );
                maps\mp\_matchdata::logAttachmentStat( var_1[var_5], "shots", self.trackingWeaponShots );
            }

            if ( self.trackingWeaponKills > 0 )
            {
                incrementAttachmentStat( var_1[var_5], "kills", self.trackingWeaponKills );
                maps\mp\_matchdata::logAttachmentStat( var_1[var_5], "kills", self.trackingWeaponKills );
            }

            if ( self.trackingWeaponHits > 0 )
            {
                incrementAttachmentStat( var_1[var_5], "hits", self.trackingWeaponHits );
                maps\mp\_matchdata::logAttachmentStat( var_1[var_5], "hits", self.trackingWeaponHits );
            }

            if ( self.trackingWeaponHeadShots > 0 )
            {
                incrementAttachmentStat( var_1[var_5], "headShots", self.trackingWeaponHeadShots );
                maps\mp\_matchdata::logAttachmentStat( var_1[var_5], "headShots", self.trackingWeaponHeadShots );
            }

            if ( self.trackingWeaponDeaths > 0 )
            {
                incrementAttachmentStat( var_1[var_5], "deaths", self.trackingWeaponDeaths );
                maps\mp\_matchdata::logAttachmentStat( var_1[var_5], "deaths", self.trackingWeaponDeaths );
            }
        }
    }

    self.trackingWeaponName = "none";
    self.trackingWeaponShots = 0;
    self.trackingWeaponKills = 0;
    self.trackingWeaponHits = 0;
    self.trackingWeaponHeadShots = 0;
    self.trackingWeaponDeaths = 0;
}

uploadGlobalStatCounters()
{
    level waittill( "game_ended" );

    if ( !maps\mp\_utility::matchMakingGame() )
        return;

    var_0 = 0;
    var_1 = 0;
    var_2 = 0;
    var_3 = 0;
    var_4 = 0;
    var_5 = 0;

    foreach ( var_7 in level.players )
        var_5 += var_7.timePlayed["total"];

    incrementcounter( "global_minutes", int( var_5 / 60 ) );

    if ( !maps\mp\_utility::wasLastRound() )
        return;

    wait 0.05;

    foreach ( var_7 in level.players )
    {
        var_0 += var_7.kills;
        var_1 += var_7.deaths;
        var_2 += var_7.assists;
        var_3 += var_7.headshots;
        var_4 += var_7.suicides;
    }

    incrementcounter( "global_kills", var_0 );
    incrementcounter( "global_deaths", var_1 );
    incrementcounter( "global_assists", var_2 );
    incrementcounter( "global_headshots", var_3 );
    incrementcounter( "global_suicides", var_4 );
    incrementcounter( "global_games", 1 );
}
