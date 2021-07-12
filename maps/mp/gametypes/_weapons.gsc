// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_equipment;

attachmentGroup( attachmentName )
{
    return tablelookup( "mp/attachmentTable.csv", 4, attachmentName, 2 );
}

getAttachmentList()
{
    attachmentList = [];
    index = 0;

    for ( attachmentName = tablelookup( "mp/attachmentTable.csv", 9, index, 4 ); attachmentName != ""; attachmentName = tablelookup( "mp/attachmentTable.csv", 9, index, 4 ) )
    {
        attachmentList[attachmentList.size] = attachmentName;
        index++;
    }

    return common_scripts\utility::alphabetize( attachmentList );
}

init()
{
    level.scavenger_altmode = 1;
    level.scavenger_secondary = 1;
    level.maxPerPlayerExplosives = max( maps\mp\_utility::getIntProperty( "scr_maxPerPlayerExplosives", 2 ), 1 );
    level.riotShieldXPBullets = maps\mp\_utility::getIntProperty( "scr_riotShieldXPBullets", 15 );

    switch ( maps\mp\_utility::getIntProperty( "perk_scavengerMode", 0 ) )
    {
        case 1:
            level.scavenger_altmode = 0;
            break;
        case 2:
            level.scavenger_secondary = 0;
            break;
        case 3:
            level.scavenger_altmode = 0;
            level.scavenger_secondary = 0;
            break;
    }

    attachmentList = getAttachmentList();
    max_weapon_num = 149;
    level.weaponList = [];

    for ( weaponId = 0; weaponId <= max_weapon_num; weaponId++ )
    {
        weapon_name = tablelookup( "mp/statstable.csv", 0, weaponId, 4 );

        if ( weapon_name == "" )
            continue;

        if ( !issubstr( tablelookup( "mp/statsTable.csv", 0, weaponId, 2 ), "weapon_" ) )
            continue;

        if ( issubstr( weapon_name, "iw5_" ) )
        {
            weaponTokens = strtok( weapon_name, "_" );
            weapon_name = weaponTokens[0] + "_" + weaponTokens[1] + "_mp";
            level.weaponList[level.weaponList.size] = weapon_name;
            continue;
        }
        else
            level.weaponList[level.weaponList.size] = weapon_name + "_mp";

        attachmentNames = [];

        for ( innerLoopCount = 0; innerLoopCount < 10; innerLoopCount++ )
        {
            attachmentName = tablelookup( "mp/statStable.csv", 0, weaponId, innerLoopCount + 11 );

            if ( attachmentName == "" )
                break;

            attachmentNames[attachmentName] = 1;
        }

        attachments = [];

        foreach ( attachmentName in attachmentList )
        {
            if ( !isdefined( attachmentNames[attachmentName] ) )
                continue;

            level.weaponList[level.weaponList.size] = weapon_name + "_" + attachmentName + "_mp";
            attachments[attachments.size] = attachmentName;
        }

        attachmentCombos = [];

        for ( i = 0; i < attachments.size - 1; i++ )
        {
            colIndex = tablelookuprownum( "mp/attachmentCombos.csv", 0, attachments[i] );

            for ( j = i + 1; j < attachments.size; j++ )
            {
                if ( tablelookup( "mp/attachmentCombos.csv", 0, attachments[j], colIndex ) == "no" )
                    continue;

                attachmentCombos[attachmentCombos.size] = attachments[i] + "_" + attachments[j];
            }
        }

        foreach ( combo in attachmentCombos )
            level.weaponList[level.weaponList.size] = weapon_name + "_" + combo + "_mp";
    }

    foreach ( weaponName in level.weaponList )
        precacheitem( weaponName );

    precacheitem( "flare_mp" );
    precacheitem( "scavenger_bag_mp" );
    precacheitem( "frag_grenade_short_mp" );
    precacheitem( "c4death_mp" );
    precacheitem( "destructible_car" );
    precacheitem( "destructible_toy" );
    precacheitem( "bouncingbetty_mp" );
    precacheitem( "scrambler_mp" );
    precacheitem( "portable_radar_mp" );

    precacheshellshock( "default" );
    precacheshellshock( "concussion_grenade_mp" );
    thread maps\mp\_flashgrenades::main();
    thread maps\mp\_entityheadicons::init();
    thread maps\mp\_empgrenade::init();

    claymoreDetectionConeAngle = 70;
    level.claymoreDetectionDot = cos( claymoreDetectionConeAngle );
    level.claymoreDetectionMinDist = 20;
    level.claymoreDetectionGracePeriod = 0.75;
    level.claymoreDetonateRadius = 192;
    level.mineDetectionGracePeriod = 0.3;
    level.mineDetectionRadius = 100;
    level.mineDetectionHeight = 20;
    level.mineDamageRadius = 256;
    level.mineDamageMin = 70;
    level.mineDamageMax = 210;
    level.mineDamageHalfHeight = 46;
    level.mineSelfDestructTime = 120;
    level.mine_launch = loadfx( "impacts/bouncing_betty_launch_dirt" );
    level.mine_spin = loadfx( "dust/bouncing_betty_swirl" );
    level.mine_explode = loadfx( "explosions/bouncing_betty_explosion" );
    level.mine_beacon["enemy"] = loadfx( "misc/light_c4_blink" );
    level.mine_beacon["friendly"] = loadfx( "misc/light_mine_blink_friendly" );
    level.empGrenadeExplode = loadfx( "explosions/emp_grenade" );
    level.delayMineTime = 3.0;
    level.sentry_fire = loadfx( "muzzleflashes/shotgunflash" );
    level.stingerFXid = loadfx( "explosions/aerial_explosion_large" );

    level.primary_weapon_array = [];
    level.side_arm_array = [];
    level.grenade_array = [];
    level.missile_array = [];
    level.inventory_array = [];
    level.mines = [];

    precachemodel( "weapon_claymore_bombsquad" );
    precachemodel( "weapon_c4_bombsquad" );
    precachemodel( "projectile_m67fraggrenade_bombsquad" );
    precachemodel( "projectile_semtex_grenade_bombsquad" );
    precachemodel( "weapon_light_stick_tactical_bombsquad" );
    precachemodel( "projectile_bouncing_betty_grenade" );
    precachemodel( "projectile_bouncing_betty_grenade_bombsquad" );
    precachemodel( "projectile_bouncing_betty_trigger" );
    precachemodel( "weapon_jammer" );
    precachemodel( "weapon_jammer_bombsquad" );
    precachemodel( "weapon_radar" );
    precachemodel( "weapon_radar_bombsquad" );
    precachemodel( "mp_trophy_system" );
    precachemodel( "mp_trophy_system_bombsquad" );

    level._effect["equipment_explode"] = loadfx( "explosions/sparks_a" );
    level._effect["sniperDustLarge"] = loadfx( "dust/sniper_dust_kickup" );
    level._effect["sniperDustSmall"] = loadfx( "dust/sniper_dust_kickup_minimal" );
    level._effect["sniperDustLargeSuppress"] = loadfx( "dust/sniper_dust_kickup_accum_suppress" );
    level._effect["sniperDustSmallSuppress"] = loadfx( "dust/sniper_dust_kickup_accum_supress_minimal" );
    level thread onPlayerConnect();
    level.c4explodethisframe = 0;
    common_scripts\utility::array_thread( getentarray( "misc_turret", "classname" ), ::turret_monitorUse );
}

dumpIt()
{
    wait 5.0;
}

bombSquadWaiter()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire",  weaponEnt, weaponName );
        team = level.otherTeam[self.team];

        if ( weaponName == "c4_mp" )
        {
            weaponEnt thread createBombSquadModel( "weapon_c4_bombsquad", "tag_origin", team, self );
            continue;
        }

        if ( weaponName == "claymore_mp" )
        {
            weaponEnt thread createBombSquadModel( "weapon_claymore_bombsquad", "tag_origin", team, self );
            continue;
        }

        if ( weaponName == "frag_grenade_mp" )
        {
            weaponEnt thread createBombSquadModel( "projectile_m67fraggrenade_bombsquad", "tag_weapon", team, self );
            continue;
        }

        if ( weaponName == "frag_grenade_short_mp" )
        {
            weaponEnt thread createBombSquadModel( "projectile_m67fraggrenade_bombsquad", "tag_weapon", team, self );
            continue;
        }

        if ( weaponName == "semtex_mp" )
            weaponEnt thread createBombSquadModel( "projectile_semtex_grenade_bombsquad", "tag_weapon", team, self );
    }
}

createBombSquadModel( modelName, tagName, teamName, owner )
{
    bombSquadModel = spawn( "script_model", ( 0, 0, 0 ) );
    bombSquadModel hide();
    wait 0.05;

    if ( !isdefined( self ) )
        return;

    bombSquadModel thread bombSquadVisibilityUpdater( teamName, owner );
    bombSquadModel setmodel( modelName );
    bombSquadModel linkto( self, tagName, ( 0, 0, 0 ), ( 0, 0, 0 ) );
    bombSquadModel setcontents( 0 );
    self waittill( "death" );

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    bombSquadModel delete();
}

bombSquadVisibilityUpdater( teamName, owner )
{
    self endon( "death" );

    foreach ( player in level.players )
    {
        if ( level.teamBased )
        {
            if ( player.team == teamName && player maps\mp\_utility::_hasPerk( "specialty_detectexplosive" ) )
                self showtoplayer( player );

            continue;
        }

        if ( isdefined( owner ) && player == owner )
            continue;

        if ( !player maps\mp\_utility::_hasPerk( "specialty_detectexplosive" ) )
            continue;

        self showtoplayer( player );
    }

    for (;;)
    {
        level common_scripts\utility::waittill_any( "joined_team", "player_spawned", "changed_kit", "update_bombsquad" );
        self hide();

        foreach ( player in level.players )
        {
            if ( level.teamBased )
            {
                if ( player.team == teamName && player maps\mp\_utility::_hasPerk( "specialty_detectexplosive" ) )
                    self showtoplayer( player );

                continue;
            }

            if ( isdefined( owner ) && player == owner )
                continue;

            if ( !player maps\mp\_utility::_hasPerk( "specialty_detectexplosive" ) )
                continue;

            self showtoplayer( player );
        }
    }
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        player.hits = 0;
        player.hasDoneCombat = 0;
        player kc_regweaponforfxremoval( "remotemissile_projectile_mp" );
        player thread onPlayerSpawned();
        player thread bombSquadWaiter();
        player thread watchMissileUsage();
        player thread sniperDustWatcher();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );
        self.currentWeaponAtSpawn = self getcurrentweapon();
        self.empEndTime = 0;
        self.concussionEndTime = 0;
        self.hits = 0;
        self.hasDoneCombat = 0;

        if ( !isdefined( self.trackingWeaponName ) )
        {
            self.trackingWeaponName = "";
            self.trackingWeaponName = "none";
            self.trackingWeaponShots = 0;
            self.trackingWeaponKills = 0;
            self.trackingWeaponHits = 0;
            self.trackingWeaponHeadShots = 0;
            self.trackingWeaponDeaths = 0;
        }

        thread watchWeaponUsage();
        thread watchGrenadeUsage();
        thread watchWeaponChange();
        thread WatchStingerUsage();
        thread WatchJavelinUsage();
        thread watchSentryUsage();
        thread watchWeaponReload();
        thread watchMineUsage();
        thread maps\mp\gametypes\_class::trackRiotShield();
        thread maps\mp\_equipment::watchTrophyUsage();
        thread stanceRecoilAdjuster();
        self.lastHitTime = [];
        self.droppedDeathWeapon = undefined;
        self.tookWeaponFrom = [];
        thread updateSavedLastWeapon();
        thread updateWeaponRank();

        if ( self hasweapon( "semtex_mp" ) )
            thread monitorSemtex();

        self.currentWeaponAtSpawn = undefined;
        self.trophyRemainingAmmo = undefined;
    }
}

sniperDustWatcher()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    lastLargeShotFiredTime = undefined;

    for (;;)
    {
        self waittill( "weapon_fired" );

        if ( maps\mp\_utility::getWeaponClass( self getcurrentweapon() ) != "weapon_sniper" )
            continue;

        if ( self getstance() != "prone" )
            continue;

        playerForward = anglestoforward( self.angles );

        if ( !isdefined( lastLargeShotFiredTime ) || gettime() - lastLargeShotFiredTime > 2000 )
        {
            playfx( level._effect["sniperDustLarge"], self.origin + ( 0, 0, 10 ) + playerForward * 50, playerForward );
            lastLargeShotFiredTime = gettime();
            continue;
        }

        playfx( level._effect["sniperDustLargeSuppress"], self.origin + ( 0, 0, 10 ) + playerForward * 50, playerForward );
    }
}

WatchStingerUsage()
{
    maps\mp\_stinger::StingerUsageLoop();
}

WatchJavelinUsage()
{
    maps\mp\_javelin::JavelinUsageLoop();
}

watchWeaponChange()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    thread watchStartWeaponChange();
    self.lastDroppableWeapon = self.currentWeaponAtSpawn;
    self.hitsThisMag = [];
    weapon = self getcurrentweapon();

    if ( maps\mp\_utility::isCACPrimaryWeapon( weapon ) && !isdefined( self.hitsThisMag[weapon] ) )
        self.hitsThisMag[weapon] = weaponclipsize( weapon );

    self.bothBarrels = undefined;

    if ( issubstr( weapon, "ranger" ) )
        thread watchRangerUsage( weapon );

    for (;;)
    {
        self waittill( "weapon_change", weaponName );

        if ( weaponName == "none" )
            continue;

        if ( weaponName == "briefcase_bomb_mp" || weaponName == "briefcase_bomb_defuse_mp" )
            continue;

        if ( maps\mp\_utility::isKillstreakWeapon( weaponName ) )
        {
            continue;
        }

        weaponTokens = strtok( weaponName, "_" );
        self.bothBarrels = undefined;

        if ( issubstr( weaponName, "ranger" ) )
            thread watchRangerUsage( weaponName );

        if ( weaponTokens[0] == "alt" )
        {
            tmp = getsubstr( weaponName, 4 );
            weaponName = tmp;
            weaponTokens = strtok( weaponName, "_" );
        }
        else if ( weaponTokens[0] != "iw5" )
            weaponName = weaponTokens[0];

        if ( weaponName != "none" && weaponTokens[0] != "iw5" )
        {
            if ( maps\mp\_utility::isCACPrimaryWeapon( weaponName ) && !isdefined( self.hitsThisMag[weaponName + "_mp"] ) )
                self.hitsThisMag[weaponName + "_mp"] = weaponclipsize( weaponName + "_mp" );
        }
        else if ( weaponName != "none" && weaponTokens[0] == "iw5" )
        {
            if ( maps\mp\_utility::isCACPrimaryWeapon( weaponName ) && !isdefined( self.hitsThisMag[weaponName] ) )
                self.hitsThisMag[weaponName] = weaponclipsize( weaponName );
        }

        self.changingWeapon = undefined;

        if ( weaponTokens[0] == "iw5" )
            self.lastDroppableWeapon = weaponName;
        else if ( weaponName != "none" && mayDropWeapon( weaponName + "_mp" ) )
            self.lastDroppableWeapon = weaponName + "_mp";

        if ( isdefined( self.class_num ) )
        {
            if ( weaponTokens[0] != "iw5" )
                weaponName += "_mp";

            if ( isdefined( self.loadoutPrimaryBuff ) && self.loadoutPrimaryBuff != "specialty_null" )
            {
                if ( weaponName == self.primaryWeapon && !maps\mp\_utility::_hasPerk( self.loadoutPrimaryBuff ) )
                    maps\mp\_utility::givePerk( self.loadoutPrimaryBuff, 1 );

                if ( weaponName != self.primaryWeapon && maps\mp\_utility::_hasPerk( self.loadoutPrimaryBuff ) )
                    maps\mp\_utility::_unsetPerk( self.loadoutPrimaryBuff );
            }

            if ( isdefined( self.loadoutSecondaryBuff ) && self.loadoutSecondaryBuff != "specialty_null" )
            {
                if ( weaponName == self.secondaryWeapon && !maps\mp\_utility::_hasPerk( self.loadoutSecondaryBuff ) )
                    maps\mp\_utility::givePerk( self.loadoutSecondaryBuff, 1 );

                if ( weaponName != self.secondaryWeapon && maps\mp\_utility::_hasPerk( self.loadoutSecondaryBuff ) )
                    maps\mp\_utility::_unsetPerk( self.loadoutSecondaryBuff );
            }
        }
    }
}

watchStartWeaponChange()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.changingWeapon = undefined;

    for (;;)
    {
        self waittill( "weapon_switch_started", newWeapon );
        self.changingWeapon = newWeapon;

        if ( newWeapon == "none" && isdefined( self.isCapturingCrate ) && self.isCapturingCrate )
        {
            while ( self.isCapturingCrate )
                wait 0.05;

            self.changingWeapon = undefined;
        }
    }
}

watchWeaponReload()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );

    for (;;)
    {
        self waittill( "reload" );
        weaponName = self getcurrentweapon();
        self.bothBarrels = undefined;

        if ( !issubstr( weaponName, "ranger" ) )
            continue;

        thread watchRangerUsage( weaponName );
    }
}

watchRangerUsage( rangerName )
{
    rightAmmo = self getweaponammoclip( rangerName, "right" );
    leftAmmo = self getweaponammoclip( rangerName, "left" );
    self endon( "reload" );
    self endon( "weapon_change" );

    for (;;)
    {
        self waittill( "weapon_fired", weaponName );

        if ( weaponName != rangerName )
            continue;

        self.bothBarrels = undefined;

        if ( issubstr( rangerName, "akimbo" ) )
        {
            newLeftAmmo = self getweaponammoclip( rangerName, "left" );
            newRightAmmo = self getweaponammoclip( rangerName, "right" );

            if ( leftAmmo != newLeftAmmo && rightAmmo != newRightAmmo )
                self.bothBarrels = 1;

            if ( !newLeftAmmo || !newRightAmmo )
                return;

            leftAmmo = newLeftAmmo;
            rightAmmo = newRightAmmo;
            continue;
        }

        if ( rightAmmo == 2 && !self getweaponammoclip( rangerName, "right" ) )
        {
            self.bothBarrels = 1;
            return;
        }
    }
}

isHackWeapon( weapon )
{
    if ( weapon == "radar_mp" || weapon == "airstrike_mp" || weapon == "helicopter_mp" )
        return 1;

    if ( weapon == "briefcase_bomb_mp" )
        return 1;

    return 0;
}

mayDropWeapon( weapon )
{
    if ( weapon == "none" )
        return 0;

    if ( issubstr( weapon, "ac130" ) )
        return 0;

    if ( issubstr( weapon, "uav" ) )
        return 0;

    if ( issubstr( weapon, "killstreak" ) )
        return 0;

    invType = weaponinventorytype( weapon );

    if ( invType != "primary" )
        return 0;

    return 1;
}

dropWeaponForDeath( attacker )
{
    if ( isdefined( level.blockWeaponDrops ) )
        return;

    if ( isdefined( self.droppedDeathWeapon ) )
        return;

    if ( level.inGracePeriod )
        return;

    weapon = self.lastDroppableWeapon;

    if ( !isdefined( weapon ) )
        return;

    if ( weapon == "none" )
        return;

    if ( !self hasweapon( weapon ) )
        return;

    tokens = strtok( weapon, "_" );

    if ( tokens[0] == "alt" )
    {
        for ( i = 0; i < tokens.size; i++ )
        {
            if ( i > 0 && i < 2 )
            {
                weapon += tokens[i];
                continue;
            }

            if ( i > 0 )
            {
                weapon += ( "_" + tokens[i] );
                continue;
            }

            weapon = "";
        }
    }

    if ( weapon != "riotshield_mp" )
    {
        if ( !self anyammoforweaponmodes( weapon ) )
            return;

        clipAmmoR = self getweaponammoclip( weapon, "right" );
        clipAmmoL = self getweaponammoclip( weapon, "left" );

        if ( !clipAmmoR && !clipAmmoL )
            return;

        stockAmmo = self getweaponammostock( weapon );
        stockMax = weaponmaxammo( weapon );

        if ( stockAmmo > stockMax )
            stockAmmo = stockMax;

        item = self dropitem( weapon );

        if ( !isdefined( item ) )
            return;

        item itemweaponsetammo( clipAmmoR, stockAmmo, clipAmmoL );
    }
    else
    {
        item = self dropitem( weapon );

        if ( !isdefined( item ) )
            return;

        item itemweaponsetammo( 1, 1, 0 );
    }

    self.droppedDeathWeapon = 1;
    item.owner = self;
    item.ownersattacker = attacker;
    item thread watchPickup();
    item thread deletePickupAfterAWhile();
}

detachIfAttached( model, baseTag )
{
    attachSize = self getattachsize();

    for ( i = 0; i < attachSize; i++ )
    {
        attach = self getattachmodelname( i );

        if ( attach != model )
            continue;

        tag = self getattachtagname( i );
        self detach( model, tag );

        if ( tag != baseTag )
        {
            attachSize = self getattachsize();

            for ( i = 0; i < attachSize; i++ )
            {
                tag = self getattachtagname( i );

                if ( tag != baseTag )
                    continue;

                model = self getattachmodelname( i );
                self detach( model, tag );
                break;
            }
        }

        return 1;
    }

    return 0;
}

deletePickupAfterAWhile()
{
    self endon( "death" );
    wait 60;

    if ( !isdefined( self ) )
        return;

    self delete();
}

getItemWeaponName()
{
    classname = self.classname;
    weapname = getsubstr( classname, 7 );
    return weapname;
}

watchPickup()
{
    self endon( "death" );
    weapname = getItemWeaponName();

    for (;;)
    {
        self waittill( "trigger", player, droppedItem );

        if ( isdefined( droppedItem ) )
            break;
    }

    droppedWeaponName = droppedItem getItemWeaponName();

    if ( isdefined( player.tookWeaponFrom[droppedWeaponName] ) )
    {
        droppedItem.owner = player.tookWeaponFrom[droppedWeaponName];
        droppedItem.ownersattacker = player;
        player.tookWeaponFrom[droppedWeaponName] = undefined;
    }

    droppedItem thread watchPickup();

    if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
        player.tookWeaponFrom[weapname] = self.owner;
    else
        player.tookWeaponFrom[weapname] = undefined;
}

itemRemoveAmmoFromAltModes()
{
    origweapname = getItemWeaponName();
    curweapname = weaponaltweaponname( origweapname );

    for ( altindex = 1; curweapname != "none" && curweapname != origweapname; altindex++ )
    {
        self itemweaponsetammo( 0, 0, 0, altindex );
        curweapname = weaponaltweaponname( curweapname );
    }
}

handleScavengerBagPickup( scrPlayer )
{
    self endon( "death" );
    level endon( "game_ended" );
    self waittill( "scavenger", destPlayer );
    destPlayer notify( "scavenger_pickup" );
    destPlayer playlocalsound( "scavenger_pack_pickup" );
    offhandWeapons = destPlayer getweaponslistoffhands();

    foreach ( offhand in offhandWeapons )
    {
        if ( offhand != "throwingknife_mp" )
            continue;

        currentClipAmmo = destPlayer getweaponammoclip( offhand );
        destPlayer setweaponammoclip( offhand, currentClipAmmo + 1 );
    }

    primaryWeapons = destPlayer getweaponslistprimaries();

    foreach ( primary in primaryWeapons )
    {
        if ( !maps\mp\_utility::isCACPrimaryWeapon( primary ) && !level.scavenger_secondary )
            continue;

        if ( issubstr( primary, "alt" ) && ( issubstr( primary, "m320" ) || issubstr( primary, "gl" ) || issubstr( primary, "gp25" ) || issubstr( primary, "hybrid" ) ) )
            continue;

        if ( maps\mp\_utility::getWeaponClass( primary ) == "weapon_projectile" )
            continue;

        currentStockAmmo = destPlayer getweaponammostock( primary );
        addStockAmmo = weaponclipsize( primary );
        destPlayer setweaponammostock( primary, currentStockAmmo + addStockAmmo );
    }

    destPlayer maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
}

dropScavengerForDeath( attacker )
{
    if ( level.inGracePeriod )
        return;

    if ( !isdefined( attacker ) )
        return;

    if ( attacker == self )
        return;

    dropBag = self dropscavengerbag( "scavenger_bag_mp" );
    dropBag thread handleScavengerBagPickup( self );
}

getWeaponBasedGrenadeCount( weapon )
{
    return 2;
}

getWeaponBasedSmokeGrenadeCount( weapon )
{
    return 1;
}

getFragGrenadeCount()
{
    weapon = "frag_grenade_mp";
    count = self getammocount( weapon );
    return count;
}

getSmokeGrenadeCount()
{
    weapon = "smoke_grenade_mp";
    count = self getammocount( weapon );
    return count;
}

setWeaponStat( name, incValue, statName )
{
    maps\mp\gametypes\_gamelogic::setWeaponStat( name, incValue, statName );
}

watchWeaponUsage( weaponHand )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "weapon_fired", weaponName );
        self.hasDoneCombat = 1;

        if ( !isPrimaryWeapon( weaponName ) && !isSideArm( weaponName ) )
            continue;

        if ( isdefined( self.hitsThisMag[weaponName] ) )
            thread updateMagShots( weaponName );

        totalShots = maps\mp\gametypes\_persistence::statGetBuffered( "totalShots" ) + 1;
        hits = maps\mp\gametypes\_persistence::statGetBuffered( "hits" );
        accuracy = clamp( float( hits ) / float( totalShots ), 0.0, 1.0 ) * 10000.0;
        maps\mp\gametypes\_persistence::statSetBuffered( "totalShots", totalShots );
        maps\mp\gametypes\_persistence::statSetBuffered( "accuracy", int( accuracy ) );
        maps\mp\gametypes\_persistence::statSetBuffered( "misses", int( totalShots - hits ) );

        if ( isdefined( self.lastStandParams ) && self.lastStandParams.lastStandStartTime == gettime() )
        {
            self.hits = 0;
            return;
        }

        shotsFired = 1;
        setWeaponStat( weaponName , shotsFired, "shots" );
        setWeaponStat( weaponName, self.hits, "hits" );
        self.hits = 0;
    }
}

updateMagShots( weaponName )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "updateMagShots_" + weaponName );
    self.hitsThisMag[weaponName]--;
    wait 0.05;
    self.hitsThisMag[weaponName] = weaponclipsize( weaponName );
}

checkHitsThisMag( weaponName )
{
    self endon( "death" );
    self endon( "disconnect" );
    self notify( "updateMagShots_" + weaponName );
    waittillframeend;

    if ( isdefined( self.hitsThisMag[weaponName] ) && self.hitsThisMag[weaponName] == 0 )
    {
        weaponClass = maps\mp\_utility::getWeaponClass( weaponName );
        maps\mp\gametypes\_missions::genericChallenge( weaponClass );
        self.hitsThisMag[weaponName] = weaponclipsize( weaponName );
    }
}

checkHit( weaponName, victim )
{
    if ( maps\mp\_utility::isStrStart( weaponName, "alt_" ) )
    {
        tokens = strtok( weaponName, "_" );

        foreach ( token in tokens )
        {
            if ( token == "shotgun" )
            {
                tmpWeaponName = getsubstr( weaponName, 0, 4 );

                if ( !isPrimaryWeapon( tmpWeaponName ) && !isSideArm( tmpWeaponName ) )
                    self.hits = 1;

                continue;
            }

            if ( token == "hybrid" )
            {
                tmp = getsubstr( weaponName, 4 );
                weaponName = tmp;
            }
        }
    }

    if ( !isPrimaryWeapon( weaponName ) && !isSideArm( weaponName ) )
        return;

    switch ( weaponclass( weaponName ) )
    {
        case "rifle":
        case "smg":
        case "mg":
        case "pistol":
            self.hits++;
            break;
        case "spread":
            self.hits = 1;
            break;
        default:
            break;
    }

    waittillframeend;

    if ( isdefined( self.hitsThisMag[weaponName] ) )
        thread checkHitsThisMag( weaponName );

    if ( !isdefined( self.lastHitTime[weaponName] ) )
        self.lastHitTime[weaponName] = 0;

    if ( self.lastHitTime[weaponName] == gettime() )
        return;

    self.lastHitTime[weaponName] = gettime();
    totalShots = maps\mp\gametypes\_persistence::statGetBuffered( "totalShots" );
    hits = maps\mp\gametypes\_persistence::statGetBuffered( "hits" ) + 1;

    if ( hits <= totalShots )
    {
        maps\mp\gametypes\_persistence::statSetBuffered( "hits", hits );
        maps\mp\gametypes\_persistence::statSetBuffered( "misses", int( totalShots - hits ) );
        maps\mp\gametypes\_persistence::statSetBuffered( "accuracy", int( hits * 10000 / totalShots ) );
    }
}

attackerCanDamageItem( attacker, itemOwner )
{
    return friendlyFireCheck( itemOwner, attacker );
}

friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
    if ( !isdefined( owner ) )
        return 1;

    if ( !level.teamBased )
        return 1;

    attackerTeam = attacker.team;
    friendlyFireRule = level.friendlyfire;

    if ( isdefined( forcedFriendlyFireRule ) )
        friendlyFireRule = forcedFriendlyFireRule;

    if ( friendlyFireRule != 0 )
        return 1;

    if ( attacker == owner )
        return 1;

    if ( !isdefined( attackerTeam ) )
        return 1;

    if ( attackerTeam != owner.team )
        return 1;

    return 0;
}

watchGrenadeUsage()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    self.throwingGrenade = undefined;
    self.gotPullbackNotify = 0;

    if ( maps\mp\_utility::getIntProperty( "scr_deleteexplosivesonspawn", 1 ) == 1 )
    {
        if ( isdefined( self.c4array ) )
        {
            for ( i = 0; i < self.c4array.size; i++ )
            {
                if ( isdefined( self.c4array[i] ) )
                {
                    if ( isdefined( self.c4array[i].trigger ) )
                        self.c4array[i].trigger delete();

                    self.c4array[i] delete();
                }
            }
        }

        self.c4array = [];

        if ( isdefined( self.claymorearray ) )
        {
            for ( i = 0; i < self.claymorearray.size; i++ )
            {
                if ( isdefined( self.claymorearray[i] ) )
                {
                    if ( isdefined( self.claymorearray[i].trigger ) )
                        self.claymorearray[i].trigger delete();

                    self.claymorearray[i] delete();
                }
            }
        }

        self.claymorearray = [];

        if ( isdefined( self.bouncingbettyArray ) )
        {
            for ( i = 0; i < self.bouncingbettyArray.size; i++ )
            {
                if ( isdefined( self.bouncingbettyArray[i] ) )
                {
                    if ( isdefined( self.bouncingbettyArray[i].trigger ) )
                        self.bouncingbettyArray[i].trigger delete();

                    self.bouncingbettyArray[i] delete();
                }
            }
        }

        self.bouncingbettyArray = [];
    }
    else
    {
        if ( !isdefined( self.c4array ) )
            self.c4array = [];

        if ( !isdefined( self.claymorearray ) )
            self.claymorearray = [];

        if ( !isdefined( self.bouncingbettyArray ) )
            self.bouncingbettyArray = [];
    }

    thread watchC4();
    thread watchC4Detonation();
    thread watchC4AltDetonation();
    thread watchClaymores();
    thread deleteC4AndClaymoresOnDisconnect();
    thread watchForThrowbacks();

    for (;;)
    {
        self waittill( "grenade_pullback", weaponName );
        setWeaponStat( weaponName, 1, "shots" );
        self.hasDoneCombat = 1;

        if ( weaponName == "claymore_mp" )
            continue;

        self.throwingGrenade = weaponName;
        self.gotPullbackNotify = 1;

        if ( weaponName == "c4_mp" )
            beginC4Tracking();
        else
            beginGrenadeTracking();

        self.throwingGrenade = undefined;
    }
}

beginGrenadeTracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "offhand_end" );
    self endon( "weapon_change" );
    startTime = gettime();
    self waittill( "grenade_fire", grenade, weaponName );

    if ( gettime() - startTime > 1000 && weaponName == "frag_grenade_mp" )
        grenade.isCooked = 1;

    self.changingWeapon = undefined;
    grenade.owner = self;

    switch ( weaponName )
    {
        case "frag_grenade_mp":
        case "semtex_mp":
            grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
            grenade.originalOwner = self;
            break;
        case "concussion_grenade_mp":
        case "flash_grenade_mp":
            grenade thread empExplodeWaiter();
            break;
        case "smoke_grenade_mp":
            grenade thread watchSmokeExplode();
            break;
    }
}

watchSmokeExplode()
{
    level endon( "smokeTimesUp" );
    owner = self.owner;
    owner endon( "disconnect" );
    self waittill( "explode", position );
    smokeRadius = 128;
    smokeTime = 8;
    level thread waitSmokeTime( smokeTime, smokeRadius, position );

    for (;;)
    {
        if ( !isdefined( owner ) )
            break;

        foreach ( player in level.players )
        {
            if ( !isdefined( player ) )
                continue;

            if ( level.teamBased && player.team == owner.team )
                continue;

            if ( distancesquared( player.origin, position ) < smokeRadius * smokeRadius )
            {
                player.inPlayerSmokeScreen = owner;
                continue;
            }

            player.inPlayerSmokeScreen = undefined;
        }

        wait 0.05;
    }
}

waitSmokeTime( smokeTime, smokeRadius, position )
{
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( smokeTime );
    level notify( "smokeTimesUp" );
    waittillframeend;

    foreach ( player in level.players )
    {
        if ( isdefined( player ) )
            player.inPlayerSmokeScreen = undefined;
    }
}

AddMissileToSightTraces( team )
{
    self.team = team;
    level.missilesForSightTraces[level.missilesForSightTraces.size] = self;
    self waittill( "death" );
    newArray = [];

    foreach ( missile in level.missilesForSightTraces )
    {
        if ( missile != self )
            newArray[newArray.size] = missile;
    }

    level.missilesForSightTraces = newArray;
}

watchMissileUsage()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "missile_fire", missile, weaponName );

        if ( issubstr( weaponName, "gl_" ) )
        {
            missile.primaryWeapon = self getcurrentprimaryweapon();
            missile thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
        }

        switch ( weaponName )
        {
            case "stinger_mp":
            case "iw5_smaw_mp":
            case "at4_mp":
                level notify( "stinger_fired",  self, missile, self.stingerTarget );
                thread maps\mp\_utility::setAltSceneObj( missile, "tag_origin", 65 );
                break;
            case "uav_strike_projectile_mp":
            case "remote_mortar_missile_mp":
            case "javelin_mp":
                level notify( "stinger_fired",  self, missile, self.javelinTarget );
                thread maps\mp\_utility::setAltSceneObj( missile, "tag_origin", 65 );
                break;
            default:
                break;
        }

        switch ( weaponName )
        {
            case "ac130_105mm_mp":
            case "ac130_40mm_mp":
            case "remotemissile_projectile_mp":
            case "uav_strike_projectile_mp":
            case "remote_mortar_missile_mp":
            case "iw5_smaw_mp":
            case "javelin_mp":
            case "at4_mp":
            case "rpg_mp":
                missile thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
            default:
                continue;
        }
    }
}

watchSentryUsage()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );

    for (;;)
    {
        self waittill( "sentry_placement_finished", position );
        thread maps\mp\_utility::setAltSceneObj( position, "tag_flash", 65 );
    }
}

empExplodeWaiter()
{
    thread maps\mp\gametypes\_shellshock::endOnDeath();
    self endon( "end_explode" );
    self waittill( "explode", position );
    ents = getEMPDamageEnts( position, 512, 0 );

    foreach ( ent in ents )
    {
        if ( isdefined( ent.owner ) && !friendlyFireCheck( self.owner, ent.owner ) )
            continue;

        ent notify( "emp_damage", self.owner, 8.0 );
    }
}

beginC4Tracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    common_scripts\utility::waittill_any( "grenade_fire", "weapon_change", "offhand_end" );
    self.changingWeapon = undefined;
}

watchForThrowbacks()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( self.gotPullbackNotify )
        {
            self.gotPullbackNotify = 0;
            continue;
        }

        if ( !issubstr( weapname, "frag_" ) && !issubstr( weapname, "semtex_" ) )
            continue;

        grenade.threwBack = 1;
        thread maps\mp\_utility::incPlayerStat( "throwbacks", 1 );
        grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
        grenade.originalOwner = self;
    }
}

watchC4()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", c4, weapname );

        if ( weapname == "c4" || weapname == "c4_mp" )
        {
            if ( !self.c4array.size )
                thread watchC4AltDetonate();

            if ( self.c4array.size )
            {
                self.c4array = common_scripts\utility::array_removeUndefined( self.c4array );

                if ( self.c4array.size >= level.maxPerPlayerExplosives )
                    self.c4array[0] detonate();
            }

            self.c4array[self.c4array.size] = c4;
            c4.owner = self;
            c4.team = self.team;
            c4.activated = 0;
            c4.weaponName = weapname;
            c4 thread maps\mp\gametypes\_shellshock::c4_earthQuake();
            c4 thread c4Activate();
            c4 thread c4Damage();
            c4 thread c4EMPDamage();
            c4 thread c4EMPKillstreakWait();
            c4 waittill( "missile_stuck" );
            c4.trigger = spawn( "script_origin", c4.origin );
            c4 thread equipmentWatchUse( self );
        }
    }
}

c4EMPDamage()
{
    self endon( "death" );

    for (;;)
    {
        self waittill( "emp_damage", attacker, duration );
        playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_origin" );
        self.disabled = 1;
        self notify( "disabled" );
        wait(duration);
        self.disabled = undefined;
        self notify( "enabled" );
    }
}

c4EMPKillstreakWait()
{
    self endon( "death" );

    for (;;)
    {
        level waittill( "emp_update" );

        if ( level.teamBased && level.teamEMPed[self.team] || !level.teamBased && isdefined( level.EMPPlayer ) && level.EMPPlayer != self.owner )
        {
            self.disabled = 1;
            self notify( "disabled" );
            continue;
        }

        self.disabled = undefined;
        self notify( "enabled" );
    }
}

setClaymoreTeamHeadIcon( team )
{
    self endon( "death" );
    wait 0.05;

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( team, ( 0, 0, 20 ) );
    else if ( isdefined( self.owner ) )
        maps\mp\_entityheadicons::setPlayerHeadIcon( self.owner, ( 0, 0, 20 ) );
}

watchClaymores()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );
    self.claymorearray = [];

    for (;;)
    {
        self waittill( "grenade_fire", claymore, weapname );

        if ( weapname == "claymore" || weapname == "claymore_mp" )
        {
            if ( !isalive( self ) )
            {
                claymore delete();
                return;
            }

            claymore hide();
            claymore waittill( "missile_stuck" );
            distanceZ = 40;

            if ( distanceZ * distanceZ < distancesquared( claymore.origin, self.origin ) )
            {
                secTrace = bullettrace( self.origin, self.origin - ( 0, 0, distanceZ ), 0, self );

                if ( secTrace["fraction"] == 1 )
                {
                    claymore delete();
                    self setweaponammostock( "claymore_mp", self getweaponammostock( "claymore_mp" ) + 1 );
                    continue;
                }

                claymore.origin = secTrace["position"];
            }

            claymore show();
            self.claymorearray = common_scripts\utility::array_removeUndefined( self.claymorearray );

            if ( self.claymorearray.size >= level.maxPerPlayerExplosives )
                self.claymorearray[0] detonate();

            self.claymorearray[self.claymorearray.size] = claymore;
            claymore.owner = self;
            claymore.team = self.team;
            claymore.weaponName = weapname;
            claymore.trigger = spawn( "script_origin", claymore.origin );
            level.mines[level.mines.size] = claymore;
            claymore thread c4Damage();
            claymore thread c4EMPDamage();
            claymore thread c4EMPKillstreakWait();
            claymore thread claymoreDetonation();
            claymore thread equipmentWatchUse( self );
            claymore thread setClaymoreTeamHeadIcon( self.pers["team"] );
            self.changingWeapon = undefined;
        }
    }
}

equipmentWatchUse( owner )
{
    self endon( "spawned_player" );
    self endon( "disconnect" );
    self.trigger setcursorhint( "HINT_NOICON" );

    if ( self.weaponName == "c4_mp" )
        self.trigger sethintstring( &"MP_PICKUP_C4" );
    else if ( self.weaponName == "claymore_mp" )
        self.trigger sethintstring( &"MP_PICKUP_CLAYMORE" );
    else if ( self.weaponName == "bouncingbetty_mp" )
        self.trigger sethintstring( &"MP_PICKUP_BOUNCING_BETTY" );

    self.trigger maps\mp\_utility::setSelfUsable( owner );
    self.trigger thread maps\mp\_utility::notUsableForJoiningPlayers( self );

    for (;;)
    {
        self.trigger waittill( "trigger",  owner  );
        owner playlocalsound( "scavenger_pack_pickup" );
        owner setweaponammostock( self.weaponName, owner getweaponammostock( self.weaponName ) + 1 );
        self.trigger delete();
        self delete();
        self notify( "death" );
    }
}

claymoreDetonation()
{
    self endon( "death" );
    damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - level.claymoreDetonateRadius ), 0, level.claymoreDetonateRadius, level.claymoreDetonateRadius * 2 );
    thread deleteOnDeath( damagearea );

    for (;;)
    {
        damagearea waittill( "trigger", player );

        if ( getdvarint( "scr_claymoredebug" ) != 1 )
        {
            if ( isdefined( self.owner ) && player == self.owner )
                continue;

            if ( !friendlyFireCheck( self.owner, player, 0 ) )
                continue;
        }

        if ( lengthsquared( player getentityvelocity() ) < 10 )
            continue;

        zDistance = abs( player.origin[2] - self.origin[2] );

        if ( zDistance > 128 )
            continue;

        if ( !player shouldAffectClaymore( self ) )
            continue;

        if ( player damageconetrace( self.origin, self ) > 0 )
            break;
    }

    self playsound( "claymore_activated" );

    if ( isplayer( player ) && player maps\mp\_utility::_hasPerk( "specialty_delaymine" ) )
    {
        player notify( "triggered_claymore" );
        wait(level.delayMineTime);
    }
    else
        wait(level.claymoreDetectionGracePeriod);

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    self detonate();
}

shouldAffectClaymore( claymore )
{
    if ( isdefined( claymore.disabled ) )
        return 0;

    pos = self.origin + ( 0, 0, 32 );
    dirToPos = pos - claymore.origin;
    claymoreForward = anglestoforward( claymore.angles );
    dist = vectordot( dirToPos, claymoreForward );

    if ( dist < level.claymoreDetectionMinDist )
        return 0;

    dirToPos = vectornormalize( dirToPos );
    dot = vectordot( dirToPos, claymoreForward );
    return dot > level.claymoreDetectionDot;
}

deleteOnDeath( ent )
{
    self waittill( "death" );
    wait 0.05;

    if ( isdefined( ent ) )
    {
        if ( isdefined( ent.trigger ) )
            ent.trigger delete();

        ent delete();
    }
}

c4Activate()
{
    self endon( "death" );
    self waittill( "missile_stuck" );
    wait 0.05;
    self notify( "activated" );
    self.activated = 1;
}

watchC4AltDetonate()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "detonated" );
    level endon( "game_ended" );
    buttonTime = 0;

    for (;;)
    {
        if ( self usebuttonpressed() )
        {
            buttonTime = 0;

            while ( self usebuttonpressed() )
            {
                buttonTime += 0.05;
                wait 0.05;
            }

            if ( buttonTime >= 0.5 )
                continue;

            buttonTime = 0;

            while ( !self usebuttonpressed() && buttonTime < 0.5 )
            {
                buttonTime += 0.05;
                wait 0.05;
            }

            if ( buttonTime >= 0.5 )
                continue;

            if ( !self.c4array.size )
                return;

            self notify( "alt_detonate" );
        }

        wait 0.05;
    }
}

watchC4Detonation()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittillmatch( "detonate",  "c4_mp"  );
        newarray = [];

        for ( i = 0; i < self.c4array.size; i++ )
        {
            c4 = self.c4array[i];

            if ( isdefined( self.c4array[i] ) )
                c4 thread waitAndDetonate( 0.1 );
        }

        self.c4array = newarray;
        self notify( "detonated" );
    }
}

watchC4AltDetonation()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "alt_detonate" );
        weap = self getcurrentweapon();

        if ( weap != "c4_mp" )
        {
            newarray = [];

            for ( i = 0; i < self.c4array.size; i++ )
            {
                c4 = self.c4array[i];

                if ( isdefined( self.c4array[i] ) )
                    c4 thread waitAndDetonate( 0.1 );
            }

            self.c4array = newarray;
            self notify( "detonated" );
        }
    }
}

waitAndDetonate( delay )
{
    self endon( "death" );
    wait(delay);
    waitTillEnabled();
    self detonate();
}

deleteC4AndClaymoresOnDisconnect()
{
    self endon( "death" );
    self waittill( "disconnect" );
    c4array = self.c4array;
    claymorearray = self.claymorearray;
    wait 0.05;

    for ( i = 0; i < c4array.size; i++ )
    {
        if ( isdefined( c4array[i] ) )
            c4array[i] delete();
    }

    for ( i = 0; i < claymorearray.size; i++ )
    {
        if ( isdefined( claymorearray[i] ) )
            claymorearray[i] delete();
    }
}

c4Damage()
{
    self endon( "death" );
    self setcandamage( 1 );
    self.maxHealth = 100000;
    self.health = self.maxHealth;
    attacker = undefined;

    for (;;)
    {
        self waittill( "damage",  damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );

        if ( !isplayer( attacker ) )
            continue;

        if ( !friendlyFireCheck( self.owner, attacker ) )
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

        break;
    }

    if ( level.c4explodethisframe )
        wait(0.1 + randomfloat( 0.4 ));
    else
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    level.c4explodethisframe = 1;
    thread resetC4ExplodeThisFrame();

    if ( isdefined( type ) && ( issubstr( type, "MOD_GRENADE" ) || issubstr( type, "MOD_EXPLOSIVE" ) ) )
        self.wasChained = 1;

    if ( isdefined( iDFlags ) && iDFlags & level.iDFLAGS_PENETRATION )
        self.wasDamagedFromBulletPenetration = 1;

    self.wasDamaged = 1;

    if ( isplayer( attacker ) )
        attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "c4" );

    if ( level.teamBased )
    {
        if ( isdefined( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( self.owner ) && isdefined( self.owner.pers["team"] ) )
        {
            if ( attacker.pers["team"] != self.owner.pers["team"] )
                attacker notify( "destroyed_explosive" );
        }
    }
    else if ( isdefined( self.owner ) && isdefined( attacker ) && attacker != self.owner )
        attacker notify( "destroyed_explosive" );

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    self detonate( attacker );
}

resetC4ExplodeThisFrame()
{
    wait 0.05;
    level.c4explodethisframe = 0;
}

saydamaged( orig, amount )
{
	for ( i = 0; i < 60; i++ )
	{
		//print3d( orig, "damaged! " + amount );
		wait .05;
	}
}

waitTillEnabled()
{
    if ( !isdefined( self.disabled ) )
        return;

    self waittill( "enabled" );
}

c4DetectionTrigger( ownerTeam )
{
    self waittill( "activated" );
    trigger = spawn( "trigger_radius", self.origin - ( 0, 0, 128 ), 0, 512, 256 );
    trigger.detectId = "trigger" + gettime() + randomint( 1000000 );
    trigger.owner = self;
    trigger thread detectIconWaiter( level.otherTeam[ownerTeam] );
    self waittill( "death" );
    trigger notify( "end_detection" );

    if ( isdefined( trigger.bombSquadIcon ) )
        trigger.bombSquadIcon destroy();

    trigger delete();
}

claymoreDetectionTrigger( ownerTeam )
{
    trigger = spawn( "trigger_radius", self.origin - ( 0, 0, 128 ), 0, 512, 256 );
    trigger.detectId = "trigger" + gettime() + randomint( 1000000 );
    trigger.owner = self;
    trigger thread detectIconWaiter( level.otherTeam[ownerTeam] );
    self waittill( "death" );
    trigger notify( "end_detection" );

    if ( isdefined( trigger.bombSquadIcon ) )
        trigger.bombSquadIcon destroy();

    trigger delete();
}

detectIconWaiter( detectTeam )
{
    self endon( "end_detection" );
    level endon( "game_ended" );

    while ( !level.gameEnded )
    {
        self waittill( "trigger", player );

        if ( !player.detectExplosives )
            continue;

        if ( level.teamBased && player.team != detectTeam )
            continue;
        else if ( !level.teamBased && player == self.owner.owner )
            continue;

        if ( isdefined( player.bombSquadIds[self.detectId] ) )
            continue;

        player thread showHeadIcon( self );
    }
}

setupBombSquad()
{
    self.bombSquadIds = [];

    if ( self.detectExplosives && !self.bombSquadIcons.size )
    {
        for ( index = 0; index < 4; index++ )
        {
            self.bombSquadIcons[index] = newclienthudelem( self );
            self.bombSquadIcons[index].x = 0;
            self.bombSquadIcons[index].y = 0;
            self.bombSquadIcons[index].z = 0;
            self.bombSquadIcons[index].alpha = 0;
            self.bombSquadIcons[index].archived = 1;
            self.bombSquadIcons[index] setshader( "waypoint_bombsquad", 14, 14 );
            self.bombSquadIcons[index] setwaypoint( 0, 0 );
            self.bombSquadIcons[index].detectId = "";
        }
    }
    else if ( !self.detectExplosives )
    {
        for ( index = 0; index < self.bombSquadIcons.size; index++ )
            self.bombSquadIcons[index] destroy();

        self.bombSquadIcons = [];
    }
}

showHeadIcon( trigger )
{
    triggerDetectId = trigger.detectId;
    useID = -1;

    for ( index = 0; index < 4; index++ )
    {
        detectId = self.bombSquadIcons[index].detectId;

        if ( detectId == triggerDetectId )
            return;

        if ( detectId == "" )
            useId = index;
    }

    if ( useId < 0 )
        return;

    self.bombSquadIds[triggerDetectId] = 1;
    self.bombSquadIcons[useId].x = trigger.origin[0];
    self.bombSquadIcons[useId].y = trigger.origin[1];
    self.bombSquadIcons[useId].z = trigger.origin[2] + 24 + 128;
    self.bombSquadIcons[useId] fadeovertime( 0.25 );
    self.bombSquadIcons[useId].alpha = 1;
    self.bombSquadIcons[useId].detectId = trigger.detectId;

    while ( isalive( self ) && isdefined( trigger ) && self istouching( trigger ) )
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    self.bombSquadIcons[useId].detectId = "";
    self.bombSquadIcons[useId] fadeovertime( 0.25 );
    self.bombSquadIcons[useId].alpha = 0;
    self.bombSquadIds[triggerDetectId] = undefined;
}

getDamageableEnts( pos, radius, doLOS, startRadius )
{
    ents = [];

    if ( !isdefined( doLOS ) )
        doLOS = 0;

    if ( !isdefined( startRadius ) )
        startRadius = 0;

    radiusSq = radius * radius;
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isalive( players[i] ) || players[i].sessionstate != "playing" )
            continue;

        playerpos = maps\mp\_utility::get_damageable_player_pos( players[i] );
        distSq = distancesquared( pos, playerpos );

        if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, playerpos, startRadius, players[i] ) ) )
            ents[ents.size] = maps\mp\_utility::get_damageable_player( players[i], playerpos );
    }

    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        entpos = maps\mp\_utility::get_damageable_grenade_pos( grenades[i] );
        distSq = distancesquared( pos, entpos );

        if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, grenades[i] ) ) )
            ents[ents.size] = maps\mp\_utility::get_damageable_grenade( grenades[i], entpos );
    }

	destructibles = getentarray( "destructible", "targetname" );

	for ( i = 0; i < destructibles.size; i++ )
	{
		entpos = destructibles[ i ].origin;
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, destructibles[ i ] ) ) )
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = destructibles[ i ];
			newent.damageCenter = entpos;
			ents[ ents.size ] = newent;
		}
	}

	destructables = getentarray( "destructable", "targetname" );

	for ( i = 0; i < destructables.size; i++ )
	{
		entpos = destructables[ i ].origin;
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, destructables[ i ] ) ) )
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = true;
			newent.entity = destructables[ i ];
			newent.damageCenter = entpos;
			ents[ ents.size ] = newent;
		}
	}

	sentries = getentarray( "misc_turret", "classname" );

	foreach ( sentry in sentries )
	{
		entpos = sentry.origin + (0,0,32);
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, sentry ) ) )
		{
			switch( sentry.model )
			{
			case "sentry_minigun_weak":
			case "mp_sam_turret":
			case "mp_remote_turret":
			case "vehicle_ugv_talon_gun_mp":
				ents[ ents.size ] = get_damageable_sentry(sentry, entpos);
				break;
			}
		}
	}

	mines = getentarray( "script_model", "classname" );

	foreach ( mine in mines )
	{
		if ( mine.model != "projectile_bouncing_betty_grenade" && mine.model != "ims_scorpion_body" )
			continue;

		entpos = mine.origin + (0,0,32);
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, mine ) ) )
			ents[ ents.size ] = get_damageable_mine( mine, entpos );
	}

	return ents;
}

getEMPDamageEnts( pos, radius, doLOS, startRadius )
{
	ents = [];

	if ( !isDefined( doLOS ) )
		doLOS = false;

	if ( !isDefined( startRadius ) )
		startRadius = 0;

	grenades = getEntArray( "grenade", "classname" );
	foreach ( grenade in grenades )
	{
		entpos = grenade.origin;
		dist = distance( pos, entpos );
		if ( dist < radius && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, grenade ) ) )
			ents[ ents.size ] = grenade;
	}

	turrets = getEntArray( "misc_turret", "classname" );
	foreach ( turret in turrets )
	{
		entpos = turret.origin;
		dist = distance( pos, entpos );
		if ( dist < radius && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, turret ) ) )
			ents[ ents.size ] = turret;
	}

	return ents;
}

weaponDamageTracePassed( from, to, startRadius, ent )
{
	midpos = undefined;

	diff = to - from;
	if ( lengthsquared( diff ) < startRadius * startRadius )
		return true;
	
	dir = vectornormalize( diff );
	midpos = from + ( dir[ 0 ] * startRadius, dir[ 1 ] * startRadius, dir[ 2 ] * startRadius );

	trace = bullettrace( midpos, to, false, ent );

	if ( getdvarint( "scr_damage_debug" ) != 0 || getdvarint( "scr_debugMines" ) != 0 )
	{
		thread debugprint( from, ".dmg" );
		if ( isdefined( ent ) )
			thread debugprint( to, "." + ent.classname );
		else
			thread debugprint( to, ".undefined" );
		if ( trace[ "fraction" ] == 1 )
		{
			thread debugline( midpos, to, ( 1, 1, 1 ) );
		}
		else
		{
			thread debugline( midpos, trace[ "position" ], ( 1, .9, .8 ) );
			thread debugline( trace[ "position" ], to, ( 1, .4, .3 ) );
		}
	}

	return( trace[ "fraction" ] == 1 );
}

damageEnt( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir )
{
    if ( self.isPlayer )
    {
        self.damageOrigin = damagepos;
        self.entity thread [[ level.callbackPlayerDamage ]]( eInflictor, eAttacker, iDamage, 0, sMeansOfDeath, sWeapon, damagepos, damagedir, "none", 0 );
    }
    else
    {
        if ( self.isADestructable && ( sWeapon == "artillery_mp" || sWeapon == "claymore_mp" || sWeapon == "stealth_bomb_mp" ) )
            return;

        self.entity notify( "damage",  iDamage, eAttacker, ( 0, 0, 0 ), ( 0, 0, 0 ), "MOD_EXPLOSIVE", "", "", "", undefined, sWeapon );
    }
}

debugline( a, b, color )
{
    for ( i = 0; i < 600; i++ )
        //line( a, b, color );
        wait 0.05;
}

debugcircle( center, radius, color, segments )
{
	if ( !isDefined( segments ) )
		segments = 16;
		
	angleFrac = 360/segments;
	circlepoints = [];
	
	for( i = 0; i < segments; i++ )
	{
		angle = (angleFrac * i);
		xAdd = cos(angle) * radius;
		yAdd = sin(angle) * radius;
		x = center[0] + xAdd;
		y = center[1] + yAdd;
		z = center[2];
		circlepoints[circlepoints.size] = ( x, y, z );
	}
	
	for( i = 0; i < circlepoints.size; i++ )
	{
		start = circlepoints[i];
		if (i + 1 >= circlepoints.size)
			end = circlepoints[0];
		else
			end = circlepoints[i + 1];
		
		thread debugline( start, end, color );
	}
}

debugprint( pt, txt )
{
    for ( i = 0; i < 600; i++ )
        //print3d( pt, txt );
        wait 0.05;
}

onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage, eAttacker )
{
    self endon( "death" );
    self endon( "disconnect" );

    switch ( sWeapon )
    {
        case "concussion_grenade_mp":
            if ( !isdefined( eInflictor ) )
                return;
            else if ( meansOfDeath == "MOD_IMPACT" )
                return;

            giveFeedback = 1;

            if ( isdefined( eInflictor.owner ) && eInflictor.owner == eAttacker )
                giveFeedback = 0;

            radius = 512;
            scale = 1 - distance( self.origin, eInflictor.origin ) / radius;

            if ( scale < 0 )
                scale = 0;

            scale = 2 + 4 * scale;

            if ( isdefined( self.stunScaler ) )
                scale *= self.stunScaler;

            wait 0.05;
            eAttacker notify( "stun_hit" );
            self notify( "concussed", eAttacker );

            if ( eAttacker != self )
                eAttacker maps\mp\gametypes\_missions::processChallenge( "ch_alittleconcussed" );

            self shellshock( "concussion_grenade_mp", scale );
            self.concussionEndTime = gettime() + scale * 1000;

            if ( giveFeedback )
                eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "stun" );

            break;
        case "weapon_cobra_mk19_mp":
            break;
        default:
            maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
            break;
    }
}

isPrimaryWeapon( weapName )
{
    if ( weapName == "none" )
        return 0;

    if ( weaponinventorytype( weapName ) != "primary" )
        return 0;

    switch ( weaponclass( weapName ) )
    {
        case "rifle":
        case "smg":
        case "mg":
        case "spread":
        case "pistol":
        case "rocketlauncher":
        case "sniper":
            return 1;
        default:
            return 0;
    }
}

isAltModeWeapon( weapName )
{
    if ( weapName == "none" )
        return 0;

    return weaponinventorytype( weapName ) == "altmode";
}

isInventoryWeapon( weapName )
{
    if ( weapName == "none" )
        return 0;

    return weaponinventorytype( weapName ) == "item";
}

isRiotShield( weapName )
{
    if ( weapName == "none" )
        return 0;

    return weapontype( weapName ) == "riotshield";
}

isOffhandWeapon( weapName )
{
    if ( weapName == "none" )
        return 0;

    return weaponinventorytype( weapName ) == "offhand";
}

isSideArm( weapName )
{
    if ( weapName == "none" )
        return 0;

    if ( weaponinventorytype( weapName ) != "primary" )
        return 0;

    return weaponclass( weapName ) == "pistol";
}

isGrenade( weapName )
{
    weapClass = weaponclass( weapName );
    weapType = weaponinventorytype( weapName );

    if ( weapClass != "grenade" )
        return 0;

    if ( weapType != "offhand" )
        return 0;
}

updateSavedLastWeapon()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    currentWeapon = self.currentWeaponAtSpawn;
    self.saved_lastWeapon = currentWeapon;

    for (;;)
    {
        self waittill( "weapon_change", newWeapon );

        if ( newWeapon == "none" )
        {
            self.saved_lastWeapon = currentWeapon;
            continue;
        }

        weaponInvType = weaponinventorytype( newWeapon );

        if ( weaponInvType != "primary" && weaponInvType != "altmode" )
        {
            self.saved_lastWeapon = currentWeapon;
            continue;
        }

        updateMoveSpeedScale();
        self.saved_lastWeapon = currentWeapon;
        currentWeapon = newWeapon;
    }
}

updateWeaponRank()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    currentWeapon = self.currentWeaponAtSpawn;
    weaponTokens = strtok( currentWeapon, "_" );

    if ( weaponTokens[0] == "iw5" )
        weaponTokens[0] = weaponTokens[0] + "_" + weaponTokens[1];
    else if ( weaponTokens[0] == "alt" )
        weaponTokens[0] = weaponTokens[1] + "_" + weaponTokens[2];

    self.pers["weaponRank"] = maps\mp\gametypes\_rank::getWeaponRank( weaponTokens[0] );

    for (;;)
    {
        self waittill( "weapon_change", newWeapon );

        if ( newWeapon == "none" || maps\mp\_utility::isDeathStreakWeapon( newWeapon ) )
            continue;

        weaponInvType = weaponinventorytype( newWeapon );

        if ( weaponInvType == "primary" )
        {
            weaponTokens = strtok( newWeapon, "_" );

            if ( weaponTokens[0] == "iw5" )
            {
                self.pers["weaponRank"] = maps\mp\gametypes\_rank::getWeaponRank( weaponTokens[0] + "_" + weaponTokens[1] );
                continue;
            }

            if ( weaponTokens[0] == "alt" )
            {
                self.pers["weaponRank"] = maps\mp\gametypes\_rank::getWeaponRank( weaponTokens[1] + "_" + weaponTokens[2] );
                continue;
            }

            self.pers["weaponRank"] = maps\mp\gametypes\_rank::getWeaponRank( weaponTokens[0] );
        }
    }
}

EMPPlayer( numSeconds )
{
    self endon( "disconnect" );
    self endon( "death" );
    thread clearEMPOnDeath();
}

clearEMPOnDeath()
{
    self endon( "disconnect" );
    self waittill( "death" );
}

updateMoveSpeedScale()
{
    self.weaponList = self getweaponslistprimaries();

    if ( self.weaponList.size )
    {
        heaviestWeaponValue = 1000;

        foreach ( weapon in self.weaponList )
        {
            baseWeapon = maps\mp\_utility::getBaseWeaponName( weapon );
            weaponSpeed = int( tablelookup( "mp/statstable.csv", 4, baseWeapon, 8 ) );

            if ( weaponSpeed == 0 )
                continue;

            if ( weaponSpeed < heaviestWeaponValue )
                heaviestWeaponValue = weaponSpeed;
        }

        if ( heaviestWeaponValue > 10 )
            heaviestWeaponValue = 10;
    }
    else
        heaviestWeaponValue = 8;

    normalizedWeaponSpeed = heaviestWeaponValue / 10;
    self.weaponSpeed = normalizedWeaponSpeed;
    self setmovespeedscale( normalizedWeaponSpeed * self.moveSpeedScaler );
}

stanceRecoilAdjuster()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    self notifyonplayercommand( "adjustedStance", "+stance" );
    self notifyonplayercommand( "adjustedStance", "+goStand" );

    for (;;)
    {
        common_scripts\utility::waittill_any( "adjustedStance", "sprint_begin" );
        weapClass = maps\mp\_utility::getWeaponClass( self getcurrentprimaryweapon() );

        if ( weapClass != "weapon_lmg" && weapClass != "weapon_sniper" )
            continue;

        wait 0.5;
        self.stance = self getstance();

        if ( self.stance == "prone" )
        {
            if ( weapClass == "weapon_lmg" )
                maps\mp\_utility::setRecoilScale( 0, 40 );
            else if ( weapClass == "weapon_sniper" )
                maps\mp\_utility::setRecoilScale( 0, 60 );
            else
                maps\mp\_utility::setRecoilScale();

            continue;
        }

        if ( self.stance == "crouch" )
        {
            if ( weapClass == "weapon_lmg" )
                maps\mp\_utility::setRecoilScale( 0, 10 );
            else if ( weapClass == "weapon_sniper" )
                maps\mp\_utility::setRecoilScale( 0, 30 );
            else
                maps\mp\_utility::setRecoilScale();

            continue;
        }

        maps\mp\_utility::setRecoilScale();
    }
}

buildWeaponData( filterPerks )
{
    attachmentList = getAttachmentList();
    max_weapon_num = 149;
    baseWeaponData = [];

    for ( weaponId = 0; weaponId <= max_weapon_num; weaponId++ )
    {
        baseName = tablelookup( "mp/statstable.csv", 0, weaponId, 4 );

        if ( baseName == "" )
            continue;

        assetName = baseName + "_mp";

        if ( !issubstr( tablelookup( "mp/statsTable.csv", 0, weaponId, 2 ), "weapon_" ) )
            continue;

        if ( weaponinventorytype( assetName ) != "primary" )
            continue;

        weaponInfo = spawnstruct();
        weaponInfo.baseName = baseName;
        weaponInfo.assetName = assetName;
        weaponInfo.variants = [];
        weaponInfo.variants[0] = assetName;
        attachmentNames = [];

        for ( innerLoopCount = 0; innerLoopCount < 6; innerLoopCount++ )
        {
            attachmentName = tablelookup( "mp/statStable.csv", 0, weaponId, innerLoopCount + 11 );

            if ( filterPerks )
            {
                switch ( attachmentName )
                {
                    case "fmj":
                    case "rof":
                    case "xmags":
                        continue;
                }
            }

            if ( attachmentName == "" )
                break;

            attachmentNames[attachmentName] = 1;
        }

        attachments = [];

        foreach ( attachmentName in attachmentList )
        {
            if ( !isdefined( attachmentNames[attachmentName] ) )
                continue;

            weaponInfo.variants[weaponInfo.variants.size] = baseName + "_" + attachmentName + "_mp";
            attachments[attachments.size] = attachmentName;
        }

        for ( i = 0; i < attachments.size - 1; i++ )
        {
            colIndex = tablelookuprownum( "mp/attachmentCombos.csv", 0, attachments[j] );

            for ( j = i + 1; j < attachments.size; j++ )
            {
                if ( tablelookup( "mp/attachmentCombos.csv", 0, attachments[j], colIndex ) == "no" )
                    continue;

                weaponInfo.variants[weaponInfo.variants.size] = baseName + "_" + attachments[j] + "_" + attachments[j] + "_mp";
            }
        }

        baseWeaponData[baseName] = weaponInfo;
    }

    return baseWeaponData;
}

monitorSemtex()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "faux_spawn" );

    for (;;)
    {
        self waittill( "grenade_fire", weapon );

        if ( !issubstr( weapon.model, "semtex" ) )
            continue;

        weapon waittill( "missile_stuck", stuckTo );

        if ( !isplayer( stuckTo ) )
            continue;

        if ( level.teamBased && isdefined( stuckTo.team ) && stuckTo.team == self.team )
        {
            weapon.isStuck = "friendly";
            continue;
        }

        weapon.isStuck = "enemy";
        weapon.stuckEnemyEntity = stuckTo;
        stuckTo maps\mp\gametypes\_hud_message::playerCardSplashNotify( "semtex_stuck", self );
        thread maps\mp\gametypes\_hud_message::splashNotify( "stuck_semtex", 100 );
        self notify( "process",  "ch_bullseye"  );
    }
}

turret_monitorUse()
{
    for (;;)
    {
        self waittill( "trigger", player );
        thread turret_playerThread( player );
    }
}

turret_playerThread( player )
{
    player endon( "death" );
    player endon( "disconnect" );
    player notify( "weapon_change", "none" );
    self waittill( "turret_deactivate" );
    player notify( "weapon_change", player getcurrentweapon() );
}

spawnMine( origin, owner, type, angles )
{
    if ( !isdefined( angles ) )
        angles = ( 0, randomfloat( 360 ), 0 );

    model = "projectile_bouncing_betty_grenade";
    mine = spawn( "script_model", origin );
    mine.angles = angles;
    mine setmodel( model );
    mine.owner = owner;
    mine.weaponName = "bouncingbetty_mp";
    level.mines[level.mines.size] = mine;
    mine.killCamOffset = ( 0, 0, 4 );
    mine.killCamEnt = spawn( "script_model", mine.origin + mine.killCamOffset );
    mine.killCamEnt setscriptmoverkillcam( "explosive" );

    if ( !isdefined( type ) || type == "equipment" )
    {
        owner.equipmentMines = common_scripts\utility::array_removeUndefined( owner.equipmentMines );

        if ( owner.equipmentMines.size >= level.maxPerPlayerExplosives )
            owner.equipmentMines[0] delete();

        owner.equipmentMines[owner.equipmentMines.size] = mine;
    }
    else
        owner.killstreakMines[owner.killstreakMines.size] = mine;

    mine thread createBombSquadModel( "projectile_bouncing_betty_grenade_bombsquad", "tag_origin", level.otherTeam[owner.team], owner );
    mine thread mineBeacon();
    mine thread setClaymoreTeamHeadIcon( owner.pers["team"] );
    mine thread mineDamageMonitor();
    mine thread mineProximityTrigger();
    return mine;
}

mineDamageMonitor()
{
    self endon( "mine_triggered" );
    self endon( "mine_selfdestruct" );
    self endon( "death" );
    self setcandamage( 1 );
    self.maxHealth = 100000;
    self.health = self.maxHealth;
    attacker = undefined;

    for (;;)
    {
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );

        if ( !isplayer( attacker ) || isdefined( weapon ) && weapon == "bouncingbetty_mp" )
            continue;

        if ( !friendlyFireCheck( self.owner, attacker ) )
            continue;

        if ( isdefined( weapon ) )
        {
            switch ( weapon )
            {
                case "smoke_grenade_mp":
                    continue;
            }
        }

        break;
    }

    self notify( "mine_destroyed" );

    if ( isdefined( type ) && ( issubstr( type, "MOD_GRENADE" ) || issubstr( type, "MOD_EXPLOSIVE" ) ) )
        self.wasChained = 1;

    if ( isdefined( iDFlags ) && iDFlags & level.iDFLAGS_PENETRATION )
        self.wasDamagedFromBulletPenetration = 1;

    self.wasDamaged = 1;

    if ( isplayer( attacker ) )
        attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "bouncing_betty" );

    if ( level.teamBased )
    {
        if ( isdefined( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( self.owner ) && isdefined( self.owner.pers["team"] ) )
        {
            if ( attacker.pers["team"] != self.owner.pers["team"] )
                attacker notify( "destroyed_explosive" );
        }
    }
    else if ( isdefined( self.owner ) && isdefined( attacker ) && attacker != self.owner )
        attacker notify( "destroyed_explosive" );

    thread mineExplode( attacker );
}

mineProximityTrigger()
{
    self endon( "mine_destroyed" );
    self endon( "mine_selfdestruct" );
    self endon( "death" );
    wait 2;
    attacker = spawn( "trigger_radius", self.origin, 0, level.mineDetectionRadius, level.mineDetectionHeight );
    thread mineDeleteTrigger( attacker );
    player = undefined;

    for (;;)
    {
        attacker waittill( "trigger", player );

        if ( getdvarint( "scr_minesKillOwner" ) != 1 )
        {
            if ( isdefined( self.owner ) && player == self.owner )
                continue;

            if ( !friendlyFireCheck( self.owner, player, 0 ) )
                continue;
        }

        if ( lengthsquared( player getentityvelocity() ) < 10 )
            continue;

        if ( player damageconetrace( self.origin, self ) > 0 )
            break;
    }

    self notify( "mine_triggered" );
    self playsound( "mine_betty_click" );

    if ( isplayer( player ) && player maps\mp\_utility::_hasPerk( "specialty_delaymine" ) )
    {
        player notify( "triggered_mine" );
        wait(level.delayMineTime);
    }
    else
        wait(level.mineDetectionGracePeriod);

    thread mineBounce();
}

mineDeleteTrigger( trigger )
{
    common_scripts\utility::waittill_any( "mine_triggered", "mine_destroyed", "mine_selfdestruct", "death" );
    trigger delete();
}

mineSelfDestruct()
{
    self endon( "mine_triggered" );
    self endon( "mine_destroyed" );
    self endon( "death" );
    wait(level.mineSelfDestructTime);
    wait(randomfloat( 0.4 ));
    self notify( "mine_selfdestruct" );
    thread mineExplode();
}

mineBounce()
{
    self playsound( "mine_betty_spin" );
    playfx( level.mine_launch, self.origin );

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    explodePos = self.origin + ( 0, 0, 64 );
    self moveto( explodePos, 0.7, 0, 0.65 );
    self.killCamEnt moveto( explodePos + self.killCamOffset, 0.7, 0, 0.65 );
    self rotatevelocity( ( 0, 750, 32 ), 0.7, 0, 0.65 );
    thread playSpinnerFX();
    wait 0.65;
    thread mineExplode();
}

mineExplode( attacker )
{
    if ( !isdefined( self ) || !isdefined( self.owner ) )
        return;

    if ( !isdefined( attacker ) )
        attacker = self.owner;

    self playsound( "grenade_explode_metal" );
    playfxontag( level.mine_explode, self, "tag_fx" );
    wait 0.05;

    if ( !isdefined( self ) || !isdefined( self.owner ) )
        return;

    self hide();
    self radiusdamage( self.origin, level.mineDamageRadius, level.mineDamageMax, level.mineDamageMin, attacker, "MOD_EXPLOSIVE", "bouncingbetty_mp" );
    wait 0.2;

    if ( !isdefined( self ) || !isdefined( self.owner ) )
        return;

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    self.killCamEnt delete();
    self delete();
}

playSpinnerFX()
{
    self endon( "death" );
    timer = gettime() + 1000;

    while ( gettime() < timer )
    {
        wait 0.05;
        playfxontag( level.mine_spin, self, "tag_fx_spin1" );
        playfxontag( level.mine_spin, self, "tag_fx_spin3" );
        wait 0.05;
        playfxontag( level.mine_spin, self, "tag_fx_spin2" );
        playfxontag( level.mine_spin, self, "tag_fx_spin4" );
    }
}

mineDamageDebug( damageCenter, recieverCenter, radiusSq, ignoreEnt, damageTop, damageBottom )
{
	color[0] = ( 1, 0, 0 );
	color[1] = ( 0, 1, 0 );

	if ( recieverCenter[2] < damageBottom  )
		pass = false;
	else
		pass = true;

	damageBottomOrigin = ( damageCenter[0], damageCenter[1], damageBottom );
	recieverBottomOrigin = ( recieverCenter[0], recieverCenter[1], damageBottom );
	thread debugcircle( damageBottomOrigin, level.mineDamageRadius, color[pass], 32 );

	distSq = distanceSquared( damageCenter, recieverCenter );
	if ( distSq > radiusSq )
		pass = false;
	else
		pass = true;

	thread debugline( damageBottomOrigin, recieverBottomOrigin, color[pass] );
}

mineDamageHeightPassed( mine, victim )
{
	if ( isPlayer( victim ) && isAlive( victim ) && victim.sessionstate == "playing" )
		victimPos = victim getStanceCenter();
	else if ( victim.classname == "misc_turret" )
		victimPos = victim.origin + ( 0, 0, 32 );
	else
		victimPos = victim.origin;
	
	tempZOffset = 0; //66
	damageTop = mine.origin[2] + tempZOffset + level.mineDamageHalfHeight;  //46
	damageBottom = mine.origin[2] + tempZOffset - level.mineDamageHalfHeight;

	if ( victimPos[2] > damageTop || victimPos[2] < damageBottom )
		return false;

	return true;
}


watchMineUsage()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );

    if ( isdefined( self.equipmentMines ) )
    {
        if ( maps\mp\_utility::getIntProperty( "scr_deleteexplosivesonspawn", 1 ) == 1 )
        {
            self.equipmentMines = common_scripts\utility::array_removeUndefined( self.equipmentMines );

            foreach ( equipmentMine in self.equipmentMines )
            {
                if ( isdefined( equipmentMine.trigger ) )
                    equipmentMine.trigger delete();

                equipmentMine delete();
            }
        }
    }
    else
        self.equipmentMines = [];

    if ( !isdefined( self.killstreakMines ) )
        self.killstreakMines = [];

    for (;;)
    {
        self waittill( "grenade_fire",  projectile, weaponName );

        if ( weaponName == "bouncingbetty" || weaponName == "bouncingbetty_mp" )
        {
            if ( !isalive( self ) )
            {
                projectile delete();
                return;
            }

            self.hasDoneCombat = 1;
            projectile thread mineThrown( self );
        }
    }
}

mineThrown( owner )
{
    self.owner = owner;
    self waittill( "missile_stuck" );

    if ( !isdefined( owner ) )
        return;

    trace = bullettrace( self.origin + ( 0, 0, 4 ), self.origin - ( 0, 0, 4 ), 0, self );
    pos = trace["position"];

    if ( trace["fraction"] == 1 )
    {
        pos = getgroundposition( self.origin, 12, 0, 32 );
        trace["normal"] *= -1;
    }

    normal = vectornormalize( trace["normal"] );
    plantAngles = vectortoangles( normal );
    plantAngles += ( 90, 0, 0 );
    mine = spawnMine( pos, owner, "equipment", plantAngles );
    mine.trigger = spawn( "script_origin", mine.origin + ( 0, 0, 25 ) );
    mine thread equipmentWatchUse( owner );
    owner thread minewatchowner( mine );
    self delete();
}

minewatchowner( mine )
{
    mine endon( "death" );
    level endon( "game_ended" );
    common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );

    if ( isdefined( mine.trigger ) )
        mine.trigger delete();

    mine delete();
}

mineBeacon()
{
    effect["friendly"] = spawnfx( level.mine_beacon["friendly"], self gettagorigin( "tag_fx" ) );
    effect["enemy"] = spawnfx( level.mine_beacon["enemy"], self gettagorigin( "tag_fx" ) );
    thread mineBeaconTeamUpdater( effect );
    self waittill( "death" );
    effect["friendly"] delete();
    effect["enemy"] delete();
}

mineBeaconTeamUpdater( effect )
{
    self endon( "death" );
    ownerTeam = self.owner.team;
    wait 0.05;
    triggerfx( effect["friendly"] );
    triggerfx( effect["enemy"] );

    for (;;)
    {
        effect["friendly"] hide();
        effect["enemy"] hide();

        foreach ( player in level.players )
        {
            if ( level.teamBased )
            {
                if ( player.team == ownerTeam )
                    effect["friendly"] showtoplayer( player );
                else
                    effect["enemy"] showtoplayer( player );

                continue;
            }

            if ( player == self.owner )
            {
                effect["friendly"] showtoplayer( player );
                continue;
            }

            effect["enemy"] showtoplayer( player );
        }

        level common_scripts\utility::waittill_either( "joined_team", "player_spawned" );
    }
}
