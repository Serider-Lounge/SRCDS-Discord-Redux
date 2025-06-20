#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>

#define PLUGIN_NAME        "Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "1.0.0"
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

Discord g_Discord = null;
DiscordWebhook g_Webhook = null;

// Avatar cache: stores avatar URLs per client
char g_sClientAvatar[MAXPLAYERS + 1][256];

// Pending message queue for clients waiting on avatar fetch
ArrayList g_PendingMessages[MAXPLAYERS + 1];

bool g_bClientBanned[MAXPLAYERS + 1];

public void OnPluginStart()
{
    LoadTranslations("discord_redux.phrases");

    g_cvarBotToken = CreateConVar("discord_bot_token", "", "Discord bot token", FCVAR_PROTECTED);
    g_cvarDiscordChannel = CreateConVar("discord_channel_id", "", "Discord channel ID to relay messages");
    g_cvarRelayServerToDiscord = CreateConVar("discord_relay_server_to_discord", "1", "Relay server chat to Discord", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarRelayDiscordToServer = CreateConVar("discord_relay_discord_to_server", "1", "Relay Discord chat to server", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarWebhookUrl = CreateConVar("discord_webhook_url", "", "Discord webhook URL for relaying server chat to Discord", FCVAR_PROTECTED);
    g_cvarUsernameMode = CreateConVar("discord_username_mode", "1", "Use Discord display name instead of username (0 = username, 1 = display name)", FCVAR_NONE, true, 0.0, true, 1.0);
    g_cvarSteamAPIKey = CreateConVar("discord_steam_api_key", "", "Steam API key for fetching user avatars", FCVAR_PROTECTED);

    AutoExecConfig(true, "discord_redux");

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
        PrintToServer("%T", "Bot Unset", LANG_SERVER); // Use translation key: Bot Unset
        return;
    }

    g_Discord = new Discord(token);
    if (!g_Discord.Start())
    {
        PrintToServer("%T", "Bot Failure", LANG_SERVER); // Use translation key: Bot Failure
    }

    // Store Steam API key in global buffer for later use
    g_cvarSteamAPIKey.GetString(g_SteamAPIKey, sizeof(g_SteamAPIKey));
}

public void OnMapStart()
{
    if (g_Discord == null || !g_cvarRelayServerToDiscord.BoolValue)
        return;

    char map[PLATFORM_MAX_PATH];
    GetCurrentMap(map, sizeof(map));

    int playerCount = 0;
    int botCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            if (IsFakeClient(i))
                botCount++;
            else
                playerCount++;
        }
    }
    int maxPlayers = MaxClients;

    char description[DISCORD_DESC_LENGTH];
    char displayName[PLATFORM_MAX_PATH];
    displayName[0] = '\0';

    bool hasDisplay = GetMapDisplayName(map, displayName, sizeof(displayName));

    // Check for workshop map by prefix
    if (StrContains(map, "workshop/") == 0)
    {
        // Example: workshop/mapname.ugc123456789
        // Display: mapname, Workshop ID: 123456789
        int ugcPos = StrContains(map, ".ugc");
        if (ugcPos != -1)
        {
            int slash = -1;
            int mapLen = strlen(map);
            for (int i = mapLen - 1; i >= 0; --i)
            {
                if (map[i] == '/')
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
                strcopy(mapDisplay, sizeof(mapDisplay), map[slash + 1]);
                mapDisplay[nameLen] = '\0';
                strcopy(workshopId, sizeof(workshopId), map[ugcPos + 4]);
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
                    strcopy(shown, sizeof(shown), map);
                Format(description, sizeof(description), "%s", shown);
            }
        }
        else
        {
            char shown[PLATFORM_MAX_PATH];
            if (hasDisplay && displayName[0] != '\0')
                strcopy(shown, sizeof(shown), displayName);
            else
                strcopy(shown, sizeof(shown), map);
            Format(description, sizeof(description), "%s", shown);
        }
    }
    else
    {
        char shown[PLATFORM_MAX_PATH];
        if (hasDisplay && displayName[0] != '\0')
            strcopy(shown, sizeof(shown), displayName);
        else
            strcopy(shown, sizeof(shown), map);
        Format(description, sizeof(description), "%s", shown);
    }

    // Use translation for "Current Map"
    char title[64];
    Format(title, sizeof(title), "%T", "Current Map", LANG_SERVER);

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(title);
    embed.SetDescription(description);
    embed.SetColor(0x5865F2);

    // Player count field
    char playerCountStr[64];
    if (botCount > 0)
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d (+%d)", playerCount, maxPlayers, botCount);
    else
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d", playerCount, maxPlayers);

    char playerCountLabel[32];
    Format(playerCountLabel, sizeof(playerCountLabel), "%T", "Player Count", LANG_SERVER);
    embed.AddField(playerCountLabel, playerCountStr, true);

    char hostname[256];
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));
    embed.SetFooter(hostname, "");

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;
}

public void OnMapEnd()
{
    if (g_Discord == null || !g_cvarRelayServerToDiscord.BoolValue)
        return;

    char map[PLATFORM_MAX_PATH];
    GetCurrentMap(map, sizeof(map));

    int playerCount = 0;
    int botCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            if (IsFakeClient(i))
                botCount++;
            else
                playerCount++;
        }
    }
    int maxPlayers = MaxClients;

    char description[DISCORD_DESC_LENGTH];
    char displayName[PLATFORM_MAX_PATH];
    displayName[0] = '\0';

    bool hasDisplay = GetMapDisplayName(map, displayName, sizeof(displayName));

    if (StrContains(map, "workshop/") == 0)
    {
        int ugcPos = StrContains(map, ".ugc");
        if (ugcPos != -1)
        {
            int slash = -1;
            int mapLen = strlen(map);
            for (int i = mapLen - 1; i >= 0; --i)
            {
                if (map[i] == '/')
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
                strcopy(mapDisplay, sizeof(mapDisplay), map[slash + 1]);
                mapDisplay[nameLen] = '\0';
                strcopy(workshopId, sizeof(workshopId), map[ugcPos + 4]);
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
                    strcopy(shown, sizeof(shown), map);
                Format(description, sizeof(description), "%s", shown);
            }
        }
        else
        {
            char shown[PLATFORM_MAX_PATH];
            if (hasDisplay && displayName[0] != '\0')
                strcopy(shown, sizeof(shown), displayName);
            else
                strcopy(shown, sizeof(shown), map);
            Format(description, sizeof(description), "%s", shown);
        }
    }
    else
    {
        char shown[PLATFORM_MAX_PATH];
        if (hasDisplay && displayName[0] != '\0')
            strcopy(shown, sizeof(shown), displayName);
        else
            strcopy(shown, sizeof(shown), map);
        Format(description, sizeof(description), "%s", shown);
    }

    // Use translation for "Previous Map"
    char title[64];
    Format(title, sizeof(title), "%T", "Previous Map", LANG_SERVER);

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(title);
    embed.SetDescription(description);
    embed.SetColor(0x23272A);

    // Player count field
    char playerCountStr[64];
    if (botCount > 0)
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d (+%d)", playerCount, maxPlayers, botCount);
    else
        Format(playerCountStr, sizeof(playerCountStr), "%d/%d", playerCount, maxPlayers);

    char playerCountLabel[32];
    Format(playerCountLabel, sizeof(playerCountLabel), "%T", "Player Count", LANG_SERVER);
    embed.AddField(playerCountLabel, playerCountStr, true);

    char hostname[256];
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));
    embed.SetFooter(hostname, "");

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;
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
}

public void Discord_OnReady(Discord discord)
{
    PrintToServer("%T", "Bot Success", LANG_SERVER); // Use translation key: Bot Success
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

    char content[MAX_DISCORD_MESSAGE_LENGTH];
    message.GetContent(content, sizeof(content));

    char author[64];
    if (g_cvarUsernameMode.BoolValue)
        user.GetGlobalName(author, sizeof(author));
    else
        user.GetUsername(author, sizeof(author));

    CPrintToChatAll("%t", "Chat Format", author, content);
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

    // Use Discord Message phrase for formatting
    char playerName[MAX_NAME_LENGTH];
    char steamId64[32];
    char steamId2[32];
    char hostname[256];

    GetClientName(client, playerName, sizeof(playerName));
    GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
    GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2), true);
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));

    char formatted[MAX_DISCORD_MESSAGE_LENGTH + 256];
    Format(formatted, sizeof(formatted), "%T", "Discord Message", LANG_SERVER, sArgs, playerName, steamId64, steamId2, hostname);

    // Send as player via webhook, not as embed
    SendDiscordMessageWithAvatar(client, formatted);
}

public void OnClientPutInServer(int client)
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
    if (hasSteam64 && steamId64[0] != '\0')
    {
        Format(description, sizeof(description), "%T", "Player Join", LANG_SERVER, playerName, steamId64);
    }

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetDescription(description);
    embed.SetColor(0x57F287);
    if (hasSteam2 && steamId2[0] != '\0')
    {
        embed.SetFooter(steamId2, "");
    }

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;
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

    if (hasSteam2 && steamId2[0] != '\0')
    {
        embed.SetFooter(steamId2, "");
    }

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;

    // Reset ban flag for next connection
    g_bClientBanned[client] = false;

    // Remove avatar from cache
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

#include "discord_redux/stocks.sp"
#include "discord_redux/steam.sp"