/* Includes */
#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>
#include <SteamWorks>
#include <regex>
#include <tf2_stocks>

// Misc.
#include "discord_redux/stocks.sp"
#include "discord_redux/convars.sp"
#include "discord_redux/embeds.sp"
#include "discord_redux/halflife.sp"
#include "discord_redux/steam.sp"
#include "discord_redux/commands.sp"
#include "discord_redux/navmesh.sp"

// Games
#include "discord_redux/game/tf2.sp"

// Third-Party
#include "discord_redux/thirdparty/accelerator.sp"

/* Macros */
#define PLUGIN_NAME        "[ANY] Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "25w48h"
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
    // Setup ConVars and Commands
    InitConVars();
    RegCommands();

    // Load Translations
    LoadTranslations("discord_redux.phrases");
    LoadTranslations("discord_redux/maps.phrases");

    // Cache Player Avatars
    char steamAPIKey[128];
    g_ConVars[steam_api_key].GetString(steamAPIKey, sizeof(steamAPIKey));
    if (steamAPIKey[0] != '\0')
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i) || IsFakeClient(i))
                continue;

            if (g_SteamAvatar[i][0] == '\0')
                GetClientAvatar(i, steamAPIKey);
        }
    }
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

    if (message.IsBot)
        return;

    /***** Chat *****/
    DiscordUser author = message.Author;
    char username[MAX_DISCORD_NAME_LENGTH];
    
    char chatChannelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(chatChannelID, sizeof(chatChannelID));

    char messageChannelID[SNOWFLAKE_SIZE];
    message.GetChannelId(messageChannelID, sizeof(messageChannelID));

    // Convert Discord markdown hyperlinks from '[text](link)' to 'text (link)'
    Regex hyperlinkRegex = new Regex("\\[([^\\]]+)\\]\\(([^\\)]+)\\)", PCRE_UTF8);
    int hyperlinkMatches = hyperlinkRegex.MatchAll(content);

    char parsedContent[MAX_DISCORD_MESSAGE_LENGTH];
    strcopy(parsedContent, sizeof(parsedContent), content);

    if (hyperlinkMatches > 0)
    {
        for (int i = 0; i < hyperlinkMatches; i++)
        {
            char text[MAX_DISCORD_MESSAGE_LENGTH];
            char link[MAX_DISCORD_MESSAGE_LENGTH];
            if (hyperlinkRegex.GetSubString(1, text, sizeof(text), i) &&
                hyperlinkRegex.GetSubString(2, link, sizeof(link), i))
            {
                char match[MAX_DISCORD_MESSAGE_LENGTH];
                hyperlinkRegex.GetSubString(0, match, sizeof(match), i);

                char replacement[MAX_DISCORD_MESSAGE_LENGTH];
                Format(replacement, sizeof(replacement), "%s (%s)", text, link);

                ReplaceString(parsedContent, sizeof(parsedContent), match, replacement, false);
            }
        }
    }
    delete hyperlinkRegex;

    // Parse mentions
    char guildID[SNOWFLAKE_SIZE];
    g_ConVars[guild_id].GetString(guildID, sizeof(guildID));
    
    Regex mentionRegex = new Regex("<@([0-9]+)>", PCRE_UTF8);
    int matches = mentionRegex.MatchAll(parsedContent);
    if (matches > 0) // Users
    {
        for (int i = 0; i < matches; i++)
        {
            char userID[SNOWFLAKE_SIZE];
            if (mentionRegex.GetSubString(1, userID, sizeof(userID), i))
            {
                DiscordUser mentionedUser = DiscordUser.FindUser(discord, userID);
                char mentionedName[MAX_DISCORD_NAME_LENGTH];
                if (mentionedUser != null)
                {
                    mentionedUser.GetUserName(mentionedName, sizeof(mentionedName));
                    char mentionPattern[32], replacement[MAX_DISCORD_NAME_LENGTH + 2];
                    Format(mentionPattern, sizeof(mentionPattern), "<@%s>", userID);
                    Format(replacement, sizeof(replacement), "{#959DF7}@%s", mentionedName);
                    ReplaceString(parsedContent, sizeof(parsedContent), mentionPattern, replacement);
                }
            }
        }
    }
    delete mentionRegex;

    Regex roleRegex = new Regex("<@&([0-9]+)>", PCRE_UTF8);
    int roleMatches = roleRegex.MatchAll(parsedContent);
    if (roleMatches > 0) // Roles
    {
        for (int i = 0; i < roleMatches; i++)
        {
            char roleId[SNOWFLAKE_SIZE];
            if (roleRegex.GetSubString(1, roleId, sizeof(roleId), i))
            {
                DiscordRole mentionedRole = DiscordRole.FindRole(discord, guildID, roleId);
                char roleName[MAX_DISCORD_NAME_LENGTH];
                if (mentionedRole != null)
                {
                    mentionedRole.GetName(roleName, sizeof(roleName));
                    int roleColor = mentionedRole.Color == 0x000000 ? 0x959DF7 : mentionedRole.Color;
                    char colorCode[16];
                    Format(colorCode, sizeof(colorCode), "%06x", roleColor);

                    char rolePattern[32], replacement[MAX_DISCORD_NAME_LENGTH + 10];
                    Format(rolePattern, sizeof(rolePattern), "<@&%s>", roleId);
                    Format(replacement, sizeof(replacement), "{#%s}@%s", colorCode, roleName);
                    ReplaceString(parsedContent, sizeof(parsedContent), rolePattern, replacement);
                }
            }
        }
    }
    delete roleRegex;

    Regex channelRegex = new Regex("<#([0-9]+)>", PCRE_UTF8);
    int channelMatches = channelRegex.MatchAll(parsedContent);
    if (channelMatches > 0) // Channels
    {
        for (int i = 0; i < channelMatches; i++)
        {
            char channelID[SNOWFLAKE_SIZE];
            if (channelRegex.GetSubString(1, channelID, sizeof(channelID), i))
            {
                DiscordChannel mentionedChannel = DiscordChannel.FindChannel(discord, channelID);
                char channelName[MAX_DISCORD_CHANNEL_NAME_LENGTH];
                if (mentionedChannel != null)
                {
                    mentionedChannel.GetName(channelName, sizeof(channelName));
                    char channelPattern[32], replacement[MAX_DISCORD_CHANNEL_NAME_LENGTH + 2];
                    Format(channelPattern, sizeof(channelPattern), "<#%s>", channelID);
                    Format(replacement, sizeof(replacement), "{#959DF7}#%s", channelName);
                    ReplaceString(parsedContent, sizeof(parsedContent), channelPattern, replacement);
                }
            }
        }
    }
    delete channelRegex;

    /***** RCON *****/
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
            case USER_NAME: author.GetUserName(username, sizeof(username));
            case GLOBAL_NAME: author.GetGlobalName(username, sizeof(username));
            case NICKNAME:
            {
                char nickname[64];
                author.GetNickName(nickname, sizeof(nickname));
                if (nickname[0] != '\0')
                    strcopy(username, sizeof(username), nickname);
                else
                    author.GetGlobalName(username, sizeof(username));
            }
            default: author.GetUserName(username, sizeof(username));
        }

        // ConVar: discord_redux_randomize_color_names
        if (g_ConVars[randomize_color_names] != null && g_ConVars[randomize_color_names].BoolValue)
        {
            char userId[SNOWFLAKE_SIZE], colorCode[7];
            author.GetId(userId, sizeof(userId));
            Format(colorCode, sizeof(colorCode), "%06x", StringToInt(userId));

            char coloredUsername[MAX_DISCORD_NAME_LENGTH + 10];
            Format(coloredUsername, sizeof(coloredUsername), "{#%s}%s", colorCode, username);
            strcopy(username, sizeof(username), coloredUsername);
        }

        // Relay Message
        char discordMsg[MAX_DISCORD_NITRO_MESSAGE_LENGTH];
        switch (message.Type)
        {
            case MessageType_Reply:
            {
                Format(discordMsg, sizeof(discordMsg), "%t", "discord_redux_chat_format_reply", username, parsedContent);
                // Workaround: referenced message content not available synchronously
                StrCat(discordMsg, sizeof(discordMsg), "\n↪ \x05[reply referenced message not available]");
            }
            default: Format(discordMsg, sizeof(discordMsg), "%t", "discord_redux_chat_format", username, parsedContent);
        }
        CPrintToChatAll("%s", discordMsg);

        char rawUsername[MAX_DISCORD_NAME_LENGTH + 1];
        Regex colorRegex = new Regex("\\{#[0-9a-fA-F]{6}\\}", PCRE_UTF8);
        strcopy(rawUsername, sizeof(rawUsername), username);
        int colorMatches = colorRegex.MatchAll(rawUsername);
        if (colorMatches > 0)
        {
            for (int i = colorMatches - 1; i >= 0; i--)
            {
                char match[16];
                if (colorRegex.GetSubString(0, match, sizeof(match), i))
                {
                    ReplaceString(rawUsername, sizeof(rawUsername), match, "", false);
                }
            }
        }
        delete colorRegex;
        PrintToServer("%t", "discord_redux_chat_format_console", rawUsername, parsedContent);

        int attachmentCount = message.AttachmentCount;
        if (attachmentCount > 0)
        {
            char links[MAX_DISCORD_MESSAGE_LENGTH];
            links[0] = '\0';
            for (int i = 0; i < attachmentCount; i++)
            {
                char url[512];
                message.GetAttachmentURL(i, url, sizeof(url));
                if (i > 0)
                    StrCat(links, sizeof(links), ", ");
                StrCat(links, sizeof(links), url);
            }
            CPrintToChatAll("%s", links);
            PrintToServer("%s", links);
        }
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
        (client > 0 && (!IsClientInGame(client) || IsFakeClient(client)) ) ||
        !g_Discord.IsRunning) return Plugin_Continue;

    if (client == 0 && !IsClientInGame(client))
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

    return Plugin_Continue;
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
    if (StrEqual(command, "say_team") && !g_ConVars[show_team_chat].BoolValue)
        return;

    char commandPrefixes[64];
    g_ConVars[hide_command_prefix].GetString(commandPrefixes, sizeof(commandPrefixes));

    int len = strlen(commandPrefixes);
    int start = 0;
    for (int i = 0; i <= len; i++)
    {
        if (commandPrefixes[i] == ',' || commandPrefixes[i] == '\0')
        {
            int prefixLen = i - start;
            if (prefixLen > 0)
            {
                char prefix[16];
                strcopy(prefix, sizeof(prefix), commandPrefixes[start]);
                prefix[prefixLen] = '\0';

                char pattern[32];
                Format(pattern, sizeof(pattern), "^%s", prefix);

                Regex regex = new Regex(pattern, PCRE_UTF8);
                if (regex.Match(sArgs) > 0)
                {
                    delete regex;
                    return;
                }
                delete regex;
            }
            start = i + 1;
        }
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
    
    delete g_PendingJoinEmbed[client];
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