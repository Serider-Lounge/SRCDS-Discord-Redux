#undef REQUIRE_EXTENSIONS
#include <accelerator>

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

    int pos = StrContains(title, "Crash ID: ");
    char crashID[16];
    if (pos != -1)
    {
        pos += strlen("Crash ID: ");
        int i = 0;
        // Copy 4 chars
        for (int k = 0; k < 4 && title[pos] != '\0'; k++)
            crashID[i++] = title[pos++];
        // Skip dash
        if (title[pos] == '-') pos++;
        // Copy next 4 chars
        for (int k = 0; k < 4 && title[pos] != '\0'; k++)
            crashID[i++] = title[pos++];
        // Skip dash
        if (title[pos] == '-') pos++;
        // Copy next 4 chars
        for (int k = 0; k < 4 && title[pos] != '\0'; k++)
            crashID[i++] = title[pos++];
        crashID[i] = '\0';

        char url[64];
        Format(url, sizeof(url), "https://crash.limetech.org/%s", crashID);
        embed.SetUrl(url);
    }

    embed.Color = 0xFF0000;

    g_AcceleratorWebhook.ExecuteEmbed("", embed);
    delete embed;
}