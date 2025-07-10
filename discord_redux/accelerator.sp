#tryinclude <accelerator>

public void OnCrashUpdated(int num, const char[] crashId)
{
    if (g_Discord == null || g_DiscordChannelId[0] == '\0')
        return;

    char url[128];
    Format(url, sizeof(url), "https://crash.limetech.org/%s", crashId);

    DiscordEmbed embed = new DiscordEmbed();

    char title[DISCORD_TITLE_LENGTH];
    char description[DISCORD_DESC_LENGTH];
    Format(title, sizeof(title), "%T", "Crash Report Title", LANG_SERVER);
    Format(description, sizeof(description), "%T", "Crash Report Description", LANG_SERVER, crashId, crashId);

    embed.SetTitle(title);
    embed.SetDescription(description);
    embed.SetColor(0xED4245);

    g_Discord.SendMessageEmbed(g_DiscordChannelId, "", embed);
    delete embed;
}
