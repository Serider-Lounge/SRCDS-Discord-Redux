/**
 * Map Status embed.
 * 
 * @param   mapEnded    Whether the map has ended.
 */
stock void Embed_MapStatus(bool mapEnded = false)
{
    /* Vars */
    DiscordEmbed embed = new DiscordEmbed();

    char hostname[DISCORD_TITLE_LENGTH];
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));

    embed.SetTitle(hostname);

    char gameDesc[DISCORD_DESC_LENGTH];
    GetGameDescription(gameDesc, sizeof(gameDesc));
    
    embed.SetDescription(gameDesc);

    // Footer
    int ip[4];
    SteamWorks_GetPublicIP(ip);
    int port = FindConVar("hostport").IntValue;
    char addr[64];
    Format(addr, sizeof(addr), "steam://connect/%d.%d.%d.%d:%d", ip[0], ip[1], ip[2], ip[3], port);

    char footerIcon[256];
    g_ConVars[footer_icon].GetString(footerIcon, sizeof(footerIcon));

    embed.SetFooter(addr, footerIcon);

    // Player Count
    int onlineCount = GetOnlinePlayers();
    int maxPlayers = GetMaxPlayers();
    int botCount = GetBotCount();
    char playerCount[16];
    if (botCount > 0)
        Format(playerCount, sizeof(playerCount), "%d/%d (+ %d)", onlineCount, maxPlayers, botCount);
    else
        Format(playerCount, sizeof(playerCount), "%d/%d", onlineCount, maxPlayers);

    char hexColor[8];
    if (mapEnded)
        g_ConVars[embed_previous_map_color].GetString(hexColor, sizeof(hexColor));
    else
        g_ConVars[embed_current_map_color].GetString(hexColor, sizeof(hexColor));
    embed.Color = StringToInt(hexColor, 16);

    // Map
    char mapName[96], displayMapName[96];
    GetCurrentMap(mapName, sizeof(mapName));
    GetMapDisplayName(mapName, displayMapName, sizeof(displayMapName));

    Workshop bsp = new Workshop(displayMapName);

    DataPack pack = new DataPack();
    pack.WriteCell(embed);
    pack.WriteCell(mapEnded);
    pack.WriteCell(bsp);

    char ugcID[64];
    bsp.GetUgcID(ugcID, sizeof(ugcID));
    bsp.GetDetails(ugcID, Callback_OnWorkshopDetailsFetched, pack);
}

stock void Callback_OnWorkshopDetailsFetched(const char[] ugcid, const char[] title, const char[] preview_url, const char[] creator, const char tags[][64], int numTags, DataPack pack)
{
    pack.Reset();
    DiscordEmbed embed = pack.ReadCell();
    bool mapEnded = pack.ReadCell();
    Workshop bsp = pack.ReadCell();
    delete pack;    

    GameInfo gameinfo;
    int appid = gameinfo.appid;

    char iconURL[256];
    Format(iconURL, sizeof(iconURL), "https://shared.fastly.steamstatic.com/community_assets/images/apps/%d/%s.jpg", appid, g_GameIcon);

    char storeURL[256];
    Format(storeURL, sizeof(storeURL), "https://store.steampowered.com/app/%d", appid); 

    char gameName[64];
    gameinfo.GetGameName(gameName, sizeof(gameName));
    embed.SetAuthor(gameName, storeURL, iconURL);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[map_status_channel_id].GetString(channelID, sizeof(channelID));
    if (channelID[0] == '\0')
        g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));

    /* Embed Fields */
    char mapTitle[DISCORD_FIELD_LENGTH], displayMapName[96];
    bsp.GetString("map", displayMapName, sizeof(displayMapName));
    if (TranslationPhraseExists(mapTitle)) // Is it defined in 'discord_redux/maps.phrases.txt'?
    {
        Format(mapTitle, sizeof(mapTitle), "%T", displayMapName, LANG_SERVER);
    }
    else if (ugcid[0] != '\0') // Is it a workshop map?
    {
        Format(mapTitle, sizeof(mapTitle), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", (title[0] != '\0') ? title : displayMapName, ugcid);
    }
    else // Fallback to file name.
    {
        Format(mapTitle, sizeof(mapTitle), "%s", displayMapName);
    }

    char mapField[DISCORD_TITLE_LENGTH];
    switch (GetEngineVersion())
    {
        case Engine_Left4Dead, Engine_Left4Dead2:
            Format(mapField, sizeof(mapField), "%T", "discord_redux_campaign", LANG_SERVER);
        default:
            Format(mapField, sizeof(mapField), "%T", "discord_redux_map", LANG_SERVER);
    }
    embed.AddField(mapField, mapTitle, true);

    // Player Count
    if (!mapEnded)
    {
        int onlineCount = GetOnlinePlayers();
        int maxPlayers = GetMaxPlayers();
        int botCount = GetBotCount();

        char playerCountStr[DISCORD_FIELD_LENGTH];
        if (botCount > 0)
            Format(playerCountStr, sizeof(playerCountStr), "%d/%d (+ %d)", onlineCount, maxPlayers, botCount);
        else
            Format(playerCountStr, sizeof(playerCountStr), "%d/%d", onlineCount, maxPlayers);

        char playerField[DISCORD_TITLE_LENGTH];
        Format(playerField, sizeof(playerField), "%T", "discord_redux_player_count", LANG_SERVER);
        embed.AddField(playerField, playerCountStr, true);
    }

    // Map Rate Average
    if (g_IsMapRateLoaded && g_ConVars[maprate_enabled].BoolValue && mapEnded)
    {
        char ratingValue[16];
        int stars = RoundFloat(MapRate_GetAverage(displayMapName));        
        for (int i = 0; i < stars; i++)
        {
            StrCat(ratingValue, sizeof(ratingValue), "⭐");
        }

        if (stars > 0)
        {
            char ratingField[DISCORD_TITLE_LENGTH];
            Format(ratingField, sizeof(ratingField), "%T", "discord_redux_maprate_average", LANG_SERVER);
            embed.AddField(ratingField, ratingValue, true);
        }
    }

    if (g_ConVars[map_thumbnail_enabled].BoolValue)
    {
        if (StrEqual(preview_url, "https://community.cloudflare.steamstatic.com/public/images/sharedfiles/steam_workshop_default_image.png"))
        {
            char thumbnailUrl[256], thumbnailFormat[16], buffer[256];
            g_ConVars[map_thumbnail_url].GetString(thumbnailUrl, sizeof(thumbnailUrl));
            g_ConVars[map_thumbnail_format].GetString(thumbnailFormat, sizeof(thumbnailFormat));
            Format(buffer, sizeof(buffer), "%s%s.%s", thumbnailUrl, displayMapName, thumbnailFormat);
            embed.SetThumbnail(buffer);
        }
        else
        {
            embed.SetThumbnail(preview_url);
        }
    }

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
    if (!g_Discord)
        return;

    if (IsFakeClient(client) || !g_Discord.IsRunning)
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