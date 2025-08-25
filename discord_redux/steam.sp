public void OnSteamAvatarResponse(HTTPResponse response, any userid)
{
    if (response.Status != HTTPStatus_OK)
        return;

    JSON data = response.Data;
    if (data == null)
        return;

    JSONObject root = view_as<JSONObject>(data);
    JSONObject responseObj = view_as<JSONObject>(root.Get("response"));
    JSONArray players = view_as<JSONArray>(responseObj.Get("players"));
    if (players.Length == 0)
        return;

    JSONObject player = view_as<JSONObject>(players.Get(0));
    char avatarUrl[256];
    if (!player.GetString("avatarfull", avatarUrl, sizeof(avatarUrl)))
        return;

    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client))
        return;

    // Cache Avatar
    strcopy(g_ClientAvatar[client], sizeof(g_ClientAvatar[]), avatarUrl);

    // Send join embed if queued
    if (g_PendingMessages[client] != null && g_PendingMessages[client].Length > 0)
    {
        char marker[32];
        g_PendingMessages[client].GetString(0, marker, sizeof(marker));
        g_PendingMessages[client].Erase(0);

        if (StrEqual(marker, "[JOIN]"))
        {
            char playerName[MAX_NAME_LENGTH];
            char steamId64[32];
            char steamId2[32];

            GetClientName(client, playerName, sizeof(playerName));
            GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
            GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2), true);

            char description[256];
            Format(description, sizeof(description), "%T", "Player Join", LANG_SERVER, playerName, steamId64);

            DiscordEmbed embed = new DiscordEmbed();
            embed.SetDescription(description);

            g_cvEmbedJoinColor.GetString(g_EmbedJoinColor, sizeof(g_EmbedJoinColor));
            embed.Color = HexColorStringToInt(g_EmbedJoinColor);

            if (g_ClientAvatar[client][0] != '\0')
            {
                if (steamId2[0] != '\0')
                    embed.SetFooter(steamId2, g_ClientAvatar[client]);
                else
                    embed.SetFooter("", g_ClientAvatar[client]);
            }
            else if (steamId2[0] != '\0')
            {
                embed.SetFooter(steamId2, "");
            }

            g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
            delete embed;
        }
    }
}

stock void RefreshAllClientSteamAvatars(const char[] steamApiKey)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientConnected(client) && !IsFakeClient(client) && !IsClientSourceTV(client))
        {
            char steamId[32];
            if (GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId)))
            {
                HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/");
                req.AppendQueryParam("key", steamApiKey);
                req.AppendQueryParam("steamids", steamId);
                req.AppendQueryParam("format", "json");
                int userid = GetClientUserId(client);
                req.Get(OnSteamAvatarResponse, userid);
            }
        }
    }
}

stock void RefreshClientSteamAvatar(int client, const char[] steamApiKey)
{
    if (!IsClientConnected(client) || IsFakeClient(client) || IsClientSourceTV(client))
        return;

    char steamId[32];
    if (GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId)))
    {
        HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/");
        req.AppendQueryParam("key", steamApiKey);
        req.AppendQueryParam("steamids", steamId);
        req.AppendQueryParam("format", "json");
        int userid = GetClientUserId(client);
        req.Get(OnSteamAvatarResponse, userid);
    }
}