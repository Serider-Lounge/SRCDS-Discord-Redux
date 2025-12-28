public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
    char channelID[SNOWFLAKE_SIZE];
    g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
    
    // Relay console messages (server say)
    if (!client && g_ConVars[relay_console_messages].BoolValue)
    {
        DiscordEmbed embed = new DiscordEmbed();
        embed.SetDescription(sArgs);

        char hexColor[8];
        g_ConVars[embed_console_color].GetString(hexColor, sizeof(hexColor));
        int color = StringToInt(hexColor, 16);
        embed.Color = color;

        
        g_Discord.SendMessageEmbed(channelID, "", embed);
        delete embed;
        return;
    }

    if (StrEqual(command, "say_team") && !g_ConVars[show_team_chat].BoolValue)
        return;

    if (!IsClientInGame(client) || IsFakeClient(client))
        return;

    // Hide command prefixes
    char commandPrefixes[64];
    g_ConVars[hide_command_prefix].GetString(commandPrefixes, sizeof(commandPrefixes));

    int len = strlen(commandPrefixes);
    int start = 0;
    for (int i = 0; i <= len; i++)
    {
        if (commandPrefixes[i] == ',' || commandPrefixes[i] == '\0')
        {
            int prefixLen = i - start;
            if (prefixLen > 0)
            {
                char prefix[16];
                strcopy(prefix, sizeof(prefix), commandPrefixes[start]);
                prefix[prefixLen] = '\0';

                char pattern[32];
                Format(pattern, sizeof(pattern), "^%s", prefix);

                Regex regex = new Regex(pattern);
                if (regex.Match(sArgs) > 0)
                {
                    delete regex;
                    return;
                }
                delete regex;
            }
            start = i + 1;
        }
    }

    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char playerName[MAX_DISCORD_NAME_LENGTH];
    GetClientName(client, playerName, sizeof(playerName));

    char content[MAX_DISCORD_MESSAGE_LENGTH];
    Format(content, sizeof(content), "%T", "discord_redux_message_format", client, sArgs, playerName, steamID, "", "");

    if (g_Discord != null && g_Discord.IsRunning && g_ChatWebhook != null)
    {
        char webhookURL[256];
        g_ConVars[chat_webhook_url].GetString(webhookURL, sizeof(webhookURL));

        Regex threadID = new Regex("\\?thread_id=([0-9]+)");
        if (threadID.Match(webhookURL) > 0)
        {
            JSONObject body = new JSONObject();
            body.SetString("content", content);
            body.SetString("username", playerName);
            body.SetString("avatar_url", g_ClientAvatar[client]);

            HTTPRequest req = new HTTPRequest(webhookURL);
            req.SetHeader("Content-Type", "application/json");
            req.Post(body, HTTPResponse_OnClientSayCommand_Post);

            delete body;
        }
        else
        {
            g_ChatWebhook.SetName(playerName);
            g_ChatWebhook.SetAvatarUrl(g_ClientAvatar[client]);
            g_ChatWebhook.Execute(content);
        }
        delete threadID;
    }
}

public void HTTPResponse_OnClientSayCommand_Post(HTTPResponse response, any data)
{
    if (response.Status != HTTPStatus_OK && response.Status != HTTPStatus_NoContent)
    {
        LogError("[Discord Redux | OnClientSayCommand_Post()] HTTP Status: %d", response.Status);
    }
}

public void OnClientAuthorized(int client)
{
    if (client > 0 && !IsFakeClient(client))
    {
        GetClientAvatar(client, g_SteamWebAPIKey, Callback_OnClientAvatarFetched);
    }
}

public void Callback_OnClientAvatarFetched(int client, const char[] url, any data)
{
    strcopy(g_ClientAvatar[client], sizeof(g_ClientAvatar[]), url);
}

public void OnClientPutInServer(int client)
{
    if (!g_Discord || !g_ChatWebhook)
        return;

    if (IsFakeClient(client) || !g_Discord.IsRunning)
        return;

    Embed_PlayerStatus(client);
}

public void OnClientDisconnect(int client)
{
    if (!g_Discord || !g_ChatWebhook)
        return;

    if (IsFakeClient(client) || !g_Discord.IsRunning)
        return;

    Embed_PlayerStatus(client, true);
}

public void OnClientDisconnect_Post(int client)
{
    g_ClientAvatar[client][0] = '\0';
    g_IsClientBanned[client] = false;
}

public Action OnBanClient(int client, int time, int flags, const char[] reason, const char[] kick_message, const char[] command, any source)
{
    g_IsClientBanned[client] = true;
    return Plugin_Continue;
}