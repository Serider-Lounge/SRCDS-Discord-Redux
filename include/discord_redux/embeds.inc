public void Embed_CurrentMapStatus()
{
    // Title: hostname
    char hostname[128];
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));

    // Description: game description
    char gameDesc[128];
    GetGameDescription(gameDesc, sizeof(gameDesc));

    // Map field
    char mapName[64];
    GetCurrentMap(mapName, sizeof(mapName));

    // Strip "workshop/" and ".ugc123456789" from workshop map names
    if (strncmp(mapName, "workshop/", 9) == 0)
    {
        // Remove "workshop/" prefix
        strcopy(mapName, sizeof(mapName), mapName[9]);

        // Remove ".ugc*" suffix
        int workshopID = FindCharInString(mapName, '.', false);
        if (workshopID != -1 && StrContains(mapName[workshopID], ".ugc", false) != -1)
            mapName[workshopID] = '\0';
    }

    // Player count field
    int maxPlayers = GetMaxHumanPlayers();
    int playerCount = GetOnlinePlayers();
    int botCount = GetBotCount();

    char playerField[DISCORD_FIELD_LENGTH];
    if (botCount > 0)
        Format(playerField, sizeof(playerField), "%d/%d (+ %d)", playerCount, maxPlayers, botCount);
    else
        Format(playerField, sizeof(playerField), "%d/%d", playerCount, maxPlayers);

    // Footer: icon + steam://connect/<public_ip>:<hostport>
    int ip[4];
    SteamWorks_GetPublicIP(ip);
    char ipStr[32];
    Format(ipStr, sizeof(ipStr), "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
    int hostport = GetConVarInt(FindConVar("hostport"));
    char port[8];
    Format(port, sizeof(port), "%d", hostport);

    char footerText[DISCORD_FOOTER_LENGTH], footerIcon[256];
    Format(footerText, sizeof(footerText), "steam://connect/%s:%s", ipStr, port);

    g_ConVars[footer_icon].GetString(footerIcon, sizeof(footerIcon));

    // Map Start/End embeds
    char hexColor[8];
    if (g_bMapEnded)
        g_ConVars[embed_previous_map_color].GetString(hexColor, sizeof(hexColor));
    else
        g_ConVars[embed_current_map_color].GetString(hexColor, sizeof(hexColor));

    char playerCountField[32];
    Format(playerCountField, sizeof(playerCountField), "%T", "discord_redux_player_count", LANG_SERVER);

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(hostname);
    embed.SetDescription(gameDesc);
    embed.Color = StringToInt(hexColor, 16);

    char translatedMapName[DISCORD_FIELD_LENGTH];
    if (TranslationPhraseExists(mapName))
        Format(translatedMapName, sizeof(translatedMapName), "%T", mapName, LANG_SERVER);
    else
        strcopy(translatedMapName, sizeof(translatedMapName), mapName);

    char mapField[DISCORD_FIELD_LENGTH];
    switch (GetEngineVersion())
    {
        case Engine_Left4Dead, Engine_Left4Dead2:
        {
            Format(mapField, sizeof(mapField), "%T", "discord_redux_campaign", LANG_SERVER);
        }
        default:
        {
            Format(mapField, sizeof(mapField), "%T", "discord_redux_map", LANG_SERVER);
        }
    }

    // Workshop clickable link logic
    char ugcID[32];
    if (GetWorkshopMapID(mapName, ugcID, sizeof(ugcID)))
    {
        char clickableMap[DISCORD_FIELD_LENGTH];
        Format(clickableMap, sizeof(clickableMap), "[%s](https://steamcommunity.com/sharedfiles/filedetails/?id=%s)", translatedMapName, ugcID);
        embed.AddField(mapField, clickableMap, true);
    }
    else
    {
        embed.AddField(mapField, translatedMapName, true);
    }

    if (!g_bMapEnded)
        embed.AddField(playerCountField, playerField, true);

    // Map Thumbnail
    if (g_ConVars[map_thumbnail_enabled].BoolValue)
    {
        char thumbUrl[256], thumbFormat[16];
        g_ConVars[map_thumbnail_url].GetString(thumbUrl, sizeof(thumbUrl));
        g_ConVars[map_thumbnail_format].GetString(thumbFormat, sizeof(thumbFormat));

        char mapThumb[320];
        Format(mapThumb, sizeof(mapThumb), "%s%s.%s", thumbUrl, mapName, thumbFormat);
        embed.SetThumbnail(mapThumb);
    }

    embed.SetFooter(footerText, footerIcon);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));

    if (g_Discord != null && g_Discord.IsRunning)
    {
        g_Discord.SendMessageEmbed(channelID, "", embed);
    }
    delete embed;
}

stock bool GetWorkshopMapID(const char[] mapName, char[] buffer, int maxlen)
{
    char workshopPath[PLATFORM_MAX_PATH];
    g_ConVars[workshop_path].GetString(workshopPath, sizeof(workshopPath));
    int appID = GetAppID();

    char searchPath[PLATFORM_MAX_PATH];
    Format(searchPath, sizeof(searchPath), "%s/%d/", workshopPath, appID);

    DirectoryListing dir = OpenDirectory(searchPath);
    if (dir == null)
        return false;

    char entry[256];
    FileType fileType;
    while (dir.GetNext(entry, sizeof(entry), fileType))
    {
        if (fileType != FileType_Directory)
            continue;

        char mapFile[PLATFORM_MAX_PATH];
        Format(mapFile, sizeof(mapFile), "%s/%s/%s.bsp", searchPath, entry, mapName);
        if (FileExists(mapFile))
        {
            strcopy(buffer, maxlen, entry);
            delete dir;
            return true;
        }
    }
    delete dir;
    return false;
}