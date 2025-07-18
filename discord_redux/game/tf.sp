/*
public Action TF2_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    return Plugin_Continue;
}
*/

//public Action TF2_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
//{
//    int winner = event.GetInt("team");
//
//    // Prepare embed for Discord
//    DiscordEmbed embed = new DiscordEmbed();
//    char title[64];
//    char winnerStr[8];
//    char thumbUrl[128];
//
//    switch (winner)
//    {
//        case TFTeam_Red:
//        {
//            strcopy(winnerStr, sizeof(winnerStr), "RED");
//            strcopy(thumbUrl, sizeof(thumbUrl), "https://wiki.teamfortress.com/w/images/8/80/Team_red.png");
//        }
//        case TFTeam_Blue:
//        {
//            strcopy(winnerStr, sizeof(winnerStr), "BLU");
//            strcopy(thumbUrl, sizeof(thumbUrl), "https://wiki.teamfortress.com/w/images/0/07/Team_blu.png");
//        }
//        default:
//        {
//            strcopy(winnerStr, sizeof(winnerStr), "UNASSIGNED");
//            thumbUrl[0] = '\0';
//        }
//    }
//
//    float elapsed = event.GetFloat("round_time");
//    char timeStr[32];
//    int minutes = RoundToFloor(elapsed / 60.0);
//    int seconds = RoundToFloor(elapsed) % 60;
//    Format(timeStr, sizeof(timeStr), "%d:%02d", minutes, seconds);
//
//    // Update title formatting to use translation strings
//    if (winner == view_as<int>(TFTeam_Red) || winner == view_as<int>(TFTeam_Blue))
//    {
//        // "Round Win Title" expects {1} = RED/BLU
//        Format(title, sizeof(title), "%T", "Round Win", LANG_SERVER, winnerStr);
//    }
//    else
//    {
//        // "Round Stalemate Title" expects no args
//        Format(title, sizeof(title), "%T", "Stalemate", LANG_SERVER);
//    }
//    embed.SetTitle(title);
//    embed.SetColor((winner == view_as<int>(TFTeam_Red)) ? 0xA75D51 : (winner == view_as<int>(TFTeam_Blue)) ? 0x4F7888 : 0x1C1918);
//    embed.AddField("Elapsed Time", timeStr, false);
//
//    if (thumbUrl[0] != '\0')
//    {
//        embed.SetThumbnail(thumbUrl);
//    }
//
//    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
//    delete embed;
//
//    return Plugin_Continue;
//}

public void TF2_SendScoreboardEmbed()
{
    // Prepare player lists
    char redList[512];
    char bluList[512];
    char specList[512];
    redList[0] = '\0';
    bluList[0] = '\0';
    specList[0] = '\0';

    char playerName[MAX_NAME_LENGTH];
    char steamId64[32];
    bool firstRed = true, firstBlu = true, firstSpec = true;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i))
            continue;

        GetClientName(i, playerName, sizeof(playerName));
        GetClientAuthId(i, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
        int team = TF2_GetClientTeam(i);

        // Format as markdown link with bullet point
        char playerLink[MAX_NAME_LENGTH+64];
        Format(playerLink, sizeof(playerLink), "- [%s](http://www.steamcommunity.com/profiles/%s)", playerName, steamId64);

        switch (team)
        {
            case TFTeam_Red:
            {
                if (!firstRed) strcopy(redList[strlen(redList)], sizeof(redList) - strlen(redList), "\n");
                strcopy(redList[strlen(redList)], sizeof(redList) - strlen(redList), playerLink);
                firstRed = false;
            }
            case TFTeam_Blue:
            {
                if (!firstBlu) strcopy(bluList[strlen(bluList)], sizeof(bluList) - strlen(bluList), "\n");
                strcopy(bluList[strlen(bluList)], sizeof(bluList) - strlen(bluList), playerLink);
                firstBlu = false;
            }
            default:
            {
                if (!firstSpec) strcopy(specList[strlen(specList)], sizeof(specList) - strlen(specList), "\n");
                strcopy(specList[strlen(specList)], sizeof(specList) - strlen(specList), playerLink);
                firstSpec = false;
            }
        }
    }

    DiscordEmbed embed = new DiscordEmbed();
    char title[DISCORD_TITLE_LENGTH];
    Format(title, sizeof(title), "%T", "Scoreboard", LANG_SERVER);
    embed.SetTitle(title);
    embed.SetColor(HexColorStringToInt(g_EmbedScoreboardColor));

    embed.AddField("BLU:", (bluList[0] != '\0') ? bluList : "`N/A`", true);
    embed.AddField("RED:", (redList[0] != '\0') ? redList : "`N/A`", true);
    embed.AddField("SPEC:", (specList[0] != '\0') ? specList : "`N/A`", false);

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;

    // Clear memory for large buffers
    redList[0] = '\0';
    bluList[0] = '\0';
    specList[0] = '\0';
}