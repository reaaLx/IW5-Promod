// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_weapons;

watchTrophyUsage()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );
    self.trophyArray = [];

    for (;;)
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( weapname == "trophy" || weapname == "trophy_mp" )
        {
            if ( !isalive( self ) )
            {
                grenade delete();
                return;
            }

            grenade hide();
            grenade waittill( "missile_stuck" );
            distanceZ = 40;

            if ( distanceZ * distanceZ < distancesquared( grenade.origin, self.origin ) )
            {
                secTrace = bullettrace( self.origin, self.origin - ( 0, 0, distanceZ ), 0, self );

                if ( secTrace["fraction"] == 1 )
                {
                    grenade delete();
                    self setweaponammostock( "trophy_mp", self getweaponammostock( "trophy_mp" ) + 1 );
                    continue;
                }

                grenade.origin = secTrace["position"];
            }

            grenade show();
            self.trophyArray = common_scripts\utility::array_removeUndefined( self.trophyArray );

            if ( self.trophyArray.size >= level.maxPerPlayerExplosives )
                self.trophyArray[0] detonate();

            trophy = spawn( "script_model", grenade.origin );
            trophy setmodel( "mp_trophy_system" );
            trophy thread maps\mp\gametypes\_weapons::createBombSquadModel( "mp_trophy_system_bombsquad", "tag_origin", level.otherTeam[self.team], self );
            trophy.angles = grenade.angles;
            self.trophyArray[self.trophyArray.size] = trophy;
            trophy.owner = self;
            trophy.team = self.team;
            trophy.weaponName = weapname;

            if ( isdefined( self.trophyRemainingAmmo ) && self.trophyRemainingAmmo > 0 )
                trophy.ammo = self.trophyRemainingAmmo;
            else
                trophy.ammo = 2;

            trophy.trigger = spawn( "script_origin", trophy.origin );
            trophy thread trophyDamage( self );
            trophy thread trophyActive( self );
            trophy thread trophyDisconnectWaiter( self );
            trophy thread trophyPlayerSpawnWaiter( self );
            trophy thread trophyUseListener( self );
            trophy thread maps\mp\gametypes\_weapons::c4EMPKillstreakWait();

            if ( level.teamBased )
                trophy maps\mp\_entityheadicons::setTeamHeadIcon( trophy.team, ( 0, 0, 65 ) );
            else
                trophy maps\mp\_entityheadicons::setPlayerHeadIcon( trophy.owner, ( 0, 0, 65 ) );

            wait 0.05;

            if ( isdefined( grenade ) )
                grenade delete();
        }
    }
}

trophyUseListener( owner )
{
    self endon( "death" );
    level endon( "game_ended" );
    owner endon( "disconnect" );
    owner endon( "death" );
    self.trigger setcursorhint( "HINT_NOICON" );
    self.trigger sethintstring( &"MP_PICKUP_TROPHY" );
    self.trigger maps\mp\_utility::setSelfUsable( owner );
    self.trigger thread maps\mp\_utility::notUsableForJoiningPlayers( owner );

    for (;;)
    {
        self.trigger waittill( "trigger", owner );
        owner playlocalsound( "scavenger_pack_pickup" );
        owner maps\mp\_utility::givePerk( "trophy_mp", 0 );
        owner.trophyRemainingAmmo = self.ammo;
        self.trigger delete();
        self delete();
        self notify( "death" );
    }
}

trophyPlayerSpawnWaiter( owner )
{
    self endon( "disconnect" );
    self endon( "death" );
    owner waittill( "spawned" );
    thread trophyBreak();
}

trophyDisconnectWaiter( owner )
{
    self endon( "death" );
    owner waittill( "disconnect" );
    thread trophyBreak();
}

trophyActive( owner )
{
    owner endon( "disconnect" );
    self endon( "death" );
    position = self.origin;

    for (;;)
    {
        if ( !isdefined( level.grenades ) || level.grenades.size < 1 && level.missiles.size < 1 || isdefined( self.disabled ) )
        {
            wait 0.05;
            continue;
        }

        sentryTargets = maps\mp\_utility::combineArrays( level.grenades, level.missiles );

        foreach ( grenade in sentryTargets )
        {
            wait 0.05;

            if ( !isdefined( grenade ) )
                continue;

            if ( grenade == self )
                continue;

            if ( isdefined( grenade.weaponName ) )
            {
                switch ( grenade.weaponName )
                {
                    case "claymore_mp":
                        continue;
                }
            }

            switch ( grenade.model )
            {
                case "weapon_parabolic_knife":
                case "weapon_jammer":
                case "weapon_radar":
                case "mp_trophy_system":
                    continue;
            }

            if ( !isdefined( grenade.owner ) )
                grenade.owner = getmissileowner( grenade );

            if ( isdefined( grenade.owner ) && level.teamBased && grenade.owner.team == owner.team )
                continue;

            if ( isdefined( grenade.owner ) && grenade.owner == owner )
                continue;

            grenadeDistanceSquared = distancesquared( grenade.origin, self.origin );

            if ( grenadeDistanceSquared < 147456 )
            {
                if ( bullettracepassed( grenade.origin, self.origin, 0, self ) )
                {
                    playfx( level.sentry_fire, self.origin + ( 0, 0, 32 ), grenade.origin - self.origin, anglestoup( self.angles ) );
                    self playsound( "trophy_detect_projectile" );
                    owner thread projectileExplode( grenade, self );
                    owner maps\mp\gametypes\_missions::processChallenge( "ch_noboomforyou" );
                    self.ammo--;

                    if ( self.ammo <= 0 )
                        thread trophyBreak();
                }
            }
        }
    }
}

projectileExplode( projectile, trophy )
{
    self endon( "death" );
	projPosition = projectile.origin;
	projType = projectile.model;
	projAngles = projectile.angles;

    if ( projType == "weapon_light_marker" )
    {
        playfx( level.empGrenadeExplode, projPosition, anglestoforward( projAngles ), anglestoup( projAngles ) );
        trophy thread trophyBreak();
        projectile delete();
        return;
    }

    projectile delete();
    trophy playsound( "trophy_fire" );
    playfx( level.mine_explode, projPosition, anglestoforward( projAngles ), anglestoup( projAngles ) );
    radiusdamage( projPosition, 128, 105, 10, self, "MOD_EXPLOSIVE", "trophy_mp" );
}

trophyDamage( owner )
{
    self endon( "death" );
    owner endon( "death" );
    self setcandamage( 1 );
    self.health = 999999;
    self.maxHealth = 100;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );

        if ( !isplayer( attacker ) )
            continue;

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

        if ( isdefined( weapon ) && weapon == "emp_grenade_mp" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        self.damagetaken = self.damagetaken + damage;

        if ( isplayer( attacker ) )
            attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "trophy" );

        if ( self.damagetaken >= self.maxHealth )
        {
            attacker notify( "destroyed_explosive" );
            thread trophyBreak();
        }
    }
}

trophyBreak()
{
    playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_origin" );
    playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_origin" );
    self playsound( "sentry_explode" );
    self notify( "death" );
    placement = self.origin;
    self.trigger makeunusable();
    wait 3;

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    if ( isdefined( self ) )
        self delete();
}
