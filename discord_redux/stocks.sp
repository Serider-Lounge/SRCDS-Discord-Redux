stock bool IsValidClient(int client)
{
    return client > 0 &&
           client <= MaxClients && 
           IsClientConnected(client) && 
           !IsFakeClient(client) && 
           !IsClientSourceTV(client) && 
           IsClientInGame(client);
}

stock bool IsConsole(int client)
{
    return client == 0;
}

void SendDiscordMessageWithAvatar(int client, const char[] message)
{
    if (g_Webhook == null)
        return;

    char name[MAX_DISCORD_NAME_LENGTH];
    GetClientName(client, name, sizeof(name));
    g_Webhook.SetName(name);

    if (g_sClientAvatar[client][0] != '\0')
    {
        g_Webhook.SetAvatarUrl(g_sClientAvatar[client]);
        g_Discord.ExecuteWebhook(g_Webhook, message);
    }
    else
    {
        // Queue message if avatar is not cached
        if (g_PendingMessages[client] == null)
        {
            g_PendingMessages[client] = new ArrayList(256);
        }
        g_PendingMessages[client].PushString(message);

        // Start async fetch if not already fetching (indicated by empty cache)
        char steamId[32];
        GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId));
        int userid = GetClientUserId(client);

        HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/");
        req.AppendQueryParam("key", g_SteamAPIKey);
        req.AppendQueryParam("steamids", steamId);
        req.AppendQueryParam("format", "json");
        req.Get(OnSteamAvatarResponse, userid);
    }
}