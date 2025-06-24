enum TFGamemode
{
    DEATHMATCH = 1,
    GUNGAME,
    VSH,
    INFECTION,
    DEATHRUN,
    ARENA,
    MVM,
    PASS_TIME,
    CTF,
    CONTROL_POINT,
    ATTACK_DEFEND,
    PAYLOAD,
    PAYLOAD_RACE,
    KOTH,
    TRAINING,
    ROBOT_DESTRUCTION,
    PLAYER_DESTRUCTION,
    SPECIAL_DELIVERY,
    HYBRID_CTF_CP,
    RAID,
    BOSS_BATTLE,
    MANNPOWER,
    STOP_THAT_TANK,
    ZOMBIE_FORTRESS,
    SUPER_ZOMBIE_FORTRESS,
    ZOMBIE_ESCAPE,
    LENGTH
}

stock TFGamemode TF2_IsGamemode(bool vscript=false)
{
    char mapName[PLATFORM_MAX_PATH];
    char vscriptFile[PLATFORM_MAX_PATH];
    GetCurrentMap(mapName, sizeof(mapName));

    if (StrContains(mapName, "workshop/", false) == 0)
    {
        strcopy(mapName, sizeof(mapName), mapName[9]);
    }

    // DEATHMATCH
    if (vscript)
    {
        Format(vscriptFile, sizeof(vscriptFile), "scripts/vscripts/deathmatch/deathmatch.nut");
        File file = OpenFile(vscriptFile, "r", true);
        if (file != null)
        {
            CloseHandle(file);
            return DEATHMATCH;
        }
    }
    else if (StrContains(mapName, "dm_", false) == 0 ||
             StrContains(mapName, "deathmatch_", false) == 0 ||
             StrContains(mapName, "trade_", false) == 0 ||
             StrContains(mapName, "duel_", false) == 0)
    {
        return DEATHMATCH;
    }

    // GUNGAME
    if (vscript)
    {
        Format(vscriptFile, sizeof(vscriptFile), "scripts/vscripts/gungame/gungame.nut");
        File file = OpenFile(vscriptFile, "r", true);
        if (file != null)
        {
            CloseHandle(file);
            return GUNGAME;
        }
    }
    else if (!vscript &&
            (StrContains(mapName, "gg_", false) == 0 ||
             StrContains(mapName, "gungame_", false) == 0))
    {
        return GUNGAME;
    }

    // VSH
    if (vscript)
    {
        File file = OpenFile("scripts/vscripts/vssaxtonhale/vsh.nut", "r", true);
        if (file != null)
        {
            CloseHandle(file);
            return VSH;
        }
    }
    else if (StrContains(mapName, "vsh_", false) == 0)
    {
        return VSH;
    }

    // INFECTION
    if (vscript)
    {
        File file = OpenFile("scripts/vscripts/infection/infection.nut", "r", true);
        if (file != null)
        {
            CloseHandle(file);
            return INFECTION;
        }
    }
    else if (StrContains(mapName, "zi_", false) == 0)
    {
        return INFECTION;
    }

    // DEATHRUN
    if (StrContains(mapName, "dr_", false) == 0 ||
        StrContains(mapName, "deathrun_", false) == 0)
    {
        return DEATHRUN;
    }

    // ARENA
    if (FindEntityByClassname(-1, "tf_logic_arena") != -1 ||
        StrContains(mapName, "arena_", false) == 0)
    {
        return ARENA;
    }

    // MVM
    if (FindEntityByClassname(-1, "tf_logic_mann_vs_machine") != -1 ||
        StrContains(mapName, "mvm_", false) == 0)
    {
        return MVM;
    }

    // PASS_TIME
    if (FindEntityByClassname(-1, "passtime_logic") != -1 ||
        StrContains(mapName, "passtime_", false) == 0)
    {
        return PASS_TIME;
    }

    // CTF
    {
        int redFlags = 0, blueFlags = 0, totalFlags = 0;
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
        {
            int team = GetEntProp(ent, Prop_Send, "m_iTeamNum");
            if (team == 2) redFlags++;
            else if (team == 3) blueFlags++;
            totalFlags++;
        }

        if ((totalFlags > 0 && totalFlags % 2 == 0 && redFlags == blueFlags) ||
            (StrContains(mapName, "ctf_", false) == 0))
        {
            return CTF;
        }
    }

    // HYBRID_CTF_CP
    {
        int redFlags = 0, blueFlags = 0, totalFlags = 0;
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
        {
            int team = GetEntProp(ent, Prop_Send, "m_iTeamNum");
            if (team == 2) redFlags++;
            else if (team == 3) blueFlags++;
            totalFlags++;
        }

        if (FindEntityByClassname(-1, "tf_logic_hybrid_ctf_cp") != -1 ||
            ((StrContains(mapName, "ctf_", false) == 0) && ((redFlags == 0 && blueFlags > 0) || (blueFlags == 0 && redFlags > 0))))
        {
            return HYBRID_CTF_CP;
        }
    }

    // CONTROL_POINT
    {
        int ent = -1;
        bool found = false;
        while ((ent = FindEntityByClassname(ent, "team_control_point")) != -1)
        {
            found = true;
            break;
        }
        
        if (found ||
            StrContains(mapName, "cp_", false) == 0)
        {
            return CONTROL_POINT;
        }
    }

    // ATTACK_DEFEND
    {
        int ent = -1;
        bool hasUnowned = false;
        while ((ent = FindEntityByClassname(ent, "team_control_point")) != -1)
        {
            int team = GetEntProp(ent, Prop_Send, "m_iTeamNum");
            if (view_as<TFTeam>(team) == TFTeam_Unassigned)
            {
                hasUnowned = true;
                break;
            }
        }
        if (!hasUnowned && (StrContains(mapName, "cp_", false) == 0 || FindEntityByClassname(-1, "team_control_point_master") != -1))
        {
            return ATTACK_DEFEND;
        }
    }

    // PAYLOAD_RACE
    if (FindEntityByClassname(-1, "tf_logic_multiple_escort") != -1 ||
        StrContains(mapName, "plr_", false) == 0)
    {
        return PAYLOAD_RACE;
    }

    // PAYLOAD
    if (FindEntityByClassname(-1, "mapobj_cart_dispenser") != -1 ||
        StrContains(mapName, "pl_", false) == 0)
    {
        return PAYLOAD;
    }

    // KOTH
    {
        int ent = -1;
        bool allUnowned = true;
        bool found = false;
        while ((ent = FindEntityByClassname(ent, "team_control_point")) != -1)
        {
            found = true;
            int team = GetEntProp(ent, Prop_Send, "m_iTeamNum");
            if (view_as<TFTeam>(team) != TFTeam_Unassigned)
            {
                allUnowned = false;
                break;
            }
        }
        if ((found && allUnowned) ||
            StrContains(mapName, "koth_", false) == 0)
        {
            return KOTH;
        }
    }

    // TRAINING
    if (FindEntityByClassname(-1, "tf_logic_training_mode") != -1 ||
        StrContains(mapName, "tr_", false) == 0)
    {
        return TRAINING;
    }

    // ROBOT_DESTRUCTION
    if (FindEntityByClassname(-1, "tf_logic_robot_destruction") != -1 ||
        StrContains(mapName, "rd_", false) == 0)
    {
        return ROBOT_DESTRUCTION;
    }

    // PLAYER_DESTRUCTION
    if (FindEntityByClassname(-1, "tf_logic_player_destruction") != -1 ||
        StrContains(mapName, "pd_", false) == 0)
    {
        return PLAYER_DESTRUCTION;
    }

    // SPECIAL_DELIVERY
    {
        int flagCount = 0;
        int ent = -1;
        bool unowned = false;
        while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
        {
            flagCount++;
            int team = GetEntProp(ent, Prop_Send, "m_iTeamNum");
            if (view_as<TFTeam>(team) == TFTeam_Unassigned)
            {
                unowned = true;
            }
        }
        if ((flagCount == 1 && unowned) ||
            StrContains(mapName, "sd_", false) == 0)
        {
            return SPECIAL_DELIVERY;
        }
    }

    // RAID
    if (FindEntityByClassname(-1, "tf_logic_raid") != -1)
    {
        return RAID;
    }

    // BOSS_BATTLE
    if (FindEntityByClassname(-1, "tf_logic_boss_battle") != -1)
    {
        return BOSS_BATTLE;
    }

    // MANNPOWER
    if (FindEntityByClassname(-1, "tf_logic_mannpower") != -1)
    {
        return MANNPOWER;
    }

    // STOP_THAT_TANK
    if (vscript)
    {
        File file = OpenFile("scripts/vscripts/stopthattank/RobotMain.nut", "r", true);
        if (file != null)
        {
            CloseHandle(file);
            return STOP_THAT_TANK;
        }
    }
    else if (StrContains(mapName, "stt_", false) == 0 ||
             StrContains(mapName, "stopthattank_", false) == 0)
    {
        return STOP_THAT_TANK;
    }

    // ZOMBIE_FORTRESS
    if (StrContains(mapName, "zf_", false) == 0)
    {
        return ZOMBIE_FORTRESS;
    }

    // SUPER_ZOMBIE_FORTRESS
    if (StrContains(mapName, "szf_", false) == 0)
    {
        return SUPER_ZOMBIE_FORTRESS;
    }

    // ZOMBIE_ESCAPE
    if (StrContains(mapName, "ze_", false) == 0)
    {
        return ZOMBIE_ESCAPE;
    }

    return view_as<TFGamemode>(-1);
}

stock bool TF2_IsSuddenDeath()
{
    return GameRules_GetProp("m_iRoundState") == 7;
}

stock bool TF2_IsPermaDeathMode()
{
    return  TF2_IsGamemode() == ARENA ||
            TF2_IsSuddenDeath();
}