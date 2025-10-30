/* Includes */
#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>
#include <SteamWorks>
#include <regex>

#include <discord_redux/convars>
#include <discord_redux/embeds>
#include <discord_redux/halflife>
#include <discord_redux/steam>

/* Macros */
#define PLUGIN_NAME        "[ANY] Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "25w44b"
#define PLUGIN_URL         "https://github.com/Serider-Lounge/SRCDS-Discord-Redux"

/* Plugin Metadata */
public Plugin myinfo = 
{
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESC,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
};

/* ========[Forwards]======== */
public void OnPluginStart()
{
    // Setup ConVars
    InitConVars();

    // Load Translations
    LoadTranslations("discord_redux.phrases");
    LoadTranslations("discord_redux/maps.phrases");
}

public void OnPluginEnd()
{
    if (g_Discord != null)
        g_Discord = null;

    if (g_ChatWebhook != null)
        g_ChatWebhook = null;
}

public void OnConfigsExecuted()
{
    g_ConVars[version] = CreateConVar("discord_redux_version", PLUGIN_VERSION, "Discord Redux version.", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    
    UpdateConVars();
}

public void OnMapStart()
{
    g_bMapEnded = false;
}

public void OnMapEnd()
{
    g_bMapEnded = true;
    Embed_CurrentMapStatus();
}

/* ========[Discord]======== */
void OnDiscordReady(Discord discord, const char[] session_id, int shard_id, int guild_count, const char[] guild_ids, int guild_id_count, any data)
{
    char botName[64], botID[32];
    discord.GetBotName(botName, sizeof(botName));
    discord.GetBotId(botID, sizeof(botID));
    char botStatus[128];

    FormatEx(botStatus, sizeof(botStatus), "%T", "discord_redux_bot_success", LANG_SERVER, botName, botID);
    PrintToServer("%s", botStatus);

    Embed_CurrentMapStatus();
}

void OnDiscordMessage(Discord discord, DiscordMessage message, any data)
{
    if (g_Discord == null) return;

    char content[MAX_DISCORD_MESSAGE_LENGTH];
    message.GetContent(content, sizeof(content));

    char messageChannelID[SNOWFLAKE_SIZE];
    message.GetChannelId(messageChannelID, sizeof(messageChannelID));

    if (message.IsBot)
        return;

    // Chat
    DiscordUser author = message.Author;
    char username[MAX_DISCORD_NAME_LENGTH];
    
    char chatChannelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(chatChannelID, sizeof(chatChannelID));

    // RCON
    char rconChannelID[SNOWFLAKE_SIZE];
    g_ConVars[rcon_channel_id].GetString(rconChannelID, sizeof(rconChannelID));

    if (StrEqual(messageChannelID, chatChannelID))
    {
        // Commands
        if (StrEqual(content, "!map", false) || StrEqual(content, "!status", false))
        {
            Embed_CurrentMapStatus();
        }

        // Username
        switch (g_ConVars[username_mode].IntValue)
        {
            case USER_NAME:
            {
                author.GetUserName(username, sizeof(username));
            }
            case GLOBAL_NAME:
            {
                author.GetGlobalName(username, sizeof(username));
            }
            case NICKNAME:
            {
                char nickname[64];
                author.GetNickName(nickname, sizeof(nickname));
                if (nickname[0] != '\0')
                    strcopy(username, sizeof(username), nickname);
                else
                    author.GetGlobalName(username, sizeof(username));
            }
            default:
            {
                author.GetUserName(username, sizeof(username));
            }
        }

        // discord_redux_randomize_color_names
        if (g_ConVars[randomize_color_names] != null && g_ConVars[randomize_color_names].BoolValue)
        {
            int hash = 0;
            for (int i = 0; username[i] != '\0'; i++)
            {
                hash = (hash * 31) + username[i];
            }

            int colorInt = hash & 0xFFFFFF;

            char colorCode[7];
            Format(colorCode, sizeof(colorCode), "%06x", colorInt);

            char coloredUsername[MAX_DISCORD_NAME_LENGTH + 10];
            Format(coloredUsername, sizeof(coloredUsername), "{#%s}%s", colorCode, username);
            strcopy(username, sizeof(username), coloredUsername);
        }

        // Relay Message
        char discordMsg[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
        switch (message.Type)
        {
            case MessageType_Reply:
                Format(discordMsg, sizeof(discordMsg), "%t", "discord_redux_chat_format_reply", username, content);
            default:
                Format(discordMsg, sizeof(discordMsg), "%t", "discord_redux_chat_format", username, content);
        }
        CPrintToChatAll("%s", discordMsg);
        PrintToServer("%t", "discord_redux_chat_format_console", username, content);
    }
    else if (StrEqual(messageChannelID, rconChannelID))
    {
        DiscordEmbed embed = new DiscordEmbed();
        char response[MAX_CONSOLE_LENGTH],
             inputMsg[MAX_DISCORD_NITRO_MESSAGE_LENGTH],
             outputMsg[sizeof(response)];
        
        ServerCommandEx(response, sizeof(response), "%s", content);

        if (StrContains(response, "Unknown Command", false) != -1)
            return;
            
        if (response[0] == '\0')
            Format(outputMsg, sizeof(outputMsg), "%T", "discord_redux_rcon_print_error", LANG_SERVER);
        else
            Format(outputMsg, sizeof(outputMsg), "%T", "discord_redux_rcon_output", LANG_SERVER, response);

        Format(inputMsg, sizeof(inputMsg), "%T", "discord_redux_rcon_input", LANG_SERVER, content);

        
        char embedMsg[sizeof(outputMsg) + sizeof(inputMsg)];
        Format(embedMsg, sizeof(embedMsg), "%s\n%s", outputMsg, inputMsg);
        embed.SetDescription(embedMsg);

        g_Discord.SendMessageEmbed(rconChannelID, "", embed);
        delete embed;
    }
}

/* ========[Client]======== */
DiscordEmbed g_PendingJoinEmbed[MAXPLAYERS];
char g_PendingJoinChannel[MAXPLAYERS][SNOWFLAKE_SIZE];

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (g_Discord == null ||
        g_ChatWebhook == null ||
        (client > 0 &&
        (!IsClientInGame(client) || IsFakeClient(client))) ||
        !g_Discord.IsRunning ||
        StrEqual(command, "say_team", false) &&
        !g_ConVars[show_team_chat].BoolValue) return Plugin_Continue;

    // Hide Chat Commands
    char commandPrefixes[64];
    g_ConVars[hide_command_prefix].GetString(commandPrefixes, sizeof(commandPrefixes));

    char prefix[16];
    int start = 0, len = strlen(commandPrefixes);
    for (int i = 0; i <= len; i++)
    {
        if (commandPrefixes[i] == ',' || commandPrefixes[i] == '\0')
        {
            int plen = i - start;
            if (plen > 0 && plen < sizeof(prefix))
            {
                // Copy prefix substring
                for (int j = 0; j < plen; j++)
                    prefix[j] = commandPrefixes[start + j];
                prefix[plen] = '\0';

                if (strncmp(sArgs, prefix, plen, false) == 0)
                {
                    return Plugin_Continue;
                }
            }
            start = i + 1;
        }
    }

    if (client == 0)
    {
        DiscordEmbed embed = new DiscordEmbed();
        embed.SetDescription(sArgs);

        char hexColor[8];
        g_ConVars[embed_console_color].GetString(hexColor, sizeof(hexColor));
        embed.Color = StringToInt(hexColor, 16);

        char channelID[SNOWFLAKE_SIZE];
        g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
        g_Discord.SendMessageEmbed(channelID, "", embed);
        delete embed;
        return Plugin_Continue;
    }

    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char playerName[MAX_DISCORD_NAME_LENGTH];
    GetClientName(client, playerName, sizeof(playerName));

    char content[MAX_DISCORD_MESSAGE_LENGTH];
    Format(content, sizeof(content), "%T", "discord_redux_message_format", client, sArgs, playerName, steamID, "", "");

    if (g_ChatWebhook != null)
    {
        g_ChatWebhook.SetName(playerName);

        char apiKey[128];
        g_ConVars[steam_api_key].GetString(apiKey, sizeof(apiKey));

        if (g_SteamAvatar[client][0] != '\0')
        {
            g_ChatWebhook.SetAvatarUrl(g_SteamAvatar[client]);
            g_ChatWebhook.Execute(content);
        }
        else
        {
            g_PendingWebhooks[client] = g_ChatWebhook;
            strcopy(g_PendingDiscordMessages[client], sizeof(g_PendingDiscordMessages[]), content);

            GetClientAvatar(client, apiKey);
        }
    }

    return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
    if (g_Discord == null || g_ChatWebhook == null)
        return;

    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || !g_Discord.IsRunning)
        return;

    char steamID64[32], steamID2[32], playerName[MAX_NAME_LENGTH];
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64), true);
    GetClientAuthId(client, AuthId_Steam2, steamID2, sizeof(steamID2), true);
    GetClientName(client, playerName, sizeof(playerName));

    // Store embed for later sending
    if (g_PendingJoinEmbed[client] != null) delete g_PendingJoinEmbed[client];    
    g_PendingJoinEmbed[client] = new DiscordEmbed();

    char desc[DISCORD_DESC_LENGTH];
    Format(desc, sizeof(desc), "%T", "discord_redux_player_join", LANG_SERVER, playerName, steamID64);
    g_PendingJoinEmbed[client].SetDescription(desc);

    char hexColor[8];
    g_ConVars[embed_join_color].GetString(hexColor, sizeof(hexColor));
    g_PendingJoinEmbed[client].Color = StringToInt(hexColor, 16);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
    strcopy(g_PendingJoinChannel[client], sizeof(g_PendingJoinChannel[]), channelID);

    char steamAPIKey[128];
    g_ConVars[steam_api_key].GetString(steamAPIKey, sizeof(steamAPIKey));
    GetClientAvatar(client, steamAPIKey);
}

public void OnClientAvatarRetrieved(int client)
{
    if (g_PendingJoinEmbed[client] == null)
        return;

    char steamID2[32];
    GetClientAuthId(client, AuthId_Steam2, steamID2, sizeof(steamID2), true);

        g_PendingJoinEmbed[client].SetFooter(steamID2, g_SteamAvatar[client]);
    
    g_Discord.SendMessageEmbed(g_PendingJoinChannel[client], "", g_PendingJoinEmbed[client]);
    
    delete g_PendingJoinEmbed[client]; g_PendingJoinEmbed[client] = null;
}

public void OnClientDisconnect(int client)
{
    if (g_Discord == null || g_ChatWebhook == null)
        return;

    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || !g_Discord.IsRunning)
        return;

    char steamID64[32], steamID2[32], playerName[MAX_NAME_LENGTH];
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64), true);
    GetClientAuthId(client, AuthId_Steam2, steamID2, sizeof(steamID2), true);
    GetClientName(client, playerName, sizeof(playerName));

    DiscordEmbed embed = new DiscordEmbed();

    char desc[DISCORD_DESC_LENGTH];

    if (g_bIsClientBanned[client])
    {
        Format(desc, sizeof(desc), "%T", "discord_redux_player_banned", LANG_SERVER, playerName, steamID64);
        g_bIsClientBanned[client] = false;
    }
    else if (IsClientInKickQueue(client))
    {
        Format(desc, sizeof(desc), "%T", "discord_redux_player_kicked", LANG_SERVER, playerName, steamID64);
    }
    else
    {
        Format(desc, sizeof(desc), "%T", "discord_redux_player_leave", LANG_SERVER, playerName, steamID64);
    }

    // Always use leave color for kick/ban/leave
    char hexColor[8];
    g_ConVars[embed_leave_color].GetString(hexColor, sizeof(hexColor));
    embed.Color = StringToInt(hexColor, 16);

    embed.SetDescription(desc);

    char steamAPIKey[128];
    g_ConVars[steam_api_key].GetString(steamAPIKey, sizeof(steamAPIKey));
    GetClientAvatar(client, steamAPIKey);

    embed.SetFooter(steamID2, g_SteamAvatar[client]);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
    g_Discord.SendMessageEmbed(channelID, "", embed);
    delete embed;
}

public Action OnBanClient(int client, int time, int flags, const char[] reason, const char[] kick_message, const char[] command, any source)
{
    g_bIsClientBanned[client] = true;
    return Plugin_Continue;
}