#include <serider/core>

#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>

#define PLUGIN_NAME        "[ANY] Discord Redux | x64 Support"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "1.0.0-alpha"
#define PLUGIN_URL         "https://github.com/Serider-Lounge/SRCDS-Discord-Redux"

public Plugin myinfo = 
{
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESC,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
};

ConVar g_cvarBotToken;
ConVar g_cvarDiscordChannel;
char g_DiscordChannelId[SNOWFLAKE_SIZE];
ConVar g_cvarRelayServerToDiscord;
ConVar g_cvarRelayDiscordToServer;
ConVar g_cvarWebhookUrl;
char g_WebhookUrl[256];
ConVar g_cvarUsernameMode;
ConVar g_cvarSteamAPIKey;
char g_SteamAPIKey[64];
ConVar g_cvarAllowColorTags;
ConVar g_cvarFooterServerIP;
ConVar g_cvarFooterIcon;
ConVar g_cvarRandomizeNameColors;

Discord g_Discord = null;
DiscordWebhook g_Webhook = null;

ArrayList g_PendingMessages[MAXPLAYERS+1];

char g_sClientAvatar[MAXPLAYERS+1][256];

bool g_bClientBanned[MAXPLAYERS+1];

char g_mapName[PLATFORM_MAX_PATH];

public void OnPluginStart()
{
    LoadTranslations("discord_redux.phrases");

    g_cvarBotToken = CreateConVar("discord_bot_token", "", "Discord bot token.", FCVAR_PROTECTED);
    g_cvarDiscordChannel = CreateConVar("discord_channel_id", "", "Discord channel ID to relay messages.");
    g_cvarRelayServerToDiscord = CreateConVar("discord_relay_server_to_discord", "1", "Relay server chat to Discord.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarRelayDiscordToServer = CreateConVar("discord_relay_discord_to_server", "1", "Relay Discord chat to server.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarWebhookUrl = CreateConVar("discord_webhook_url", "", "Discord webhook URL for relaying server chat to Discord.", FCVAR_PROTECTED);
    g_cvarUsernameMode = CreateConVar("discord_username_mode", "1", "Use Discord display name instead of username (0 = username, 1 = display name).", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarSteamAPIKey = CreateConVar("discord_steam_api_key", "", "Steam Web API Key for fetching user avatars.", FCVAR_PROTECTED);
    g_cvarAllowColorTags = CreateConVar("discord_allow_color_tags", "0", "Allow {color} tags to be parsed (requires discord_relay_discord_to_server).", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarFooterServerIP = CreateConVar("discord_footer_server_ip", "1", "Show server public IP in embed footer.", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarFooterIcon = CreateConVar("discord_footer_icon", "https://raw.githubusercontent.com/Serider-Lounge/SRCDS-Discord-Redux/refs/heads/main/steam.png", "Footer icon URL for Discord embeds.", FCVAR_NONE);
    g_cvarRandomizeNameColors = CreateConVar("discord_randomize_name_colors", "0", "Randomize Discord user name colors.", FCVAR_NONE, true, 0.0, true, 1.0);

    AutoExecConfig(true, "discord_redux");

    CreateConVar("discord_redux_version", PLUGIN_VERSION, "Discord Redux version.", FCVAR_NOTIFY | FCVAR_SPONLY);

    g_cvarDiscordChannel.GetString(g_DiscordChannelId, sizeof(g_DiscordChannelId));
    g_cvarWebhookUrl.GetString(g_WebhookUrl, sizeof(g_WebhookUrl));
    if (g_WebhookUrl[0] != '\0')
    {
        if (g_Webhook != null)
        {
            delete g_Webhook;
        }
        g_Webhook = new DiscordWebhook(g_WebhookUrl);
    }

    char token[256];
    g_cvarBotToken.GetString(token, sizeof(token));
    if (token[0] == '\0')
    {
        PrintToServer("%T", "Bot Unset", LANG_SERVER);
        return;
    }

    g_Discord = new Discord(token);
    if (!g_Discord.Start())
    {
        PrintToServer("%T", "Bot Failure", LANG_SERVER);
    }

    g_cvarSteamAPIKey.GetString(g_SteamAPIKey, sizeof(g_SteamAPIKey));

    for (int i = 0; i <= MAXPLAYERS; i++)
        g_PendingMessages[i] = null;

    for (int i = 0; i <= MAXPLAYERS; i++)
    {
        g_sClientAvatar[i][0] = '\0';
        g_bClientBanned[i] = false;
    }
}

public void OnConfigsExecuted()
{
    g_cvarDiscordChannel.GetString(g_DiscordChannelId, sizeof(g_DiscordChannelId));
    g_cvarWebhookUrl.GetString(g_WebhookUrl, sizeof(g_WebhookUrl));
    if (g_WebhookUrl[0] != '\0')
    {
        if (g_Webhook != null)
        {
            delete g_Webhook;
        }
        g_Webhook = new DiscordWebhook(g_WebhookUrl);
    }
    else
    {
        if (g_Webhook != null)
        {
            delete g_Webhook;
            g_Webhook = null;
        }
    }

    char token[256];
    g_cvarBotToken.GetString(token, sizeof(token));
    if (token[0] == '\0')
    {
        PrintToServer("%T", "Bot Unset", LANG_SERVER);
        return;
    }

    if (g_Discord != null)
    {
        delete g_Discord;
        g_Discord = null;
    }

    g_Discord = new Discord(token);
    if (!g_Discord.Start())
    {
        PrintToServer("%T", "Bot Failure", LANG_SERVER);
    }

    g_cvarSteamAPIKey.GetString(g_SteamAPIKey, sizeof(g_SteamAPIKey));
}

public void OnMapStart()
{
    if (g_Discord == null || !g_cvarRelayServerToDiscord.BoolValue)
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

    char description[DISCORD_DESC_LENGTH];
    char displayName[PLATFORM_MAX_PATH];
    displayName[0] = '\0';

    bool hasDisplay = GetMapDisplayName(g_mapName, displayName, sizeof(displayName));

    if (StrContains(g_mapName, "workshop/") == 0)
    {
        int ugcPos = StrContains(g_mapName, ".ugc");
        if (ugcPos != -1)
        {
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
            char mapDisplay[PLATFORM_MAX_PATH];
            char workshopId[32];
            if (slash != -1 && ugcPos > slash)
            {
                int nameLen = ugcPos - (slash + 1);
                strcopy(mapDisplay, sizeof(mapDisplay), g_mapName[slash + 1]);
                mapDisplay[nameLen] = '\0';
                strcopy(workshopId, sizeof(workshopId), g_mapName[ugcPos + 4]);
                int idEnd = FindCharInString(workshopId, '/', false);
                if (idEnd != -1)
                    workshopId[idEnd] = '\0';
                Format(description, sizeof(description), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", mapDisplay, workshopId);
            }
            else
            {
                char shown[PLATFORM_MAX_PATH];
                if (hasDisplay && displayName[0] != '\0')
                    strcopy(shown, sizeof(shown), displayName);
                else
                    strcopy(shown, sizeof(shown), g_mapName);
                Format(description, sizeof(description), "%s", shown);
            }
        }
        else
        {
            char shown[PLATFORM_MAX_PATH];
            if (hasDisplay && displayName[0] != '\0')
                strcopy(shown, sizeof(shown), displayName);
            else
                strcopy(shown, sizeof(shown), g_mapName);
            Format(description, sizeof(description), "%s", shown);
        }
    }
    else
    {
        char shown[PLATFORM_MAX_PATH];
        if (hasDisplay && displayName[0] != '\0')
            strcopy(shown, sizeof(shown), displayName);
        else
            strcopy(shown, sizeof(shown), g_mapName);
        Format(description, sizeof(description), "%s", shown);
    }

    char title[64];
    Format(title, sizeof(title), "%T", "Current Map", LANG_SERVER);

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(title);
    embed.SetDescription(description);
    embed.SetColor(0x5865F2);

    char playerCountStr[64];
    if (botCount > 0)
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d (+ %d)", playerCount, maxPlayers, botCount);
    else
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d", playerCount, maxPlayers);

    char playerCountLabel[32];
    Format(playerCountLabel, sizeof(playerCountLabel), "%T", "Player Count", LANG_SERVER);
    embed.AddField(playerCountLabel, playerCountStr, true);

    char footerIcon[256];
    g_cvarFooterIcon.GetString(footerIcon, sizeof(footerIcon));
    char ipStr[64];
    char ipStrRaw[32];
    char portStr[16];
    GetConVarString(FindConVar("hostip"), ipStrRaw, sizeof(ipStrRaw));
    GetConVarString(FindConVar("hostport"), portStr, sizeof(portStr));
    if (g_cvarFooterServerIP.BoolValue && ipStrRaw[0] != '\0' && portStr[0] != '\0')
    {
        char ipDotted[32];
        HostIpStringToDotted(ipStrRaw, ipDotted, sizeof(ipDotted));
        Format(ipStr, sizeof(ipStr), "steam://connect/%s:%s", ipDotted, portStr);
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

public void OnMapEnd()
{
    if (g_Discord == null || !g_cvarRelayServerToDiscord.BoolValue)
        return;

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

    char description[DISCORD_DESC_LENGTH];
    char displayName[PLATFORM_MAX_PATH];
    displayName[0] = '\0';

    bool hasDisplay = GetMapDisplayName(g_mapName, displayName, sizeof(displayName));

    if (StrContains(g_mapName, "workshop/") == 0)
    {
        int ugcPos = StrContains(g_mapName, ".ugc");
        if (ugcPos != -1)
        {
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
            char mapDisplay[PLATFORM_MAX_PATH];
            char workshopId[32];
            if (slash != -1 && ugcPos > slash)
            {
                int nameLen = ugcPos - (slash + 1);
                strcopy(mapDisplay, sizeof(mapDisplay), g_mapName[slash + 1]);
                mapDisplay[nameLen] = '\0';
                strcopy(workshopId, sizeof(workshopId), g_mapName[ugcPos + 4]);
                int idEnd = FindCharInString(workshopId, '/', false);
                if (idEnd != -1)
                    workshopId[idEnd] = '\0';
                Format(description, sizeof(description), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", mapDisplay, workshopId);
            }
            else
            {
                char shown[PLATFORM_MAX_PATH];
                if (hasDisplay && displayName[0] != '\0')
                    strcopy(shown, sizeof(shown), displayName);
                else
                    strcopy(shown, sizeof(shown), g_mapName);
                Format(description, sizeof(description), "%s", shown);
            }
        }
        else
        {
            char shown[PLATFORM_MAX_PATH];
            if (hasDisplay && displayName[0] != '\0')
                strcopy(shown, sizeof(shown), displayName);
            else
                strcopy(shown, sizeof(shown), g_mapName);
            Format(description, sizeof(description), "%s", shown);
        }
    }
    else
    {
        char shown[PLATFORM_MAX_PATH];
        if (hasDisplay && displayName[0] != '\0')
            strcopy(shown, sizeof(shown), displayName);
        else
            strcopy(shown, sizeof(shown), g_mapName);
        Format(description, sizeof(description), "%s", shown);
    }

    char title[64];
    Format(title, sizeof(title), "%T", "Previous Map", LANG_SERVER);

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(title);
    embed.SetDescription(description);
    embed.SetColor(0x23272A);

    char playerCountStr[64];
    if (botCount > 0)
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d (+ %d)", playerCount, maxPlayers, botCount);
    else
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d", playerCount, maxPlayers);

    char playerCountLabel[32];
    Format(playerCountLabel, sizeof(playerCountLabel), "%T", "Player Count", LANG_SERVER);
    embed.AddField(playerCountLabel, playerCountStr, true);

    char footerIcon[256];
    g_cvarFooterIcon.GetString(footerIcon, sizeof(footerIcon));
    char ipStr[64];
    char ipStrRaw[32];
    char portStr[16];
    GetConVarString(FindConVar("hostip"), ipStrRaw, sizeof(ipStrRaw));
    GetConVarString(FindConVar("hostport"), portStr, sizeof(portStr));
    if (g_cvarFooterServerIP.BoolValue && ipStrRaw[0] != '\0' && portStr[0] != '\0')
    {
        char ipDotted[32];
        HostIpStringToDotted(ipStrRaw, ipDotted, sizeof(ipDotted));
        Format(ipStr, sizeof(ipStr), "steam://connect/%s:%s", ipDotted, portStr);
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
    if (g_Discord != null)
    {
        delete g_Discord;
        g_Discord = null;
    }
    if (g_Webhook != null)
    {
        delete g_Webhook;
        g_Webhook = null;
    }
}

public void Discord_OnReady(Discord discord)
{
    PrintToServer("%T", "Bot Success", LANG_SERVER);
    OnMapStart();
}

public void Discord_OnMessage(Discord discord, DiscordMessage message)
{
    if (!g_cvarRelayDiscordToServer.BoolValue)
        return;

    char channelId[SNOWFLAKE_SIZE];
    message.GetChannelId(channelId, sizeof(channelId));
    if (!StrEqual(channelId, g_DiscordChannelId))
        return;

    DiscordUser user = message.GetAuthor();

    if (user.IsBot())
        return;

    char content[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
    message.GetContent(content, sizeof(content));

    // Commands
    if (content[0] == '!')
    {
        if (StrContains(content, "scoreboard", false) != -1)
        {
            switch (GetEngineVersion())
            {
                case Engine_TF2:
                {
                    TF2_SendScoreboardEmbed();
                }
            }
        }
        else if (StrContains(content, "status", false) != -1 ||
                 StrContains(content, "g_mapName", false) != -1)
        {
            OnMapStart();
        }
    }

    char author[MAX_DISCORD_NAME_LENGTH];
    if (g_cvarUsernameMode.BoolValue)
        user.GetGlobalName(author, sizeof(author));
    else
        user.GetUsername(author, sizeof(author));

    static char colorHex[7];
    GenerateColorHexFromName(author, colorHex, sizeof(colorHex));

    static char coloredAuthor[MAX_DISCORD_NAME_LENGTH + 16];
    if (g_cvarRandomizeNameColors.BoolValue)
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
                // Skip until closing }
                while (line[i] != '\0' && line[i] != '}')
                    i++;
                if (line[i] == '}')
                    continue;
            }
            cleanContent[j++] = line[i];
        }
        cleanContent[j] = '\0';

        CPrintToChatAll("%t", "Chat Format", coloredAuthor, g_cvarAllowColorTags.BoolValue ? line : cleanContent);
        PrintToServer("%t", "Chat Format", author, cleanContent);

        while (end < len && (content[end] == '\n' || content[end] == '\r'))
            end++;
        start = end;
    }
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
    if (!g_cvarRelayServerToDiscord.BoolValue)
        return;

    if (IsConsole(client))
    {
        DiscordEmbed embed = new DiscordEmbed();
        embed.SetDescription(sArgs);
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
        !g_cvarRelayServerToDiscord.BoolValue) return;

    RefreshClientSteamAvatar(client, g_SteamAPIKey);

    if (g_PendingMessages[client] == null)
        g_PendingMessages[client] = new ArrayList(256);

    g_PendingMessages[client].PushString("[JOIN]");
}

public void OnClientDisconnect(int client)
{
    if (IsFakeClient(client) ||
        g_Discord == null ||
        !g_cvarRelayServerToDiscord.BoolValue) return;

    char playerName[MAX_NAME_LENGTH];
    char steamId64[32];
    char steamId2[32];

    GetClientName(client, playerName, sizeof(playerName));
    bool hasSteam64 = GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
    bool hasSteam2 = GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2), true);

    char description[256];
    bool banned = g_bClientBanned[client];
    bool kicked = IsClientInKickQueue(client);

    if (hasSteam64 && steamId64[0] != '\0')
    {
        if (banned)
        {
            Format(description, sizeof(description), "%T", "Player Banned", LANG_SERVER, playerName, steamId64);
        }
        else if (kicked)
        {
            Format(description, sizeof(description), "%T", "Player Kicked", LANG_SERVER, playerName, steamId64);
        }
        else
        {
            Format(description, sizeof(description), "%T", "Player Leave", LANG_SERVER, playerName, steamId64);
        }
    }

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetDescription(description);
    embed.SetColor(0xED4245);

    if (g_sClientAvatar[client][0] != '\0')
    {
        if (hasSteam2 && steamId2[0] != '\0')
            embed.SetFooter(steamId2, g_sClientAvatar[client]);
        else
            embed.SetFooter("", g_sClientAvatar[client]);
    }
    else if (hasSteam2 && steamId2[0] != '\0')
    {
        embed.SetFooter(steamId2, "");
    }

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;

    g_bClientBanned[client] = false;
    g_sClientAvatar[client][0] = '\0';
}

public Action OnBanClient(int client, int time, int flags, const char[] reason, const char[] kick_message, const char[] command, any source)
{
    if (client > 0 && client <= MaxClients)
    {
        g_bClientBanned[client] = true;
    }
    return Plugin_Continue;
}

void HostIpStringToDotted(const char[] ipStrRaw, char[] buffer, int maxlen)
{
    if (StrContains(ipStrRaw, ".") != -1)
    {
        strcopy(buffer, maxlen, ipStrRaw);
        return;
    }
    strcopy(buffer, maxlen, "unknown");
}

void GenerateColorHexFromName(const char[] name, char[] hex, int hexLen)
{
    int hash = 5381;
    for (int i = 0; name[i] != '\0'; i++)
        hash = ((hash << 5) + hash) + name[i]; // djb2

    int r = ((hash >> 16) & 0x7F) + 64;
    int g = ((hash >> 8) & 0x7F) + 64;
    int b = (hash & 0x7F) + 64;

    Format(hex, hexLen, "%02X%02X%02X", r, g, b);
}

//#include "discord_redux/accelerator.sp"
#include "discord_redux/stocks.sp"
#include "discord_redux/steam.sp"

#include "discord_redux/game.sp"