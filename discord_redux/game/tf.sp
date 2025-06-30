/*
public Action TF2_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    return Plugin_Continue;
}
*/

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
    embed.SetColor(0x2a2725);

    embed.AddField("BLU:", (bluList[0] != '\0') ? bluList : "`N/A`", true);
    embed.AddField("RED:", (redList[0] != '\0') ? redList : "`N/A`", true);
    embed.AddField("SPEC", (specList[0] != '\0') ? specList : "`N/A`", false);

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;
}