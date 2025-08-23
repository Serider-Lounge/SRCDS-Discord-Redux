#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>

#define PLUGIN_NAME        "[ANY] Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "1.1.0-alpha"
#define PLUGIN_URL         "https://github.com/Serider-Lounge/SRCDS-Discord-Redux"

public Plugin myinfo = 
{
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESC,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
};

ConVar g_cvBotToken;

ConVar g_cvDiscordChannel;
char g_DiscordChannelId[SNOWFLAKE_SIZE];

ConVar g_cvRelayServerToDiscord;
ConVar g_cvRelayDiscordToServer;

ConVar g_cvWebhookUrl;
char g_WebhookUrl[256];

ConVar g_cvUsernameMode;

ConVar g_cvSteamAPIKey;
char g_SteamAPIKey[64];

ConVar g_cvAllowColorTags;
ConVar g_cvFooterServerIP;
ConVar g_cvFooterIcon;
ConVar g_cvRandomizeNameColors;
ConVar g_cvShowTeamChat;

ConVar g_cvWordBlacklist;
char g_WordBlacklist[1024];
ConVar g_cvHideCommandPrefix;
char g_HideCommandPrefix[256];

ConVar g_cvStaffWebhookUrl;
char g_StaffWebhookUrl[256];

ConVar g_cvDiscordRCONChannel;
char g_DiscordRCONChannelId[SNOWFLAKE_SIZE];

ConVar g_cvEmbedCurrentMapColor;
char g_EmbedCurrentMapColor[8];
ConVar g_cvEmbedPreviousMapColor;
char g_EmbedPreviousMapColor[8];
ConVar g_cvEmbedJoinColor;
char g_EmbedJoinColor[8];
ConVar g_cvEmbedLeaveColor;
char g_EmbedLeaveColor[8];
ConVar g_cvEmbedKickColor;
char g_EmbedKickColor[8];
ConVar g_cvEmbedBanColor;
char g_EmbedBanColor[8];
ConVar g_cvEmbedConsoleColor;
char g_EmbedConsoleColor[8];
ConVar g_cvEmbedScoreboardColor;
char g_EmbedScoreboardColor[8];

Discord g_Discord;
DiscordWebhook g_Webhook;

ArrayList g_PendingMessages[MAXPLAYERS+1];

char g_ClientAvatar[MAXPLAYERS+1][256];

bool g_ClientBanned[MAXPLAYERS+1];

char g_mapName[PLATFORM_MAX_PATH];

public void OnPluginStart()
{
    LoadTranslations("discord_redux.phrases");

    /* ConVars */
    g_cvBotToken = CreateConVar("discord_bot_token", "", "Discord bot token.", FCVAR_PROTECTED);
    g_cvDiscordChannel = CreateConVar("discord_channel_id", "", "Discord channel ID to relay messages.");
    g_cvRelayServerToDiscord = CreateConVar("discord_relay_server_to_discord", "1", "Relay server chat to Discord.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvRelayDiscordToServer = CreateConVar("discord_relay_discord_to_server", "1", "Relay Discord chat to server.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvWebhookUrl = CreateConVar("discord_webhook_url", "", "Discord webhook URL for relaying server chat to Discord.", FCVAR_PROTECTED);
    g_cvStaffWebhookUrl = CreateConVar("discord_staff_webhook_url", "", "Discord webhook URL for staff messages.", FCVAR_NONE);
    g_cvUsernameMode = CreateConVar("discord_username_mode", "1", "Use Discord display name instead of username (0 = username, 1 = display name).", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvSteamAPIKey = CreateConVar("discord_steam_api_key", "", "Steam Web API Key for fetching user avatars.", FCVAR_PROTECTED);
    g_cvAllowColorTags = CreateConVar("discord_allow_color_tags", "0", "Allow {color} tags to be parsed (requires discord_relay_discord_to_server).", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvFooterServerIP = CreateConVar("discord_footer_server_ip", "1", "Show server public IP in embed footer.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvFooterIcon = CreateConVar("discord_footer_icon", "https://raw.githubusercontent.com/Serider-Lounge/SRCDS-Discord-Redux/refs/heads/main/steam.png", "Footer icon URL for Discord embeds.", FCVAR_NONE);
    g_cvRandomizeNameColors = CreateConVar("discord_randomize_name_colors", "0", "Randomize Discord user name colors.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvShowTeamChat = CreateConVar("discord_show_team_chat", "0", "Relay team chat to Discord (requires discord_relay_server_to_discord).", FCVAR_NONE, true, 0.0, true, 1.0);
    
    g_cvWordBlacklist = CreateConVar("discord_word_blacklist", "", "Blacklist words using a regex pattern.", FCVAR_NONE);
    HookConVarChange(g_cvWordBlacklist, OnWordBlacklistChanged);

    g_cvHideCommandPrefix = CreateConVar("discord_hide_command_prefix", "!,/", "Hide specified command prefixes on Discord (separated by commas).", FCVAR_NONE);

    g_cvStaffWebhookUrl = CreateConVar("discord_staff_webhook_url", "", "Discord webhook URL for staff alerts.", FCVAR_NONE);
    g_cvDiscordRCONChannel = CreateConVar("discord_rcon_channel_id", "", "Discord channel ID for RCON messages.", FCVAR_NONE);

    g_cvEmbedCurrentMapColor = CreateConVar("discord_embed_current_map_color", "f4900c", "Embed color for current map embeds.");
    g_cvEmbedPreviousMapColor = CreateConVar("discord_embed_previous_map_color", "31373d", "Embed color for previous map embeds.");
    g_cvEmbedJoinColor = CreateConVar("discord_embed_join_color", "77b255", "Embed color for join embeds.");
    g_cvEmbedLeaveColor = CreateConVar("discord_embed_leave_color", "be1831", "Embed color for leave embeds.");
    g_cvEmbedKickColor = CreateConVar("discord_embed_kick_color", "dd2e44", "Embed color for kick embeds.");
    g_cvEmbedBanColor = CreateConVar("discord_embed_ban_color", "dd2e44", "Embed color for ban embeds.");
    g_cvEmbedConsoleColor = CreateConVar("discord_embed_console_color", "e3e8ec", "Embed color for console messages.");
    g_cvEmbedScoreboardColor = CreateConVar("discord_embed_scoreboard_color", "c1694f", "Embed color for the scoreboard.");

    AutoExecConfig(true, "discord_redux");

    CreateConVar("discord_redux_version", PLUGIN_VERSION, "Discord Redux version.", FCVAR_NOTIFY | FCVAR_SPONLY);

    char token[256];
    g_cvBotToken.GetString(token, sizeof(token));
    if (token[0] == '\0')
    {
        PrintToServer("%T", "Bot Unset", LANG_SERVER);
        return;
    }

    g_Discord = new Discord(token);
    g_Discord.SetReadyCallback(Discord_OnReady);
    g_Discord.SetMessageCallback(Discord_OnMessage);
    g_Discord.Start();

    if (!g_Discord.Start())
        PrintToServer("%T", "Bot Failure", LANG_SERVER);
    else
        PrintToServer("%T", "Bot Success", LANG_SERVER);

    g_cvWebhookUrl.GetString(g_WebhookUrl, sizeof(g_WebhookUrl));
    if (g_WebhookUrl[0] != '\0')
    {
        if (g_Webhook != null)
        {
            delete g_Webhook;
        }
        g_Webhook = new DiscordWebhook(g_Discord, g_WebhookUrl);
    }

    g_cvSteamAPIKey.GetString(g_SteamAPIKey, sizeof(g_SteamAPIKey));

    for (int i = 0; i <= MAXPLAYERS; i++)
        g_PendingMessages[i] = null;

    for (int i = 0; i <= MAXPLAYERS; i++)
    {
        g_ClientAvatar[i][0] = '\0';
        g_ClientBanned[i] = false;
    }

    g_cvWordBlacklist.GetString(g_WordBlacklist, sizeof(g_WordBlacklist));
    WordFilter_Compile();

    g_cvHideCommandPrefix.GetString(g_HideCommandPrefix, sizeof(g_HideCommandPrefix));

    g_cvDiscordRCONChannel.GetString(g_DiscordRCONChannelId, sizeof(g_DiscordRCONChannelId));

    g_cvStaffWebhookUrl.GetString(g_StaffWebhookUrl, sizeof(g_StaffWebhookUrl));
}

public void OnConfigsExecuted()
{
    g_cvDiscordChannel.GetString(g_DiscordChannelId, sizeof(g_DiscordChannelId));
    g_cvWebhookUrl.GetString(g_WebhookUrl, sizeof(g_WebhookUrl));

    char token[256];
    g_cvBotToken.GetString(token, sizeof(token));
    if (token[0] == '\0')
    {
        PrintToServer("%T", "Bot Unset", LANG_SERVER);
        return;
    }

    if (g_Webhook != null)
    {
        delete g_Webhook;
        g_Webhook = null;
    }

    if (g_Discord != null)
    {
        delete g_Discord;
        g_Discord = null;
    }

    g_Discord = new Discord(token);
    g_Discord.SetReadyCallback(Discord_OnReady);
    g_Discord.SetMessageCallback(Discord_OnMessage);

    if (!g_Discord.Start())
    {
        PrintToServer("%T", "Bot Failure", LANG_SERVER);
    }

    if (g_WebhookUrl[0] != '\0' && g_Discord != null)
    {
        g_Webhook = new DiscordWebhook(g_Discord, g_WebhookUrl);
    }
    else
    {
        g_Webhook = null;
    }

    g_cvSteamAPIKey.GetString(g_SteamAPIKey, sizeof(g_SteamAPIKey));
    g_cvWordBlacklist.GetString(g_WordBlacklist, sizeof(g_WordBlacklist));
    WordFilter_Compile();
    g_cvHideCommandPrefix.GetString(g_HideCommandPrefix, sizeof(g_HideCommandPrefix));
    g_cvDiscordRCONChannel.GetString(g_DiscordRCONChannelId, sizeof(g_DiscordRCONChannelId));
    g_cvStaffWebhookUrl.GetString(g_StaffWebhookUrl, sizeof(g_StaffWebhookUrl));
}

public void OnMapEnd()
{
    if (g_Discord == null || !g_cvRelayServerToDiscord.BoolValue)
        return;

    GetCurrentMap(g_mapName, sizeof(g_mapName));

    char mapName[PLATFORM_MAX_PATH];
    if (StrContains(g_mapName, "workshop/") == 0)
    {
        int ugcPos = StrContains(g_mapName, ".ugc");
        int slash = -1;
        int mapLen = strlen(g_mapName);

        for (int i = mapLen - 1; i >= 0; --i)
        {
            if (g_mapName[i] == '/')
            {
                slash = i;
                break;
            }
        }

        if (ugcPos != -1 && slash != -1 && ugcPos > slash)
        {
            int nameLen = ugcPos - (slash + 1);
            char mapDisplay[PLATFORM_MAX_PATH];
            char workshopId[32];

            strcopy(mapDisplay, sizeof(mapDisplay), g_mapName[slash + 1]);
            mapDisplay[nameLen] = '\0';

            strcopy(workshopId, sizeof(workshopId), g_mapName[ugcPos + 4]);
            int idEnd = FindCharInString(workshopId, '/', false);
            if (idEnd != -1)
                workshopId[idEnd] = '\0';

            Format(mapName, sizeof(mapName), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", mapDisplay, workshopId);
        }
        else
        {
            strcopy(mapName, sizeof(mapName), g_mapName);
        }
    }
    else
    {
        strcopy(mapName, sizeof(mapName), g_mapName);
    }

    char servername[256];
    GetConVarString(FindConVar("hostname"), servername, sizeof(servername));

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(servername);
    //embed.SetDescription("");

    char previousMapTitle[64];
    Format(previousMapTitle, sizeof(previousMapTitle), "%T", "Previous Map", LANG_SERVER);
    embed.AddField(previousMapTitle, mapName, true);

    g_cvEmbedPreviousMapColor.GetString(g_EmbedPreviousMapColor, sizeof(g_EmbedPreviousMapColor));
    embed.Color = HexColorStringToInt(g_EmbedPreviousMapColor);

    char footerIcon[256];
    g_cvFooterIcon.GetString(footerIcon, sizeof(footerIcon));
    char ipStr[64];
    char portStr[16];
    int ipaddr[4];
    bool hasPublicIP = SteamWorks_GetPublicIP(ipaddr);
    GetConVarString(FindConVar("hostport"), portStr, sizeof(portStr));
    if (g_cvFooterServerIP.BoolValue && hasPublicIP && portStr[0] != '\0')
    {
        Format(ipStr, sizeof(ipStr), "steam://connect/%d.%d.%d.%d:%s", ipaddr[0], ipaddr[1], ipaddr[2], ipaddr[3], portStr);
        embed.SetFooter(ipStr, footerIcon);
    }
    else
    {
        embed.SetFooter("", footerIcon);
    }

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;
}

public void OnPluginEnd()
{
    g_Discord.Stop();
}

public void Discord_OnReady(Discord discord, any data)
{
    if (g_Discord == null || !g_cvRelayServerToDiscord.BoolValue)
        return;

    /* Games */
    //switch (GetEngineVersion())
    //{
    //    case Engine_TF2:
    //    {
    //        //HookEvent("teamplay_round_start", TF2_OnRoundStart);
    //        HookEvent("teamplay_round_win", TF2_OnRoundEnd);
    //    }
    //}

    GetCurrentMap(g_mapName, sizeof(g_mapName));

    int playerCount = GetClientCount(false);
    int botCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsFakeClient(i))
        {
            botCount++;
            playerCount--;
        }
    }
    int maxPlayers = MaxClients;

    char mapName[PLATFORM_MAX_PATH];
    if (StrContains(g_mapName, "workshop/") == 0)
    {
        int ugcPos = StrContains(g_mapName, ".ugc");
        int slash = -1;
        int mapLen = strlen(g_mapName);

        for (int i = mapLen - 1; i >= 0; --i)
        {
            if (g_mapName[i] == '/')
            {
                slash = i;
                break;
            }
        }

        if (ugcPos != -1 && slash != -1 && ugcPos > slash)
        {
            int nameLen = ugcPos - (slash + 1);
            char mapDisplay[PLATFORM_MAX_PATH];
            char workshopId[32];

            strcopy(mapDisplay, sizeof(mapDisplay), g_mapName[slash + 1]);
            mapDisplay[nameLen] = '\0';

            strcopy(workshopId, sizeof(workshopId), g_mapName[ugcPos + 4]);
            int idEnd = FindCharInString(workshopId, '/', false);
            if (idEnd != -1)
                workshopId[idEnd] = '\0';

            Format(mapName, sizeof(mapName), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", mapDisplay, workshopId);
        }
        else
        {
            strcopy(mapName, sizeof(mapName), g_mapName);
        }
    }
    else
    {
        strcopy(mapName, sizeof(mapName), g_mapName);
    }

    char servername[256];
    GetConVarString(FindConVar("hostname"), servername, sizeof(servername));

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(servername);
    //embed.SetDescription("");

    char currentMapTitle[64];
    Format(currentMapTitle, sizeof(currentMapTitle), "%T", "Current Map", LANG_SERVER);
    embed.AddField(currentMapTitle, mapName, true);

    g_cvEmbedCurrentMapColor.GetString(g_EmbedCurrentMapColor, sizeof(g_EmbedCurrentMapColor));
    embed.Color = HexColorStringToInt(g_EmbedCurrentMapColor);

    char playerCountBuffer[64];
    if (botCount > 0)
        Format(playerCountBuffer, sizeof(playerCountBuffer), "%d/%d (+ %d)", playerCount, maxPlayers, botCount);
    else
        Format(playerCountBuffer, sizeof(playerCountBuffer), "%d/%d", playerCount, maxPlayers);

    char playerCountTitle[32];
    Format(playerCountTitle, sizeof(playerCountTitle), "%T", "Player Count", LANG_SERVER);
    embed.AddField(playerCountTitle, playerCountBuffer, true);

    char footerIcon[256];
    g_cvFooterIcon.GetString(footerIcon, sizeof(footerIcon));
    char ipStr[64];
    char portStr[16];
    int ipaddr[4];
    bool hasPublicIP = SteamWorks_GetPublicIP(ipaddr);
    GetConVarString(FindConVar("hostport"), portStr, sizeof(portStr));
    if (g_cvFooterServerIP.BoolValue && hasPublicIP && portStr[0] != '\0')
    {
        Format(ipStr, sizeof(ipStr), "steam://connect/%d.%d.%d.%d:%s", ipaddr[0], ipaddr[1], ipaddr[2], ipaddr[3], portStr);
        embed.SetFooter(ipStr, footerIcon);
    }
    else
    {
        embed.SetFooter("", footerIcon);
    }

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;

    /* Games */
    /*switch (GetEngineVersion())
    {
        case Engine_TF2:
        {
            HookEvent("teamplay_round_start", TF2_OnRoundStart, EventHookMode_PostNoCopy);
        }
    }*/
}

public void Discord_OnMessage(Discord discord, DiscordMessage message, any data)
{
    if (!g_cvRelayDiscordToServer.BoolValue)
        return;

    char channelId[SNOWFLAKE_SIZE];
    message.GetChannelId(channelId, sizeof(channelId));

    DiscordUser user = message.Author;
    char content[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
    message.GetContent(content, sizeof(content));

    if (StrEqual(channelId, g_DiscordChannelId))
    {
        if (user.IsBot)
            return;

        // Commands
        if (content[0] == '!')
        {
            if (StrContains(content, "scoreboard", false) != -1)
            {
                g_cvEmbedScoreboardColor.GetString(g_EmbedScoreboardColor, sizeof(g_EmbedScoreboardColor));

                switch (GetEngineVersion())
                {
                    case Engine_TF2:
                    {
                        TF2_SendScoreboardEmbed();
                    }
                }
            }
            else if (StrContains(content, "status", false) != -1 ||
                     StrContains(content, "map", false) != -1)
            {
                Discord_OnReady(g_Discord, 0);
            }
        }

        if (ShouldHideCommandPrefix(content))
            return;

        char author[MAX_DISCORD_NAME_LENGTH];
        if (g_cvUsernameMode.BoolValue)
            user.GetNickName(author, sizeof(author));
        else
            user.GetUserName(author, sizeof(author));

        static char colorHex[7];
        GenerateColorHexFromName(author, colorHex, sizeof(colorHex));

        static char coloredAuthor[MAX_DISCORD_NAME_LENGTH + 16];
        if (g_cvRandomizeNameColors.BoolValue)
            Format(coloredAuthor, sizeof(coloredAuthor), "{#%s}%s{default}", colorHex, author);
        else
            strcopy(coloredAuthor, sizeof(coloredAuthor), author);

        char line[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
        int start = 0;
        int len = strlen(content);
        while (start < len)
        {
            int end = start;
            while (end < len && content[end] != '\n' && content[end] != '\r')
                end++;

            int lineLen = end - start;
            if (lineLen > sizeof(line) - 1)
                lineLen = sizeof(line) - 1;

            if (lineLen > 0)
                strcopy(line, sizeof(line), content[start]);
            line[lineLen] = '\0';

            // Strip {color} tags from the message before printing
            char cleanContent[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
            int j = 0;
            for (int i = 0; line[i] != '\0' && j < sizeof(cleanContent) - 1; i++)
            {
                if (line[i] == '{')
                {
                    while (line[i] != '\0' && line[i] != '}')
                        i++;
                    if (line[i] == '}')
                        continue;
                }
                cleanContent[j++] = line[i];
            }
            cleanContent[j] = '\0';

            switch (message.Type)
            {
                case MessageType_Reply:
                {
                    CPrintToChatAll("%t", "Chat Format (Reply)", coloredAuthor, g_cvAllowColorTags.BoolValue ? line : cleanContent);
                }
                default:
                {
                    CPrintToChatAll("%t", "Chat Format", coloredAuthor, g_cvAllowColorTags.BoolValue ? line : cleanContent);
                }
            }
            PrintToServer("*DISCORD* %s: %s", author, g_cvAllowColorTags.BoolValue ? line : cleanContent);

            while (end < len && (content[end] == '\n' || content[end] == '\r'))
                end++;
            start = end;
        }
    }

    // RCON channel command execution
    char rconChannelId[SNOWFLAKE_SIZE];
    g_cvDiscordRCONChannel.GetString(rconChannelId, sizeof(rconChannelId));
    char msgChannelId[SNOWFLAKE_SIZE];
    message.GetChannelId(msgChannelId, sizeof(msgChannelId));
    if (StrEqual(msgChannelId, rconChannelId))
    {
        if (user.IsBot)
            return;

        if (content[0] == '\0')
            return;

        char response[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
        ServerCommandEx(response, sizeof(response), "%s", content);

        if (g_DiscordRCONChannelId[0] != '\0')
        {
            if (StrContains(response, "Unknown Command", false) != -1)
                return;

            char username[MAX_DISCORD_NAME_LENGTH];
            user.GetUserName(username, sizeof(username));
            char avatar[256];
            user.GetAvatarUrl(false, avatar, sizeof(avatar));

            char inputMsg[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
            char outputMsg[MAX_DISCORD_NITRO_MESSAGE_LENGTH];

            if (response[0] == '\0')
                Format(outputMsg, sizeof(outputMsg), "%T", "RCON Print Error", LANG_SERVER);
            else
                Format(outputMsg, sizeof(outputMsg), "%T", "RCON Output", LANG_SERVER, response);

            Format(inputMsg, sizeof(inputMsg), "%T", "RCON Input", LANG_SERVER, content);

            DiscordEmbed embed = new DiscordEmbed();
            char embedMsg[MAX_DISCORD_NITRO_MESSAGE_LENGTH * 2];
            Format(embedMsg, sizeof(embedMsg), "%s\n%s", outputMsg, inputMsg);
            embed.SetDescription(embedMsg);

            g_Discord.SendMessageEmbed(g_DiscordRCONChannelId, "", embed);
            delete embed;
        }
    }
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    char detectedWord[MAX_MESSAGE_LENGTH];
    if (WordFilter_IsBlocked(sArgs, detectedWord))
    {
        char playerName[MAX_NAME_LENGTH];
        GetClientName(client, playerName, sizeof(playerName));
        PrintToServer("%t", "Blocked Word", LANG_SERVER, playerName, detectedWord);

        // Report it to staff channel
        if (g_StaffWebhookUrl[0] != '\0' && g_Discord != null)
        {
            char playerNameWebhook[MAX_NAME_LENGTH];
            GetClientName(client, playerNameWebhook, sizeof(playerNameWebhook));

            DiscordWebhook webhook = new DiscordWebhook(g_Discord, g_StaffWebhookUrl);
            webhook.SetName(playerNameWebhook);

            if (g_ClientAvatar[client][0] != '\0')
                webhook.SetAvatarUrl(g_ClientAvatar[client]);

            webhook.Execute(sArgs);
            delete webhook;
        }

        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
    if (!g_cvRelayServerToDiscord.BoolValue ||
        ShouldHideCommandPrefix(sArgs) ||
        WordFilter_IsBlocked(sArgs) ||
        (StrEqual(command, "say_team", false) && !g_cvShowTeamChat.BoolValue)) return;

    if (IsConsole(client))
    {
        DiscordEmbed embed = new DiscordEmbed();
        embed.SetDescription(sArgs);

        g_cvEmbedConsoleColor.GetString(g_EmbedConsoleColor, sizeof(g_EmbedConsoleColor));
        embed.Color = HexColorStringToInt(g_EmbedConsoleColor);

        g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
        delete embed;
        return;
    }

    char playerName[MAX_NAME_LENGTH];
    char steamId64[32];
    char steamId2[32];
    char hostname[256];

    GetClientName(client, playerName, sizeof(playerName));
    GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
    GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2), true);
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));

    char formatted[MAX_DISCORD_NITRO_MESSAGE_LENGTH + 256];
    Format(formatted, sizeof(formatted), "%T", "Discord Message", LANG_SERVER, sArgs, playerName, steamId64, steamId2, hostname);

    SendDiscordMessageWithAvatar(client, formatted);
}

public void OnClientPutInServer(int client)
{
    if (IsFakeClient(client) ||
        g_Discord == null ||
        !g_cvRelayServerToDiscord.BoolValue) return;

    RefreshClientSteamAvatar(client, g_SteamAPIKey);

    if (g_PendingMessages[client] == null)
        g_PendingMessages[client] = new ArrayList(256);

    g_PendingMessages[client].PushString("[JOIN]");
}

public void OnClientDisconnect(int client)
{
    if (IsFakeClient(client) ||
        g_Discord == null ||
        !g_cvRelayServerToDiscord.BoolValue) return;

    char playerName[MAX_NAME_LENGTH];
    char steamId64[32];
    char steamId2[32];

    GetClientName(client, playerName, sizeof(playerName));
    bool hasSteam64 = GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
    bool hasSteam2 = GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2), true);

    char description[256];
    bool banned = g_ClientBanned[client];
    bool kicked = IsClientInKickQueue(client);

    if (hasSteam64 && steamId64[0] != '\0')
    {
        if (banned)
        {
            g_cvEmbedBanColor.GetString(g_EmbedBanColor, sizeof(g_EmbedBanColor));
            Format(description, sizeof(description), "%T", "Player Banned", LANG_SERVER, playerName, steamId64);
        }
        else if (kicked)
        {
            g_cvEmbedKickColor.GetString(g_EmbedKickColor, sizeof(g_EmbedKickColor));
            Format(description, sizeof(description), "%T", "Player Kicked", LANG_SERVER, playerName, steamId64);
        }
        else
        {
            g_cvEmbedLeaveColor.GetString(g_EmbedLeaveColor, sizeof(g_EmbedLeaveColor));
            Format(description, sizeof(description), "%T", "Player Leave", LANG_SERVER, playerName, steamId64);
        }
    }

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetDescription(description);

    if (banned)
        embed.Color = HexColorStringToInt(g_EmbedBanColor);
    else if (kicked)
        embed.Color = HexColorStringToInt(g_EmbedKickColor);
    else
        embed.Color = HexColorStringToInt(g_EmbedLeaveColor);

    if (g_ClientAvatar[client][0] != '\0')
    {
        if (hasSteam2 && steamId2[0] != '\0')
            embed.SetFooter(steamId2, g_ClientAvatar[client]);
        else
            embed.SetFooter("", g_ClientAvatar[client]);
    }
    else if (hasSteam2 && steamId2[0] != '\0')
    {
        embed.SetFooter(steamId2, "");
    }

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;

    g_ClientBanned[client] = false;
    g_ClientAvatar[client][0] = '\0';
}

public Action OnBanClient(int client, int time, int flags, const char[] reason, const char[] kick_message, const char[] command, any source)
{
    if (client > 0 && client <= MaxClients)
    {
        g_ClientBanned[client] = true;
    }
    return Plugin_Continue;
}

public void OnWordBlacklistChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_cvWordBlacklist.GetString(g_WordBlacklist, sizeof(g_WordBlacklist));
    WordFilter_Compile();
}

#include "discord_redux/stocks.sp"
#include "discord_redux/steam.sp"
#include "discord_redux/wordfilter.sp"

#include "discord_redux/game.sp"