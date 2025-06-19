#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>

#include "discord_redux/stocks.sp"

#define PLUGIN_NAME        "Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "1.0"
#define PLUGIN_URL         "https://github.com/Heapons/Discord-Redux"

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

    // Re-fetch Steam Avatars for all connected clients using the stock
    RefreshAllClientSteamAvatars(g_SteamAPIKey);
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

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (!g_cvarRelayServerToDiscord.BoolValue)
        return Plugin_Continue;

    if (IsConsole(client))
    {
        // Send as Discord bot user, as embed, message as-is (no code block)
        DiscordEmbed embed = new DiscordEmbed();
        embed.SetDescription(sArgs);
        g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
        delete embed;
        return Plugin_Continue;
    }

    if (g_Webhook == null)
        return Plugin_Continue;

    char name[64];
    // Select name type based on cvar
    switch (g_cvarUsernameMode.IntValue)
    {
        case 0: GetClientName(client, name, sizeof(name)); // Username (default)
        case 1: GetClientName(client, name, sizeof(name)); // No global name for players, fallback to name
        case 2: GetClientName(client, name, sizeof(name)); // No nickname API, fallback to name
        default: GetClientName(client, name, sizeof(name));
    }

    // Set webhook name to sender's name before sending message
    g_Webhook.SetName(name);

    // Fetch Steam avatar and set as webhook avatar
    char steamId[32];
    GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId));

    HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/");
    req.AppendQueryParam("key", g_SteamAPIKey);
    req.AppendQueryParam("steamids", steamId);
    req.AppendQueryParam("format", "json"); // Explicitly request JSON format

    // Set webhook avatar to the last known avatar for this client, if available
    static char g_sClientAvatar[MAXPLAYERS + 1][256];
    int userid = GetClientUserId(client);
    if (g_sClientAvatar[client][0] != '\0')
    {
        g_Webhook.SetAvatarUrl(g_sClientAvatar[client]);
    }

    req.Get(OnSteamAvatarResponse, userid);

    // Send only the message itself, no prefix
    g_Discord.ExecuteWebhook(g_Webhook, sArgs);

    return Plugin_Continue;
}

public void OnSteamAvatarResponse(HTTPResponse response, any userid)
{
    if (response.Status != HTTPStatus_OK)
        return;

    JSON data = response.Data;
    if (data == null)
        return;

    JSONObject root = view_as<JSONObject>(data);
    JSONObject responseObj = view_as<JSONObject>(root.Get("response"));
    JSONArray players = view_as<JSONArray>(responseObj.Get("players"));
    if (players.Length == 0)
        return;

    JSONObject player = view_as<JSONObject>(players.Get(0));
    char avatarUrl[256];
    if (!player.GetString("avatarfull", avatarUrl, sizeof(avatarUrl)))
        return;

    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client))
        return;

    static char g_sClientAvatar[MAXPLAYERS + 1][256];
    strcopy(g_sClientAvatar[client], sizeof(g_sClientAvatar[]), avatarUrl);

    if (g_Webhook != null)
    {
        g_Webhook.SetAvatarUrl(avatarUrl);
    }
}