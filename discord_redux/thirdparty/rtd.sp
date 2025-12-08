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
	PrintToServer("[Discord Redux | DEBUG] %N rolled perk: %s", client, perkName);

	DiscordEmbed embed = new DiscordEmbed();
	embed.SetAuthor(playerName, steamProfile, g_ClientAvatar[client]);

    char description[DISCORD_DESC_LENGTH];
    Format(description, sizeof(description), "Rolled **%s**", perkName);
	embed.SetDescription(description);

	embed.Color = StringToInt(steamID);

	g_Discord.SendMessageEmbed(channelID, "", embed);
	delete embed;
}