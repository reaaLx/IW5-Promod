// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

setOverkillPro()
{

}

unsetOverkillPro()
{

}

setEmpImmune()
{

}

unsetEmpImmune()
{

}

setAutoSpot()
{
    autoSpotAdsWatcher();
    autoSpotDeathWatcher();
}

autoSpotDeathWatcher()
{
    self waittill( "death" );
    self endon( "disconnect" );
    self endon( "endAutoSpotAdsWatcher" );
    level endon( "game_ended" );
    self autospotoverlayoff();
}

unsetAutoSpot()
{
    self notify( "endAutoSpotAdsWatcher" );
    self autospotoverlayoff();
}

autoSpotAdsWatcher()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "endAutoSpotAdsWatcher" );
    level endon( "game_ended" );
    spotter = 0;

    for (;;)
    {
        wait 0.05;

        if ( self isusingturret() )
        {
            self autospotoverlayoff();
            continue;
        }

        adsLevel = self playerads();

        if ( adsLevel < 1 && spotter )
        {
            spotter = 0;
            self autospotoverlayoff();
        }

        if ( adsLevel < 1 && !spotter )
            continue;

        if ( adsLevel == 1 && !spotter )
        {
            spotter = 1;
            self autospotoverlayon();
        }
    }
}

setRegenSpeed()
{

}

unsetRegenSpeed()
{

}

setHardShell()
{
    self.shellShockReduction = 0.25;
}

unsetHardShell()
{
    self.shellShockReduction = 0;
}

setSharpFocus()
{
    self setviewkickscale( 0.5 );
}

unsetSharpFocus()
{
    self setviewkickscale( 1 );
}

setDoubleLoad()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "endDoubleLoad" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "reload" );
        weapons = self getweaponslist( "primary" );

        foreach ( weapon in weapons )
        {
            ammoInClip = self getweaponammoclip( weapon );
            clipSize = weaponclipsize( weapon );
            difference = clipSize - ammoInClip;
            ammoReserves = self getweaponammostock( weapon );

            if ( ammoInClip != clipSize && ammoReserves > 0 )
            {
                if ( ammoInClip + ammoReserves >= clipSize )
                {
                    self setweaponammoclip( weapon, clipSize );
                    self setweaponammostock( weapon, ammoReserves - difference );
                    continue;
                }

                self setweaponammoclip( weapon, ammoInClip + ammoReserves );

                if ( ammoReserves - difference > 0 )
                {
                    self setweaponammostock( weapon, ammoReserves - difference );
                    continue;
                }

                self setweaponammostock( weapon, 0 );
            }
        }
    }
}

unsetDoubleLoad()
{
    self notify( "endDoubleLoad" );
}

setMarksman()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    maps\mp\_utility::setRecoilScale( 10 );
    self.recoilScale = 10;
}

unsetMarksman()
{
    maps\mp\_utility::setRecoilScale( 0 );
    self.recoilScale = 0;
}

setStunResistance()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.stunScaler = 0.5;
}

unsetStunResistance()
{
    self.stunScaler = 1;
}

setSteadyAimPro()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self setaimspreadmovementscale( 0.5 );
}

unsetSteadyAimPro()
{
    self notify( "end_SteadyAimPro" );
    self setaimspreadmovementscale( 1.0 );
}

blastshieldUseTracker( perkName, useFunc )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "end_perkUseTracker" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "empty_offhand" );

        if ( !common_scripts\utility::isOffhandWeaponEnabled() )
            continue;

        self [[ useFunc ]]( maps\mp\_utility::_hasPerk( "_specialty_blastshield" ) );
    }
}

perkUseDeathTracker()
{
    self endon( "disconnect" );
    self waittill( "death" );
    self._usePerkEnabled = undefined;
}

setRearView()
{

}

unsetRearView()
{
    self notify( "end_perkUseTracker" );
}

setEndGame()
{
    if ( isdefined( self.endGame ) )
        return;

    self.maxHealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" ) * 4;
    self.health = self.maxHealth;
    self.endGame = 1;
    self.attackerTable[0] = "";
    self visionsetnakedforplayer( "end_game", 5 );
    thread endGameDeath( 7 );
    self.hasDoneCombat = 1;
}

unsetEndGame()
{
    self notify( "stopEndGame" );
    self.endGame = undefined;
    revertVisionSet();

    if ( !isdefined( self.endGameTimer ) )
        return;

    self.endGameTimer maps\mp\gametypes\_hud_util::destroyElem();
    self.endGameIcon maps\mp\gametypes\_hud_util::destroyElem();
}

revertVisionSet()
{
    if ( isdefined( level.nukeDetonated ) )
        self visionsetnakedforplayer( level.nukeVisionSet, 1 );
    else
        self visionsetnakedforplayer( "", 1 );
}

endGameDeath( duration )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    level endon( "game_ended" );
    self endon( "stopEndGame" );
    wait(duration + 1);
    maps\mp\_utility::_suicide();
}

setSiege()
{
    thread trackSiegeEnable();
    thread trackSiegeDissable();
}

trackSiegeEnable()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stop_trackSiege" );

    for (;;)
    {
        self waittill( "gambit_on" );
        self.moveSpeedScaler = 0;
        maps\mp\gametypes\_weapons::updateMoveSpeedScale();
        class = weaponclass( self getcurrentweapon() );

        if ( class == "pistol" || class == "smg" )
            self setspreadoverride( 1 );
        else
            self setspreadoverride( 2 );

        self player_recoilscaleon( 0 );
        self allowjump( 0 );
    }
}

trackSiegeDissable()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stop_trackSiege" );

    for (;;)
    {
        self waittill( "gambit_off" );
        unsetSiege();
    }
}

stanceStateListener()
{
    self endon( "death" );
    self endon( "disconnect" );
    self notifyonplayercommand( "adjustedStance", "+stance" );

    for (;;)
    {
        self waittill( "adjustedStance" );

        if ( self.moveSpeedScaler != 0 )
            continue;

        unsetSiege();
    }
}

jumpStateListener()
{
    self endon( "death" );
    self endon( "disconnect" );
    self notifyonplayercommand( "jumped", "+goStand" );

    for (;;)
    {
        self waittill( "jumped" );

        if ( self.moveSpeedScaler != 0 )
            continue;

        unsetSiege();
    }
}

unsetSiege()
{
    self.moveSpeedScaler = 1;
    self resetspreadoverride();
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    self player_recoilscaleoff();
    self allowjump( 1 );
}

setChallenger()
{
    if ( !level.hardcoreMode )
    {
        self.maxHealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );

        if ( isdefined( self.xpScaler ) && self.xpScaler == 1 && self.maxHealth > 30 )
            self.xpScaler = 2;
    }
}

unsetChallenger()
{
    self.xpScaler = 1;
}

setSaboteur()
{
    self.objectiveScaler = 1.2;
}

unsetSaboteur()
{
    self.objectiveScaler = 1;
}

setLightWeight()
{
    self.moveSpeedScaler = maps\mp\_utility::lightWeightScalar();
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
}

unsetLightWeight()
{
    self.moveSpeedScaler = 1;
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
}

setBlackBox()
{
    self.killStreakScaler = 1.5;
}

unsetBlackBox()
{
    self.killStreakScaler = 1;
}

setSteelNerves()
{
    maps\mp\_utility::givePerk( "specialty_bulletaccuracy", 1 );
    maps\mp\_utility::givePerk( "specialty_holdbreath", 0 );
}

unsetSteelNerves()
{
    maps\mp\_utility::_unsetPerk( "specialty_bulletaccuracy" );
    maps\mp\_utility::_unsetPerk( "specialty_holdbreath" );
}

setDelayMine()
{

}

unsetDelayMine()
{

}

setBackShield()
{
    self attachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
}

unsetBackShield()
{
    self detachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
}

setLocalJammer()
{
    if ( !maps\mp\_utility::isEMPed() )
        self radarjamon();
}

unsetLocalJammer()
{
    self radarjamoff();
}

setAC130()
{
    thread killstreakThink( "ac130", 7, "end_ac130Think" );
}

unsetAC130()
{
    self notify( "end_ac130Think" );
}

setSentryMinigun()
{
    thread killstreakThink( "airdrop_sentry_minigun", 2, "end_sentry_minigunThink" );
}

unsetSentryMinigun()
{
    self notify( "end_sentry_minigunThink" );
}

setTank()
{
    thread killstreakThink( "tank", 6, "end_tankThink" );
}

unsetTank()
{
    self notify( "end_tankThink" );
}

setPrecision_airstrike()
{
    thread killstreakThink( "precision_airstrike", 6, "end_precision_airstrike" );
}

unsetPrecision_airstrike()
{
    self notify( "end_precision_airstrike" );
}

setPredatorMissile()
{
    thread killstreakThink( "predator_missile", 4, "end_predator_missileThink" );
}

unsetPredatorMissile()
{
    self notify( "end_predator_missileThink" );
}

setHelicopterMinigun()
{
    thread killstreakThink( "helicopter_minigun", 5, "end_helicopter_minigunThink" );
}

unsetHelicopterMinigun()
{
    self notify( "end_helicopter_minigunThink" );
}

killstreakThink( streakName, streakVal, endonString )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( endonString );

    for (;;)
    {
        self waittill( "killed_enemy" );

        if ( self.pers["cur_kill_streak"] != streakVal )
            continue;

        thread maps\mp\killstreaks\_killstreaks::giveKillstreak( streakName );
        thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( streakName, streakVal );
        return;
    }
}

setThermal()
{
    self thermalvisionon();
}

unsetThermal()
{
    self thermalvisionoff();
}

setOneManArmy()
{
    thread oneManArmyWeaponChangeTracker();
}

unsetOneManArmy()
{
    self notify( "stop_oneManArmyTracker" );
}

oneManArmyWeaponChangeTracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "stop_oneManArmyTracker" );

    for (;;)
    {
        self waittill( "weapon_change", newWeapon );

        if ( newWeapon != "onemanarmy_mp" )
            continue;

        thread selectOneManArmyClass();
    }
}

isOneManArmyMenu( menu )
{
    if ( menu == game["menu_onemanarmy"] )
        return 1;

    if ( isdefined( game["menu_onemanarmy_defaults_splitscreen"] ) && menu == game["menu_onemanarmy_defaults_splitscreen"] )
        return 1;

    if ( isdefined( game["menu_onemanarmy_custom_splitscreen"] ) && menu == game["menu_onemanarmy_custom_splitscreen"] )
        return 1;

    return 0;
}

selectOneManArmyClass()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    common_scripts\utility::_disableWeaponSwitch();
    common_scripts\utility::_disableOffhandWeapons();
    common_scripts\utility::_disableUsability();
    self openpopupmenu( game["menu_onemanarmy"] );
    thread closeOMAMenuOnDeath();
    self waittill( "menuresponse", menu, className );
    common_scripts\utility::_enableWeaponSwitch();
    common_scripts\utility::_enableOffhandWeapons();
    common_scripts\utility::_enableUsability();

    if ( className == "back" || !isOneManArmyMenu( menu ) || maps\mp\_utility::isUsingRemote() )
    {
        if ( self getcurrentweapon() == "onemanarmy_mp" )
        {
            common_scripts\utility::_disableWeaponSwitch();
            common_scripts\utility::_disableOffhandWeapons();
            common_scripts\utility::_disableUsability();
            self switchtoweapon( common_scripts\utility::getLastWeapon() );
            self waittill( "weapon_change" );
            common_scripts\utility::_enableWeaponSwitch();
            common_scripts\utility::_enableOffhandWeapons();
            common_scripts\utility::_enableUsability();
        }

        return;
    }

    thread giveOneManArmyClass( className );
}

closeOMAMenuOnDeath()
{
    self endon( "menuresponse" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "death" );
    common_scripts\utility::_enableWeaponSwitch();
    common_scripts\utility::_enableOffhandWeapons();
    common_scripts\utility::_enableUsability();
    self closepopupmenu();
}

giveOneManArmyClass( className )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( maps\mp\_utility::_hasPerk( "specialty_omaquickchange" ) )
    {
        changeDuration = 3.0;
        self playlocalsound( "foly_onemanarmy_bag3_plr" );
        self playsoundtoteam( "foly_onemanarmy_bag3_npc", "allies", self );
        self playsoundtoteam( "foly_onemanarmy_bag3_npc", "axis", self );
    }
    else
    {
        changeDuration = 6.0;
        self playlocalsound( "foly_onemanarmy_bag6_plr" );
        self playsoundtoteam( "foly_onemanarmy_bag6_npc", "allies", self );
        self playsoundtoteam( "foly_onemanarmy_bag6_npc", "axis", self );
    }

    thread omaUseBar( changeDuration );
    common_scripts\utility::_disableWeapon();
    common_scripts\utility::_disableOffhandWeapons();
    common_scripts\utility::_disableUsability();
    wait(changeDuration);
    common_scripts\utility::_enableWeapon();
    common_scripts\utility::_enableOffhandWeapons();
    common_scripts\utility::_enableUsability();
    self.omaClassChanged = 1;
    maps\mp\gametypes\_class::giveLoadout( self.pers["team"], className, 0 );

    if ( isdefined( self.carryFlag ) )
        self attach( self.carryFlag, "J_spine4", 1 );

    self notify( "changed_kit" );
    level notify( "changed_kit" );
}

omaUseBar( duration )
{
    self endon( "disconnect" );
    useBar = maps\mp\gametypes\_hud_util::createPrimaryProgressBar( 0, -25 );
    useBarText = maps\mp\gametypes\_hud_util::createPrimaryProgressBarText( 0, -25 );
    useBarText settext( &"MPUI_CHANGING_KIT" );
    useBar maps\mp\gametypes\_hud_util::updateBar( 0, 1 / duration );

    for ( waitedTime = 0; waitedTime < duration && isalive( self ) && !level.gameEnded; waitedTime += 0.05 )
        wait 0.05;

    useBar maps\mp\gametypes\_hud_util::destroyElem();
    useBarText maps\mp\gametypes\_hud_util::destroyElem();
}

setBlastShield()
{
    self setweaponhudiconoverride( "primaryoffhand", "specialty_blastshield" );
}

unsetBlastShield()
{
    self setweaponhudiconoverride( "primaryoffhand", "none" );
}

setFreefall()
{

}

unsetFreefall()
{

}

setTacticalInsertion()
{
    self setoffhandsecondaryclass( "flash" );
    maps\mp\_utility::_giveWeapon( "flare_mp", 0 );
    self givestartammo( "flare_mp" );
    thread monitorTIUse();
}

unsetTacticalInsertion()
{
    self notify( "end_monitorTIUse" );
}

clearPreviousTISpawnpoint()
{
    common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );

    if ( isdefined( self.setSpawnpoint ) )
        deleteTI( self.setSpawnpoint );
}

updateTISpawnPosition()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "end_monitorTIUse" );

    while ( maps\mp\_utility::isReallyAlive( self ) )
    {
        if ( isValidTISpawnPosition() )
            self.TISpawnPosition = self.origin;

        wait 0.05;
    }
}

isValidTISpawnPosition()
{
    if ( canspawn( self.origin ) && self isonground() )
        return 1;
    else
        return 0;
}

monitorTIUse()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "end_monitorTIUse" );
    thread updateTISpawnPosition();
    thread clearPreviousTISpawnpoint();

    for (;;)
    {
        self waittill( "grenade_fire", lightstick, weapName );

        if ( weapName != "flare_mp" )
            continue;

        if ( isdefined( self.setSpawnpoint ) )
            deleteTI( self.setSpawnpoint );

        if ( !isdefined( self.TISpawnPosition ) )
            continue;

        if ( maps\mp\_utility::touchingBadTrigger() )
            continue;

        TIGroundPosition = playerphysicstrace( self.TISpawnPosition + ( 0, 0, 16 ), self.TISpawnPosition - ( 0, 0, 2048 ) ) + ( 0, 0, 1 );
        glowStick = spawn( "script_model", TIGroundPosition );
        glowStick.angles = self.angles;
        glowStick.team = self.team;
        glowStick.owner = self;
        glowStick.enemyTrigger = spawn( "script_origin", TIGroundPosition );
        glowStick thread GlowStickSetupAndWaitForDeath( self );
        glowStick.playerSpawnPos = self.TISpawnPosition;
        glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_light_stick_tactical_bombsquad", "tag_fire_fx", level.otherTeam[self.team], self );
        self.setSpawnpoint = glowStick;
        return;
    }
}

GlowStickSetupAndWaitForDeath( owner )
{
    self setmodel( level.precacheModel["enemy"] );

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 20 ) );
    else
        maps\mp\_entityheadicons::setPlayerHeadIcon( owner, ( 0, 0, 20 ) );

    thread GlowStickDamageListener( owner );
    thread GlowStickEnemyUseListener( owner );
    thread GlowStickUseListener( owner );
    thread GlowStickTeamUpdater( level.otherTeam[self.team], level.spawnGlow["enemy"], owner );
    dummyGlowStick = spawn( "script_model", self.origin + ( 0, 0, 0 ) );
    dummyGlowStick.angles = self.angles;
    dummyGlowStick setmodel( level.precacheModel["friendly"] );
    dummyGlowStick setcontents( 0 );
    dummyGlowStick thread GlowStickTeamUpdater( self.team, level.spawnGlow["friendly"], owner );
    dummyGlowStick playloopsound( "emt_road_flare_burn" );
    self waittill( "death" );
    dummyGlowStick stoploopsound();
    dummyGlowStick delete();
}

GlowStickTeamUpdater( showForTeam, showEffect, owner )
{
    self endon( "death" );
    wait 0.05;
    angles = self gettagangles( "tag_fire_fx" );
    fxEnt = spawnfx( showEffect, self gettagorigin( "tag_fire_fx" ), anglestoforward( angles ), anglestoup( angles ) );
    triggerfx( fxEnt );
    thread deleteOnDeath( fxEnt );

    for (;;)
    {
        self hide();
        fxEnt hide();

        foreach ( player in level.players )
        {
            if ( player.team == showForTeam && level.teamBased )
            {
                self showtoplayer( player );
                fxEnt showtoplayer( player );
                continue;
            }

            if ( !level.teamBased && player == owner && showEffect == level.spawnGlow["friendly"] )
            {
                self showtoplayer( player );
                fxEnt showtoplayer( player );
                continue;
            }

            if ( !level.teamBased && player != owner && showEffect == level.spawnGlow["enemy"] )
            {
                self showtoplayer( player );
                fxEnt showtoplayer( player );
            }
        }

        level common_scripts\utility::waittill_either( "joined_team", "player_spawned" );
    }
}

deleteOnDeath( ent )
{
    self waittill( "death" );

    if ( isdefined( ent ) )
        ent delete();
}

GlowStickDamageListener( owner )
{
    self endon( "death" );
    self setcandamage( 1 );
    self.health = 999999;
    self.maxHealth = 100;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, attacker ) )
            continue;

        if ( isdefined( weapon ) )
        {
            switch ( weapon )
            {
                case "concussion_grenade_mp":
                case "smoke_grenade_mp":
                case "flash_grenade_mp":
                    continue;
            }
        }

        if ( !isdefined( self ) )
            return;

        if ( type == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        if ( isdefined( iDFlags ) && iDFlags & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        self.damagetaken = self.damagetaken + damage;

        if ( isplayer( attacker ) )
            attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "tactical_insertion" );

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isdefined( owner ) && attacker != owner )
            {
                attacker notify( "destroyed_insertion", owner );
                attacker notify( "destroyed_explosive" );
                owner thread maps\mp\_utility::leaderDialogOnPlayer( "ti_destroyed" );
            }

            attacker thread deleteTI( self );
        }
    }
}

GlowStickUseListener( owner )
{
    self endon( "death" );
    level endon( "game_ended" );
    owner endon( "disconnect" );
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( &"MP_PATCH_PICKUP_TI" );
    thread updateEnemyUse( owner );

    for (;;)
    {
        self waittill( "trigger", player );
        player playsound( "chemlight_pu" );
        player thread setTacticalInsertion();
        player thread deleteTI( self );
    }
}

updateEnemyUse( owner )
{
    self endon( "death" );

    for (;;)
    {
        maps\mp\_utility::setSelfUsable( owner );
        level common_scripts\utility::waittill_either( "joined_team", "player_spawned" );
    }
}

deleteTI( TI )
{
    if ( isdefined( TI.enemyTrigger ) )
        TI.enemyTrigger delete();

    spot = TI.origin;
    spotAngles = TI.angles;
    TI delete();
    dummyGlowStick = spawn( "script_model", spot );
    dummyGlowStick.angles = spotAngles;
    dummyGlowStick setmodel( level.precacheModel["friendly"] );
    dummyGlowStick setcontents( 0 );
    thread dummyGlowStickDelete( dummyGlowStick );
}

dummyGlowStickDelete( stick )
{
    wait 2.5;
    stick delete();
}

GlowStickEnemyUseListener( owner )
{
    self endon( "death" );
    level endon( "game_ended" );
    owner endon( "disconnect" );
    self.enemyTrigger setcursorhint( "HINT_NOICON" );
    self.enemyTrigger sethintstring( &"MP_PATCH_DESTROY_TI" );
    self.enemyTrigger maps\mp\_utility::makeEnemyUsable( owner );

    for (;;)
    {
        self.enemyTrigger waittill( "trigger", player );
        player notify( "destroyed_insertion", owner );
        player notify( "destroyed_explosive" );

        if ( isdefined( owner ) && player != owner )
            owner thread maps\mp\_utility::leaderDialogOnPlayer( "ti_destroyed" );

        player thread deleteTI( self );
    }
}

setLittlebirdSupport()
{
    thread killstreakThink( "littlebird_support", 2, "end_littlebird_support_think" );
}

unsetLittlebirdSupport()
{
    self notify( "end_littlebird_support_think" );
}

setPainted()
{
    if ( isplayer( self ) )
    {
        paintedTime = 10.0;

        if ( maps\mp\_utility::_hasPerk( "specialty_quieter" ) )
            paintedTime *= 0.5;

        self.painted = 1;
        self setperk( "specialty_radararrow", 1, 0 );
        thread unsetPainted( paintedTime );
        thread watchPaintedDeath();
    }
}

watchPaintedDeath()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "death" );
    self.painted = 0;
}

unsetPainted( time )
{
    self notify( "painted_again" );
    self endon( "painted_again" );
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    wait(time);
    self.painted = 0;
    self unsetperk( "specialty_radararrow", 1 );
}

isPainted()
{
    return isdefined( self.painted ) && self.painted;
}

setFinalStand()
{
    maps\mp\_utility::givePerk( "specialty_pistoldeath", 0 );
}

unsetFinalStand()
{
    maps\mp\_utility::_unsetPerk( "specialty_pistoldeath" );
}

setCarePackage()
{
    thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop_assault", 0, 0, self, 1 );
}

unsetCarePackage()
{

}

setUAV()
{
    thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "uav", 0, 0, self, 1 );
}

unsetUAV()
{

}

setStoppingPower()
{
    maps\mp\_utility::givePerk( "specialty_bulletdamage", 0 );
    thread watchStoppingPowerKill();
}

watchStoppingPowerKill()
{
    self notify( "watchStoppingPowerKill" );
    self endon( "watchStoppingPowerKill" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "killed_enemy" );
    unsetStoppingPower();
}

unsetStoppingPower()
{
    maps\mp\_utility::_unsetPerk( "specialty_bulletdamage" );
    self notify( "watchStoppingPowerKill" );
}

setC4Death()
{
    if ( !maps\mp\_utility::_hasPerk( "specialty_pistoldeath" ) )
        maps\mp\_utility::givePerk( "specialty_pistoldeath", 0 );
}

unsetC4Death()
{
    if ( maps\mp\_utility::_hasPerk( "specialty_pistoldeath" ) )
        maps\mp\_utility::_unsetPerk( "specialty_pistoldeath" );
}

setJuiced()
{
    self endon( "death" );
    self endon( "faux_spawn" );
    self endon( "disconnect" );
    self endon( "unset_juiced" );
    level endon( "end_game" );
    self.isjuiced = 1;
    self.moveSpeedScaler = 1.25;
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();

    if ( level.splitscreen )
    {
        yOffset = 56;
        iconSize = 21;
    }
    else
    {
        yOffset = 80;
        iconSize = 32;
    }

    self.juicedTimer = maps\mp\gametypes\_hud_util::createTimer( "hudsmall", 1.0 );
    self.juicedTimer maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, yOffset );
    self.juicedTimer settimer( 7.0 );
    self.juicedTimer.color = ( 0.8, 0.8, 0 );
    self.juicedTimer.archived = 0;
    self.juicedTimer.foreground = 1;
    self.juicedIcon = maps\mp\gametypes\_hud_util::createIcon( "specialty_juiced", iconSize, iconSize );
    self.juicedIcon.alpha = 0;
    self.juicedIcon maps\mp\gametypes\_hud_util::setParent( self.juicedTimer );
    self.juicedIcon maps\mp\gametypes\_hud_util::setPoint( "BOTTOM", "TOP" );
    self.juicedIcon.archived = 1;
    self.juicedIcon.sort = 1;
    self.juicedIcon.foreground = 1;
    self.juicedIcon fadeovertime( 1.0 );
    self.juicedIcon.alpha = 0.85;
    thread unsetJuicedOnDeath();
    thread unsetJuicedOnRide();
    wait 5;

    if ( isdefined( self.juicedIcon ) )
    {
        self.juicedIcon fadeovertime( 2.0 );
        self.juicedIcon.alpha = 0.0;
    }

    if ( isdefined( self.juicedTimer ) )
    {
        self.juicedTimer fadeovertime( 2.0 );
        self.juicedTimer.alpha = 0.0;
    }

    wait 2;
    unsetJuiced();
}

unsetJuiced( player )
{
    if ( !isdefined( player ) )
    {
        if ( maps\mp\_utility::isJuggernaut() )
            self.moveSpeedScaler = self.juggmovespeedscaler;
        else
        {
            self.moveSpeedScaler = 1;

            if ( maps\mp\_utility::_hasPerk( "specialty_lightweight" ) )
                self.moveSpeedScaler = maps\mp\_utility::lightWeightScalar();
        }

        maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    }

    if ( isdefined( self.juicedIcon ) )
        self.juicedIcon destroy();

    if ( isdefined( self.juicedTimer ) )
        self.juicedTimer destroy();

    self.isjuiced = undefined;
    self notify( "unset_juiced" );
}

unsetJuicedOnRide()
{
    self endon( "disconnect" );
    self endon( "unset_juiced" );

    for (;;)
    {
        wait 0.05;

        if ( maps\mp\_utility::isUsingRemote() )
        {
            thread unsetJuiced();
            break;
        }
    }
}

unsetJuicedOnDeath()
{
    self endon( "disconnect" );
    self endon( "unset_juiced" );
    common_scripts\utility::waittill_any( "death", "faux_spawn" );
    thread unsetJuiced( self );
}

setCombatHigh()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "unset_combathigh" );
    level endon( "end_game" );
    self.damageBlockedTotal = 0;

    if ( level.splitscreen )
    {
        yOffset = 56;
        iconSize = 21;
    }
    else
    {
        yOffset = 112;
        iconSize = 32;
    }

    if ( isdefined( self.juicedTimer ) )
        self.juicedTimer destroy();

    if ( isdefined( self.juicedIcon ) )
        self.juicedIcon destroy();

    self.combatHighOverlay = newclienthudelem( self );
    self.combatHighOverlay.x = 0;
    self.combatHighOverlay.y = 0;
    self.combatHighOverlay.alignx = "left";
    self.combatHighOverlay.aligny = "top";
    self.combatHighOverlay.horzalign = "fullscreen";
    self.combatHighOverlay.vertalign = "fullscreen";
    self.combatHighOverlay setshader( "combathigh_overlay", 640, 480 );
    self.combatHighOverlay.sort = -10;
    self.combatHighOverlay.archived = 1;
    self.combatHighTimer = maps\mp\gametypes\_hud_util::createTimer( "hudsmall", 1.0 );
    self.combatHighTimer maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, yOffset );
    self.combatHighTimer settimer( 10.0 );
    self.combatHighTimer.color = ( 0.8, 0.8, 0 );
    self.combatHighTimer.archived = 0;
    self.combatHighTimer.foreground = 1;
    self.combatHighIcon = maps\mp\gametypes\_hud_util::createIcon( "specialty_painkiller", iconSize, iconSize );
    self.combatHighIcon.alpha = 0;
    self.combatHighIcon maps\mp\gametypes\_hud_util::setParent( self.combatHighTimer );
    self.combatHighIcon maps\mp\gametypes\_hud_util::setPoint( "BOTTOM", "TOP" );
    self.combatHighIcon.archived = 1;
    self.combatHighIcon.sort = 1;
    self.combatHighIcon.foreground = 1;
    self.combatHighOverlay.alpha = 0.0;
    self.combatHighOverlay fadeovertime( 1.0 );
    self.combatHighIcon fadeovertime( 1.0 );
    self.combatHighOverlay.alpha = 1.0;
    self.combatHighIcon.alpha = 0.85;
    thread unsetCombatHighOnDeath();
    thread unsetCombatHighOnRide();
    wait 8;
    self.combatHighIcon fadeovertime( 2.0 );
    self.combatHighIcon.alpha = 0.0;
    self.combatHighOverlay fadeovertime( 2.0 );
    self.combatHighOverlay.alpha = 0.0;
    self.combatHighTimer fadeovertime( 2.0 );
    self.combatHighTimer.alpha = 0.0;
    wait 2;
    self.damageBlockedTotal = undefined;
    maps\mp\_utility::_unsetPerk( "specialty_combathigh" );
}

unsetCombatHighOnDeath()
{
    self endon( "disconnect" );
    self endon( "unset_combathigh" );
    self waittill( "death" );
    thread maps\mp\_utility::_unsetPerk( "specialty_combathigh" );
}

unsetCombatHighOnRide()
{
    self endon( "disconnect" );
    self endon( "unset_combathigh" );

    for (;;)
    {
        wait 0.05;

        if ( maps\mp\_utility::isUsingRemote() )
        {
            thread maps\mp\_utility::_unsetPerk( "specialty_combathigh" );
            break;
        }
    }
}

unsetCombatHigh()
{
    self notify( "unset_combathigh" );
    self.combatHighOverlay destroy();
    self.combatHighIcon destroy();
    self.combatHighTimer destroy();
}

setLightArmor()
{
    thread giveLightArmor();
}

giveLightArmor()
{
    self notify( "give_light_armor" );
    self endon( "give_light_armor" );
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "end_game" );

    if ( isdefined( self.hasLightArmor ) && self.hasLightArmor == 1 )
        removeLightArmor( self.previousMaxHealth );

    lightArmorHP = 200;
    thread removeLightArmorOnDeath();
    self.hasLightArmor = 1;
    self.combatHighOverlay = newclienthudelem( self );
    self.combatHighOverlay.x = 0;
    self.combatHighOverlay.y = 0;
    self.combatHighOverlay.alignx = "left";
    self.combatHighOverlay.aligny = "top";
    self.combatHighOverlay.horzalign = "fullscreen";
    self.combatHighOverlay.vertalign = "fullscreen";
    self.combatHighOverlay setshader( "combathigh_overlay", 640, 480 );
    self.combatHighOverlay.sort = -10;
    self.combatHighOverlay.archived = 1;
    self.previousMaxHealth = self.maxHealth;
    self.maxHealth = lightArmorHP;
    self.health = self.maxHealth;
    sheildHealth = 50;
    previousHealth = self.health;

    for (;;)
    {
        if ( self.maxHealth != lightArmorHP )
        {
            removeLightArmor();
            break;
        }

        if ( self.health < 100 )
        {
            removeLightArmor( self.previousMaxHealth );
            break;
        }

        if ( self.health < previousHealth )
        {
            sheildHealth -= ( previousHealth - self.health );
            previousHealth = self.health;

            if ( sheildHealth <= 0 )
            {
                removeLightArmor( self.previousMaxHealth );
                break;
            }
        }

        wait 0.5;
    }
}

removeLightArmorOnDeath()
{
    self endon( "disconnect" );
    self endon( "give_light_armor" );
    self endon( "remove_light_armor" );
    self waittill( "death" );
    removeLightArmor();
}

removeLightArmor( maxHealth )
{
    if ( isdefined( maxHealth ) )
        self.maxHealth = maxHealth;

    if ( isdefined( self.combatHighOverlay ) )
        self.combatHighOverlay destroy();

    self.hasLightArmor = undefined;
    self notify( "remove_light_armor" );
}

unsetLightArmor()
{
    thread removeLightArmor( self.previousMaxHealth );
}

setRevenge()
{
    self notify( "stopRevenge" );
    wait 0.05;

    if ( !isdefined( self.lastKilledBy ) )
        return;

    if ( level.teamBased && self.team == self.lastKilledBy.team )
        return;

    revengeParams = spawnstruct();
    revengeParams.showTo = self;
    revengeParams.icon = "compassping_revenge";
    revengeParams.offset = ( 0, 0, 64 );
    revengeParams.width = 10;
    revengeParams.height = 10;
    revengeParams.archived = 0;
    revengeParams.delay = 1.5;
    revengeParams.constantSize = 0;
    revengeParams.pinToScreenEdge = 1;
    revengeParams.fadeOutPinnedIcon = 0;
    revengeParams.is3D = 0;
    self.revengeParams = revengeParams;
    self.lastKilledBy maps\mp\_entityheadicons::setHeadIcon( revengeParams.showTo, revengeParams.icon, revengeParams.offset, revengeParams.width, revengeParams.height, revengeParams.archived, revengeParams.delay, revengeParams.constantSize, revengeParams.pinToScreenEdge, revengeParams.fadeOutPinnedIcon, revengeParams.is3D );
    thread watchRevengeDeath();
    thread watchRevengeKill();
    thread watchRevengeDisconnected();
    thread watchRevengeVictimDisconnected();
    thread watchStopRevenge();
}

watchRevengeDeath()
{
    self endon( "stopRevenge" );
    self endon( "disconnect" );
    lastKilledBy = self.lastKilledBy;

    for (;;)
    {
        lastKilledBy waittill( "spawned_player" );
        lastKilledBy maps\mp\_entityheadicons::setHeadIcon( self.revengeParams.showTo, self.revengeParams.icon, self.revengeParams.offset, self.revengeParams.width, self.revengeParams.height, self.revengeParams.archived, self.revengeParams.delay, self.revengeParams.constantSize, self.revengeParams.pinToScreenEdge, self.revengeParams.fadeOutPinnedIcon, self.revengeParams.is3D );
    }
}

watchRevengeKill()
{
    self endon( "stopRevenge" );
    self waittill( "killed_enemy" );
    self notify( "stopRevenge" );
}

watchRevengeDisconnected()
{
    self endon( "stopRevenge" );
    self.lastKilledBy waittill( "disconnect" );
    self notify( "stopRevenge" );
}

watchStopRevenge()
{
    lastKilledBy = self.lastKilledBy;
    self waittill( "stopRevenge" );

    if ( !isdefined( lastKilledBy ) )
        return;

    foreach ( key, headIcon in lastKilledBy.entityHeadIcons )
    {
        if ( !isdefined( headIcon ) )
            continue;

        headIcon destroy();
    }
}

watchRevengeVictimDisconnected()
{
    objID = self.objIdFriendly;
    lastKilledBy = self.lastKilledBy;
    lastKilledBy endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "stopRevenge" );
    self waittill( "disconnect" );

    if ( !isdefined( lastKilledBy ) )
        return;

    foreach ( key, headIcon in lastKilledBy.entityHeadIcons )
    {
        if ( !isdefined( headIcon ) )
            continue;

        headIcon destroy();
    }
}

unsetRevenge()
{
    self notify( "stopRevenge" );
}
