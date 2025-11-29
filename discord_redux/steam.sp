char g_SteamAvatar[MAXPLAYERS][256];

public void GetClientAvatar(int client, const char[] steamAPIKey, char[] buffer, int maxlen)
{
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
    if (players.Length == 0)
    {
        delete root;
        delete responseObj;
        return;
    }

    JSONObject player = view_as<JSONObject>(players.Get(0));
    char avatarUrl[256];
    if (!player.GetString("avatarfull", avatarUrl, sizeof(avatarUrl)))
    {
        delete player;
        delete players;
        delete responseObj;
        delete root;
        return;
    }
    strcopy(g_SteamAvatar[client], sizeof(g_SteamAvatar[]), avatarUrl);

    delete player;
    delete players;
    delete responseObj;
    delete root;
}