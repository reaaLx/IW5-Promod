main()
{
    setDvar("scr_sd_bombtimer", 45);
    setDvar("scr_sd_defusetime", 7);
    setDvar("scr_sd_multibomb", 0);
    setDvar("scr_sd_numlives", 1);
    setDvar("scr_sd_planttime", 5);
    setDvar("scr_sd_playerrespawndelay", 0);
    setDvar("scr_sd_roundlimit", 23);
    setDvar("scr_sd_roundswitch", 4);
    setDvar("scr_sd_scorelimit", 0);
	setDvar("scr_sd_winlimit", 12); 
    setDvar("scr_sd_timelimit", 1.75);
    setDvar("scr_sd_waverespawndelay", 0);
    setDvar("scr_dom_numlives", 0);
    setDvar("scr_dom_playerrespawndelay", 7);
    setDvar("scr_dom_roundlimit", 2);
    setDvar("scr_dom_roundswitch", 1);
    setDvar("scr_dom_scorelimit", 0);
    setDvar("scr_dom_timelimit", 15);
    setDvar("scr_dom_waverespawndelay", 0);
    setDvar("koth_autodestroytime", 120);
    setDvar("koth_capturetime", 20);
    setDvar("koth_delayPlayer", 0);
    setDvar("koth_destroytime", 10);
    setDvar("koth_kothmode", 0);
    setDvar("koth_spawnDelay", 45);
    setDvar("koth_spawntime", 10);
    setDvar("scr_koth_numlives", 0);
    setDvar("scr_koth_playerrespawndelay", 0);
    setDvar("scr_koth_roundlimit", 2);
    setDvar("scr_koth_roundswitch", 1);
    setDvar("scr_koth_scorelimit", 0);
    setDvar("scr_koth_timelimit", 20);
    setDvar("scr_koth_waverespawndelay", 0);
    setDvar("scr_sab_bombtimer", 45);
    setDvar("scr_sab_defusetime", 5);
    setDvar("scr_sab_hotpotato", 0);
    setDvar("scr_sab_numlives", 0);
    setDvar("scr_sab_planttime", 5);
    setDvar("scr_sab_playerrespawndelay", 7);
    setDvar("scr_sab_roundlimit", 4);
    setDvar("scr_sab_roundswitch", 2);
    setDvar("scr_sab_scorelimit", 0);
    setDvar("scr_sab_timelimit", 10);
    setDvar("scr_sab_waverespawndelay", 0);
    setDvar("scr_war_numlives", 0);
    setDvar("scr_war_playerrespawndelay", 0);
    setDvar("scr_war_roundlimit", 2);
    setDvar("scr_war_scorelimit", 0);
    setDvar("scr_war_roundswitch", 1);
    setDvar("scr_war_timelimit", 15);
    setDvar("scr_war_waverespawndelay", 0);
    setDvar("scr_dm_numlives", 0);
    setDvar("scr_dm_playerrespawndelay", 0);
    setDvar("scr_dm_roundlimit", 1);
    setDvar("scr_dm_scorelimit", 0);
    setDvar("scr_dm_timelimit", 10);
    setDvar("scr_dm_waverespawndelay", 0);
    setDvar("bg_fallDamageMinHeight", 140);
    setDvar("bg_fallDamageMaxHeight", 350);
    setDvar("scr_game_matchstarttime", 10);
	setDvar("g_smoothClients", 1);
	setDvar("g_inactivity", 0);
	setDvar("g_no_script_spam", 1);
	setDvar("sv_timeout", 240);
	setDvar("sv_maxPing", 0);
    setDvar("sv_minPing", 0);
    setDvar("scr_game_spectatetype", 1);
	setDvar("scr_team_fftype", 1);
    setDvar("scr_hardcore", 0);
	//Promod custom Dvars
	//Weapon drop
    setDvar("class_assault_allowdrop", 1);
    setDvar("class_specops_allowdrop", 1);
    setDvar("class_demolitions_allowdrop", 0);
    setDvar("class_sniper_allowdrop", 0);
	//class Limits
	setDvar( "class_sniper_limit", 1 );
	setDvar( "class_specops_limit", 2 );
	setDvar( "class_demolitions_limit", 1 );
	setDvar( "class_assault_limit", 0 ); // 0 means unlimited!
	//Killcams
	setDvar("scr_game_allowkillcam", 0);
}