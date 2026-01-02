static const int g_ItemQualityColors[] =
{
    0xB2B2B2, // Normal
    0x4D7455, // Genuine
    0x8D834B, // Customized
    0x476291, // Vintage has to stay at 3 for backwards compatibility
    0x70550F, // Well-Designed
    0x8650AC, // Unusual
    0xFFD700, // Unique
    0x70B04A, // Community
    0xA50F79, // Valve / Developer
    0x70B04A, // Self-Made
    0x8D834B, // Customized
    0xCF6A32, // Strange
    0x8650AC, // Completed
    0x38F3AB, // Haunted
    0xAA0000, // Collector's
    0xFAFAFA  // Decorated
};

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
    public int GetPopFileName(char[] buffer, int maxlen)
    {
        if (this.index == -1) return 0;

        char name[128];
        GetEntPropString(this.index , Prop_Send, "m_iszMvMPopfileName", name, sizeof(name));
        return strcopy(buffer, maxlen, name[19]);
    }
}

public void Event_ItemFound(Event event, const char[] name, bool dontBroadcast)
{
    int itemdef = event.GetInt("itemdef"),
        player  = event.GetInt("player"),
        method  = event.GetInt("method"),
        quality = event.GetInt("quality");

    HTTPRequest req = new HTTPRequest("https://api.steampowered.com/IEconItems_440/GetSchemaItems/v1/");
    req.AppendQueryParam("key", "%s", g_SteamWebAPIKey);
    req.AppendQueryParam("start", "%d", itemdef);

    DataPack pack = new DataPack();
    pack.WriteCell(player);
    pack.WriteCell(method);
    pack.WriteCell(quality);

    req.Get(HTTPResponse_ItemFound, pack);
}

public void HTTPResponse_ItemFound(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    int client  = pack.ReadCell(),
        method  = pack.ReadCell(),
        quality = pack.ReadCell();
    delete pack;

    // HTTP
    if (response.Status != HTTPStatus_OK || response.Data == null)
        return;

    JSONObject root = view_as<JSONObject>(response.Data);
    JSONObject result = view_as<JSONObject>(root.Get("result"));
    JSONArray items = view_as<JSONArray>(result.Get("items"));
    JSONObject item = view_as<JSONObject>(items.Get(0));

    char itemName[DISCORD_TITLE_LENGTH], image_url_large[256], used_by_classes[DISCORD_DESC_LENGTH];
    item.GetString("name", itemName, sizeof(itemName));
    item.GetString("image_url_large", image_url_large, sizeof(image_url_large));

    JSONArray classes = view_as<JSONArray>(item.Get("used_by_classes"));
    int count = classes.Length;

    char class[64];
    for (int i = 0; i < count; i++)
    {
        classes.GetString(i, class, sizeof(class));
        char formatted[128];
        Format(formatted, sizeof(formatted), "- [%s](https://wiki.teamfortress.com/wiki/%s)\n", class, class);
        StrCat(used_by_classes, sizeof(used_by_classes), formatted);
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
    
    char itemMethod[DISCORD_TITLE_LENGTH];
    switch (method)
    {
        case 0:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_dropped", LANG_SERVER);
        }
        case 1:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_crafted", LANG_SERVER);
        }
        case 2:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_traded", LANG_SERVER);
        }
        case 3:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_purchased", LANG_SERVER);
        }
        case 4:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_found_in_crate", LANG_SERVER);
        }
        case 5:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_gifted", LANG_SERVER);
        }
        case 6:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_support", LANG_SERVER);
        }
        case 7:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_promotion", LANG_SERVER);
        }
        case 8:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_earned", LANG_SERVER);
        }
        case 9:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_refunded", LANG_SERVER);
        }
        case 13:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_preview_item", LANG_SERVER);
        }
        case 14:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_preview_item_purchased", LANG_SERVER);
        }
        case 15:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_periodic_score_reward", LANG_SERVER);
        }
        case 18:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_holiday_gift", LANG_SERVER);
        }
        case 19:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_community_market_purchase", LANG_SERVER);
        }
        case 20:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_recipe_output", LANG_SERVER);
        }
        case 22:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_quest_output", LANG_SERVER);
        }
        case 23:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_quest_loaner", LANG_SERVER);
        }
        case 24:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_trade_up", LANG_SERVER);
        }
        case 25:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_quest_merasmission_output", LANG_SERVER);
        }
        case 26:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_viral_competitive_beta_pass_spread", LANG_SERVER);
        }
        case 27:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_blood_money_purchase", LANG_SERVER);
        }
        case 28:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_paint_kit", LANG_SERVER);
        }
        default:
        {
            Format(itemMethod, sizeof(itemMethod), "%T", "item_found_method_dropped", LANG_SERVER);
        }
    }
    
    embed.SetTitle(itemMethod);
    embed.AddField(itemName, used_by_classes, true);
    embed.SetThumbnail(image_url_large);
    embed.SetFooter(steamID2, footerIcon);
    if (quality >= 0 && quality < sizeof(g_ItemQualityColors))
        embed.Color = g_ItemQualityColors[quality];
    else
        embed.Color = 0xB2B2B2;

    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
    if (channelID[0] != '\0')
        g_Discord.SendMessageEmbed(channelID, "", embed);

    delete embed;
}