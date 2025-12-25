#define MAX_CONSOLE_LENGTH 1024

enum
{
    /* Settings */
    // Chat
    randomize_color_names,
    show_team_chat,
    hide_command_prefix,

    /* Steam */
    steam_api_key,
    anonymous_pfp,
    item_found,

    /* Discord */
    // Relay
    relay_server_to_discord,
    relay_discord_to_server,
    relay_console_messages,

    // Bot
    bot_token,
    chat_channel_id,
    player_status_channel_id,
    map_status_channel_id,
    guild_id,

    // Chat
    chat_webhook_url,
    username_mode,

    // Moderation
    staff_mention,
    staff_mention_cooldown,
    report_webhook_url,

    // RCON
    rcon_channel_id,

    // Embed Colors
    embed_current_map_color,
    embed_previous_map_color,
    embed_join_color,
    embed_leave_color,
    embed_kick_color,
    embed_ban_color,
    embed_console_color,
    embed_scoreboard_color,

    // Footer
    footer_server_ip,
    footer_icon,

    // Map Status
    map_thumbnail_enabled,
    map_thumbnail_url,
    map_thumbnail_format,

    /* Community */
    discord_invite,

    /* Third-Party */
    accelerator_webhook_url,
    maprate_enabled,
    rtd_enabled,

    MAX_CONVARS
}

enum UsernameMode
{
    Mode_UserName = 0,
    Mode_GlobalName,
    Mode_NickName
}

ConVar g_ConVars[MAX_CONVARS];

Discord g_Discord;
DiscordWebhook g_ChatWebhook,
               g_ReportWebhook,
               g_AcceleratorWebhook;

bool g_IsClientBanned[MAXPLAYERS+1],
     g_IsMapRateLoaded,
     g_IsRTDLoaded;

char g_SteamWebAPIKey[64],
     g_GameName[64],
     g_GameIcon[128],
     g_ClientAvatar[MAXPLAYERS][256];

int g_AppID;

public void InitConVars()
{
    /* ConVars */
    switch (GetEngineVersion())
    {
        // Only these games support HEX chat colors as far as I know.
        case Engine_TF2, Engine_CSS, Engine_HL2DM, Engine_DODS:
        {
            g_ConVars[randomize_color_names] = CreateConVar("discord_redux_randomize_color_names", "0", "Randomize Discord user name colors.");
        }
    }
    g_ConVars[show_team_chat] = CreateConVar("discord_redux_show_team_chat", "0", "Relay team chat to Discord (requires relay_server_to_discord).");
    g_ConVars[hide_command_prefix] = CreateConVar("discord_redux_hide_command_prefix", "!,/", "Hide specified command prefixes on Discord (separated by commas).");

    g_ConVars[steam_api_key] = CreateConVar("discord_redux_steam_api_key", "", "Steam Web API Key for fetching user avatars.", FCVAR_PROTECTED);
    GetConVarString(g_ConVars[steam_api_key], g_SteamWebAPIKey, sizeof(g_SteamWebAPIKey));
    g_ConVars[anonymous_pfp] = CreateConVar("discord_redux_anonymous_pfp", "0", "Generate a unique colored square for in-game player avatars.");
    if (GetEngineVersion() == Engine_TF2)
    {
        g_ConVars[item_found] = CreateConVar("discord_redux_item_found", "1", "Relay item found events.");
        g_ConVars[item_found].AddChangeHook(ConVar_ItemFound);
    }
    g_ConVars[relay_server_to_discord] = CreateConVar("discord_redux_relay_server_to_discord", "1", "Relay server chat to Discord.");
    g_ConVars[relay_discord_to_server] = CreateConVar("discord_redux_relay_discord_to_server", "1", "Relay Discord chat to server.");
    g_ConVars[relay_console_messages] = CreateConVar("discord_redux_relay_console_messages", "1", "Relay server console messages to Discord.");

    g_ConVars[bot_token] = CreateConVar("discord_redux_bot_token", "", "Discord bot token.", FCVAR_PROTECTED);
    g_ConVars[chat_channel_id] = CreateConVar("discord_redux_chat_channel_id", "", "Discord channel ID to relay messages.", FCVAR_PROTECTED);
    g_ConVars[player_status_channel_id] = CreateConVar("discord_redux_player_status_channel_id", "", "Discord channel ID for player join/leave messages.", FCVAR_PROTECTED);
    g_ConVars[map_status_channel_id] = CreateConVar("discord_redux_map_status_channel_id", "", "Discord channel ID for map status.", FCVAR_PROTECTED);
    g_ConVars[guild_id] = CreateConVar("discord_redux_guild_id", "", "Discord server ID.");
    g_ConVars[staff_mention] = CreateConVar("discord_redux_staff_mention", "", "Discord role/user mention(s) for sm_calladmin (leave blank to disable). https://help.zapier.com/hc/en-us/articles/8496165585165-Tips-for-formatting-Discord-messages");
    g_ConVars[staff_mention_cooldown] = CreateConVar("discord_redux_staff_mention_cooldown", "15", "Cooldown time in seconds between staff mentions for sm_calladmin.");

    g_ConVars[chat_webhook_url] = CreateConVar("discord_redux_chat_webhook_url", "", "Discord webhook URL for relaying server chat to Discord.", FCVAR_PROTECTED);
    g_ConVars[username_mode] = CreateConVar("discord_redux_username_mode", "1", "Use Discord display name instead of username (0 = username, 1 = global name, 2 = nickname).");
    g_ConVars[rcon_channel_id] = CreateConVar("discord_redux_rcon_channel_id", "", "Discord channel ID for RCON messages.", FCVAR_PROTECTED);

    g_ConVars[report_webhook_url] = CreateConVar("discord_redux_report_webhook_url", "", "Discord webhook URL for bug reports.");

    g_ConVars[embed_current_map_color] = CreateConVar("discord_redux_embed_current_map_color", "f4900c", "Embed color for current map embeds.");
    g_ConVars[embed_previous_map_color] = CreateConVar("discord_redux_embed_previous_map_color", "31373d", "Embed color for previous map embeds.");
    g_ConVars[embed_join_color] = CreateConVar("discord_redux_embed_join_color", "77b255", "Embed color for join embeds.");
    g_ConVars[embed_leave_color] = CreateConVar("discord_redux_embed_leave_color", "be1831", "Embed color for leave embeds.");
    g_ConVars[embed_kick_color] = CreateConVar("discord_redux_embed_kick_color", "dd2e44", "Embed color for kick embeds.");
    g_ConVars[embed_ban_color] = CreateConVar("discord_redux_embed_ban_color", "dd2e44", "Embed color for ban embeds.");
    g_ConVars[embed_console_color] = CreateConVar("discord_redux_embed_console_color", "e3e8ec", "Embed color for console messages.");
    g_ConVars[embed_scoreboard_color] = CreateConVar("discord_redux_embed_scoreboard_color", "c1694f", "Embed color for the scoreboard.");

    g_ConVars[footer_server_ip] = CreateConVar("discord_redux_footer_server_ip", "1", "Show server public IP in embed footer.");
    g_ConVars[footer_icon] = CreateConVar("discord_redux_footer_icon", "https://raw.githubusercontent.com/Serider-Lounge/SRCDS-Discord-Redux/refs/heads/main/steam.png", "Footer icon URL for Discord embeds.");

    g_ConVars[map_thumbnail_enabled] = CreateConVar("discord_redux_map_thumbnail_enabled", "1", "Show map thumbnail in map embeds.");
    g_ConVars[map_thumbnail_url] = CreateConVar("discord_redux_map_thumbnail_url", "https://image.gametracker.com/images/maps/160x120/tf2/", "Discord map thumbnail URL.");
    g_ConVars[map_thumbnail_format] = CreateConVar("discord_redux_map_thumbnail_format", "jpg", "Discord map thumbnail format.");

    g_ConVars[discord_invite] = CreateConVar("discord_redux_invite", "", "Discord invite link.");

    // Third-Party
    g_ConVars[accelerator_webhook_url] = CreateConVar("discord_redux_accelerator_webhook_url", "", "Discord webhook URL for crash reports.", FCVAR_PROTECTED);
    g_ConVars[maprate_enabled] = CreateConVar("discord_redux_maprate_enabled", "1", "Show average map rating in map embeds.");
    g_ConVars[rtd_enabled] = CreateConVar("discord_redux_rtd_enabled", "1", "Relay RTD rolls.");

    AutoExecConfig(true, "discord_redux");

    UpdateConVars();
}

public void ConVar_ItemFound(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (StrEqual(newValue, "1"))
    {
        HookEvent("item_found", Event_ItemFound);
    }
    else
    {
        UnhookEvent("item_found", Event_ItemFound);
    }
}

public void UpdateConVars()
{
    char webhookURL[256], channelID[SNOWFLAKE_SIZE];
    for (int i = 0; i < MAX_CONVARS; i++)
    {
        if (g_ConVars[i] != null)
        {
            switch (i)
            {
                case bot_token:
                {
                    char token[256];
                    g_ConVars[i].GetString(token, sizeof(token));
                    if (token[0] == '\0' || g_Discord) return;
                    g_Discord = new Discord(token);
                    g_Discord.SetReadyCallback(OnDiscordReady);
                    g_Discord.Start();
                }
                case chat_channel_id:
                {
                    g_ConVars[i].GetString(channelID, sizeof(channelID));
                    if (channelID[0] != '\0') g_Discord.SetMessageCallback(OnDiscordMessage);
                }
                case rcon_channel_id:
                {
                    g_ConVars[i].GetString(channelID, sizeof(channelID));
                    if (channelID[0] != '\0') g_Discord.SetMessageCallback(OnDiscordMessage);
                }
                case chat_webhook_url:
                {
                    g_ConVars[i].GetString(webhookURL, sizeof(webhookURL));
                    if (webhookURL[0] != '\0') g_ChatWebhook = new DiscordWebhook(g_Discord, webhookURL);
                }
                case report_webhook_url:
                {
                    g_ConVars[i].GetString(webhookURL, sizeof(webhookURL));
                    if (webhookURL[0] != '\0') g_ReportWebhook = new DiscordWebhook(g_Discord, webhookURL);
                }
                case accelerator_webhook_url:
                {
                    g_ConVars[i].GetString(webhookURL, sizeof(webhookURL));
                    if (webhookURL[0] != '\0') g_AcceleratorWebhook = new DiscordWebhook(g_Discord, webhookURL);
                }
                case player_status_channel_id:
                {
                    g_ConVars[i].GetString(channelID, sizeof(channelID));
                    if (channelID[0] == '\0') g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
                }
                case map_status_channel_id:
                {
                    g_ConVars[i].GetString(channelID, sizeof(channelID));
                    if (channelID[0] == '\0') g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
                }
                case hide_command_prefix:
                {
                    char commandPrefixes[64];
                    g_ConVars[i].GetString(commandPrefixes, sizeof(commandPrefixes));
                }
                case steam_api_key:
                {
                    g_ConVars[i].GetString(g_SteamWebAPIKey, sizeof(g_SteamWebAPIKey));
                }
                case item_found:
                {
                    if (g_ConVars[i].BoolValue)
                        HookEvent("item_found", Event_ItemFound);
                    else
                        UnhookEvent("item_found", Event_ItemFound);
                }
            }
        }
    }
}
