/* Includes */
#include <sourcemod>
#include <discord>
#include <multicolors>
#include <ripext>
#include <SteamWorks>
#include <regex>
#undef REQUIRE_EXTENSIONS
#tryinclude <tf2_stocks>
#define REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#tryinclude <maprate>
#define REQUIRE_PLUGIN

// Discord Redux 
#include "discord_redux/convars.sp"
#include "discord_redux/clients.sp"
#include "discord_redux/commands.sp"

#include <discord_redux/stocks>
#include <discord_redux/embeds>
#include <discord_redux/steam>
#include <discord_redux/shared/navmesh>

/* Macros */
#define PLUGIN_NAME        "[ANY] Discord Redux"
#define PLUGIN_AUTHOR      "Heapons"
#define PLUGIN_DESC        "Server ⇄ Discord Relay"
#define PLUGIN_VERSION     "26w01c"
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

#define LIB_MAPRATE "maprate"
#define LIB_RTD2    "RollTheDice2"

/* ========[Forwards]======== */
public void OnPluginStart()
{
    // Libraries
    g_IsMapRateLoaded = LibraryExists(LIB_MAPRATE);
    g_IsRTDLoaded = LibraryExists(LIB_RTD2);

    // ConVars & Commands
    InitConVars();
    RegCommands();

    // Load Translations
    LoadTranslations("discord_redux.phrases");
    LoadTranslations("discord_redux/maps.phrases");
    LoadTranslations("discord_redux/events.phrases");

    // Fetch Game Info
    GameInfo gameinfo;
    g_AppID = gameinfo.appid;
    Steam_GetAppDetails(g_AppID, g_SteamWebAPIKey, Callback_OnAppDetailsFetched);

    // Cache avatars for all connected clients on plugin start
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && !IsFakeClient(client))
        {
            GetClientAvatar(client, g_SteamWebAPIKey, Callback_OnClientAvatarFetched);
        }
    }
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, LIB_MAPRATE))
        g_IsMapRateLoaded = true;
    else if (StrEqual(name, LIB_RTD2))
        g_IsRTDLoaded = true;
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, LIB_MAPRATE))
        g_IsMapRateLoaded = false;
    else if (StrEqual(name, LIB_RTD2))
        g_IsRTDLoaded = false;
}

public void Callback_OnAppDetailsFetched(int appid, const char[] name, const char[] icon, any data)
{
    strcopy(g_GameName, sizeof(g_GameName), name);
    strcopy(g_GameIcon, sizeof(g_GameIcon), icon);
}

public void OnMapStart()
{
    Embed_MapStatus();
}

public void OnMapEnd()
{
    Embed_MapStatus(true);
}

public void OnConfigsExecuted()
{
    UpdateConVars();
}

void OnDiscordReady(Discord discord, const char[] session_id, int shard_id, int guild_count, const char[] guild_ids, int guild_id_count, any data)
{
    char botName[MAX_DISCORD_NAME_LENGTH], botID[32];
    discord.GetBotName(botName, sizeof(botName));
    discord.GetBotId(botID, sizeof(botID));
    char botStatus[128];

    FormatEx(botStatus, sizeof(botStatus), "%T", "discord_redux_bot_success", LANG_SERVER, botName, botID);
    PrintToServer("%s", botStatus);

    OnMapStart();
}

void OnDiscordMessage(Discord discord, DiscordMessage message, any data)
{
    if (!g_Discord) return;

    char content[MAX_DISCORD_MESSAGE_LENGTH];
    message.GetContent(content, sizeof(content));

    if (message.IsBot)
        return;

    // Chat
    DiscordUser author = message.Author;
    char username[MAX_DISCORD_NAME_LENGTH];
    
    char chatChannelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(chatChannelID, sizeof(chatChannelID));
    
    char messageChannelID[SNOWFLAKE_SIZE];
    message.GetChannelId(messageChannelID, sizeof(messageChannelID));

    // Convert Discord markdown hyperlinks from '[text](link)' to 'text (link)'
    Regex hyperlinkRegex = new Regex("\\[([^\\]]+)\\]\\(([^\\)]+)\\)");
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
                Format(replacement, sizeof(replacement), "%s \x05(%s)\x01", text, link);

                ReplaceString(parsedContent, sizeof(parsedContent), match, replacement, false);
            }
        }
    }
    delete hyperlinkRegex;

    // Parse mentions
    char guildID[SNOWFLAKE_SIZE];
    g_ConVars[guild_id].GetString(guildID, sizeof(guildID));

    // User mentions
    Regex userRegex = new Regex("<@([0-9]+)>");
    int userMatches = userRegex.MatchAll(parsedContent);
    if (userMatches > 0)
    {
        for (int i = 0; i < userMatches; i++)
        {
            char userID[SNOWFLAKE_SIZE];
            if (userRegex.GetSubString(1, userID, sizeof(userID), i))
            {
                DiscordUser user;
                //if (guildID[0] != '\0')
                //    user = DiscordUser.FindUser(g_Discord, userID, guildID);
                //else
                user = DiscordUser.FindUser(g_Discord, userID);

                char mentionedName[MAX_DISCORD_NAME_LENGTH];
                if (user != null)
                    user.GetUserName(mentionedName, sizeof(mentionedName));
                else
                    Format(mentionedName, sizeof(mentionedName), "<@%s>", userID);

                char match[32];
                userRegex.GetSubString(0, match, sizeof(match), i);

                char replacement[MAX_DISCORD_NAME_LENGTH + 12];
                int color = StringToInt(userID) & 0xFFFFFF;
                if (user != null)
                {
                    if (g_ConVars[randomize_color_names].BoolValue)
                        Format(replacement, sizeof(replacement), "\x07%06X@%s\x01", color, mentionedName);
                    else
                        Format(replacement, sizeof(replacement), "\x01\x03@%s\x01", mentionedName);
                }
                else
                {
                    Format(replacement, sizeof(replacement), "\x01\x03<@%s>\x01", userID);
                }
                ReplaceString(parsedContent, sizeof(parsedContent), match, replacement, false);
            }
        }
    }
    delete userRegex;

    // Role mentions
    Regex roleRegex = new Regex("<@&([0-9]+)>");
    int roleMatches = roleRegex.MatchAll(parsedContent);
    if (roleMatches > 0)
    {
        for (int i = 0; i < roleMatches; i++)
        {
            char roleId[SNOWFLAKE_SIZE];
            if (roleRegex.GetSubString(1, roleId, sizeof(roleId), i))
            {
                DiscordRole mentionedRole = DiscordRole.FindRole(g_Discord, guildID, roleId);
                char roleName[MAX_DISCORD_NAME_LENGTH];
                if (mentionedRole != null)
                {
                    mentionedRole.GetName(roleName, sizeof(roleName));
                    char colorCode[16];
                    if (mentionedRole.Color == 0x000000)
                        strcopy(colorCode, sizeof(colorCode), "");
                    else
                        Format(colorCode, sizeof(colorCode), "\x07%06X", mentionedRole.Color);

                    char match[32];
                    roleRegex.GetSubString(0, match, sizeof(match), i);

                    char replacement[MAX_DISCORD_NAME_LENGTH + 10];
                    Format(replacement, sizeof(replacement), "\x05%s@%s\x01", colorCode, roleName);

                    ReplaceString(parsedContent, sizeof(parsedContent), match, replacement, false);
                }
            }
        }
    }
    delete roleRegex;

    // Channel mentions
    Regex channelRegex = new Regex("<#([0-9]+)>");
    int channelMatches = channelRegex.MatchAll(parsedContent);
    if (channelMatches > 0)
    {
        for (int i = 0; i < channelMatches; i++)
        {
            char channelID[SNOWFLAKE_SIZE];
            if (channelRegex.GetSubString(1, channelID, sizeof(channelID), i))
            {
                DiscordChannel mentionedChannel = DiscordChannel.FindChannel(g_Discord, channelID);
                char channelName[MAX_DISCORD_CHANNEL_NAME_LENGTH];
                if (channelName[0] != '\0')
                {
                    mentionedChannel.GetName(channelName, sizeof(channelName));
                    char match[32];
                    channelRegex.GetSubString(0, match, sizeof(match), i);

                    char replacement[MAX_DISCORD_CHANNEL_NAME_LENGTH + 2];
                    Format(replacement, sizeof(replacement), "\x04#%s\x01", channelName);

                    ReplaceString(parsedContent, sizeof(parsedContent), match, replacement, false);
                }
            }
        }
    }
    delete channelRegex;

    // RCON
    char rconChannelID[SNOWFLAKE_SIZE];
    g_ConVars[rcon_channel_id].GetString(rconChannelID, sizeof(rconChannelID));

    if (StrEqual(messageChannelID, chatChannelID))
    {
        if (StrEqual(content, "!map", false) || StrEqual(content, "!status", false))
        {
            Embed_MapStatus();
        }

        // Username
        UsernameMode mode = view_as<UsernameMode>(g_ConVars[username_mode].IntValue);
        switch (mode)
        {
            case Mode_UserName:
            {
                author.GetUserName(username, sizeof(username));
            }
            case Mode_GlobalName:
            {
                author.GetGlobalName(username, sizeof(username));
            }
            case Mode_NickName:
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
            case MessageType_Reply: Format(discordMsg, sizeof(discordMsg), "%t", "discord_redux_chat_format_reply", username, parsedContent);
            default: Format(discordMsg, sizeof(discordMsg), "%t", "discord_redux_chat_format", username, parsedContent);
        }
        CPrintToChatAll("%s", discordMsg);

        char rawUsername[MAX_DISCORD_NAME_LENGTH + 1];
        Regex colorRegex = new Regex("\\{#[0-9a-fA-F]{6}\\}");
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
        for (int i = 0; i < attachmentCount; i++)
        {
            char url[512];
            message.GetAttachmentURL(i, url, sizeof(url));
            Format(url, sizeof(url), "%d. \x04%s", i + 1, url);
            CPrintToChatAll(url);
            PrintToServer(url);
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

// Games
#include "discord_redux/game/tf2.sp"

// Third-Party
#include "discord_redux/thirdparty/accelerator.sp"
#include "discord_redux/thirdparty/rtd.sp"