typedef WorkshopDetailsCallback = function void (
    const char[] ugcid,
    const char[] title,
    const char[] preview_url,
    const char[] creator,
    const char[][] tags,
    int numTags,
    any data
);

methodmap Workshop < StringMap
{
    public Workshop(const char[] mapName)
    {
        StringMap bsp = new StringMap();

        bsp.SetString("map", mapName); 

        return view_as<Workshop>(bsp);
    }

    /**
     * Gets the UGC ID of the workshop map as a string.
     * 
     * @param buffer Buffer to store UGC ID string.
     * @param maxlen Maximum length of buffer.
     * @return       True if UGC ID was found, false otherwise.
     */
    public bool GetUgcID(char[] buffer, int maxlen)
    {
        char workshopPath[128];
        GameInfo gameinfo;
        Format(workshopPath, sizeof(workshopPath), "../steamapps/workshop/content/%d", gameinfo.appid);

        DirectoryListing dir = OpenDirectory(workshopPath);
        if (dir == null) return false;

        char entry[PLATFORM_MAX_PATH];
        FileType fileType;

        while (dir.GetNext(entry, sizeof(entry), fileType))
        {
            if (fileType != FileType_Directory)
                continue;

            char mapName[96];
            this.GetString("map", mapName, sizeof(mapName));
            char mapFile[PLATFORM_MAX_PATH];
            Format(mapFile, sizeof(mapFile), "%s/%s/%s.bsp", workshopPath, entry, mapName);
            if (FileExists(mapFile))
            {
                strcopy(buffer, maxlen, entry);
                delete dir;
                return true;
            }
        }
        delete dir;
        return false;
    }

    /**
     * Makes an HTTP request to get details about the workshop map.
     * @param callback    Callback to receive details.
     */
    public void GetDetails(const char[] ugcid, WorkshopDetailsCallback callback, any data = 0)
    {
        HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/");
        req.AppendFormParam("itemcount", "1");
        req.AppendFormParam("publishedfileids[0]", ugcid);

        DataPack pack = new DataPack();
        pack.WriteFunction(callback);
        pack.WriteString(ugcid);
        pack.WriteCell(data);

        req.PostForm(HTTPResponse_GetWorkshopDetails, pack);
    }
}

/**
 * Callback function to handle the HTTP response for Workshop.GetDetails().
 * Calls the user callback with (ugcid, title, preview_url, creator, tags, numTags, data).
 */
stock void HTTPResponse_GetWorkshopDetails(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    Function callback = pack.ReadFunction();
    char ugcid[PLATFORM_MAX_PATH];
    pack.ReadString(ugcid, sizeof(ugcid));
    any data = pack.ReadCell();
    delete pack;

    char title[256], preview_url[256], creator[64];
    char tags[16][64];
    int numTags = 0;

    if (response.Status == HTTPStatus_OK && response.Data != null)
    {
        JSONObject root = view_as<JSONObject>(response.Data);
        JSONObject responseObj = view_as<JSONObject>(root.Get("response"));
        JSONArray details = view_as<JSONArray>(responseObj.Get("publishedfiledetails"));
        if (details.Length > 0)
        {
            JSONObject detail = view_as<JSONObject>(details.Get(0));
            detail.GetString("title", title, sizeof(title));
            detail.GetString("preview_url", preview_url, sizeof(preview_url));
            detail.GetString("creator", creator, sizeof(creator));

            JSONArray tagsArray = view_as<JSONArray>(detail.Get("tags"));
            numTags = tagsArray.Length < sizeof(tags) ? tagsArray.Length : sizeof(tags);
            for (int i = 0; i < numTags; i++)
            {
                JSONObject tagObj = view_as<JSONObject>(tagsArray.Get(i));
                tagObj.GetString("tag", tags[i], sizeof(tags[]));
                delete tagObj;
            }
            delete tagsArray;
            delete detail;
        }
        delete details;
        delete responseObj;
        delete root;
    }
    else
    {
        strcopy(preview_url, sizeof(preview_url), "https://community.cloudflare.steamstatic.com/public/images/sharedfiles/steam_workshop_default_image.png");
    }

    Call_StartFunction(INVALID_HANDLE, callback);
    Call_PushString(ugcid);
    Call_PushString(title);
    Call_PushString(preview_url);
    Call_PushString(creator);
    Call_PushArray(tags, sizeof(tags));
    Call_PushCell(numTags);
    Call_PushCell(data);
    Call_Finish();
}