public void RTD2_Rolled(int client, RTDPerk perk, int iDuration)
{
	if (!g_IsRTDLoaded || !g_ConVars[rtd_enabled].BoolValue)
		return;

	char channelID[SNOWFLAKE_SIZE];
	g_ConVars[chat_channel_id].GetString(channelID, sizeof(channelID));
	if (channelID[0] == '\0')
		return;

	char playerName[MAX_NAME_LENGTH];
	GetClientName(client, playerName, sizeof(playerName));

    char steamID[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));
    char steamProfile[256];
    Format(steamProfile, sizeof(steamProfile), "https://steamcommunity.com/profiles/%s", steamID);

	char perkName[RTD2_MAX_PERK_NAME_LENGTH];
	perk.GetName(perkName, sizeof(perkName));

	DiscordEmbed embed = new DiscordEmbed();
	embed.SetAuthor(playerName, steamProfile, g_ClientAvatar[client]);

    char description[DISCORD_DESC_LENGTH];
    Format(description, sizeof(description), "Rolled **%s**", perkName);
	embed.SetDescription(description);
	embed.SetThumbnail("https://em-content.zobj.net/source/animated-noto-color-emoji/427/game-die_1f3b2.gif");
	embed.SetFooter("github.com/Phil25/RTD", "https://github.com/apple-touch-icon.png");

	embed.Color = 0xFFD700;

	g_Discord.SendMessageEmbed(channelID, "", embed);
	delete embed;
}