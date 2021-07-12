main()
{
    level endon("restarting");
    thread errorMessage();
    for (;;)
    {
        if (getDvarInt("sv_cheats") || (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "strat"))
            break;
        forceDvar("g_gravity", "800");
        forceDvar("g_speed", "190");
        forceDvar("g_knockback", "1000");
        forceDvar("g_playercollisionejectspeed", "25");
        forceDvar("g_dropforwardspeed", "10");
        forceDvar("g_drophorzspeedrand", "100");
        forceDvar("g_dropupspeedbase", "10");
        forceDvar("g_dropupspeedrand", "5");
        forceDvar("g_useholdtime", "0");
        if (isDefined(game["PROMOD_MATCH_MODE"]) && (game["PROMOD_MATCH_MODE"] == "match" || game["PROMOD_MATCH_MODE"] == "pub"))
        {
            forceDvar("g_maxdroppedweapons", "16");
            if (!game["LAN_MODE"])
                forceDvar("g_smoothclients", "1");
        }
        wait 2;
    }
}
forceDvar(dvar, value)
{
    if (getDvar(dvar) != value)
        setDvar(dvar, value);
}
errorMessage()
{
    level endon("restarting");
    for (;;)
    {
        if (getDvarInt("sv_cheats") || (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "strat"))
            break;
        if ((getDvarInt("scr_player_maxhealth") != 100 && game["HARDCORE_MODE"] != 1 && game["CUSTOM_MODE"] != 1) || (getDvarInt("scr_player_maxhealth") != 30 && game["HARDCORE_MODE"] == 1 && game["CUSTOM_MODE"] != 1))
            iprintlnbold("^1Server Violation^7: Modified Player Health");
        wait 5;
    }
}