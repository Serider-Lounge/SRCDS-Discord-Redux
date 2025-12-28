#include <discord>
#include <accelerator>
#include <regex>
#undef REQUIRE_EXTENSIONS
#tryinclude <ripext>

ConVar g_AcceleratorWebhookURL;
DiscordWebhook g_AcceleratorWebhook;

public Plugin myinfo = 
{
    name = "[ANY] Discord Redux | Accelerator",
    author = "Heapons",
    description = "Accelerator ⇄ Discord Relay",
    version = "25w52a",
    url = "https://github.com/Serider-Lounge/SRCDS-Discord-Redux"
};

public void OnPluginStart()
{
    g_AcceleratorWebhookURL = CreateConVar("discord_redux_accelerator_webhook_url", "", "Discord webhook URL for Accelerator crash reports.", FCVAR_PLUGIN|FCVAR_ARCHIVE);
    g_AcceleratorWebhookURL.AddChangeHook(OnConVarChanged);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_AcceleratorWebhook = new DiscordWebhook(null, newValue);
}

public void Accelerator_OnDoneUploadingCrashes()
{
    if (!g_AcceleratorWebhook)
        CreateTimer(1.0, Timer_SendAcceleratorEmbed, _, TIMER_REPEAT);
    else
        Accelerator_SendEmbed();
}

public Action Timer_SendAcceleratorEmbed(Handle timer)
{
    if (!g_AcceleratorWebhook)
        return Plugin_Continue;
    else
        Accelerator_SendEmbed();
    return Plugin_Stop;
}

public void Accelerator_SendEmbed()
{
    if (!Accelerator_IsDoneUploadingCrashes() || Accelerator_GetUploadedCrashCount() == 0)
        return;

    char title[DISCORD_TITLE_LENGTH];
    Accelerator_GetCrashHTTPResponse(0, title, sizeof(title));

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(title);

    char crashID[16], url[64];
    Regex regex = new Regex("[A-Z0-9]{4}(?:-[A-Z0-9]{4}){2}");
    if (regex && regex.Match(title) > 0)
    {
        regex.GetSubString(0, crashID, sizeof(crashID));
        ReplaceString(crashID, sizeof(crashID), "-", "");
        Format(url, sizeof(url), "https://crash.limetech.org/%s", crashID);
        embed.SetUrl(url);
    }

    embed.Color = 0xFF0000;

    char webhookURL[256];
    g_AcceleratorWebhookURL.GetString(webhookURL, sizeof(webhookURL));

    regex = new Regex("\\?thread_id=([0-9]+)");
    if (regex.Match(webhookURL) > 0)
    {
        JSONObject embedObj = new JSONObject(), body = new JSONObject();
        JSONArray embeds = new JSONArray();

        embedObj.SetString("title", title);
        embedObj.SetInt("color", 0xFF0000);
        if (url[0] != '\0') embedObj.SetString("url", url);

        embeds.Push(embedObj);
        body.Set("embeds", embeds);

        HTTPRequest req = new HTTPRequest(webhookURL);
        req.SetHeader("Content-Type", "application/json");
        req.Post(body, HTTPResponse_Accelerator);

        delete embedObj; 
        delete embeds; 
        delete body;
    }
    else
    {
        g_AcceleratorWebhook.ExecuteEmbed("", embed);
    }
    delete regex;
    delete embed;
}

public void HTTPResponse_Accelerator(HTTPResponse response, any data)
{
    if (response.Status != HTTPStatus_OK && response.Status != HTTPStatus_NoContent)
        LogError("[Discord Redux | Accelerator_SendEmbed()] HTTP Status: %d", response.Status);
}