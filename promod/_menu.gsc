#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
init() 
{
    precacheShader("navbar_edge");
    level.assaultCount = 0;
    level.smgCount = 0;
    level.demoCount = 0;
    level.scopeCount = 0;
    level thread onPlayerConnect();
}
onPlayerConnect() 
{
    for (;;) 
    {
        level waittill("connected", player );
        player thread onPlayerSpawned();
        player thread create_cac_menu();
        
        player thread runMenu();
        player thread watchButtons();
        player thread updateLimitDisplay();
        //player thread classBinds();
        
    }
}
onPlayerSpawned() 
{
    self endon("disconnect");
    for (;;) 
    {
        self waittill("spawned_player");
        /*
        while (!gameFlag("prematch_done") || (isDefined(level.strat_over) && !level.strat_over)) wait.1;
        wait.2;
        */
        self notify("weapon_change", self getCurrentWeapon());
    }
}

updateLimitDisplay() 
{
    self endon("disconnect");
    while (true) 
    {
        self waittill("classchanged");
        if (self.mOpen == "primary") 
        {
            self getClassCount();
            self.mText[0] setText("AR (" + level.assaultCount + "/" + level.weaponLimit["weapon_assault"] + ")");
            self.mText[1] setText("SMG (" + level.smgCount + "/" + level.weaponLimit["weapon_smg"] + ")");
            self.mText[2] setText("SHOTGUNS (" + level.demoCount + "/" + level.weaponLimit["weapon_shotgun"] + ")");
            self.mText[3] setText("LMG (" + level.lmgCount + "/" + level.weaponLimit["weapon_lmg"] + ")");
            self.mText[4] setText("SNIPER (" + level.scopeCount + "/" + level.weaponLimit["weapon_sniper"] + ")");
            if ((level.assaultCount >= level.weaponLimit["weapon_assault"]) && level.weaponLimit["weapon_assault"] != 0 && self.hasClass != "weapon_assault") 
                self.mText[0].alpha = .35;
            else self.mText[0].alpha = 1;
            if ((level.smgCount >= level.weaponLimit["weapon_smg"]) && level.weaponLimit["weapon_smg"] != 0 && self.hasClass != "weapon_smg") 
                self.mText[1].alpha = .35;
            else self.mText[1].alpha = 1;
            if ((level.demoCount >= level.weaponLimit["weapon_shotgun"]) && level.weaponLimit["weapon_shotgun"] != 0 && self.hasClass != "weapon_shotgun") 
                self.mText[2].alpha = .35;
            else self.mText[2].alpha = 1;
            if ((level.lmgCount >= level.weaponLimit["weapon_lmg"]) && level.weaponLimit["weapon_lmg"] != 0 && self.hasClass != "weapon_lmg") 
                self.mText[3].alpha = .35;
            else self.mText[3].alpha = 1;
            if ((level.scopeCount >= level.weaponLimit["weapon_sniper"]) && level.weaponLimit["weapon_sniper"] != 0 && self.hasClass != "weapon_sniper") 
                self.mText[4].alpha = .35;
            else self.mText[4].alpha = 1;
        }
    }
}
blank() 
{

}


create_cac_menu() 
{
    self endon("disconnect");
    self endon("cac_done");
    self addMenu("main", "INVENTORY", "1. Primary, 2. Attachment, 3. Camo, 4. Side Arm, 5. Grenade, 6. Start!, ,Default Classes, ,Toggle Fov Scale, Toggle Normal Map, Toggle Film Tweak", "none");
    self addFunc("main", ::setMenu, "primary");
    self addFunc("main", ::setMenu, "attach");
    self addFunc("main", ::setMenu, "camo");
    self addFunc("main", ::setMenu, "secondary");
    self addFunc("main", ::setMenu, "tac_nade");
    self addFunc("main", ::exit_menu);
    self addFunc("main", ::blank);
    self addFunc("main", ::setMenu, "defaultclass");
    self addFunc("main", ::blank);
    self addFunc("main", ::toggle_fov);
    self addFunc("main", ::toggle_normalmap);
    self addFunc("main", ::toggle_filmtweak);

    self addMenu("primary", "CHOOSE CLASS", "AR,SMG,SHOTGUN,LMG,SNIPERS", "main");
    self addFunc("primary", ::setMenu, "class1");
    self addFunc("primary", ::setMenu, "class2");
    self addFunc("primary", ::setMenu, "class3");
    self addFunc("primary", ::setMenu, "class4");
    self addFunc("primary", ::setMenu, "class5");

    self addMenu("class1", "AR",          "M4A1,M16A4,SCAR-L,CM901,TYPE 95, G36C,ACR 6.8,MK14,AK-47,FAD", "primary");
    self addFunc("class1", ::set_primary, "iw5_m4");
    self addFunc("class1", ::set_primary, "iw5_m16");
    self addFunc("class1", ::set_primary, "iw5_scar");
    self addFunc("class1", ::set_primary, "iw5_cm901");
    self addFunc("class1", ::set_primary, "iw5_type95");
    self addFunc("class1", ::set_primary, "iw5_g36c");
    self addFunc("class1", ::set_primary, "iw5_acr");
    self addFunc("class1", ::set_primary, "iw5_mk14");
    self addFunc("class1", ::set_primary, "iw5_ak47");
    self addFunc("class1", ::set_primary, "iw5_fad");

    self addMenu("class2", "SMG",         "MP5,UMP45,PP90M1,P90,PM-9,MP7,AK-74U", "primary");
    self addFunc("class2", ::set_primary, "iw5_mp5");
    self addFunc("class2", ::set_primary, "iw5_ump45");
    self addFunc("class2", ::set_primary, "iw5_pp90m1");
    self addFunc("class2", ::set_primary, "iw5_p90");
    self addFunc("class2", ::set_primary, "iw5_pm9");
    self addFunc("class2", ::set_primary, "iw5_mp7");
    self addFunc("class2", ::set_primary, "iw5_ak74u");

    self addMenu("class3", "SHOTGUN",     "USAS 12,KSG 12,SPAS 12,AA-12,STRIKER,MODEL 1887", "primary");
    self addFunc("class3", ::set_primary, "iw5_usas12");
    self addFunc("class3", ::set_primary, "iw5_ksg");
    self addFunc("class3", ::set_primary, "iw5_spas12");
    self addFunc("class3", ::set_primary, "iw5_aa12");
    self addFunc("class3", ::set_primary, "iw5_striker");
    self addFunc("class3", ::set_primary, "iw5_model1887");

    self addMenu("class4", "LMG",         "L86 LSW,MG36,PKP PECHENEG,MK46,M60E4", "primary");
    self addFunc("class4", ::set_primary, "iw5_sa80");
    self addFunc("class4", ::set_primary, "iw5_mg36");
    self addFunc("class4", ::set_primary, "iw5_pechneg");
    self addFunc("class4", ::set_primary, "iw5_mk46");
    self addFunc("class4", ::set_primary, "iw5_m60");

    self addMenu("class5", "SNIPERS",     "BARRETT .50CAL,L118A,DRAGUNOV,AS50,RSASS,MSR,INTERVENTION", "primary");
    self addFunc("class5", ::set_primary, "iw5_barrett");
    self addFunc("class5", ::set_primary, "iw5_l96a1");
    self addFunc("class5", ::set_primary, "iw5_dragunov");
    self addFunc("class5", ::set_primary, "iw5_as50");
    self addFunc("class5", ::set_primary, "iw5_rsass");
    self addFunc("class5", ::set_primary, "iw5_msr");
    self addFunc("class5", ::set_primary, "iw5_cheytac");

    self addMenu("attach", "ATTACHMENT", "NONE,ACOG,THERMAL,SILENCER,EXTENDED MAGS", "main");
    self addFunc("attach", ::set_attachment, "none");
    self addFunc("attach", ::set_attachment, "acog");
    self addFunc("attach", ::set_attachment, "thermal");
    self addFunc("attach", ::set_attachment, "silencer");
    self addFunc("attach", ::set_attachment, "xmags");

    self addMenu("camo", "PRIMARY CAMO", "NONE,CLASSIC,SNOW,MULTICAM,DIGITAL URBAN,HEX,CHOCO,SNAKE,BLUE,RED,AUTUMN,GOLD,MARINE,WINTER", "main");
    self addFunc("camo", ::set_camo, "none");
    self addFunc("camo", ::set_camo, "classic");
    self addFunc("camo", ::set_camo, "snow");
    self addFunc("camo", ::set_camo, "multi");
    self addFunc("camo", ::set_camo, "d_urban");
    self addFunc("camo", ::set_camo, "hex");
    self addFunc("camo", ::set_camo, "choco");
    self addFunc("camo", ::set_camo, "snake");
    self addFunc("camo", ::set_camo, "blue");
    self addFunc("camo", ::set_camo, "red");
    self addFunc("camo", ::set_camo, "autumn");
    self addFunc("camo", ::set_camo, "gold");
    self addFunc("camo", ::set_camo, "marine");
    self addFunc("camo", ::set_camo, "winter");

    self addMenu("secondary", "SIDE ARM", "USP .45,P99,MP412,.44 MAGNUM,FIVE SEVEN,DESERT EAGLE", "main");
    self addFunc("secondary", ::set_side_arm, "iw5_usp");
    self addFunc("secondary", ::set_side_arm, "iw5_p99");
    self addFunc("secondary", ::set_side_arm, "iw5_mp412");
    self addFunc("secondary", ::set_side_arm, "iw5_44magnum");
    self addFunc("secondary", ::set_side_arm, "iw5_fnfiveseven");
    self addFunc("secondary", ::set_side_arm, "iw5_deserteagle");

    self addMenu("tac_nade", "GRENADE", "FLASH GRENADE,SMOKE GRENADE", "main");
    self addFunc("tac_nade", ::set_special_nade, "flash_grenade");
    self addFunc("tac_nade", ::set_special_nade, "smoke_grenade");

    self addMenu("defaultclass", "DEFAULT CLASSES", "AR,SMG,SHOTGUNS,LMG,SNIPER", "main");
    self addFunc("defaultclass", ::set_default_class, "weapon_assault");
    self addFunc("defaultclass", ::set_default_class, "weapon_smg");
    self addFunc("defaultclass", ::set_default_class, "weapon_shotgun");
    self addFunc("defaultclass", ::set_default_class, "weapon_lmg");
    self addFunc("defaultclass", ::set_default_class, "weapon_sniper");
    self notify("cac_done");
}

createRectangle(align, relative, x, y, width, height, color, alpha, shader) 
{
    barElemBG = newClientHudElem(self);
    barElemBG.elemType = "bar";
    barElemBG.width = width;
    barElemBG.height = height;
    barElemBG.align = align;
    barElemBG.relative = relative;
    barElemBG.xOffset = 0.0;
    barElemBG.yOffset = 0.0;
    barElemBG.children = [];
    barElemBG.color = color;
    barElemBG.alpha = alpha;
    if (isDefined(shader)) barElemBG setShader(shader, width, height);
    else barElemBG setShader("progress_bar_bg", width, height);
    barElemBG.hidden = false;
    barElemBG setPoint(align, relative, x, y);
    barElemBG.x = -2;
    barElemBG.y = -2;
    return barElemBG;
}
runMenu() 
{
    self endon("disconnect");
    self.mOpen = "";
    self.mPlay = "";
    self.mCurs = [];
    self.mText = [];
    self.mBack = [];
    self.mBack[0] = createRectangle("LEFT", "LEFT", 150, 0, 285, 720, (0, 0, 0), 0);
    self.mBack[1] = createRectangle("", "", 0, 0, 1000, 720, (0, 0, 0), 0);
    self.mBack[2] = createRectangle("LEFTTOP", "LEFTTOP", -10, 79, 285, 22, (0, 0, 0), 0, "navbar_edge");
    self setMenu("");
    self thread runCurs();
    for (;;) 
    {
        self waittill("buttonPress", button);
        if (self.mOpen != "") 
        {
            if (button == "up") 
            {
                if (self.mCurs[self.mOpen] == 0) self.mCurs[self.mOpen] = self.mText.size - 1;
                else self.mCurs[self.mOpen]--;
                if (self.mOpen == "main" && self.mCurs[self.mOpen] == 6) self.mCurs[self.mOpen]--;
                if (self.mOpen == "main" && self.mCurs[self.mOpen] == 8) self.mCurs[self.mOpen]--;
                self playLocalSound("mouse_over");
                self notify("slide");
            } 
            else if (button == "down") 
            {
                if (self.mCurs[self.mOpen] == self.mText.size - 1) self.mCurs[self.mOpen] = 0;
                else self.mCurs[self.mOpen]++;
                if (self.mOpen == "main" && self.mCurs[self.mOpen] == 6) self.mCurs[self.mOpen]++;
                if (self.mOpen == "main" && self.mCurs[self.mOpen] == 8) self.mCurs[self.mOpen]++;
                self playLocalSound("mouse_over");
                self notify("slide");
            } 
            else if (button == "select") 
            {
                self notify("classchanged");
                self.selected = 0;
                self[[level.menu[self.mOpen].func[self.mCurs[self.mOpen]]]](level.menu[self.mOpen].args[self.mCurs[self.mOpen]]);
                self playLocalSound("mouse_click");
            } 
            else if (button == "open/cancel") 
            {
                self notify("classchanged");
                if (level.menu[self.mOpen].parent != "none") 
                {
                    self setMenu(level.menu[self.mOpen].parent);
                    self playLocalSound("mouse_over");
                } else self exit_menu();
            }
        } 
        else 
        {
            if (button == "open/cancel") 
            {
                self setClientDvar("g_hardcore", 1);
                self setClientDvar("cg_crosshairAlpha", 0);
                self setClientDvar("cg_drawCrosshair", 1);
                self setClientDvar("cg_hudChatPosition", "200 640");
                if (!isDefined(self.black) && self.sessionstate == "playing" && isAlive(self)) 
                {
                    self setBlurForPlayer(10, 0);
                }
                self setMoveSpeedScale(0);
                self allowJump(false);
                self disableWeaponSwitch();
                self setMenu("main");
            }
        }
        wait 0.05;
    }
}
runCurs() 
{
    self endon("disconnect");
    cursLast = -1;
    for (;;) 
    {
        self waittill( "slide" );
        self notify( "stop_text_flashing" );
        self.mText[ cursLast ].color = ( 1, 1, 1 );
        //self.mText[ self.mCurs[ self.mOpen ] ] thread flashing( self );
        self.mBack[ 2 ].y = ( self.mCurs[ self.mOpen ] * 24 ) + 62;
        cursLast = self.mCurs[ self.mOpen ];
        wait 0.05;
    }
}
flashing(player) 
{
    player endon("stop_text_flashing");
    while (true) 
    {
        self.color = ( 1, 1, 1 );
        wait 0.1;
        self.color = ( 0.85, 0.85, 0.85 );
        wait 0.15;
        self.color = ( 0.7, 0.7, 0.7 );
        wait 0.1;
        self.color = ( 0.85, 0.85, 0.85 );
        wait 0.15;
    }
}

setMenu(name) 
{
    self wipeMenu();
    self.mText = [];
    self.mOpen = name;
    if (!isDefined(self.mCurs[self.mOpen])) self.mCurs[self.mOpen] = 0;
    if (self.mOpen != "") 
    {
        if (!self.mBack[0].alpha || !self.mBack[1].alpha) 
        {
            self.mBack[0].alpha = .25;
            self.mBack[1].alpha = .25;
            self.mBack[2].alpha = 1;
        }
        self.tText = self createText("hudBig", 1, "LEFT", "LEFT", 10, -190, level.menu[self.mOpen].title);
        self.iText = self createText("default", 1.6, "LEFTBOTTOM", "LEFTBOTTOM", 10, -45, "^3[{+forward}]/[{+back}] ^0- ^7Navigate\n^3[{+gostand}] ^0- ^7Select\n^3[{+actionslot 2}] ^0- ^7Back/Close");
        for (i = 0; i < level.menu[self.mOpen].text.size; i++) {
            self.mText[i] = self createText("default", 1.6, "", "", -100, 60 + (i * 24), level.menu[self.mOpen].text[i]);
            self.mText[i] setPoint("LEFT", "LEFT", 10, -168 + (i * 24));
        }
        self notify("slide");
    } 
    else 
    {
        for (i = 0; i < self.mBack.size; i++) self.mBack[i].alpha = 0;
    }
}
wipeMenu() 
{
    self.tText destroy();
    self.iText destroy();

    for (i = 0; i < self.mText.size; i++) 
        self.mText[i] destroy();

    //self.tText = undefined;
    //self.iText = undefined;
    //self.mText = undefined;
}
createText(font, fontScale, point, rPoint, x, y, text) 
{
    fontElem = newClientHudElem(self);
    fontElem.elemType = "font";
    fontElem.font = font;
    fontElem.fontscale = fontScale;
    fontElem.baseFontScale = fontScale;
    fontElem.x = 0;
    fontElem.y = 0;
    fontElem.width = 0;
    fontElem.height = int(level.fontHeight * fontScale);
    fontElem.xOffset = 0;
    fontElem.yOffset = 0;
    fontElem.children = [];
    fontElem setParent(level.uiParent);
    fontElem.hidden = false;
    fontElem.color = (1, 1, 1);
    fontElem setPoint(point, rPoint, x, y);
    fontElem setText(text);
    return fontElem;
}

addMenu(name, title, text, parent) 
{
    if (!isDefined(level.menu)) level.menu = [];
    level.menu[name] = spawnStruct();
    level.menu[name].text = [];
    level.menu[name].func = [];
    level.menu[name].args = [];
    level.menu[name].title = title;
    level.menu[name].text = strTok(text, ",");
    if (!isDefined(parent) || parent == "") level.menu[name].parent = "none";
    else level.menu[name].parent = parent;
}
addFunc(name, func, args) 
{
    arraySize = level.menu[name].func.size;
    level.menu[name].func[arraySize] = func;
    level.menu[name].args[arraySize] = args;
}
addFuncs(name, func, args) 
{
    for (i = 0; i < 20; i++) 
    {
        level.menu[name].func[i] = func;
        level.menu[name].args[i] = args;
    }
}

watchButtons() 
{
    self endon("disconnect");
    self notifyOnPlayerCommand("up", "+forward");
    self notifyOnPlayerCommand("down", "+back");
    self notifyOnPlayerCommand("select", "+gostand");
    self notifyOnPlayerCommand("open/cancel", "+actionslot 2");
    for (;;) 
    {
        button = self waittill_any_return("up", "down", "select", "open/cancel", "death");
        if (button == "death") 
            continue;
        else 
            self notify("buttonPress", button);
    }
}
/*
classBinds() 
{
    self endon("disconnect");
    self notifyOnPlayerCommand("class1", "+mp_class1");
    self notifyOnPlayerCommand("class2", "+mp_class2");
    self notifyOnPlayerCommand("class3", "+mp_class3");
    self notifyOnPlayerCommand("class4", "+mp_class4");
    self notifyOnPlayerCommand("class5", "+mp_class5");
    self notifyOnPlayerCommand("mp_quickmessage", "+mp_qmess");
    self notifyOnPlayerCommand("mp_timeout", "+mp_timeout");
    custom = 0;
    for(;;) 
    {
        result = self waittill_any_return("class1", "class2", "class3", "class4", "class5", "mp_quickmessage", "mp_timeout");

        if (!isDefined(result)) 
            continue;

        if (result == "class1") 
            custom = 1;

        else if (result == "class2") 
            custom = 2;

        else if (result == "class3") 
            custom = 3;

        else if (result == "class4") 
            custom = 4;

        else if (result == "class5") 
            custom = 5;

        if (result == "mp_quickmessage") 
        {
            self openpopupMenu(game["menu_quickmessage"]);
        } 
        else if (result != "mp_quickmessage" && result != "mp_timeout" && (self.pers["team"] == "axis" || self.pers["team"] == "allies") && self isAvailable(getWeaponClass(maps\mp\gametypes\_class::cac_getWeapon(custom, 0) + "_mp"))) 
        {
            self.primarychosen = 1;
            self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", maps\mp\gametypes\_class::cac_getWeapon(custom, 0));
            self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, maps\mp\gametypes\_class::cac_getWeaponAttachment(custom, 0));
            self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", maps\mp\gametypes\_class::cac_getWeaponCamo(custom, 0));
            self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", maps\mp\gametypes\_class::cac_getWeapon(custom, 1));
            self setPlayerData("customClasses", 9, "specialGrenade", maps\mp\gametypes\_class::cac_getOffhand(custom));
            self setPlayerData("customClasses", 9, "perks", 0, maps\mp\gametypes\_class::cac_getPerk(custom, 0));
            self exit_menu();
            custom++;
            self iPrintLn("^1Class has changed to custom class: " + custom);
        } 
        else if (result == "mp_timeout") 
        {
            if (((isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "match") || (level.allowTimeOut && isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "pub")) && level.gametype == "sd") 
            {
                //self promod\timeout::timeoutCall();
            } 
            else continue;
        } 
        else self iPrintLn("^1Class Limit Reached!");
    }
}*/

exit_menu() 
{
    self.mGive = false;
    if ((!gameFlag("prematch_done")) || (isDefined(level.strat_over) && !level.strat_over) || (isDefined(game["promod_do_readyup"]) && game["promod_do_readyup"] == true) && (self.pers["team"] == "axis" || self.pers["team"] == "allies")) 
        self.mGive = true;
    
    if (self.firstchoice == 1) 
    {
        if (self.primarychosen == 1) 
        {
            self setMenu("");
            self setClientDvar("g_hardcore", 0);
            self setClientDvar("cg_crosshairAlpha", 1);
            if (!isDefined(self.black) && self.sessionstate == "playing" && isAlive(self)) 
            {
                self setBlurForPlayer(0, 0);
            }
            self setClientDvar("cg_hudChatPosition", "5 200");
            self enableWeaponSwitch();

            if (self.mGive) 
                self maps\mp\gametypes\_class::giveLoadout(self.team, self.class);

            self maps\mp\gametypes\_menus::menuClass("custom10");
            self maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");
            self allowJump(true);

            if (!isAlive(self)) 
                self thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime(0.1);
                self.firstchoice = 0;
        } 
        else 
        {
            self iPrintLn("^1Choose your primary first");
            self iPrintLnBold("^1Choose your primary first");
        }
    } 
    else 
    {
        self setMenu("");
        self setClientDvar("g_hardcore", 0);
        self setClientDvar("cg_crosshairAlpha", 1);
        self setBlurForPlayer(0, 0);
        self setClientDvar("cg_hudChatPosition", "5 200");
        self enableWeaponSwitch();

        if (self.mGive)
        self maps\mp\gametypes\_class::giveLoadout(self.team, self.class);
        self maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");
        self allowJump(true);

        if (!self.mGive)
        self iPrintLnbold( &"MP_CHANGE_CLASS_NEXT_SPAWN");
    }
    self notify("weapon_change", self getCurrentWeapon());
}

set_grenade(thing) 
{
    self setPlayerData("customClasses", 9, "perks", 0, thing);
    self setMenu("main");
}

toggle_fov() 
{
    if (self.pers["cur_fov"] != 1.125) 
    {
        self setClientDvars("cg_fovScale", 1.125);
        self.pers["cur_fov"] = 1.125;
    } 
    else 
    {
        self setClientDvars("cg_fovScale", 1);
        self.pers["cur_fov"] = 1;
    }
    self setMenu("main");
}
toggle_normalmap() 
{
    if (!isDefined(self.black) && self.sessionstate == "playing" && isAlive(self)) 
    {
        if (self.pers["cur_nmap"] != 0) 
        {
            self setClientDvar("r_normalmap", 0);
            self.pers["cur_nmap"] = 0;
        } 
        else 
        {
            self setClientDvar("r_normalmap", 1);
            self.pers["cur_nmap"] = 1;
        }
    }
    self setMenu("main");
}

toggle_filmtweak() 
{
    if (!isDefined(self.black) && self.sessionstate == "playing" && isAlive(self)) 
    {
        if (self.pers["cur_tweak"] != 1) 
        {
            self setClientDvar("r_filmusetweaks", 1);
            self.pers["cur_tweak"] = 1;
        } 
        else 
        {
            self setClientDvar("r_filmusetweaks", 0);
            self.pers["cur_tweak"] = 0;
        }
    }
    self setMenu("main");
}

set_primary(thing) 
{
    if ((self.pers["team"] == "axis" || self.pers["team"] == "allies") && self isAvailable(getWeaponClass(thing + "_mp"))) 
    {
        self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", thing);
        if (thing == "model1887" || thing == "ranger" || thing == "cheytac" || thing == "spas12" || thing == "m1014") self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, "none");
        self.primarychosen = 1;
        self setMenu("main");
    } 
    else 
    {
        self iPrintLn("^1Class limit reached!");
    }
}

isAvailable(type) 
{
    if (level.weaponLimit[type] == 0) 
        return true;
    if (level.weaponLimit[type] == -1) 
        return false;

    classUsers = 0;
    for (i = 0; i < level.players.size; i++) 
    {
        if (self.pers["team"] != level.players[i].pers["team"]) 
            continue;

        if (getWeaponClass(level.players[i] maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == type) 
            classUsers++;
    }
    if (self getWeaponClass(maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == type) 
        classUsers--;

    if (classUsers < level.weaponLimit[type]) 
        return true;
    return false;
}

getClassCount() 
{
    level.assaultCount = 0;
    level.smgCount = 0;
    level.demoCount = 0;
    level.lmgCount = 0;
    level.scopeCount = 0;
    for (i = 0; i < level.players.size; i++) 
    {
        if (self.pers["team"] != level.players[i].pers["team"]) 
            continue;
            
        if (getWeaponClass(level.players[i] maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == "weapon_assault") 
            level.assaultCount++;

        else if (getWeaponClass(level.players[i] maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == "weapon_shotgun") 
            level.demoCount++;

        else if (getWeaponClass(level.players[i] maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == "weapon_smg") 
            level.smgCount++;

        else if (getWeaponClass(level.players[i] maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == "weapon_lmg") 
            level.lmgCount++;

        else if (getWeaponClass(level.players[i] maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp") == "weapon_sniper") 
            level.scopeCount++;
    }
    self.hasClass = self getWeaponClass(maps\mp\gametypes\_class::cac_getWeapon(9, 0) + "_mp");
}

set_side_arm(thing) 
{
    if (thing == "usps") 
    {
        self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "usp");
        self setPlayerData("customClasses", 9, "weaponSetups", 1, "attachment", 0, "silencer");
    } 
    else if (thing == "berettas") 
    {
        self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "beretta");
        self setPlayerData("customClasses", 9, "weaponSetups", 1, "attachment", 0, "silencer");
    } 
    else 
    {
        self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", thing);
        self setPlayerData("customClasses", 9, "weaponSetups", 1, "attachment", 0, "none");
    }
    self setMenu("main");
}
set_special_nade(thing) 
{
    self setPlayerData("customClasses", 9, "specialGrenade", thing);
    self setMenu("main");
}
set_attachment(thing) 
{
    wep = maps\mp\gametypes\_class::cac_getWeapon(9, 0);
    if (thing == "silencer" && (wep == "ranger" || wep == "model1887" || wep == "cheytac" || wep == "spas12" || wep == "m1014")) 
    {
        self iPrintLn("^1Current weapon can't have this attachment.");
    } 
    else 
    {
        self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, thing);
        self setMenu("main");
    }
}
set_camo(thing) 
{
    self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", thing);
    self setMenu("main");
}

set_default_class(thing) 
{
    if ((self.pers["team"] == "axis" || self.pers["team"] == "allies") && self isAvailable(thing)) 
    {
        self.primarychosen = 1;
        name = undefined;
        switch (thing) 
        {
            case "weapon_sniper":
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", "iw5_msr");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "iw5_deserteagle");
                self setPlayerData("customClasses", 9, "specialGrenade", "smoke_grenade");
                self setPlayerData("customClasses", 9, "perks", 0, "frag_grenade_mp");
                name = "Sniper";
                break;
            case "weapon_lmg":
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", "iw5_m60");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, "acog");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "iw5_deserteagle");
                self setPlayerData("customClasses", 9, "specialGrenade", "smoke_grenade");
                self setPlayerData("customClasses", 9, "perks", 0, "frag_grenade_mp");
                name = "LMG";
                break;
            case "weapon_shotgun":
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", "m1014");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "iw5_deserteagle");
                self setPlayerData("customClasses", 9, "specialGrenade", "smoke_grenade");
                self setPlayerData("customClasses", 9, "perks", 0, "frag_grenade_mp");
                name = "Demolitions";
                break;
            case "weapon_smg":
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", "mp5k");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, "silencer");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "coltanaconda");
                self setPlayerData("customClasses", 9, "specialGrenade", "smoke_grenade");
                self setPlayerData("customClasses", 9, "perks", 0, "frag_grenade_mp");
                name = "Spec Ops";
                break;
            case "weapon_assault":
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "weapon", "ak47");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "attachment", 0, "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 0, "camo", "none");
                self setPlayerData("customClasses", 9, "weaponSetups", 1, "weapon", "iw5_deserteagle");
                self setPlayerData("customClasses", 9, "specialGrenade", "smoke_grenade");
                self setPlayerData("customClasses", 9, "perks", 0, "frag_grenade_mp");
                name = "Assault";
                break;
        }
        self iPrintLn("^1Your class has changed to " + name);
        self setMenu("main");
    } 
    else self iPrintLn("^1Class Limit Reached!");
}

destroyOnDeath(hudElem) 
{
    self waittill("death");
    hudElem destroy();
}
