#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
init()
{
    setDvarIfUninitialized("promod_allow_wbhitmarker", 1);
    setDvarIfUninitialized("promod_allow_strattime", 1);
    setDvarIfUninitialized("promod_allow_readyup", 0);
    setDvarIfUninitialized("promod_allow_timeout", 0);
    setDvarIfUninitialized("promod_allow_winningkc", 0);
    setDvarIfUninitialized("promod_allow_scopedelay", 1);
    setDvarIfUninitialized("class_assault_allowdrop", 1);
    setDvarIfUninitialized("class_specops_allowdrop", 1);
    setDvarIfUninitialized("class_demolitions_allowdrop", 0);
    setDvarIfUninitialized("class_lmg_allowdrop", 0);
    setDvarIfUninitialized("class_sniper_allowdrop", 0);
    if (level.gametype == "sd" || level.gametype == "sab")
    {
        setDvarIfUninitialized("class_assault_limit", 5 );
        setDvarIfUninitialized("class_specops_limit", 5);
        setDvarIfUninitialized("class_demolitions_limit", 5);
        setDvarIfUninitialized("class_lmg_limit", 5 );
        setDvarIfUninitialized("class_sniper_limit", 1);
    }
    else
    {
        setDvarIfUninitialized("class_assault_limit", 5 );
        setDvarIfUninitialized("class_specops_limit", 5);
        setDvarIfUninitialized("class_demolitions_limit", 5);
        setDvarIfUninitialized("class_lmg_limit", 5 );
        setDvarIfUninitialized("class_sniper_limit", 1);
    }
    level.weaponLimit = [];
    level.weaponLimit["weapon_assault"] = getDvarInt("class_assault_limit");
    level.weaponLimit["weapon_smg"] = getDvarInt("class_specops_limit");
    level.weaponLimit["weapon_shotgun"] = getDvarInt("class_demolitions_limit");
    level.weaponLimit["weapon_lmg"] = getDvarInt("class_lmg_limit");
    level.weaponLimit["weapon_sniper"] = getDvarInt("class_sniper_limit");
    

    level.assaultdrop = getDvarInt("class_assault_allowdrop");
    level.smgdrop = getDvarInt("class_specops_allowdrop");
    level.shotgundrop = getDvarInt("class_demolitions_allowdrop");
    level.lmgdrop = getDvarInt("class_lmg_allowdrop");
    level.sniperdrop = getDvarInt("class_sniper_allowdrop");
    
    level.allowWbHitmarkers = getDvarInt("promod_allow_wbhitmarker");
    level.allowScopeDelay = GetDvarInt("promod_allow_scopedelay");
    level.allowWinningKC = getDvarInt("promod_allow_winningkc");
    level.allowStrat = getDvarInt("promod_allow_strattime");
    level.allowReadyUp = getDvarInt("promod_allow_readyup");
    level.allowTimeOut = getDvarInt("promod_allow_timeout");

    if (getdvar("promod_strat_length") != "")
    {
        game["PROMOD_STRATTIME"] = getdvarfloat("promod_strat_length");
    }
    if (isDefined(game["PROMOD_STRATTIME"]) && (game["PROMOD_STRATTIME"] < 2.0 || game["PROMOD_STRATTIME"] > 20.0))
    {
        game["PROMOD_STRATTIME"] = 8.0;
    }   
    if (level.gametype != "sd" && level.gametype != "sab")
    {
        level.showAliveCounter = false;
    }
    else
    {
        level.showAliveCounter = true;
    }
    if (level.gametype != "sd")
    {
        level.allowknifeRound = false;
        level.bombDroppable = false;
    }
    else
    {
        level.bombDroppable = true;
    }
    if (level.allowReadyUp || level.allowTimeOut)
    {
        level.allowStrat = true;
    }
    if (level.allowTimeOut)
    {
        level.allowReadyUp = true;
    }

    setDvar("cl_maxpackets", 100);
    setDvar("perk_scavengerMode", 0);
    setDvar("promod_version", "v3.2-war");
    setDvar("player_breath_fire_delay ", "0");
    setDvar("player_breath_gasp_lerp", "0");
    setDvar("player_breath_gasp_scale", "0.0");
    setDvar("player_breath_gasp_time", "0");
    setDvar("player_breath_snd_delay ", "0");
    setDvar("perk_extraBreath", "0");
    setDvar("perk_improvedextraBreath", "0");
    setDvar("cg_scoreboardpingtext", 1);
    setDvar("cg_scoreboardpinggraph", 0);
    setDvar("bg_fallDamageMinHeight", 140);
    setDvar("bg_fallDamageMaxHeight", 350);
    setDvar("ui_hud_showdeathicons", 0);
    setDvar("glass_damageToDestroy", 11);
    setDvar("glass_damageToWeaken", 10);
    setDvar("glass_fringe_maxsize", 0);
    setDvar("glass_fall_gravity", 400);
    setDvar("player_throwBackInnerRadius", "0");
    setDvar("player_throwBackOuterRadius", "0");
    setDvar("bg_weaponBobAmplitudeSprinting", "0 0");
    setDvar("bg_weaponBobAmplitudeStanding", "0 0");
    setDvar("bg_weaponBobAmplitudeProne", "0 0");
    setDvar("bg_weaponBobAmplitudeDuck", "0 0");
    setDvar("bg_weaponBobMax", 0);
    setDvar("bg_viewBobAmplitudeSprinting", "0 0");
    setDvar("bg_viewBobAmplitudeStanding", "0 0");
    setDvar("bg_viewBobAmplitudeStandingADS", "0 0");
    setDvar("bg_viewBobAmplitudeProne", "0 0");
    setDvar("bg_viewBobAmplitudeDuck", "0 0");
    setDvar("bg_viewBobMax", 0);

    setDvar("cg_brass", 0);
    setDvar("r_drawsun", 0);
    setDvar("r_fog", 0);
    setDvar("cg_scoreboardpingtext", 1);
    setDvar("r_desaturation", 0);
    setDvar("snd_cinematicVolumeScale", 0);
    setDvar("sm_enable", 0);
    setDvar("r_dlightLimit", 0);
    setDvar("r_lodscalerigid", 1);
    setDvar("r_lodscaleskinned", 1);
    setDvar("cg_viewzsmoothingmin", 1);
    setDvar("cg_viewzsmoothingmax", 16);
    setDvar("cg_viewzsmoothingtime", 0.1);
    setDvar("cg_huddamageiconheight", 64);
    setDvar("cg_huddamageiconwidth", 128);
    setDvar("r_filmtweakInvert", 0);
    setDvar("r_zfeather", 0);
    setDvar("r_smc_enable", 0);
    setDvar("r_distortion", 0);
    setDvar("r_specularcolorscale", 0);
    setDvar("fx_drawclouds", 0);
    setDvar("waypointiconheight", 15);
    setDvar("waypointiconwidth", 15);
    setDvar("cg_drawBreathHint", 0);
    setDvar("perk_weapSpreadMultiplier", 0.55);
    setDvar("cg_drawThroughWalls", 0);
    setDvar("cg_enemyNameFadeIn", 1);
    setDvar("cg_enemyNameFadeOut", 1);
    setDvar("cg_hudChatPosition", "5 200");
    setDvar("g_hardcore", 0);
    setDvar("lowAmmoWarningColor1", "0 0 0 0");
    setDvar("lowAmmoWarningColor2", "0 0 0 0");
    setDvar("lowAmmoWarningNoAmmoColor1", "0 0 0 0");
    setDvar("lowAmmoWarningNoAmmoColor2", "0 0 0 0");
    setDvar("lowAmmoWarningNoReloadColor1", "0 0 0 0");
    setDvar("lowAmmoWarningNoReloadColor2", "0 0 0 0");

    setDvar("jump_height", 41.5);

    setDvar("sv_enableBounces", 1);
    setDvar("sv_enableDoubleTaps", 1);

    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        player thread teamNames();
        player thread doDvars();
        player thread onPlayerSpawned();

        /*
        if ( level.gameType == "sd" )
            player thread noGhosting();
        */
    }
}
onPlayerSpawned()
{
    self endon("disconnect");
    for (;;)
    {
        self waittill("spawned_player");
        if ( isDefined( self.black ) )
            self.black destroy();
        if ( game["roundsPlayed"] > 0 && self.sessionstate == "playing" && isAlive( self ) )
            self freezeControls(false);
        
        if(level.allowScopeDelay)
            self thread doAwpFix();

        if (level.bombDroppable)
            self thread dropBomb();
        
        if (level.showAliveCounter)
            self thread showAlive();
        
        /*
        if (level.gameType == "sd" && !game["strat_finished"] && !game["promod_do_readyup"] && !game["promod_timeout_called"] && !game["promod_in_timeout"] && ((isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "match") || (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "pub" && level.allowStrat)))
            self thread promod\strattime::doAmmo();
        */

        self thread weaponloop();
        //thread doDvars();
        
    }
}
teamNames()
{
    self endon("names_done");
    self endon("disconnect");
    if (game["attackers"] == "allies")
    {
        setDvar("g_ScoresColor_Allies", "0.8 0 0 1");
        setDvar("g_ScoresColor_Axis", "0 0.5 1 1");
        setDvar("g_TeamColor_Allies", "0.8 0 0 1");
        setDvar("g_TeamColor_Axis", "0 0.5 1 1");
        setDvar("g_TeamName_Allies", "Attack");
        setDvar("g_TeamName_Axis", "Defence");
    }
    else if (game["defenders"] == "allies")
    {
        setDvar("g_ScoresColor_Allies", "0 0.5 1 1");
        setDvar("g_ScoresColor_Axis", "0.8 0 0 1");
        setDvar("g_TeamColor_Allies", "0 0.5 1 1");
        setDvar("g_TeamColor_Axis", "0.8 0 0 1");
        setDvar("g_TeamName_Allies", "Defence");
        setDvar("g_TeamName_Axis", "Attack");
    }
    if (game["switchsides"])
    {
        if (game["defenders"] == "allies")
        {
            setDvar("g_ScoresColor_Allies", "0 0.5 1 1");
            setDvar("g_ScoresColor_Axis", "0.8 0 0 1");
            setDvar("g_TeamColor_Allies", "0 0.5 1 1");
            setDvar("g_TeamColor_Axis", "0.8 0 0 1");
            setDvar("g_TeamName_Allies", "Defence");
            setDvar("g_TeamName_Axis", "Attack");
        }
        else if (game["attackers"] == "allies")
        {
            setDvar("g_ScoresColor_Allies", "0.8 0 0 1");
            setDvar("g_ScoresColor_Axis", "0 0.5 1 1");
            setDvar("g_TeamColor_Allies", "0.8 0 0 1");
            setDvar("g_TeamColor_Axis", "0 0.5 1 1");
            setDvar("g_TeamName_Allies", "Attack");
            setDvar("g_TeamName_Axis", "Defence");
        }
    }
    self notify("names_done");
}
doDvars()
{
    if (self.pers["cur_nmap"] == 0)
    {
        self setClientDvar("r_normalmap", 0);
    }
    else
    {
        self setClientDvar("r_normalmap", 1);
    }
    if (self.pers["cur_tweak"] == 1)
    {    
        self setClientDvar("r_filmusetweaks", 1);
    }
    else
    {    
        self setClientDvar("r_filmusetweaks", 0);
    }
}
weaponLoop()
{
    self endon("death");
    self endon("disconnect");
    while (true)
    {
        self waittill("weapon_change", newWeapon);
        if (isSubStr( newWeapon, "iw5_deserteagle"))
        {
            self player_recoilScaleOn(60);
        }
        else
        {
            self player_recoilScaleOn(100);
        }

        /*
        if ( newWeapon == "iw5_cheytac_mp" && newWeapon == "iw5_msr" && newWeapon == "iw5_l96a1_mp" && !self _hasPerk("specialty_bulletaccuracy" ) )
        {    
            self _setPerk( "specialty_bulletaccuracy" );
        }
        else if ( newWeapon == "iw5_cheytac_mp" && newWeapon == "iw5_msr" && newWeapon == "iw5_l96a1_mp" && self _hasPerk("specialty_bulletaccuracy" ) )
        {    
            self _unsetPerk( "specialty_bulletaccuracy" );
        }
        if ( ( isSubStr( newWeapon, "iw5_masada" ) || 
        isSubStr( newWeapon, "iw5_m4" ) || 
        isSubStr( newWeapon, "iw5_m16" ) || 
        isSubStr( newWeapon, "iw5_scar" ) || 
        isSubStr( newWeapon, "iw5_cm901" ) || 
        isSubStr( newWeapon, "iw5_type95" ) || 
        isSubStr( newWeapon, "iw5_g36c" ) || 
        isSubStr( newWeapon, "iw5_acr" ) ||
        isSubStr( newWeapon, "iw5_mk14" ) || 
        isSubStr( newWeapon, "iw5_ak47" ) || 
        isSubStr( newWeapon, "iw5_fad" ) || 
        isSubStr( newWeapon, "iw5_mp5" ) || 
        isSubStr( newWeapon, "iw5_ump45" ) || 
        isSubStr( newWeapon, "iw5_pp90m1" ) || 
        isSubStr( newWeapon, "iw5_p90" ) || 
        isSubStr( newWeapon, "iw5_pm9" ) || 
        isSubStr( newWeapon, "iw5_mp7" ) || 
        isSubStr( newWeapon, "iw5_ak74u" ) ||
        isSubStr( newWeapon, "iw5_usas12" ) ||
        isSubStr( newWeapon, "iw5_ksg" ) ||
        isSubStr( newWeapon, "iw5_spas12" ) ||
        isSubStr( newWeapon, "iw5_aa12" ) ||
        isSubStr( newWeapon, "iw5_striker" ) ||
        isSubStr( newWeapon, "iw5_model1887" ) ) && !self _hasPerk( "specialty_bulletdamage" ) )
        {    
            self _setPerk( "specialty_bulletdamage" );
        }
        else if ( ( !isSubStr( newWeapon, "iw5_masada") && 
        !isSubStr( newWeapon, "iw5_m4" ) &&
        !isSubStr( newWeapon, "iw5_m16" ) &&
        !isSubStr( newWeapon, "iw5_scar" ) &&
        !isSubStr( newWeapon, "iw5_cm901" ) &&
        !isSubStr( newWeapon, "iw5_type95" ) &&
        !isSubStr( newWeapon, "iw5_g36c" ) &&
        !isSubStr( newWeapon, "iw5_acr" ) &&
        !isSubStr( newWeapon, "iw5_mk14" ) &&
        !isSubStr( newWeapon, "iw5_ak47" ) &&
        !isSubStr( newWeapon, "iw5_fad" ) &&
        !isSubStr( newWeapon, "iw5_mp5" ) &&
        !isSubStr( newWeapon, "iw5_ump45" ) &&
        !isSubStr( newWeapon, "iw5_pp90m1" ) &&
        !isSubStr( newWeapon, "iw5_p90" ) &&
        !isSubStr( newWeapon, "iw5_pm9" ) &&
        !isSubStr( newWeapon, "iw5_mp7" ) &&
        !isSubStr( newWeapon, "iw5_ak74u" ) &&
        !isSubStr( newWeapon, "iw5_usas12" ) &&
        !isSubStr( newWeapon, "iw5_ksg" ) &&
        !isSubStr( newWeapon, "iw5_spas12" ) &&
        !isSubStr( newWeapon, "iw5_aa12" ) &&
        !isSubStr( newWeapon, "iw5_striker" ) &&
        !isSubStr( newWeapon, "iw5_model1887" ) ) && self _hasPerk("specialty_bulletdamage" ) )
        {    
            self _unsetPerk("specialty_bulletdamage");
        }
        */
        
    }
}

noGhosting()
{
    self endon("disconnect");
    self waittill("death");
    wait 1.5;
    if (self.sessionstate != "playing" && game["state"] != "postgame")
    {
        self freezeControls(true);
        if (isInKillcam())
        {    
            self waittill_any("abort_killcam", "killcam_ended");
        }
        self.black = self createFontString("default", 1.4);
        self.black setPoint("CENTER", "CENTER", 0, 0);
        self.black setText("^1No Ghosting! ^7Press ^1[{+toggleads_throw}] ^7to spectate teammates!");

        self setClientDvar("r_filmusetweaks", 0);
        self VisionSetNakedForPlayer("blacktest", 0);
    }
    self notifyOnPlayerCommand("melee", "+melee");
    for (;;)
    {
        self waittill("melee");
        if (self.sessionstate != "playing" && game["state"] != "postgame" && !isInKillcam() && self.pers["team"] != "spectator")
        {
            
            self freezeControls(true);
            spectatedPlayer = self GetSpectatingPlayer();

            if (!isDefined(self.black) && !isDefined(spectatedPlayer))
            {
                self.black = self createFontString("default", 1.4);
                self.black setPoint("CENTER", "CENTER", 0, 0);
                self.black setText("^1No Ghosting! ^7Press ^1[{+toggleads_throw}] ^7to spectate your teammates!");

                self setClientDvar("r_filmusetweaks", 0);
                self VisionSetNakedForPlayer("blacktest", 0);
            }
        }
    }
}

dropBomb()
{
    self endon("death");
    self endon("disconnect");
    self notifyOnPlayerCommand("drop_bomb", "+actionslot 4");
    for (;;)
    {
        self waittill("drop_bomb");

        if (level.gameType != "sd" && level.gameType != "sab")
            continue;

        if (level.gameType == "sd" && self.pers["team"] != game["attackers"])
            continue;

        if (!self.isBombCarrier)
            continue;

        if (self.isPlanting)
            continue;

        self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
        self.isBombCarrier = false;
        level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry("none");
        wait 1.5;
        level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry("friendly");
    }
}

doAwpFix() 
{
    self endon( "death" );
    self endon( "disconnect" );

    for(;;)
    {
        self waittill( "weapon_fired", weapon );

        if ( weapon == "iw5_msr_mp" )
            self allowADS( false );
            self thread watchSwitch();
            wait 1;
            self notify( "allow" );
            wait 0.1;
            self allowADS( true );
    }
}

watchSwitch()
{
    self endon( "allow" );
    self endon( "death" );

    for(;;)
    {
        self waittill( "weapon_change", newWeapon );

        if ( newWeapon != "iw5_msr_mp" )
            self allowADS( true );
    }
    self notify( "allow" );
}

showAlive()
{
    self endon("death");
    self endon("disconnect");

    alive_attackers = level.aliveCount[game["attackers"]];
    alive_defenders = level.aliveCount[game["defenders"]];

    sap = self createFontString("default", 1.8);
    sap setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", -136, -12);
    sap.hidewheninmenu = true;

    self thread deleteondeath(sap);

    while (game["state"] == "playing" && game["state"] != "postgame" && !isInKillcam())
    {
        alive_attackers = level.aliveCount[game["attackers"]];
        alive_defenders = level.aliveCount[game["defenders"]];

        if (self.pers["team"] == game["attackers"])
        {    
            sap setText("^2" + alive_attackers + "^1" + alive_defenders);
        }
        else if (self.pers["team"] == game["defenders"])
        {    
            sap setText("^2" + alive_defenders + "^1" + alive_attackers);
        }

        wait 0.1;
    }
    sap destroy();
}

deleteOnDeath(hud)
{
    self waittill("death");
    hud destroy();
}