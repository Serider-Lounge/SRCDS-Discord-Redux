methodmap TFResource
{
    /**
     * Constructor to create a TFResource object out of a tf_objective_resource entity.
     *
     * @param entity Entity index.
     * @return       Entity index as a TFResource object.
     */
    public TFResource(int entity)
    {
        return view_as<TFResource>(entity);
    }

    property int index
    {
        public get()
        {
            return view_as<int>(this);
        }
    }

    /**
     * Gets the name of the current MvM popfile.
     *
     * @param name      The buffer to store the popfile name.
     * @param maxlen    The maximum length of the buffer.
     * @return          The length of the popfile name, returns 0 if not found.
     */
    public int GetName(char[] buffer, int maxlen)
    {
        if (this.index == -1) return 0;

        char name[128];
        GetEntPropString(this.index , Prop_Send, "m_iszMvMPopfileName", name, sizeof(name));
        return strcopy(buffer, maxlen, name[19]);
    }
}

public void Event_ItemFound(Event event, const char[] name, bool dontBroadcast)
{
    HTTPRequest req = new HTTPRequest("https://api.steampowered.com/IEconItems_440/GetSchemaItems/v1/");
    req.AppendQueryParam("key", "%s", g_SteamWebAPIKey);
    req.AppendQueryParam("start", "%d", event.GetInt("itemdef"));

    req.Get(HTTPResponse_ItemFound, event.GetInt("player"));
}

public void HTTPResponse_ItemFound(HTTPResponse response, int client)
{
    // HTTP
    if (response.Status != HTTPStatus_OK || !response.Data) return;

    JSONObject root = view_as<JSONObject>(response.Data);
    JSONObject result = view_as<JSONObject>(root.Get("result"));
    JSONArray items = view_as<JSONArray>(result.Get("items"));
    JSONObject item = view_as<JSONObject>(items.Get(0));

    char itemName[DISCORD_TITLE_LENGTH], image_url_large[256], used_by_classes[DISCORD_DESC_LENGTH];
    item.GetString("name", itemName, sizeof(itemName));
    item.GetString("image_url", image_url_large, sizeof(image_url_large));

    JSONArray classes = view_as<JSONArray>(item.Get("used_by_classes"));
    int count = classes.Length;

    char class[64];
    for (int i = 0; i < count; i++)
    {
        classes.GetString(i, class, sizeof(class));

        Format(class, sizeof(class), "[%s](https://wiki.teamfortress.com/wiki/%s)", class, class);
        StrCat(used_by_classes, sizeof(used_by_classes), "- ");
        StrCat(used_by_classes, sizeof(used_by_classes), class);
        StrCat(used_by_classes, sizeof(used_by_classes), "\n");
    }

    delete classes;
    delete item;
    delete items;
    delete result;
    delete root;

    // Discord
    char playerName[MAX_NAME_LENGTH];
    GetClientName(client, playerName, sizeof(playerName));

    char steamID2[MAX_AUTHID_LENGTH], steamID64[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, steamID2, sizeof(steamID2));
    GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64));

    char steamProfile[256];
    Format(steamProfile, sizeof(steamProfile), "http://steamcommunity.com/profiles/%s", steamID64);

    char footerIcon[256];
    g_ConVars[footer_icon].GetString(footerIcon, sizeof(footerIcon));

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetAuthor(playerName, steamProfile, g_ClientAvatar[client]);
    embed.SetTitle(itemName);

    embed.SetDescription(used_by_classes);
    embed.SetThumbnail(image_url_large);
    embed.SetFooter(steamID2, footerIcon);
    embed.Color = StringToInt(steamID64);

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
    if (channelID[0] != '\0')
        g_Discord.SendMessageEmbed(channelID, "", embed);

    delete embed;
}