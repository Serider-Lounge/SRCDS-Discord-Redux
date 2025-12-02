public void Embed_CurrentMapStatus()
{
    // Title: hostname
    char hostname[128];
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));

    // Description: game description
    char gameDesc[128];
    GetGameDescription(gameDesc, sizeof(gameDesc));

    // Map field
    char mapName[64], displayMapName[64];
    GetCurrentMap(mapName, sizeof(mapName));
    GetMapDisplayName(mapName, displayMapName, sizeof(displayMapName));

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
    if (g_HasMapEnded)
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

    // Steam Workshop
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

    if (!g_HasMapEnded)
        embed.AddField(playerCountField, playerField, true);

    // Map Rate Average
    if (g_IsMapRateLoaded && g_ConVars[map_rating_enabled].BoolValue && g_HasMapEnded)
    {
        char ratingValue[16];
        int stars = RoundFloat(MapRate_GetAverage(mapName));        
        for (int i = 0; i < stars; i++)
        {
            StrCat(ratingValue, sizeof(ratingValue), "⭐");
        }

        if (stars > 0)
        {
            char ratingField[DISCORD_FIELD_LENGTH];
            Format(ratingField, sizeof(ratingField), "%T", "discord_redux_maprate_average", LANG_SERVER);
            embed.AddField(ratingField, ratingValue, true);
        }
    }

    // Map Thumbnail
    if (g_ConVars[map_thumbnail_enabled].BoolValue)
    {
        char thumbUrl[256], thumbFormat[16];
        g_ConVars[map_thumbnail_url].GetString(thumbUrl, sizeof(thumbUrl));
        g_ConVars[map_thumbnail_format].GetString(thumbFormat, sizeof(thumbFormat));

        char mapThumb[320];
        Format(mapThumb, sizeof(mapThumb), "%s%s.%s", thumbUrl, mapName, thumbFormat);

        if (GetWorkshopMapID(mapName, ugcID, sizeof(ugcID)))
        {
            Format(mapThumb, sizeof(mapThumb), "https://community.cloudflare.steamstatic.com/public/images/sharedfiles/steam_workshop_default_image.png");
        }

        embed.SetThumbnail(mapThumb);
    }

    embed.SetFooter(footerText, footerIcon);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
    if (g_Discord.IsRunning)
    {
        g_Discord.SendMessageEmbed(channelID, "", embed);
    }
    delete embed;
}
