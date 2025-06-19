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

// Re-fetch Steam Avatars for all connected clients
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