#include maps\mp\gametypes\_hud_util;
main()
{
    precacheStatusIcon("compassping_enemyfiring");
    precacheStatusIcon("compassping_player");
    level.timeLimitOverride = true;
    level.rdyup = true;
    setDvar("g_deadChat", 1);
    setClientNameMode("auto_change");
    setGameEndTime(0);
    numlives = getdvar("scr_sd_numlives");
    timelimit = getdvar("scr_sd_timelimit");
    setdvar("scr_sd_numlives", 0);
    setdvar("scr_sd_timelimit", 0);
    thread periodAnnounce();
    level.ready_up_over = false;
    previous_not_ready_count = 0;
    thread updatePlayerHUDInterval();
    thread lastPlayerReady();
    while (!level.ready_up_over)
    {
        wait 0.05;
        all_players_ready = true;
        level.not_ready_count = 0;
        if (level.players.size < 1)
        {
            all_players_ready = false;
            continue;
        }
        for (i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            if (!isDefined(player.looped))
            {
                player setclientdvar("self_ready", 0);
                player.looped = true;
                player.promodconfig = false;
                player.ready = false;
                player.update = false;
                player.statusicon = "compassping_enemyfiring";
                player thread selfLoop();
            }
            player.oldready = player.update;
            if (player.ready)
            {
                player.update = true;
                if (!game["promod_first_readyup_done"] && (isAlive(player) && isDefined(player.pers["class"]) && !isDefined(player.inrecmenu) && !player.promodconfig))
                {
                    player.promodconfig = true;
                    player.inrecmenu = true;
                }
            }
            if (!player.ready || isDefined(player.inrecmenu) && player.inrecmenu && !player.promodconfig)
            {
                level.not_ready_count++;
                all_players_ready = false;
                player.update = false;
            }
            player.newready = player.update;
            if (player.oldready != player.newready && (!isDefined(player.inrecmenu) || !player.inrecmenu))
            {
                player setclientdvar("self_ready", int(player.ready));
                player.oldready = player.newready;
                if (player.ready)
                    player.statusicon = "compassping_player";
                else
                    player.statusicon = "compassping_enemyfiring";
            }
        }
        if (previous_not_ready_count != level.not_ready_count)
        {
            for (i = 0; i < level.players.size; i++)
            {
                level.players[i] setclientdvar("waiting_on", level.not_ready_count);
                level.players[i] ShowScoreBoard();
                previous_not_ready_count = level.not_ready_count;
            }
        }
        if (all_players_ready)
            level.ready_up_over = true;
    }
    level notify("kill_ru_period");
    level notify("header_destroy");
    for (i = 0; i < level.players.size; i++)
    {
        level.players[i] setclientdvars("self_ready", "", "ui_hud_hardcore", 1);
        level.players[i].statusicon = "";
    }
    for (i = 0; i < level.players.size; i++)
        level.players[i] ShowScoreBoard();
    game["state"] = "postgame";
    visionSetNaked("mpIntro", 1);
    level.inReadyUpTimer = true;
    matchStartText = createServerFontString("objective", 1.5);
    matchStartText setPoint("CENTER", "CENTER", 0, -75);
    matchStartText.sort = 1001;
    matchStartText setText("All Players are Ready!");
    matchStartText.foreground = false;
    matchStartText.hidewheninmenu = false;
    matchStartText.glowColor = (0.6, 0.64, 0.69);
    matchStartText.glowAlpha = 1;
    matchStartText setPulseFX(100, 4000, 1000);
    matchStartText2 = createServerFontString("objective", 1.5);
    matchStartText2 setPoint("CENTER", "CENTER", 0, -60);
    matchStartText2.sort = 1001;
    matchStartText2 setText(game["strings"]["match_starting_in"]);
    matchStartText2.foreground = false;
    matchStartText2.hidewheninmenu = false;
    matchStartTimer = createServerTimer("objective", 1.4);
    matchStartTimer setPoint("CENTER", "CENTER", 0, -45);
    matchStartTimer setTimer(5);
    matchStartTimer.sort = 1001;
    matchStartTimer.foreground = false;
    matchStartTimer.hideWhenInMenu = false;
    setdvar("scr_sd_numlives", numlives);
    setdvar("scr_sd_timelimit", timelimit);
    wait 5;
    visionSetNaked(getDvar("mapname"), 1);
    matchStartText destroyElem();
    matchStartText2 destroyElem();
    matchStartTimer destroyElem();
    game["promod_do_readyup"] = false;
    level.inReadyUpTimer = false;
    game["promod_first_readyup_done"] = 1;
    game["state"] = "playing";
    map_restart(true);
}
lastPlayerReady()
{
    wait 0.5;
    while (!level.ready_up_over)
    {
        maxwait = 0;
        while (!level.ready_up_over && level.not_ready_count == 1 && level.players.size > 1 && maxwait <= 5)
        {
            wait 0.05;
            maxwait += 0.05;
        }
        if (level.not_ready_count == 1 && level.players.size > 1)
        {
            for (i = 0; i < level.players.size; i++)
            {
                player = level.players[i];
                if (player.ready)
                {
                    player.soundplayed = undefined;
                    player.timesplayed = undefined;
                }
                else
                {
                    if ((!isDefined(player.soundplayed) || gettime() - 20000 > player.soundplayed) && (!isDefined(player.timesplayed) || player.timesplayed < 4) && (!isDefined(player.inrecmenu) || !player.inrecmenu))
                    {
                        player iprintLnBold("You are the ^3last ^7one to ready up!");
                        player.soundplayed = gettime();
                        if (isDefined(player.timesplayed))
                            player.timesplayed++;
                        else
                            player.timesplayed = 1;
                    }
                }
            }
        }
        wait 0.05;
    }
}
updatePlayerHUDInterval()
{
    level endon("kill_ru_period");
    while (!level.ready_up_over)
    {
        wait 5;
        for (i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            if (isDefined(player))
            {
                if (isDefined(player.ready) && !isDefined(player.inrecmenu))
                {
                    player setclientdvar("self_ready", int(player.ready));
                }
                if (isDefined(level.not_ready_count))
                {
                    player setclientdvar("waiting_on", level.not_ready_count);
                    player.notreadyhud setValue(level.not_ready_count);
                }
            }
        }
    }
}
selfLoop()
{
    self endon("disconnect");
    if (isDefined(self.in_ready_up_loop) && self.in_ready_up_loop)
        return;
    self.in_ready_up_loop = true;
    self thread onSpawn();
    self thread clientHUD();
    self thread destroyOnDisconnect();
    self setClientDvar("self_kills", "");
    self saveStats();
    while (!level.ready_up_over)
    {
        while (!isDefined(self.pers["team"] == "none") || self.pers["team"] == "none")
            wait 0.05;
        wait 0.05;
        if (self useButtonPressed())
            self.ready = !self.ready;
        while (self useButtonPressed())
            wait 0.1;
        if (self.ready)
        {
            self.readyhud setText("Ready");
            self.readyhud.color = (.73, .99, .73);
            self.statusicon = "compassping_player";
        }
        else
        {
            self.readyhud setText("Not Ready");
            self.readyhud.color = (1, .66, .66);
            self.statusicon = "compassping_enemyfiring";
        }
    }
    self resetStats();
}
clientHUD()
{
    self endon("disconnect");
    if (!game["promod_first_readyup_done"])
        self waittill("spawned_player");
    text = "";
    if (!game["promod_first_readyup_done"])
        text = "Pre-Match Ready-Up Period";
    else if (game["promod_timeout_called"])
        text = "Timeout Ready-Up Period";
    else
        text = "Half-Time Ready-Up Period";
    if (isDefined(self.periodtext))
        self.periodtext destroy();
    if (!isDefined(self.periodtext))
    {
        self.periodtext = createFontString("objective", 1.4);
        self.periodtext setPoint("CENTER", "CENTER", 0, 200);
        self.periodtext.sort = 1001;
        self.periodtext setText(text);
        self.periodtext.foreground = false;
        self.periodtext.hidewheninmenu = true;
    }
    if (game["promod_first_readyup_done"])
    {
        if (isDefined(self.halftimetext))
            self.halftimetext destroy();
        if (!isDefined(self.halftimetext))
        {
            self.halftimetext = createFontString("objective", 1.3);
            self.halftimetext setPoint("CENTER", "CENTER", 0, 215);
            self.halftimetext.sort = 1001;
        }
        if (game["promod_timeout_called"])
        {
            if (isDefined(game["LAN_MODE"]) && game["LAN_MODE"])
                self.halftimetext setText("Timeout Elapsed");
            else
                self.halftimetext setText("Timeout Remaining");
        }
        else
            self.halftimetext setText("Half-Time Elapsed");
        self.halftimetext.foreground = false;
        self.halftimetext.hidewheninmenu = true;
    }
    if (isDefined(self.status))
        self.status destroy();
    if (!isDefined(self.status))
    {
        self.status = newHudElem(self);
        self.status.x = -40;
        self.status.y = 145;
        self.status.horzAlign = "right";
        self.status.vertAlign = "top";
        self.status.alignX = "center";
        self.status.alignY = "middle";
        self.status.fontScale = 1.4;
        self.status.font = "default";
        self.status.color = (.8, 1, 1);
        self.status.hidewheninmenu = true;
        self.status setText("Status");
    }
    if (isDefined(self.readyhud))
        self.readyhud destroy();
    if (!isDefined(self.readyhud))
    {
        self.readyhud = newHudElem(self);
        self.readyhud.x = -40;
        self.readyhud.y = 160;
        self.readyhud.horzAlign = "right";
        self.readyhud.vertAlign = "top";
        self.readyhud.alignX = "center";
        self.readyhud.alignY = "middle";
        self.readyhud.fontScale = 1.4;
        self.readyhud.font = "default";
        self.readyhud.color = (1, .66, .66);
        self.readyhud.hidewheninmenu = true;
        self.readyhud setText("Not Ready");
    }
    if (isDefined(self.waitingon))
        self.waitingon destroy();
    if (!isDefined(self.waitingon))
    {
        self.waitingon = newHudElem(self);
        self.waitingon.x = -40;
        self.waitingon.y = 80;
        self.waitingon.horzAlign = "right";
        self.waitingon.vertAlign = "top";
        self.waitingon.alignX = "center";
        self.waitingon.alignY = "middle";
        self.waitingon.fontScale = 1.4;
        self.waitingon.font = "default";
        self.waitingon.color = (.8, 1, 1);
        self.waitingon.hidewheninmenu = true;
        self.waitingon setText("^7Waiting On^1");
    }
    if (isDefined(self.playerstext))
        self.playerstext destroy();
    if (!isDefined(self.playerstext))
    {
        self.playerstext = newHudElem(self);
        self.playerstext.x = -40;
        self.playerstext.y = 120;
        self.playerstext.horzAlign = "right";
        self.playerstext.vertAlign = "top";
        self.playerstext.alignX = "center";
        self.playerstext.alignY = "middle";
        self.playerstext.fontScale = 1.4;
        self.playerstext.font = "default";
        self.playerstext.color = (.8, 1, 1);
        self.playerstext.hidewheninmenu = true;
        self.playerstext setText("Players");
    }
    if (isDefined(self.notreadyhud))
        self.notreadyhud destroy();
    if (!isDefined(self.notreadyhud))
    {
        self.notreadyhud = newHudElem(self);
        self.notreadyhud.x = -40;
        self.notreadyhud.y = 100;
        self.notreadyhud.horzAlign = "right";
        self.notreadyhud.vertAlign = "top";
        self.notreadyhud.alignX = "center";
        self.notreadyhud.alignY = "middle";
        self.notreadyhud.fontScale = 1.4;
        self.notreadyhud.font = "default";
        self.notreadyhud.color = (.98, .98, .60);
        self.notreadyhud.hidewheninmenu = true;
        self.notreadyhud setValue(level.not_ready_count);
    }
    level waittill("kill_ru_period");
    if (isDefined(self.periodtext))
        self.periodtext destroy();
    if (isDefined(self.halftimetext))
        self.halftimetext destroy();
    if (isDefined(self.status))
        self.status destroy();
    if (isDefined(self.readyhud))
        self.readyhud destroy();
    if (isDefined(self.waitingon))
        self.waitingon destroy();
    if (isDefined(self.playerstext))
        self.playerstext destroy();
    if (isDefined(self.notreadyhud))
        self.notreadyhud destroy();
}
onSpawn()
{
    self endon("disconnect");
    while (!level.ready_up_over)
    {
        self waittill("spawned_player");
        self iprintlnbold("Press ^3[{+activate}] ^7to Ready-Up");
    }
}
periodAnnounce()
{
    if (!game["promod_first_readyup_done"])
        return;
    if (!isDefined(level.halftimetimer))
    {
        level.halftimetimer = createServerTimer("objective", 1.4);
        level.halftimetimer setPoint("CENTER", "CENTER", 0, 230);
        if (!game["promod_timeout_called"] || game["promod_timeout_called"] && isDefined(game["LAN_MODE"]) && game["LAN_MODE"])
            level.halftimetimer setTimerUp(0);
        else
            level.halftimetimer setTimer(300);
        level.halftimetimer.sort = 1001;
        level.halftimetimer.foreground = false;
        level.halftimetimer.hideWhenInMenu = true;
    }
    level waittill("kill_ru_period");
    if (isDefined(level.halftimetimer))
        level.halftimetimer destroy();
}
disableBombsites()
{
    if (level.gametype == "sd" && isDefined(level.bombZones))
        for (j = 0; j < level.bombZones.size; j++)
            level.bombZones[j] maps\mp\gametypes\_gameobjects::disableObject();
}
saveStats()
{
    self.oldpersscore = self.pers["score"];
    self.oldperskills = self.pers["kills"];
    self.oldpersassists = self.pers["assists"];
    self.oldpersdeaths = self.pers["deaths"];
    self.oldperssuicides = self.pers["suicides"];
    self.oldscore = self.score;
    self.oldkills = self.kills;
    self.oldassists = self.assists;
    self.olddeaths = self.deaths;
    self.oldsuicides = self.suicides;
}
resetStats()
{
    self.pers["score"] = self.oldpersscore;
    self.pers["kills"] = self.oldperskills;
    self.pers["assists"] = self.oldpersassists;
    self.pers["deaths"] = self.oldpersdeaths;
    self.pers["suicides"] = self.oldperssuicides;
    self.score = self.oldscore;
    self.kills = self.oldkills;
    self.assists = self.oldassists;
    self.deaths = self.olddeaths;
    self.suicides = self.oldsuicides;
}
destroyOnDisconnect()
{
    level endon("kill_ru_period");
    self waittill("disconnect");
    if (isDefined(self.periodtext))
        self.periodtext destroy();
    if (isDefined(self.halftimetext))
        self.halftimetext destroy();
    if (isDefined(self.status))
        self.status destroy();
    if (isDefined(self.readyhud))
        self.readyhud destroy();
    if (isDefined(self.waitingon))
        self.waitingon destroy();
    if (isDefined(self.playerstext))
        self.playerstext destroy();
    if (isDefined(self.notreadyhud))
        self.notreadyhud destroy();
}