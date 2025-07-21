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

int HexColorStringToInt(const char[] hex)
{
    int color = 0;
    int len = strlen(hex);
    for (int i = 0; i < len && i < 6; i++)
    {
        char c = hex[i];
        int value = 0;
        if (c >= '0' && c <= '9')
            value = c - '0';
        else if (c >= 'A' && c <= 'F')
            value = c - 'A' + 10;
        else if (c >= 'a' && c <= 'f')
            value = c - 'a' + 10;
        color = (color << 4) | value;
    }
    return color;
}

void SendDiscordMessageWithAvatar(int client, const char[] message)
{
    if (g_Webhook == null)
        return;

    char name[MAX_DISCORD_NAME_LENGTH];
    GetClientName(client, name, sizeof(name));
    g_Webhook.SetName(name);

    if (g_ClientAvatar[client][0] != '\0')
    {
        g_Webhook.SetAvatarUrl(g_ClientAvatar[client]);
        g_Discord.ExecuteWebhook(g_Webhook, message);
    }
    else
    {
        // Queue message if avatar is not cached
        if (g_PendingMessages[client] == null)
        {
            g_PendingMessages[client] = new ArrayList(256);
        }
        g_PendingMessages[client].PushString(message);

        // Start async fetch if not already fetching (indicated by empty cache)
        char steamId[32];
        GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId));
        int userid = GetClientUserId(client);

        HTTPRequest req = new HTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/");
        req.AppendQueryParam("key", g_SteamAPIKey);
        req.AppendQueryParam("steamids", steamId);
        req.AppendQueryParam("format", "json");
        req.Get(OnSteamAvatarResponse, userid);
    }
}

void GenerateColorHexFromName(const char[] name, char[] hex, int hexLen)
{
    int hash = 5381;
    for (int i = 0; name[i] != '\0'; i++)
        hash = ((hash << 5) + hash) + name[i]; // djb2

    int r = ((hash >> 16) & 0x7F) + 64;
    int g = ((hash >> 8) & 0x7F) + 64;
    int b = (hash & 0x7F) + 64;

    Format(hex, hexLen, "%02X%02X%02X", r, g, b);
}

bool ShouldHideCommandPrefix(const char[] msg)
{
    char prefixList[256];
    strcopy(prefixList, sizeof(prefixList), g_HideCommandPrefix);
    int len = strlen(prefixList);
    int start = 0;
    for (int i = 0; i <= len; i++)
    {
        if (prefixList[i] == ',' || prefixList[i] == '\0')
        {
            if (i > start)
            {
                char prefix[32];
                int plen = i - start;
                if (plen >= sizeof(prefix)) plen = sizeof(prefix) - 1;
                strcopy(prefix, sizeof(prefix), prefixList[start]);
                prefix[plen] = '\0';
                if (prefix[0] != '\0' && StrContains(msg, prefix, false) == 0)
                    return true;
            }
            start = i + 1;
        }
    }
    return false;
}