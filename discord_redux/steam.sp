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
    strcopy(g_sClientAvatar[client], sizeof(g_sClientAvatar[]), avatarUrl);

    // Send all pending messages for this client
    if (g_PendingMessages[client] != null)
    {
        int count = g_PendingMessages[client].Length;
        for (int i = 0; i < count; i++)
        {
            char msg[256];
            g_PendingMessages[client].GetString(i, msg, sizeof(msg));
            if (StrEqual(msg, "[JOIN]"))
            {
                // Send join embed with avatar as footer icon
                char playerName[MAX_NAME_LENGTH];
                char steamId64[32];
                char steamId2[32];
                GetClientName(client, playerName, sizeof(playerName));
                bool hasSteam64 = GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64), true);
                bool hasSteam2 = GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2), true);

                char description[256];
                if (hasSteam64 && steamId64[0] != '\0')
                {
                    Format(description, sizeof(description), "%T", "Player Join", LANG_SERVER, playerName, steamId64);
                }

                DiscordEmbed embed = new DiscordEmbed();
                embed.SetDescription(description);
                embed.SetColor(0x57F287);
                if (hasSteam2 && steamId2[0] != '\0')
                    embed.SetFooter(steamId2, avatarUrl);
                else
                    embed.SetFooter("", avatarUrl);
                g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
                delete embed;
            }
            else
            {
                g_Webhook.SetAvatarUrl(avatarUrl);
                char name[MAX_DISCORD_NAME_LENGTH];
                GetClientName(client, name, sizeof(name));
                g_Webhook.SetName(name);
                g_Discord.ExecuteWebhook(g_Webhook, msg);
            }
        }
        g_PendingMessages[client].Clear();
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