# [ANY] Discord Redux | x64 support ~ IN ALPHA‼
Rewrite and continuation of [Discord Relay](https://github.com/Heapons/sp-discordrelay).
> [!NOTE]
> This plugin has only been developed in [Team Fortress 2](https://store.steampowered.com/app/440/Team_Fortress_2/); but pull requests to extend support for other games are VERY MUCH welcome!

### [See the TO-DO list here‼](https://github.com/orgs/Serider-Lounge/projects/3)

## How to install?
### Stable
- Go to [Releases](https://github.com/Serider-Lounge/SRCDS-Discord-Redux/releases).
  - `discord_redux.smx` goes in `addons/sourcemod/plugins/`.
  - ` discord_redux.phrases.txt` goes in `addons/sourcemod/translations/`.
### Developmental
- Go to [Actions](https://github.com/Serider-Lounge/SRCDS-Discord-Redux/actions/workflows/compile.yml).
- Click on the latest ✅.
- Download the package under **Artifacts**.
  - Extract it in `addons/sourcemod/`.
> [!NOTE]
> If the packages have been expired, run the workflow again.

## Dependencies
- [sm-ext-discord](https://github.com/ProjectSky/sm-ext-discord/actions)
  - ⚠ If you're on Linux, it's recommended to download the **Debian 12** package to prevent errors. 
- [ripext](https://github.com/ErikMinekus/sm-ripext/releases)
- [SteamWorks](https://github.com/KyleSanderson/SteamWorks/releases)
  - If you're on **64-bits**, get it from [this fork](https://github.com/irql-notlessorequal/SteamWorks/actions) instead.
- [multicolors](https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/multicolors.inc) (Compile-only)

## Features (so far)
- Chat is relayed between Server and Discord in both ways.
  - Steam avatars are also displayed.
- Server commands can be executed from a Discord channel (RCON).
- Map Status.
  - Can be called through `!map` or `!status`.
  - Previous/Current map.
  - Player Count (+ Bots).
- **[TOGGLE]** Show usernames or display names in **Discord→Server** messages.
- **[TOGGLE]** Parse color tags (or not, in case you want to prevent griefing).
  - Mostly useful for those who use [Chat Processor](https://github.com/KeithGDR/chat-processor) like me.
- **[TOGGLE]** Randomize name colors in **Discord→Server** messages.
  - Implemented it for readability as per requested.
- Hide things:
  - **[TOGGLE]** Team chat.
  - **[TOGGLE]** Command prefixes.
  - **[REGEX]** Filter keywords/-phrases.

## Discord Commands (prefixed with `!`)
### General
- `map`, `status`
    - Displays `Current Map` embed.
### Team Fortress 2
- `scoreboard`
    - Displays an embed containing a list of players and what teams they are on.

## ConVars

| Name | Description |
|------|-------------|
|`discord_bot_token`|Discord bot token.<br>- See: [https://discord.com/developers/applications/`<bot_userid>`/bot](https://discord.com/developers/applications/)</br> |
|`discord_channel_id`|Discord channel ID to relay messages.|
|`discord_relay_server_to_discord`|Relay server chat to Discord.|
|`discord_relay_discord_to_server`|Relay Discord chat to server.|
|`discord_webhook_url`|Discord webhook URL for relaying server chat to Discord.|
|`discord_staff_webhook_url`|Discord webhook URL for staff messages/alerts.<br>\*For the moment, this is only useful for the word filter.|
|`discord_username_mode`|Use Discord display name instead of username.<br>(0 = username \| 1 = display name).|
|`discord_steam_api_key`|Steam Web API Key for fetching user avatars.<br>- See: https://steamcommunity.com/dev/apikey</br> |
|`discord_allow_color_tags`|Allow [color tags](https://www.doctormckay.com/morecolors.php) to be parsed (requires `discord_relay_discord_to_server`).|
|`discord_footer_server_ip`|Show server public IP in embed footer.<br>\*`hostip` has to be set.|
|`discord_footer_icon`|Footer icon URL for Discord embeds.|
|`discord_randomize_name_colors`|Randomize Discord user name colors.|
|`discord_show_team_chat`|Relay team chat to Discord (requires `discord_relay_server_to_discord`).|
|`discord_word_blacklist`|Blacklist words using a [regex pattern](https://regex101.com/).|
|`discord_hide_command_prefix`|Hide specified command prefixes on Discord (separated by commas).|
|`discord_rcon_channel_id`|Discord channel ID for RCON messages.|
|`discord_embed_current_map_color`|Embed color for current map embeds.|
|`discord_embed_previous_map_color`|Embed color for previous map embeds.|
|`discord_embed_join_color`|Embed color for join embeds.|
|`discord_embed_leave_color`|Embed color for leave embeds.|
|`discord_embed_kick_color`|Embed color for kick embeds.|
|`discord_embed_ban_color`|Embed color for ban embeds.|
|`discord_embed_console_color`|Embed color for console messages.|
|`discord_embed_scoreboard_color`|Embed color for the scoreboard.|
|`discord_redux_version`|Discord Redux version.|
> [!WARNING]
> Only give access to the RCON channel to ***trusted*** individuals‼

## QNA
### Why does **Discord → Server** not work❓
- You need to configure these in `cfg/sourcemod/discord_redux.cfg`: 
    - Set up a [Discord bot](https://discord.com/developers/applications/) and copy its token.
    - Enable [Developer Mode](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID#h_01HRSTXPS5CRSRTWYCGPHZQ37H) and copy the [channel id](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID#h_01HRSTXPS5FMK2A5SMVSX4JW4E).

### Why does **Server → Discord** not work❓
You need to set up a [Discord Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) in the channel that will be used as a relay.

### Why don't Player Avatars not show up❓
You need to register your [Steam Web API Key](https://steamcommunity.com/dev/apikey).
> [!NOTE]
> A player's avatar is cached once they join the server.

### Why using `!` commands instead of Discord slash commands❓
Because I haven't figured them out yet.