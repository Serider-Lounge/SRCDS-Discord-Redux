typedef AppDetailsCallback = function void (
    int appid,
    const char[] name,
    const char[] icon,
    any data
);

methodmap SteamApp
{
    /**
     * Stores a Steam store asset into a buffer.
     * Available assets:
     * - library_600x900
     * - library_hero
     * - page_bg_raw
     * - logo
     * - capsule_616x353
     * - page_bg_generated_v6b
     * - hero_capsule
     * - header
     * 
     * @param asset     The asset filename (without extension).
     * @param buffer    Buffer to store the full URL.
     * @param maxlen    Maximum length of the buffer.
     */
    public void GetStoreAsset(const char[] asset, char[] buffer, int maxlen)
    {
        GameInfo gameinfo;
        Format(buffer, maxlen, "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/%d/%s.jpg", gameinfo.appid, asset);
    }
}

/**
 * Queries the Steam Web API for app details.
 *
 * @param appid      The AppID to query.
 * @param key        Steam Web API key.
 * @param callback   Callback to receive app details.
 * @param data       Optional data to pass to callback.
 */
stock void Steam_GetAppDetails(int appid, const char[] key, AppDetailsCallback callback, any data = 0)
{
    HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ICommunityService/GetApps/v1/");
    req.AppendQueryParam("key", "%s", key);
    req.AppendQueryParam("appids[0]", "%d", appid);

    DataPack pack = new DataPack();
    pack.WriteFunction(callback);
    pack.WriteCell(appid);
    pack.WriteCell(data);

    req.Get(HTTPResponse_GetAppDetails, pack);
}

/**
 * Handles the HTTP response for Steam_GetAppDetails().
 * Calls the user callback with (appid, name, icon, data).
 */
stock void HTTPResponse_GetAppDetails(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    Function callback = pack.ReadFunction();
    int appid = pack.ReadCell();
    any data = pack.ReadCell();
    delete pack;

    char name[128], icon[128];

    if (response.Status == HTTPStatus_OK && response.Data != null)
    {
        JSONObject root = view_as<JSONObject>(response.Data);
        JSONObject responseObj = view_as<JSONObject>(root.Get("response"));
        JSONArray apps = view_as<JSONArray>(responseObj.Get("apps"));
        for (int i = 0; i < apps.Length; i++)
        {
            JSONObject app = view_as<JSONObject>(apps.Get(i));
            if (app.GetInt("appid") == appid)
            {
                app.GetString("name", name, sizeof(name));
                app.GetString("icon", icon, sizeof(icon));
                delete app;
                break;
            }
            delete app;
        }
        delete apps;
        delete responseObj;
        delete root;
    }

    Call_StartFunction(INVALID_HANDLE, callback);
    Call_PushCell(appid);
    Call_PushString(name);
    Call_PushString(icon);
    Call_PushCell(data);
    Call_Finish();
}