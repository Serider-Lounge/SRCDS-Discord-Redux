#include <discord_redux/embeds/map_status>

/**
 * Map Status embed.
 * 
 * @param   mapEnded    Whether the map has ended.
 */
stock void Embed_MapStatus(bool mapEnded = false)
{
    if (!g_Discord || !g_Discord.IsRunning)
        return;

    DiscordEmbed embed = new DiscordEmbed();

    // Map
    char mapName[DISCORD_FIELD_LENGTH], displayMapName[32];
    GetCurrentMap(mapName, sizeof(mapName));
    GetMapDisplayName(mapName, displayMapName, sizeof(displayMapName));

    char ugcID[64], title[256], preview_url[256];
    Workshop map = new Workshop(displayMapName);
    bool isWorkshop = map.GetUgcID(ugcID, sizeof(ugcID));
    char mapTitle[DISCORD_TITLE_LENGTH];
    Format(mapTitle, sizeof(mapTitle), "%T", "discord_redux_map", LANG_SERVER);

    if (isWorkshop)
    {
        map.GetString("title", title, sizeof(title));
        map.GetString("preview_url", preview_url, sizeof(preview_url));

        if (title[0] == '\0')
        {
            DataPack pack = new DataPack();
            pack.WriteCell(embed);
            pack.WriteCell(map);
            pack.WriteCell(mapEnded);
            pack.WriteString(displayMapName);

            map.GetDetails(ugcID, Embed_WorkshopMapStatus, pack);
            return;
        }
        Format(mapName, sizeof(mapName), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", title, ugcID);
        embed.AddField(mapTitle, mapName, true);
    }
    else
    {
        if (TranslationPhraseExists(displayMapName)) Format(mapName, sizeof(mapName), "%T", displayMapName, LANG_SERVER);
        embed.AddField(mapTitle, mapName, true);
    }

    Embed_MapStatus_Color(embed, mapEnded);
    Embed_MapStatus_Title(embed);
    Embed_MapStatus_Description(embed);
    Embed_MapStatus_Footer(embed);
    Embed_MapStatus_Author(embed);
    Embed_MapStatus_PlayerCount(embed, mapEnded);
    Embed_MapStatus_MapRate(embed, mapEnded, displayMapName);
    Embed_MapStatus_Thumbnail(embed);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[map_status_channel_id].GetString(channelID, sizeof(channelID));
    if (channelID[0] == '\0') g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));

    g_Discord.SendMessageEmbed(channelID, "", embed);
    delete embed;
}

/**
 * (Workshop) Map Status embed.
 * 
 * @param   ugcid       The UGC ID of the workshop map.
 * @param   title       The title of the workshop map.
 * @param   preview_url The preview URL of the workshop map.
 * @param   creator     The creator of the workshop map.
 * @param   tags        The tags of the workshop map.
 * @param   numTags     The number of tags.
 * @param   pack        The data-pack containing the stored variables.
 */
stock void Embed_WorkshopMapStatus(const char[] ugcid, const char[] title, const char[] preview_url, const char[] creator, const char tags[][64], int numTags, DataPack pack)
{
    pack.Reset();
    DiscordEmbed embed = pack.ReadCell();
    Workshop map = pack.ReadCell();
    bool mapEnded = pack.ReadCell();
    char displayMapName[32];
    pack.ReadString(displayMapName, sizeof(displayMapName));
    delete pack;

    map.SetString("title", title);
    map.SetString("preview_url", preview_url);

    char mapName[DISCORD_FIELD_LENGTH];
    Format(mapName, sizeof(mapName), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", title, ugcid);
    char mapTitle[DISCORD_TITLE_LENGTH];
    Format(mapTitle, sizeof(mapTitle), "%T", "discord_redux_map", LANG_SERVER);
    embed.AddField(mapTitle, mapName, true);

    Embed_MapStatus_Color(embed, mapEnded);
    Embed_MapStatus_Title(embed);
    Embed_MapStatus_Description(embed);
    Embed_MapStatus_Footer(embed);
    Embed_MapStatus_Author(embed);
    Embed_MapStatus_PlayerCount(embed, mapEnded);
    Embed_MapStatus_MapRate(embed, mapEnded, displayMapName);

    char preview_url_latest[256];
    map.GetString("preview_url", preview_url_latest, sizeof(preview_url_latest));
    if (g_ConVars[map_thumbnail_enabled].BoolValue && preview_url_latest[0] != '\0')
    {
        embed.SetThumbnail(preview_url_latest);
    }
    else
    {
        Embed_MapStatus_Thumbnail(embed);
    }

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[map_status_channel_id].GetString(channelID, sizeof(channelID));
    if (channelID[0] == '\0') g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));

    g_Discord.SendMessageEmbed(channelID, "", embed);
    delete embed;
}

/**
 * Player join/leave notification.
 * 
 * @param   client      The client index.
 * @param   isLeaving   Whether the player is leaving.
 */
stock void Embed_PlayerStatus(int client, bool isLeaving = false)
{
    if (!g_Discord || !g_Discord.IsRunning)
        return;

    if (IsFakeClient(client))
        return;

    DiscordEmbed embed = new DiscordEmbed();

    char playerName[MAX_NAME_LENGTH];
    GetClientName(client, playerName, sizeof(playerName));

    char steamID2[MAX_AUTHID_LENGTH], steamID64[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, steamID2, sizeof(steamID2));
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64));

    char steamProfile[256];
    Format(steamProfile, sizeof(steamProfile), "http://steamcommunity.com/profiles/%s", steamID64);

    char footerIcon[256];
    g_ConVars[footer_icon].GetString(footerIcon, sizeof(footerIcon));

    char message[MAX_DISCORD_MESSAGE_LENGTH], hexColor[8];
    if (isLeaving)
    {
        if (g_IsClientBanned[client])
        {
            Format(message, sizeof(message), "%T", "discord_redux_player_banned", LANG_SERVER);
            g_ConVars[embed_ban_color].GetString(hexColor, sizeof(hexColor));
        }
        else if (IsClientInKickQueue(client))
        {
            Format(message, sizeof(message), "%T", "discord_redux_player_kicked", LANG_SERVER);
            g_ConVars[embed_kick_color].GetString(hexColor, sizeof(hexColor));
        }
        else
        {
            Format(message, sizeof(message), "%T", "discord_redux_player_leave", LANG_SERVER);
            g_ConVars[embed_leave_color].GetString(hexColor, sizeof(hexColor));
        }
    }
    else
    {
        Format(message, sizeof(message), "%T", "discord_redux_player_join", LANG_SERVER);
        g_ConVars[embed_join_color].GetString(hexColor, sizeof(hexColor));
    }

    embed.SetAuthor(playerName, steamProfile, g_ClientAvatar[client]);
    embed.SetDescription(message);
    embed.SetFooter(steamID2, footerIcon);
    embed.Color = StringToInt(hexColor, 16);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[player_status_channel_id].GetString(channelID, sizeof(channelID));
    if (channelID[0] == '\0')
        g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));

    g_Discord.SendMessageEmbed(channelID, "", embed);
    delete embed;
}