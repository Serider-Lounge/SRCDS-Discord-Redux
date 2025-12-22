typedef AvatarQueryCallback = function void (int client, const char[] url, any data);

/**
 * Make an HTTP request to the Steam API to get the client's avatar URL.
 * 
 * @param client      The client index.
 * @param callback    The function to call when the avatar URL is fetched.
 */
stock void GetClientAvatar(int client, const char[] key, AvatarQueryCallback callback, any data = 0)
{
    if (client <= 0) return;

    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/");
    req.AppendQueryParam("key", "%s", key);
    req.AppendQueryParam("steamids", "%s", steamID);

    DataPack pack = new DataPack();
    pack.WriteFunction(callback);
    pack.WriteCell(client);
    pack.WriteCell(data);

    req.Get(HTTPResponse_GetClientAvatar, pack);
}

/**
 * Callback function to handle the HTTP response for GetClientAvatar().
 * 
 * @param response The HTTP response.
 * @param pack     DataPack containing callback, client, data.
 */
stock void HTTPResponse_GetClientAvatar(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    Function callback = pack.ReadFunction();
    int client = pack.ReadCell();
    any data = pack.ReadCell();
    delete pack;

    char avatarfull[256] = "https://avatars.steamstatic.com/b5bd56c1aa4644a474a2e4972be27ef9e82e517e_full.jpg";
    if (response.Status == HTTPStatus_OK && response.Data != null)
    {
        JSONObject root = view_as<JSONObject>(response.Data);
        JSONObject responseObj = view_as<JSONObject>(root.Get("response"));
        JSONArray players = view_as<JSONArray>(responseObj.Get("players"));
        if (players.Length > 0)
        {
            JSONObject player = view_as<JSONObject>(players.Get(0));
            player.GetString("avatarfull", avatarfull, sizeof(avatarfull));
            delete player;
        }
        delete players;
        delete responseObj;
        delete root;
    }

    Call_StartFunction(INVALID_HANDLE, callback);
    Call_PushCell(client);
    Call_PushString(avatarfull);
    Call_PushCell(data);
    Call_Finish();
}