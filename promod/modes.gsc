main()
{
    mode = toLower(getDvar("promod_mode"));
    if (!validMode(mode))
    {
        mode = "comp_public";
        setDvar("promod_mode", mode);
    }
    setgMode(mode);
}
validMode(mode)
{
    switch (mode)
    {
    case "comp_public":
    case "comp_public_hc":
    case "custom_public":
    case "strat":
    case "match":
    case "knockout":
        return true;
    }
    keys = strtok(mode, "_");
    if (keys.size <= 1)
        return false;
    switches = [];
    switches["match_knockout"] = false;
    switches["1v1_2v2"] = false;
    switches["lan_pb"] = false;
    switches["hc_done"] = false;
    switches["knife_done"] = false;
    switches["mr_done"] = false;
    for (i = 0; i < keys.size; i++)
    {
        switch (keys[i])
        {
        case "match":
        case "knockout":
            if (switches["match_knockout"])
                return false;
            switches["match_knockout"] = true;
            break;
        case "1v1":
        case "2v2":
            if (switches["1v1_2v2"])
                return false;
            switches["1v1_2v2"] = true;
            break;
        case "lan":
        case "pb":
            if (switches["lan_pb"])
                return false;
            switches["lan_pb"] = true;
            break;
        case "knife":
        case "hc":
            if (switches[keys[i] + "_done"])
                return false;
            switches[keys[i] + "_done"] = true;
            break;
        default:
            if (keys[i] != "mr" && isSubStr(keys[i], "mr") && "mr" + int(strtok(keys[i], "mr")[0]) == keys[i] && int(strtok(keys[i], "mr")[0]) > 0 && !switches["mr_done"])
                switches["mr_done"] = true;
            else
                return false;
            break;
        }
    }
    return switches["match_knockout"];
}
monitorMode()
{
    o_mode = toLower(getDvar("promod_mode"));
    o_cheats = getDvarInt("sv_cheats");
    for (;;)
    {
        mode = toLower(getDvar("promod_mode"));
        cheats = getDvarInt("sv_cheats");
        if (mode != o_mode)
        {
            if (isDefined(game["state"]) && game["state"] == "postgame")
            {
                setDvar("promod_mode", o_mode);
                continue;
            }
            if (validMode(mode))
            {
                level notify("restarting");
                iPrintLN("Changing To Mode: ^1" + mode + "\nPlease Wait While It Loads...");
                setgMode(mode);
                wait 2;
                map_restart(false);
                setDvar("promod_mode", mode);
            }
            else
            {
                if (isDefined(mode) && mode != "")
                    iPrintLN("Error Changing To Mode: ^1" + mode + "\nSyntax:\nmatch|knockout_lan|pb_hc_knife_1v1|2v2_mr#,\nNormal Modes: comp_public, comp_public_hc, custom_public, strat");
                setDvar("promod_mode", o_mode);
            }
        }
        else if (cheats != o_cheats)
        {
            map_restart(false);
            break;
        }
        wait 0.1;
    }
}
setgMode(mode)
{
    limited_mode = 0;
    knockout_mode = 0;
    mr_rating = 0;
    game["CUSTOM_MODE"] = 0;
    game["LAN_MODE"] = 0;
    game["HARDCORE_MODE"] = 0;
    if (!isDefined(game["PROMOD_STRATTIME"]))
        game["PROMOD_STRATTIME"] = 8;
    game["PROMOD_MODE_HUD"] = "";
    game["PROMOD_MATCH_MODE"] = "";
    game["PROMOD_KNIFEROUND"] = 0;
    if (mode == "comp_public")
    {
        promod\comp::main();
        game["PROMOD_MATCH_MODE"] = "pub";
        game["PROMOD_MODE_HUD"] = "^1Competitive ^7Public";
        pub();
    }
    else if (mode == "comp_public_hc")
    {
        promod\comp::main();
        game["PROMOD_MATCH_MODE"] = "pub";
        game["HARDCORE_MODE"] = 1;
        game["PROMOD_MODE_HUD"] = "^1Competitive ^7Public ^1HC";
        pub();
    }
    else if (mode == "custom_public")
    {
        promod_ruleset\custom_public::main();
        game["CUSTOM_MODE"] = 1;
        game["PROMOD_MATCH_MODE"] = "pub";
        game["PROMOD_MODE_HUD"] = "^1Custom ^7Public";
        game["PROMOD_KNIFEROUND"] = getDvarInt("promod_kniferound");
    }
    else if (mode == "strat")
    {
        promod\comp::main();
        game["PROMOD_MODE_HUD"] = "^1Strat ^7Mode";
        game["PROMOD_MATCH_MODE"] = "strat";
        setDvar("class_specops_limit", 0);
        setDvar("class_demolitions_limit", 0);
        setDvar("class_sniper_limit", 0);
    }
    if (game["PROMOD_MATCH_MODE"] == "")
    {
        exploded = StrTok(mode, "_");
        for (i = 0; i < exploded.size; i++)
        {
            switch (exploded[i])
            {
            case "match":
                game["PROMOD_MATCH_MODE"] = "match";
                break;
            case "knockout":
                knockout_mode = 1;
                game["PROMOD_MATCH_MODE"] = "match";
                break;
            case "lan":
                game["LAN_MODE"] = 1;
                break;
            case "1v1":
            case "2v2":
                limited_mode = int(strtok(exploded[i], "v")[0]);
                break;
            case "knife":
                game["PROMOD_KNIFEROUND"] = 1;
                break;
            case "pb":
                game["PROMOD_PB_OFF"] = 1;
                break;
            case "hc":
                game["HARDCORE_MODE"] = 1;
                break;
            default:
                if (isSubStr(exploded[i], "mr"))
                    mr_rating = strtok(exploded[i], "mr")[0];
                break;
            }
        }
    }
    if (game["PROMOD_MATCH_MODE"] == "match")
        promod\comp::main();
    if (limited_mode)
    {
        setDvar("class_demolitions_limit", 0);
        setDvar("class_sniper_limit", 0);
        game["PROMOD_MODE_HUD"] += "^1" + limited_mode + "V" + limited_mode + " ";
    }
    if (knockout_mode)
        game["PROMOD_MODE_HUD"] += "^4Knockout";
    else if (game["PROMOD_MATCH_MODE"] == "match")
        game["PROMOD_MODE_HUD"] += "^7Match";
    if (game["PROMOD_KNIFEROUND"] && game["PROMOD_MATCH_MODE"] == "match")
        game["PROMOD_MODE_HUD"] += " ^7Knife";
    if (game["LAN_MODE"])
    {
        setDvar("g_antilag", 0);
        setDvar("g_smoothClients", 0);
        game["PROMOD_MODE_HUD"] += " ^4LAN";
        if (knockout_mode)
            game["PROMOD_STRATTIME"] = 10;
    }
    if (game["HARDCORE_MODE"])
    {
        if (game["PROMOD_MATCH_MODE"] == "match")
            game["PROMOD_MODE_HUD"] += " ^1HC";
        setDvar("scr_hardcore", 1);
    }
    if (int(mr_rating) > 0 && (level.gametype == "sd" || level.gametype == "sab"))
    {
        game["PROMOD_MODE_HUD"] += " " + "^1MR" + int(mr_rating);
        setDvar("scr_" + level.gametype + "_roundswitch", int(mr_rating));
        setDvar("scr_" + level.gametype + "_roundlimit", int(mr_rating) * 2);
        setDvar("scr_" + level.gametype + "_winlimit", 0);
        if (knockout_mode && level.gametype == "sd")
            setDvar("scr_sd_scorelimit", int(mr_rating) + 1);
    }
    else if (game["PROMOD_MATCH_MODE"] == "match")
        game["PROMOD_MODE_HUD"] += " ^1Standard";
    if (getDvarInt("sv_cheats"))
        game["PROMOD_MODE_HUD"] += " ^1CHEATS ^7ON";
    if (level.gametype != "sd")
        game["PROMOD_KNIFEROUND"] = 0;
}
pub()
{
    setDvar("scr_war_roundswitch", 0);
    setDvar("scr_war_roundlimit", 1);
}