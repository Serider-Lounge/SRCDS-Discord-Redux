#include <discord>
#include <accelerator>
#include <regex>

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
    char title[DISCORD_TITLE_LENGTH];
    Accelerator_GetCrashHTTPResponse(0, title, sizeof(title));

    DiscordEmbed embed = new DiscordEmbed();
    embed.SetTitle(title);

    char crashID[16];
    Regex regex = new Regex("[A-Z0-9]{4}(?:-[A-Z0-9]{4}){2}");
    if (regex && regex.Match(title) > 0)
    {
        regex.GetSubString(0, crashID, sizeof(crashID));
        ReplaceString(crashID, sizeof(crashID), "-", "");
        char url[64];
        Format(url, sizeof(url), "https://crash.limetech.org/%s", crashID);
        embed.SetUrl(url);
    }
    delete regex;

    embed.Color = 0xFF0000;

    g_AcceleratorWebhook.ExecuteEmbed("", embed);
    delete embed;
}