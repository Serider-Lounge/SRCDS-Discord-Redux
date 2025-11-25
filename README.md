# [ANY] Discord Redux | x64 support ~ (still) IN ALPHA‼
Rewrite and continuation of [Discord Relay](https://github.com/Heapons/sp-discordrelay).
> [!NOTE]
> This plugin has only been developed in [<img src="https://cdn.fastly.steamstatic.com/steamcommunity/public/images/apps/440/033bdd91842b6aca0633ee1e5f3e6b82f2e8962f.ico" width="16" height="16" style="vertical-align: text-bottom;"> **Team Fortress 2**](https://store.steampowered.com/app/440) and [<img src="https://cdn.fastly.steamstatic.com/steamcommunity/public/images/apps/550/1a8d50f6078b5d023582ea1793b0e53813d57b7f.ico" width="16" height="16" style="vertical-align: text-bottom;"> **Left 4 Dead 2**](https://store.steampowered.com/app/550); but pull requests to extend support for other games are VERY MUCH welcome!

## Dependencies
- [sm-ext-discord](https://github.com/ProjectSky/sm-ext-discord/actions)
  - ⚠ If you're on Linux, it's recommended to download the **Ubuntu 22.04** package to prevent errors. 
- [ripext](https://github.com/ErikMinekus/sm-ripext/releases)
- [SteamWorks](https://github.com/KyleSanderson/SteamWorks/releases)
  - If you're on **64-bits**, get it from [this fork](https://github.com/irql-notlessorequal/SteamWorks/actions) instead.
- [multicolors](https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/multicolors.inc) (Compile-only)

## How to install?
- Go to [Actions](https://github.com/Serider-Lounge/SRCDS-Discord-Redux/actions/workflows/compile.yml).
- Click on the latest ✅.
- Download the package under **Artifacts**.
  - Extract it in `<modname>/addons/sourcemod/` (e.g. `tf/addons/sourcemod/`).
> [!NOTE]
> If the packages have been expired, run the workflow again.

## ConVars

| Name | Description |
|------|-------------|
| `discord_redux_enabled` | Toggle Discord Redux altogether. |
| `discord_redux_randomize_color_names` | Randomize Discord user name colors. |
| `discord_redux_show_team_chat` | Relay team chat to Discord (requires relay_server_to_discord). |
| `discord_redux_hide_command_prefix` | Hide specified command prefixes on Discord (separated by commas, e.g. `!,/`). |
| `discord_redux_steam_api_key` | Steam Web API Key for fetching user avatars.<br>(See: [Steam API Key](https://steamcommunity.com/dev/apikey)) |
| `discord_redux_workshop_path` | Path to Steam Workshop add-ons folder, relative to the game directory. |
| `discord_redux_relay_server_to_discord` | Relay server chat to Discord. |
| `discord_redux_relay_discord_to_server` | Relay Discord chat to server. |
| `discord_redux_bot_token` | Discord bot token.<br>(See: [Discord Developer Portal](https://discord.com/developers/applications/)) |
| `discord_redux_chat_channel_id` | Discord channel ID to relay messages. |
| `discord_redux_player_status_channel_id` | Discord channel ID for player join/leave messages. |
| `discord_redux_map_status_channel_id` | Discord channel ID for map status. |
| `discord_redux_guild_id` | Discord server ID. |
| `discord_redux_staff_mention` | Discord role/user mention(s) for staff alerts (leave blank to disable). |
| `discord_redux_staff_mention_cooldown` | Cooldown time in seconds between staff mentions for sm_calladmin. |
| `discord_redux_chat_webhook_url` | Discord webhook URL for relaying server chat to Discord. |
| `discord_redux_username_mode` | Use Discord display name instead of username.<br>(0 = Username | 1 = Global Name | 2 = Nickname) |
| `discord_redux_rcon_channel_id` | Discord channel ID for RCON messages. |
| `discord_redux_report_webhook_url` | Discord webhook URL for bug reports. |
| `discord_redux_embed_current_map_color` | Embed color for current map embeds. |
| `discord_redux_embed_previous_map_color` | Embed color for previous map embeds. |
| `discord_redux_embed_join_color` | Embed color for join embeds. |
| `discord_redux_embed_leave_color` | Embed color for leave embeds. |
| `discord_redux_embed_kick_color` | Embed color for kick embeds. |
| `discord_redux_embed_ban_color` | Embed color for ban embeds. |
| `discord_redux_embed_console_color` | Embed color for console messages. |
| `discord_redux_embed_scoreboard_color` | Embed color for the scoreboard. |
| `discord_redux_footer_server_ip` | Show server public IP in embed footer. |
| `discord_redux_footer_icon` | Footer icon URL for Discord embeds. |
| `discord_redux_map_thumbnail_enabled` | Show map thumbnail in map embeds. |
| `discord_redux_map_thumbnail_url` | Discord map thumbnail URL. |
| `discord_redux_map_thumbnail_format` | Discord map thumbnail format. |
| `discord_redux_invite` | Discord invite link. |
| `discord_redux_accelerator_webhook_url` | Discord webhook URL for crash reports.<br>⚠ Requires [Accelerator](https://github.com/asherkin/accelerator/actions)‼ |
| `discord_redux_version` | Discord Redux version. |
> [!WARNING]
> Only give access to the RCON channel to ***trusted*** individuals‼

> [!NOTE]
> If your game doesn't support HEX chat colors, `discord_redux_randomize_color_names` won't be available.

## QNA
### Why does **Discord → Server** not work❓
- You need to configure these in `cfg/sourcemod/discord_redux.cfg`: 
    - Set up a [Discord bot](https://discord.com/developers/applications/) and copy its token.
    - Enable [Developer Mode](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID#h_01HRSTXPS5CRSRTWYCGPHZQ37H) and copy the [channel id](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID#h_01HRSTXPS5FMK2A5SMVSX4JW4E).

### Why does **Server → Discord** not work❓
You need to set up a [Discord Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) in the channel that will be used as a relay.

### Why don't Player Avatars not show up❓
You need to register your [Steam Web API Key](https://steamcommunity.com/dev/apikey).

### Why using `!` commands instead of Discord slash commands❓
Eventually™
