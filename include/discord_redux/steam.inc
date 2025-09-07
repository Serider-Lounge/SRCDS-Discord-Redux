DiscordWebhook g_PendingWebhooks[MAXPLAYERS];
char g_PendingDiscordMessages[MAXPLAYERS][MAX_MESSAGE_LENGTH];
char g_SteamAvatar[MAXPLAYERS][256];

public void GetClientAvatar(int client, const char[] steamAPIKey)
{
    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char url[256];
    Format(url, sizeof(url), "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s", steamAPIKey, steamID);

    HTTPRequest req = new HTTPRequest(url);
    req.Get(GetClientAvatar_Callback, client);
}

public void GetClientAvatar_Callback(HTTPResponse response, int client)
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

    // Store the avatar URL in g_SteamAvatar
    strcopy(g_SteamAvatar[client], sizeof(g_SteamAvatar[]), avatarUrl);

    // Notify main plugin that avatar is ready
    OnClientAvatarRetrieved(client);

    delete player; delete players; delete responseObj; delete root;
}

public void ClientSayWithAvatar(int client, const char[] apiKey, DiscordWebhook webhook, const char[] message)
{
    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char url[256];
    Format(url, sizeof(url), "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s", apiKey, steamID);

    strcopy(g_PendingDiscordMessages[client], sizeof(g_PendingDiscordMessages[]), message);
    g_PendingWebhooks[client] = webhook;

    HTTPRequest req = new HTTPRequest(url);
    req.Get(ClientSayWithAvatar_Callback, client);
}

public void ClientSayWithAvatar_Callback(HTTPResponse response, int client)
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

    DiscordWebhook webhook = g_PendingWebhooks[client];
    webhook.SetAvatarUrl(avatarUrl);

    // Send the message after avatar is set
    webhook.Execute(g_PendingDiscordMessages[client]);

    delete player; delete players; delete responseObj; delete root;
}