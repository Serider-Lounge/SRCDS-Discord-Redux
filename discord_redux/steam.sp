char g_SteamAvatar[MAXPLAYERS][256];

public void GetClientAvatar(int client, const char[] steamAPIKey)
{
    if (g_SteamAvatar[client][0] != '\0') return;

    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char url[256];
    Format(url, sizeof(url), "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s", steamAPIKey, steamID);

    HTTPRequest req = new HTTPRequest(url);
    req.Get(GetClientAvatar_Post, client);
}

public void GetClientAvatar_Post(HTTPResponse response, int client)
{
    if (response.Status != HTTPStatus_OK) return;

    JSON data = response.Data;
    if (data == null) return;

    JSONObject root = view_as<JSONObject>(data);
    JSONObject responseObj = view_as<JSONObject>(root.Get("response"));
    JSONArray players = view_as<JSONArray>(responseObj.Get("players"));
    JSONObject player = view_as<JSONObject>(players.Get(0));
    
    char avatarUrl[256];
    if (player.GetString("avatarfull", avatarUrl, sizeof(avatarUrl)))
    {
        Format(g_SteamAvatar[client], sizeof(g_SteamAvatar[]), avatarUrl);
        PrintToServer("[Discord Redux] Retrieved avatar for %N: %s", client, g_SteamAvatar[client]);
    }

    char steamID64[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64));
    if (g_ConVars[anonymous_pfp].BoolValue)
    {
        int uniqueColor = StringToInt(steamID64) & 0xFFFFFF;
        char coloredSquare[256];
        Format(coloredSquare, sizeof(coloredSquare), "https://dummyimage.com/184/%d/%d.png", uniqueColor, uniqueColor);
        Format(g_SteamAvatar[client], sizeof(g_SteamAvatar[]), "%s", coloredSquare);
    }

    OnSteamAvatarReady(client);

    delete player;
    delete players;
    delete responseObj;
    delete root;
}