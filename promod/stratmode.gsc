main()
{
    thread onPlayerConnect();
    thread createServerHUD();
}
onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread nadeTraining();
        player thread monitorKeys();
        player createHUD();
    }
}
monitorKeys()
{
    self endon("disconnect");
    for (;;)
    {
        wait 0.05;
        if (self.sessionstate != "playing")
            continue;
        if (self useButtonPressed() && !self meleeButtonPressed())
        {
            useButtonTime = 0;
            while (self useButtonPressed() && !self meleeButtonPressed())
            {
                useButtonTime += 0.05;
                wait 0.05;
            }
            if (useButtonTime > 0.5 || !useButtonTime)
                continue;
            for (i = 0; i < 0.5; i += 0.1)
            {
                wait 0.1;
                if (self useButtonPressed() && !self meleeButtonPressed())
                {
                    loadPos();
                    break;
                }
            }
        }
        if (self meleeButtonPressed() && !self useButtonPressed())
        {
            meleeButtonTime = 0;
            while (self meleeButtonPressed() && !self useButtonPressed())
            {
                meleeButtonTime += 0.05;
                wait 0.05;
            }
            if (meleeButtonTime > 0.5 || !meleeButtonTime)
                continue;
            for (i = 0; i < 0.5; i += 0.1)
            {
                wait 0.1;
                if (self meleeButtonPressed() && !self useButtonPressed())
                {
                    savePos();
                    break;
                }
            }
        }
        if (self meleeButtonPressed() || self useButtonPressed())
        {
            wait 0.1;
            bothButtonTime = 0;
            while (bothButtonTime < 0.5 && self meleeButtonPressed() && self useButtonPressed())
            {
                bothButtonTime += 0.05;
                wait 0.05;
            }
            if (bothButtonTime > 0.35)
            {
                if (!isDefined(self.nofly))
                {
                    self.nofly = true;
                    self.hint1 setText("Enable: Hold ^3[{+melee}] ^7+ ^3[{+activate}]");
                    self.hint2.color = (0.5, 0.5, 0.5);
                    self.hint3.color = (0.5, 0.5, 0.5);
                }
                else
                {
                    self.nofly = undefined;
                    self.hint1 setText("Disable: Hold ^3[{+melee}] ^7+ ^3[{+activate}]");
                    self.hint2.color = (0.8, 1, 1);
                    self.hint3.color = (0.8, 1, 1);
                }
            }
            while (self meleeButtonPressed() && self useButtonPressed())
                wait 0.05;
        }
    }
}
loadPos()
{
    self endon("disconnect");
    if (!isDefined(self.savedorg))
        self iprintln("No Previous Position Saved");
    else
    {
        self freezecontrols(true);
        wait 0.05;
        self setOrigin(self.savedorg);
        self SetPlayerAngles(self.savedang);
        self freezecontrols(false);
        self iprintln("Position Loaded");
    }
}
savePos()
{
    if (!self isOnGround())
        return;
    self.savedorg = self.origin;
    self.savedang = self GetPlayerAngles();
    self iprintln("Position Saved");
}
nadeTraining()
{
    self endon("disconnect");
    for (;;)
    {
        self waittill("grenade_fire", grenade, weaponName);
        grenades = getentarray("grenade", "classname");
        for (i = 0; i < grenades.size; i++)
        {
            self giveWeapon(weaponName);
            self setWeaponAmmoClip(weaponName, 1);
            if (isDefined(grenades[i].origin) && !isDefined(self.flying) && !isDefined(self.nofly))
            {
                if (distance(grenades[i].origin, self.origin) < 140)
                {
                    self.flying = true;
                    grenades[i] thread nadeFlying(self, weaponName);
                }
            }
        }
        wait 0.1;
    }
}
nadeFlying(player, weaponName)
{
    player endon("disconnect");
    time = 3;
    if (weaponName == "frag_grenade_mp")
        time = 3;
    else if (weaponName == "flash_grenade_mp")
        time = 1.5;
    else
        time = 1;
    old_player_origin = player.origin;
    player.flyobject = spawn("script_model", player.origin);
    player.flyobject solid();
    player.flyobject linkto(self);
    player Playerlinkto(player.flyobject);
    stop_flying = false;
    return_flying = false;
    while (isDefined(self))
    {
        if (player attackButtonPressed())
        {
            stop_flying = true;
            break;
        }
        if (player useButtonPressed())
        {
            return_flying = true;
            break;
        }
        wait 0.05;
    }
    if (stop_flying || return_flying)
        wait 0.1;
    else
    {
        for (i = 0; i < time - 0.5; i += 0.1)
        {
            wait 0.1;
            if (player useButtonPressed())
                break;
        }
    }
    player.flyobject unlink();
    if (stop_flying)
    {
        for (i = 0; i < time + 0.4; i += 0.1)
        {
            wait 0.1;
            if (player useButtonPressed())
                break;
        }
    }
    player.flyobject moveto(old_player_origin, 0.1);
    wait 0.2;
    player unlink();
    player.flying = undefined;
    if (isDefined(player.flyobject))
        player.flyobject delete ();
}
createHUD()
{
    if (!isDefined(self.hint1))
    {
        self.hint1 = newClientHudElem(self);
        self.hint1.x = -7;
        self.hint1.y = 100;
        self.hint1.horzAlign = "right";
        self.hint1.vertAlign = "top";
        self.hint1.alignX = "right";
        self.hint1.alignY = "middle";
        self.hint1.fontScale = 1.4;
        self.hint1.font = "default";
        self.hint1.color = (0.8, 1, 1);
        self.hint1.hidewheninmenu = true;
        self.hint1 setText("Disable: Hold ^3[{+melee}] ^7+ ^3[{+activate}]");
    }
    if (!isDefined(self.hint2))
    {
        self.hint2 = newClientHudElem(self);
        self.hint2.x = -7;
        self.hint2.y = 115;
        self.hint2.horzAlign = "right";
        self.hint2.vertAlign = "top";
        self.hint2.alignX = "right";
        self.hint2.alignY = "middle";
        self.hint2.fontScale = 1.4;
        self.hint2.font = "default";
        self.hint2.color = (0.8, 1, 1);
        self.hint2.hidewheninmenu = true;
        self.hint2 setText("Stop: Press ^3[{+attack}]");
    }
    if (!isDefined(self.hint3))
    {
        self.hint3 = newClientHudElem(self);
        self.hint3.x = -7;
        self.hint3.y = 130;
        self.hint3.horzAlign = "right";
        self.hint3.vertAlign = "top";
        self.hint3.alignX = "right";
        self.hint3.alignY = "middle";
        self.hint3.fontScale = 1.4;
        self.hint3.font = "default";
        self.hint3.color = (0.8, 1, 1);
        self.hint3.hidewheninmenu = true;
        self.hint3 setText("Return: Press ^3[{+activate}]");
    }
    if (!isDefined(self.hint4))
    {
        self.hint4 = newClientHudElem(self);
        self.hint4.x = -7;
        self.hint4.y = 175;
        self.hint4.horzAlign = "right";
        self.hint4.vertAlign = "top";
        self.hint4.alignX = "right";
        self.hint4.alignY = "middle";
        self.hint4.fontScale = 1.4;
        self.hint4.font = "default";
        self.hint4.color = (0.8, 1, 1);
        self.hint4.hidewheninmenu = true;
        self.hint4 setText("Save: Press ^3[{+melee}] ^7twice");
    }
    if (!isDefined(self.hint5))
    {
        self.hint5 = newClientHudElem(self);
        self.hint5.x = -7;
        self.hint5.y = 190;
        self.hint5.horzAlign = "right";
        self.hint5.vertAlign = "top";
        self.hint5.alignX = "right";
        self.hint5.alignY = "middle";
        self.hint5.fontScale = 1.4;
        self.hint5.font = "default";
        self.hint5.color = (0.8, 1, 1);
        self.hint5.hidewheninmenu = true;
        self.hint5 setText("Load: Press ^3[{+activate}] ^7twice");
    }
}
createServerHUD()
{
    nadetraining = newHudElem();
    nadetraining.x = -7;
    nadetraining.y = 80;
    nadetraining.horzAlign = "right";
    nadetraining.vertAlign = "top";
    nadetraining.alignX = "right";
    nadetraining.alignY = "middle";
    nadetraining.fontScale = 1.4;
    nadetraining.font = "default";
    nadetraining.color = (0.8, 1, 1);
    nadetraining.hidewheninmenu = true;
    nadetraining setText("Nadetraining");
    position = newHudElem();
    position.x = -7;
    position.y = 155;
    position.horzAlign = "right";
    position.vertAlign = "top";
    position.alignX = "right";
    position.alignY = "middle";
    position.fontScale = 1.4;
    position.font = "default";
    position.color = (0.8, 1, 1);
    position.hidewheninmenu = true;
    position setText("Position");
}