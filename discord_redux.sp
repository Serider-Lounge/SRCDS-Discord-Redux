#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>

#define PLUGIN_NAME        "Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "1.0"
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

    AutoExecConfig(true);

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
        PrintToServer("%T", "Bot Not Set", LANG_SERVER); // Use translation key: Bot Not Set
        return;
    }

    g_Discord = new Discord(token);
    if (!g_Discord.Start())
    {
        PrintToServer("%T", "Bot Failed", LANG_SERVER); // Use translation key: Bot Failed
    }

    // Store Steam API key in global buffer for later use
    g_cvarSteamAPIKey.GetString(g_SteamAPIKey, sizeof(g_SteamAPIKey));

    for (int i = 1; i <= MaxClients; i++)
    {
        g_sClientAvatar[i][0] = '\0';
        if (g_PendingMessages[i] != null)
        {
            delete g_PendingMessages[i];
            g_PendingMessages[i] = null;
        }
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
}

public void Discord_OnReady(Discord discord)
{
    PrintToServer("%T", "Bot Ready", LANG_SERVER); // Use translation key: Bot Ready
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

    SendDiscordMessageWithAvatar(client, sArgs);
}

#include "discord_redux/stocks.sp"
#include "discord_redux/steam.sp"