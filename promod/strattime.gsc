#include maps\mp\gametypes\_hud_util;
main()
{
    if (game["promod_timeout_called"])
    {
        thread promod\timeout::main();
        return;
    }
    game["strat_finished"] = 0;
    level.oldff = getdvar("scr_team_fftype");
    setDvar("scr_team_fftype", 0);
    self setWeaponAmmoClip("frag_grenade_mp", 0);
    self setWeaponAmmoClip("flash_grenade_mp", 0);
    self setWeaponAmmoClip("smoke_grenade_mp", 0);
    thread Strat_Time();
    level waittill("strat_over");
    foreach (player in level.players)
    {
        if (player.pers["team"] == "allies" || player.pers["team"] == "axis" && player.sessionstate == "playing")
        {
            player maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");
            player allowsprint(true);
            player allowJump(true);
        }
    }
    self setWeaponAmmoClip("frag_grenade_mp", 1);
    self setWeaponAmmoClip("flash_grenade_mp", 1);
    self setWeaponAmmoClip("smoke_grenade_mp", 1);
    game["strat_finished"] = 1;
    self notify("god_done");
    setDvar("scr_team_fftype", level.oldff);
    level notify("strat_done");
    if (game["promod_timeout_called"])
    {
        thread promod\timeout::main();
        return;
    }
}
doAmmo()
{
    self endon("disconnect");
    self endon("death");
    self endon("god_done");
    while (game["strat_finished"] != 1)
    {
        currentWeapon = self getCurrentWeapon();
        if (currentWeapon != "none")
        {
            if (isSubStr(self getCurrentWeapon(), "_akimbo_"))
            {
                self setWeaponAmmoClip(currentweapon, 9999, "left");
                self setWeaponAmmoClip(currentweapon, 9999, "right");
            }
            else
                self setWeaponAmmoClip(currentWeapon, 9999);
            self GiveMaxAmmo(currentWeapon);
        }
        currentoffhand = self GetCurrentOffhand();
        if (currentoffhand != "none")
        {
            self setWeaponAmmoClip(currentoffhand, 9999);
            self GiveMaxAmmo(currentoffhand);
        }
        self setWeaponAmmoClip("frag_grenade_mp", 0);
        self setWeaponAmmoClip("flash_grenade_mp", 0);
        self setWeaponAmmoClip("smoke_grenade_mp", 0);
        wait 0.05;
    }
    self setWeaponAmmoClip("frag_grenade_mp", 1);
    self setWeaponAmmoClip("flash_grenade_mp", 1);
    self setWeaponAmmoClip("smoke_grenade_mp", 1);
}
Strat_Time()
{
    thread Strat_Time_Timer();
    level.strat_over = false;
    level.strat_time_left = game["PROMOD_STRATTIME"];
    time_increment = .25;
    while (!level.strat_over)
    {
        foreach (player in level.players)
        {
            if (player.pers["team"] == "allies" || player.pers["team"] == "axis" && player.sessionstate == "playing")
            {
                player setMoveSpeedScale(0);
                player allowJump(false);
                player allowsprint(false);
                player freezeControls(false);
            }
        }
        wait time_increment;
        level.strat_time_left -= time_increment;
        if (level.strat_time_left <= 0 || game["promod_timeout_called"])
        {
            level notify("kill_strat_timer");
            level.strat_over = true;
        }
    }
    game["strat_finished"] = 1;
    level notify("strat_over");
}
Strat_Time_Timer()
{
    matchStartText = createServerFontString("objective", 1.5);
    matchStartText setPoint("CENTER", "CENTER", 0, -20);
    matchStartText.sort = 1001;
    matchStartText setText("Strat Time");
    matchStartText.foreground = false;
    matchStartText.hidewheninmenu = false;
    matchStartTimer = createServerTimer("objective", 1.4);
    matchStartTimer setPoint("CENTER", "CENTER", 0, 0);
    matchStartTimer setTimer(game["PROMOD_STRATTIME"]);
    matchStartTimer.sort = 1001;
    matchStartTimer.foreground = false;
    matchStartTimer.hideWhenInMenu = false;
    level waittill("kill_strat_timer");
    if (isDefined(matchStartText))
        matchStartText destroy();
    if (isDefined(matchStartTimer))
        matchStartTimer destroy();
}