#define MAX_CONSOLE_LENGTH 1024

enum
{
    /* Settings */
    // Plugin
    plugin_enabled,

    // Chat
    randomize_color_names,
    show_team_chat,
    word_filter_enabled,
    hide_command_prefix,

    /* Steam */
    steam_api_key,
    workshop_path,

    /* Discord */
    // Relay
    relay_server_to_discord,
    relay_discord_to_server,

    // Bot
    bot_token,
    chat_channel_id,
    player_status_channel_id,
    map_status_channel_id,
    guild_id,

    // Chat
    chat_webhook_url,
    username_mode,

    // Staff
    staff_channel_id,
    staff_role_id,

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

    // Thumbnail
    map_thumbnail_enabled,
    map_thumbnail_url,
    map_thumbnail_format,

    /* Community */
    discord_invite,

    /* Advanced */
    version,

/********************************/
    MAX_CONVARS
/********************************/
}

enum UsernameMode
{
    USER_NAME = 0,
    GLOBAL_NAME,
    NICKNAME
}

ConVar g_ConVars[MAX_CONVARS];

Discord g_Discord = null;
DiscordWebhook g_ChatWebhook = null;

bool g_bMapEnded,
     g_bIsClientBanned[MAXPLAYERS+1];

public void InitConVars()
{
    /* ConVars */
    g_ConVars[plugin_enabled] = CreateConVar("discord_redux_enabled", "1", "Toggle Discord Redux altogether.", FCVAR_NOTIFY);

    switch (GetEngineVersion())
    {
        // Only these games support HEX chat colors as far as I know.
        case Engine_TF2, Engine_CSS, Engine_HL2DM, Engine_DODS:
        {
            g_ConVars[randomize_color_names] = CreateConVar("discord_redux_randomize_color_names", "0", "Randomize Discord user name colors.", FCVAR_NOTIFY);
        }
    }
    g_ConVars[show_team_chat] = CreateConVar("discord_redux_show_team_chat", "0", "Relay team chat to Discord (requires relay_server_to_discord).", FCVAR_NOTIFY);
    g_ConVars[hide_command_prefix] = CreateConVar("discord_redux_hide_command_prefix", "!,/", "Hide specified command prefixes on Discord (separated by commas).", FCVAR_NOTIFY);

    g_ConVars[steam_api_key] = CreateConVar("discord_redux_steam_api_key", "", "Steam Web API Key for fetching user avatars.", FCVAR_PROTECTED);
    g_ConVars[workshop_path] = CreateConVar("discord_redux_workshop_path", "../steamapps/workshop/content/", "Path to Steam Workshop add-ons folder, relative to the game directory (use \"..\" to go up a directory).", FCVAR_NOTIFY);

    g_ConVars[relay_server_to_discord] = CreateConVar("discord_redux_relay_server_to_discord", "1", "Relay server chat to Discord.", FCVAR_NOTIFY);
    g_ConVars[relay_discord_to_server] = CreateConVar("discord_redux_relay_discord_to_server", "1", "Relay Discord chat to server.", FCVAR_NOTIFY);

    g_ConVars[bot_token] = CreateConVar("discord_redux_bot_token", "", "Discord bot token.", FCVAR_PROTECTED);
    g_ConVars[chat_channel_id] = CreateConVar("discord_redux_chat_channel_id", "", "Discord channel ID to relay messages.", FCVAR_PROTECTED);
    g_ConVars[staff_channel_id] = CreateConVar("discord_redux_staff_channel_id", "", "Discord channel ID for staff alerts.", FCVAR_PROTECTED);
    g_ConVars[player_status_channel_id] = CreateConVar("discord_redux_player_status_channel_id", "", "Discord channel ID for player join/leave messages.", FCVAR_PROTECTED);
    g_ConVars[map_status_channel_id] = CreateConVar("discord_redux_map_status_channel_id", "", "Discord channel ID for map status.", FCVAR_PROTECTED);
    g_ConVars[guild_id] = CreateConVar("discord_redux_guild_id", "", "Discord server ID.", FCVAR_NOTIFY);

    g_ConVars[chat_webhook_url] = CreateConVar("discord_redux_chat_webhook_url", "", "Discord webhook URL for relaying server chat to Discord.", FCVAR_PROTECTED);
    g_ConVars[username_mode] = CreateConVar("discord_redux_username_mode", "1", "Use Discord display name instead of username (0 = username, 1 = global name, 2 = nickname).", FCVAR_NOTIFY);
    g_ConVars[rcon_channel_id] = CreateConVar("discord_redux_rcon_channel_id", "", "Discord channel ID for RCON messages.", FCVAR_PROTECTED);

    g_ConVars[embed_current_map_color] = CreateConVar("discord_redux_embed_current_map_color", "f4900c", "Embed color for current map embeds.", FCVAR_NOTIFY);
    g_ConVars[embed_previous_map_color] = CreateConVar("discord_redux_embed_previous_map_color", "31373d", "Embed color for previous map embeds.", FCVAR_NOTIFY);
    g_ConVars[embed_join_color] = CreateConVar("discord_redux_embed_join_color", "77b255", "Embed color for join embeds.", FCVAR_NOTIFY);
    g_ConVars[embed_leave_color] = CreateConVar("discord_redux_embed_leave_color", "be1831", "Embed color for leave embeds.", FCVAR_NOTIFY);
    g_ConVars[embed_kick_color] = CreateConVar("discord_redux_embed_kick_color", "dd2e44", "Embed color for kick embeds.", FCVAR_NOTIFY);
    g_ConVars[embed_ban_color] = CreateConVar("discord_redux_embed_ban_color", "dd2e44", "Embed color for ban embeds.", FCVAR_NOTIFY);
    g_ConVars[embed_console_color] = CreateConVar("discord_redux_embed_console_color", "e3e8ec", "Embed color for console messages.", FCVAR_NOTIFY);
    g_ConVars[embed_scoreboard_color] = CreateConVar("discord_redux_embed_scoreboard_color", "c1694f", "Embed color for the scoreboard.", FCVAR_NOTIFY);

    g_ConVars[footer_server_ip] = CreateConVar("discord_redux_footer_server_ip", "1", "Show server public IP in embed footer.", FCVAR_NOTIFY);
    g_ConVars[footer_icon] = CreateConVar("discord_redux_footer_icon", "https://raw.githubusercontent.com/Serider-Lounge/SRCDS-Discord-Redux/refs/heads/main/steam.png", "Footer icon URL for Discord embeds.", FCVAR_NOTIFY);

    g_ConVars[map_thumbnail_enabled] = CreateConVar("discord_redux_map_thumbnail_enabled", "1", "Show map thumbnail in map embeds.", FCVAR_NOTIFY);
    g_ConVars[map_thumbnail_url] = CreateConVar("discord_redux_map_thumbnail_url", "https://image.gametracker.com/images/maps/160x120/tf2/", "Discord map thumbnail URL.", FCVAR_NOTIFY);
    g_ConVars[map_thumbnail_format] = CreateConVar("discord_redux_map_thumbnail_format", "jpg", "Discord map thumbnail format.", FCVAR_NOTIFY);

    g_ConVars[discord_invite] = CreateConVar("discord_redux_invite", "", "Discord invite link.", FCVAR_NOTIFY);

    AutoExecConfig(true, "discord_redux");

    /* Commands */
    //RegAdminCmd("sm_discord_bot", Command_DiscordBot, ADMFLAG_GENERIC);

    RegConsoleCmd("sm_discord", Command_Discord, "Discord Redux: Show plugin info and commands.", FCVAR_NONE);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    char name[64];
    convar.GetName(name, sizeof(name));

    ShowActivity(0, "[Discord Redux] Changed '%s' from '%s' to '%s'", name, oldValue, newValue);

    UpdateConVars();
}

public void UpdateConVars()
{
    for (int i = 0; i < MAX_CONVARS; i++)
    {
        if (g_ConVars[i] != null)
        {
            switch (i)
            {
                case bot_token:
                {
                    if (g_Discord != null) return;

                    char botToken[256];
                    g_ConVars[bot_token].GetString(botToken, sizeof(botToken));

                    g_Discord = new Discord(botToken);
                    g_Discord.SetReadyCallback(OnDiscordReady);

                    if (!g_Discord.IsRunning)
                        g_Discord.Start();
                }
                case chat_channel_id:
                {
                    char chatChannelID[SNOWFLAKE_SIZE];
                    g_ConVars[chat_channel_id].GetString(chatChannelID, sizeof(chatChannelID));

                    if (chatChannelID[0] != '\0')
                        g_Discord.SetMessageCallback(OnDiscordMessage);
                }
                case chat_webhook_url:
                {
                    char webhookURL[256];
                    g_ConVars[chat_webhook_url].GetString(webhookURL, sizeof(webhookURL));
                    
                    if (webhookURL[0] != '\0')
                        g_ChatWebhook = new DiscordWebhook(g_Discord, webhookURL);
                }
                case staff_channel_id:
                {
                    char staffChannelID[SNOWFLAKE_SIZE];
                    g_ConVars[staff_channel_id].GetString(staffChannelID, sizeof(staffChannelID));
                }
                case player_status_channel_id:
                {
                    char playerStatusChannelID[SNOWFLAKE_SIZE];
                    g_ConVars[player_status_channel_id].GetString(playerStatusChannelID, sizeof(playerStatusChannelID));
                    if (playerStatusChannelID[0] == '\0')
                        g_ConVars[chat_channel_id].GetString(playerStatusChannelID, sizeof(playerStatusChannelID));
                }
                case map_status_channel_id:
                {
                    char mapStatusChannelID[SNOWFLAKE_SIZE];
                    g_ConVars[map_status_channel_id].GetString(mapStatusChannelID, sizeof(mapStatusChannelID));
                    if (mapStatusChannelID[0] == '\0')
                        g_ConVars[chat_channel_id].GetString(mapStatusChannelID, sizeof(mapStatusChannelID));
                }
            }
		}
	}
}

public Action Command_Discord(int client, int args)
{
    char discordInvite[128];
    g_ConVars[discord_invite].GetString(discordInvite, sizeof(discordInvite));
    
    if (discordInvite[0] != '\0')
        CReplyToCommand(client, "%s", discordInvite);
    
    return Plugin_Handled;
}

public Action Command_DiscordBot(int client, int args)
{
    PrintToChat(client, "g_Discord = %s", g_Discord != null ? "non-null" : "null");
    return Plugin_Handled;
}