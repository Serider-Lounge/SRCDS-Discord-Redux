# [ANY] Discord Redux | x64 support‼
Rewrite and continuation of [Discord Relay](https://github.com/Heapons/sp-discordrelay).
> ![NOTE]
> This plugin has been developed in [Team Fortress 2](https://store.steampowered.com/app/440/Team_Fortress_2/); but pull requests to support other games are VERY MUCH welcome!

## Dependencies
- [sm-ext-discord](https://github.com/ProjectSky/sm-ext-discord)
- [ripext](https://github.com/ErikMinekus/sm-ripext)

## Discord Commands (prefixed with `!`)
### General
- `map` or `status`.
    - Displays `Current Map` embed.
### Team Fortress 2
- `scoreboard`
    - Displays an embed containing a list of players and what teams they are on.

## ConVars

|Name|Description|
|----|-----------|
|`discord_bot_token`|Discord bot token.<br>> See: [https://discord.com/developers/applications/`<bot_userid>`/bot](https://discord.com/developers/applications/)</br>|
|`discord_channel_id`|Discord channel ID to relay messages.|
|`discord_relay_server_to_discord`|Relay server chat to Discord.|
|`discord_relay_discord_to_server`|Relay Discord chat to server.|
|`discord_webhook_url`|Discord webhook URL for relaying server chat to Discord.|
|`discord_username_mode`|Use Discord display name instead of username (0 = username, 1 = display name).|
|`discord_steam_api_key`|Steam Web API Key for fetching user avatars.<br>> See: https://steamcommunity.com/dev/apikey</br>|
|`discord_redux_version`|Discord Redux version.|

## QNA
### Why does **Discord → Server** not work❓
- You need to configure these in `cfg/discord_redux.cfg`: 
    - Set up a [Discord bot](https://discord.com/developers/applications/) and copy its token.
    - Enable [Developer Mode](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID#h_01HRSTXPS5CRSRTWYCGPHZQ37H) and copy the [channel id](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID#h_01HRSTXPS5FMK2A5SMVSX4JW4E).

### Why does **Server → Discord** not work❓
You need to set up a [Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) in the channel that will be used as a relay.

### Why don't Player Avatars not show up❓
You need to register your [Steam Web API Key](https://steamcommunity.com/dev/apikey).
> ![NOTE]
> Avatars are only cached once on player join‼

### `/lib/x86_64-linux-gnu/libc.so.6: version 'GLIBC_2.38' not found`
As far as my (albeit, limited) Linux knowledge goes, you need to be the latest version of your distro.
> ![WARNING]
> Untested on Windows‼

### Why using `!` commands instead of Discord slash commands❓
Because I haven't figured them out yet. It's that simple. 😅