#include <discord_redux/steam/clients>

int g_LastStaffMentionTime = 0;

stock void RegCommands()
{
    RegConsoleCmd("sm_discord", Command_Discord, "Show Discord invite.");
    RegConsoleCmd("sm_calladmin", Command_CallAdmin, "Notify admins. Usage: sm_calladmin <message>");
    RegConsoleCmd("sm_bugreport", Command_BugReport, "Report a bug to the admins. Usage: sm_bugreport <message>");
}

public Action Command_Discord(int client, int args)
{
    char url[128];
    g_ConVars[discord_invite].GetString(url, sizeof(url));
    
    if (url[0] == '\0') return Plugin_Handled;

    CReplyToCommand(client, "%s", url);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        CPrintToChat(i, "%s", url);
    }
    return Plugin_Handled;
}

public Action Command_CallAdmin(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: sm_calladmin <message>");
        return Plugin_Handled;
    }

    char message[256];
    GetCmdArgString(message, sizeof(message));
    CReplyToCommand(client, "%s", message);

    if (g_ChatWebhook == null)
    {
        return Plugin_Handled;
    }

    // Player name
    char playerName[MAX_NAME_LENGTH];
    GetClientName(client, playerName, sizeof(playerName));

    // Fetch mention string and cooldown from convars
    char mention[128];
    g_ConVars[staff_mention].GetString(mention, sizeof(mention));
    int cooldown = g_ConVars[staff_mention_cooldown].IntValue;

    int now = GetTime();

    // Set webhook name/avatar
    g_ChatWebhook.SetName(playerName);
    if (client > 0 && client <= MaxClients)
    {
        g_ChatWebhook.SetAvatarUrl(g_ClientAvatar[client]);
    }
    g_ChatWebhook.Modify();

    // Send the message itself
    g_ChatWebhook.Execute(message);

    // Ping admins afterwards
    if (mention[0] != '\0')
    {
        int remaining = cooldown - (now - g_LastStaffMentionTime);
        if (remaining > 0)
        {
            CReplyToCommand(client, "%t", "discord_redux_staff_mention_cooldown", remaining);
            return Plugin_Handled;
        }
        g_ChatWebhook.Execute(mention, PARSE_ROLES | PARSE_USERS | REPLIED_USER);
        g_LastStaffMentionTime = now;
    }
    return Plugin_Handled;
}

public Action Command_BugReport(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: sm_bugreport <message>");
        return Plugin_Handled;
    }

    char message[256];
    GetCmdArgString(message, sizeof(message));

    if (g_ReportWebhook == null)
    {
        return Plugin_Handled;
    }

    // Player name
    char playerName[64];
    GetClientName(client, playerName, sizeof(playerName));

    // Game, Map, Player Count
    char hostname[64]; GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));
    char gameDesc[64]; GetGameDescription(gameDesc, sizeof(gameDesc));
    char mapName[64];  GetCurrentMap(mapName, sizeof(mapName));
    if (strncmp(mapName, "workshop/", 9) == 0)
    {
        strcopy(mapName, sizeof(mapName), mapName[9]);
        int ugcSuffix = FindCharInString(mapName, '.', false);
        if (ugcSuffix != -1 && StrContains(mapName[ugcSuffix], ".ugc", false) != -1)
            mapName[ugcSuffix] = '\0';
    }

    // Player count
    int maxPlayers = GetMaxHumanPlayers();
    int playerCount = GetOnlinePlayers();
    int botCount = GetBotCount();

    char playerCountField[DISCORD_FIELD_LENGTH];
    if (botCount > 0)
        Format(playerCountField, sizeof(playerCountField), "%d/%d (+ %d)", playerCount, maxPlayers, botCount);
    else
        Format(playerCountField, sizeof(playerCountField), "%d/%d", playerCount, maxPlayers);

    // Embed
    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(hostname);
    embed.AddField("Game", gameDesc, true);
    embed.AddField("Map", mapName, true);
    embed.AddField("Player Count", playerCountField, true);

    float pos[3];
    GetClientAbsOrigin(client, pos);
    char playerPos[64];
    Format(playerPos, sizeof(playerPos), "- **X:** `%.2f`\n- **Y:** `%.2f`\n- **Z:** `%.2f`", pos[0], pos[1], pos[2]);
    embed.AddField("World Position", playerPos, true);
    switch (GetEngineVersion())
    {
        case Engine_TF2:
        {
            // Class & Team
            char className[32];
            switch (TF2_GetPlayerClass(client))
            {
                case TFClass_Unknown:          strcopy(className, sizeof(className), "Undefined");
                case TFClass_Scout:            strcopy(className, sizeof(className), "Scout");
                case TFClass_Soldier:          strcopy(className, sizeof(className), "Soldier");
                case TFClass_Pyro:             strcopy(className, sizeof(className), "Pyro");
                case TFClass_DemoMan:          strcopy(className, sizeof(className), "Demoman");
                case TFClass_Heavy:            strcopy(className, sizeof(className), "Heavy Weapons Guy");
                case TFClass_Engineer:         strcopy(className, sizeof(className), "Engineer");
                case TFClass_Medic:            strcopy(className, sizeof(className), "Medic");
                case TFClass_Sniper:           strcopy(className, sizeof(className), "Sniper");
                case TFClass_Spy:              strcopy(className, sizeof(className), "Spy");
                case view_as<TFClassType>(10): strcopy(className, sizeof(className), "Civilian");
                default:                       strcopy(className, sizeof(className), "Unknown");
            }
            char teamName[32];
            switch (TF2_GetClientTeam(client))
            {
                case TFTeam_Red:         strcopy(teamName, sizeof(teamName), "RED");
                case TFTeam_Blue:        strcopy(teamName, sizeof(teamName), "BLU");
                case TFTeam_Spectator:   strcopy(teamName, sizeof(teamName), "Spectator");
                case view_as<TFTeam>(5): strcopy(teamName, sizeof(teamName), "Halloween Boss");
                default:                 strcopy(teamName, sizeof(teamName), "Unassigned");
            }
            char playerInfo[64];
            Format(playerInfo, sizeof(playerInfo), "- **Class**\n  - %s\n- **Team**\n  - %s", className, teamName);
            embed.AddField("Player Info", playerInfo, false);

            // Round State
            char roundState[32];
            TF2_GetRoundState(roundState, sizeof(roundState));
            embed.AddField("Round State", roundState, true);

            // Bot Support
            char botSupport[32]; char navLoaded[sizeof(botSupport)]; // Valve NavMesh
            Format(navLoaded, sizeof(navLoaded), "Available (%d Areas)", NavMesh.GetNavAreaCount());
            Format(botSupport, sizeof(botSupport), "%s", NavMesh.IsLoaded() ? navLoaded : "Unavailable");
            embed.AddField("Bot Support", botSupport);

            // VScripts
            int total = EntityLump.Length();
            for (int i = 0; i < total; i++)
            {
                EntityLumpEntry entry = EntityLump.Get(i);
                char classname[64];
                if (entry.GetNextKey("classname", classname, sizeof(classname)) != -1 && strcmp(classname, "logic_script") == 0)
                {
                    char scriptPath[PLATFORM_MAX_PATH];
                    if (entry.GetNextKey("vscripts", scriptPath, sizeof(scriptPath)) != -1)
                    {
                        Format(scriptPath, sizeof(scriptPath), "- `%s`\n", scriptPath);
                        embed.AddField("VScripts", scriptPath);
                    }
                }
                delete entry;
            }

            // Mann Vs. Machine
            if (GameRules_GetProp("m_bPlayingMannVsMachine") == 1)
            {
                TFResource popfile = TFResource(FindEntityByClassname(-1, "tf_objective_resource"));
                if (popfile.index != -1)
                {
                    char popfileName[128];
                    int len = popfile.GetName(popfileName, sizeof(popfileName));
                    if (len > 0)
                    {
                        Format(popfileName, sizeof(popfileName), "- **Mission**\n  - `%s`", popfileName);
                        embed.AddField("Mann Vs. Machine", popfileName);
                    }
                }
            }

            // Extra Settings
            char extraSettings[DISCORD_FIELD_LENGTH];
            extraSettings[0] = '\0';
            if (GameRules_GetProp("m_bPlayingMedieval") == 1 || FindConVar("tf_medieval").BoolValue)
                StrCat(extraSettings, sizeof(extraSettings), "- Medieval Mode\n");

            if (FindConVar("mp_friendlyfire").BoolValue)
                StrCat(extraSettings, sizeof(extraSettings), "- Friendly-Fire\n");

            if (extraSettings[0] != '\0')
                embed.AddField("Extra Settings", extraSettings, true);
        }
    }

    // Assign embed color per client
    char steamID64[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64));
    embed.Color = StringToInt(steamID64);

    // Webhook
    g_ReportWebhook.SetName(playerName);
    if (client > 0 && client <= MaxClients)
    {
        g_ReportWebhook.SetAvatarUrl(g_ClientAvatar[client]);
    }
    g_ReportWebhook.Modify();

    // Player Embed
    char profileURL[128];
    Format(profileURL, sizeof(profileURL), "http://www.steamcommunity.com/profiles/%s", steamID64);
    embed.SetTitle("Steam Profile");
    embed.SetDescription(message);
    embed.SetUrl(profileURL);

    // Set footer to SteamID2
    char steamID[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
    embed.SetFooter(steamID, "https://raw.githubusercontent.com/Serider-Lounge/SRCDS-Discord-Redux/refs/heads/main/steam.png");

    g_ReportWebhook.ExecuteEmbed("", embed);
    delete embed;

    CReplyToCommand(client, "%s", message);
    return Plugin_Handled;
}