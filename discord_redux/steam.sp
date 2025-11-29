char g_SteamAvatar[MAXPLAYERS][256];

public void GetClientAvatar(int client, const char[] steamAPIKey, ArrayList avatars)
{
    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char url[256];
    Format(url, sizeof(url), "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s", steamAPIKey, steamID);

    DataPack pack = new DataPack();
    pack.WriteCell(client);
    pack.WriteCell(avatars);

    HTTPRequest req = new HTTPRequest(url);
    req.Get(GetClientAvatar_Post, pack);
}

public void GetClientAvatar_Post(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    int client = pack.ReadCell();
    ArrayList avatars = view_as<ArrayList>(pack.ReadCell());
    delete pack;

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
        avatars.SetString(client, avatarUrl, sizeof(avatarUrl));
        PrintToServer("[Discord Redux] Retrieved avatar for %N: %s", client, avatarUrl);
    }

    char steamID64[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64));
    if (g_ConVars[anonymous_pfp].BoolValue)
    {
        int uniqueColor = StringToInt(steamID64) & 0xFFFFFF;
        char squareIcon[256];
        Format(squareIcon, sizeof(squareIcon), "https://dummyimage.com/184/%d/%d.png", uniqueColor, uniqueColor);
        avatars.SetString(client, squareIcon, sizeof(squareIcon));
    }

    OnClientAvatarRetrieved(client);

    delete player;
    delete players;
    delete responseObj;
    delete root;
}