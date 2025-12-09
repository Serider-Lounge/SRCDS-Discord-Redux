stock void Embed_MapStatus_Color(DiscordEmbed embed, bool mapEnded)
{
    char hexColor[8];
    if (mapEnded)
        g_ConVars[embed_previous_map_color].GetString(hexColor, sizeof(hexColor));
    else
        g_ConVars[embed_current_map_color].GetString(hexColor, sizeof(hexColor));
    embed.Color = StringToInt(hexColor, 16);
}

stock void Embed_MapStatus_Title(DiscordEmbed embed)
{
    char hostname[DISCORD_TITLE_LENGTH];
    GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));
    embed.SetTitle(hostname);
}

stock void Embed_MapStatus_Description(DiscordEmbed embed)
{
    char gameDesc[DISCORD_DESC_LENGTH];
    GetGameDescription(gameDesc, sizeof(gameDesc));
    embed.SetDescription(gameDesc);
}

stock void Embed_MapStatus_Footer(DiscordEmbed embed)
{
    int ip[4], port = FindConVar("hostport").IntValue;
    SteamWorks_GetPublicIP(ip);
    char footerText[64];
    Format(footerText, sizeof(footerText), "steam://connect/%d.%d.%d.%d:%d", ip[0], ip[1], ip[2], ip[3], port);

    char footerIcon[256];
    g_ConVars[footer_icon].GetString(footerIcon, sizeof(footerIcon));
    embed.SetFooter(footerText, footerIcon);
}

stock void Embed_MapStatus_Author(DiscordEmbed embed)
{
    char storeURL[256];
    char iconURL[256];
    Format(iconURL, sizeof(iconURL), "https://shared.fastly.steamstatic.com/community_assets/images/apps/%d/%s.jpg", g_AppID, g_GameIcon);
    Format(storeURL, sizeof(storeURL), "https://store.steampowered.com/app/%d", g_AppID); 
    embed.SetAuthor(g_GameName, storeURL, iconURL);
}

stock void Embed_MapStatus_PlayerCount(DiscordEmbed embed, bool mapEnded)
{
    if (mapEnded) return;

    int onlineCount = GetOnlinePlayers();
    int maxPlayers = GetMaxPlayers();
    int botCount = GetBotCount();

    char playerCount[DISCORD_FIELD_LENGTH];
    if (botCount > 0)
        Format(playerCount, sizeof(playerCount), "%d/%d (+ %d)", onlineCount, maxPlayers, botCount);
    else
        Format(playerCount, sizeof(playerCount), "%d/%d", onlineCount, maxPlayers);
    char playerTitle[DISCORD_TITLE_LENGTH];
    Format(playerTitle, sizeof(playerTitle), "%T", "discord_redux_player_count", LANG_SERVER);
    embed.AddField(playerTitle, playerCount, true);
}

stock void Embed_MapStatus_MapRate(DiscordEmbed embed, bool mapEnded, const char[] displayMapName)
{
    if (mapEnded && g_IsMapRateLoaded && g_ConVars[maprate_enabled].BoolValue)
    {
        char ratingValue[16] = "";
        int stars = RoundFloat(MapRate_GetAverage(displayMapName));
        for (int i = 0; i < stars; i++)
        {
            StrCat(ratingValue, sizeof(ratingValue), "⭐");
        }

        if (stars > 0)
        {
            char ratingTitle[DISCORD_TITLE_LENGTH];
            Format(ratingTitle, sizeof(ratingTitle), "%T", "discord_redux_maprate_average", LANG_SERVER);
            embed.AddField(ratingTitle, ratingValue, true);
        }
    }
}

stock void Embed_MapStatus_Thumbnail(DiscordEmbed embed)
{
    if (!g_ConVars[map_thumbnail_enabled].BoolValue)
        return;

    char mapName[96], displayMapName[32];
    GetCurrentMap(mapName, sizeof(mapName));
    GetMapDisplayName(mapName, displayMapName, sizeof(displayMapName));

    char ugcID[64], preview_url[256];
    Workshop map = new Workshop(displayMapName);
    if (map.GetUgcID(ugcID, sizeof(ugcID)))
    {
        map.GetString("preview_url", preview_url, sizeof(preview_url));
        if (preview_url[0] != '\0')
        {
            embed.SetThumbnail(preview_url);
            return;
        }
    }

    char thumbnailUrl[256], thumbnailFormat[16], buffer[256];
    g_ConVars[map_thumbnail_url].GetString(thumbnailUrl, sizeof(thumbnailUrl));
    g_ConVars[map_thumbnail_format].GetString(thumbnailFormat, sizeof(thumbnailFormat));
    Format(buffer, sizeof(buffer), "%s%s.%s", thumbnailUrl, displayMapName, thumbnailFormat);
    embed.SetThumbnail(buffer);
}