#if defined _discord_included_
  #endinput
#endif
#define _discord_included_

#define MAX_DISCORD_MESSAGE_LENGTH       2001
#define MAX_DISCORD_NITRO_MESSAGE_LENGTH 4001
#define SNOWFLAKE_SIZE                   20
#define MAX_DISCORD_NAME_LENGTH          33
#define MAX_DISCORD_PRESENCE_LENGTH      129
#define MAX_DISCORD_CHANNEL_NAME_LENGTH  101
#define MAX_COMMAND_NAME                 33

// Limits found here: https://discordjs.guide/popular-topics/embeds.html#notes
#define DISCORD_TITLE_LENGTH  257
#define DISCORD_DESC_LENGTH   4097
#define DISCORD_FIELD_LENGTH  1025
#define DISCORD_FOOTER_LENGTH 2049
#define DISCORD_EMBED_LENGTH  6001

#define PARSE_USERS    (1<<0)
#define PARSE_EVERYONE (1<<1)
#define PARSE_ROLES    (1<<2)
#define REPLIED_USER   (1<<3)

// Command option types for slash commands
enum DiscordCommandOptionType
{
  Option_String = 3,     // String option
  Option_Integer = 4,    // Integer option
  Option_Boolean = 5,    // Boolean option
  Option_User = 6,       // User option
  Option_Channel = 7,    // Channel option
  Option_Role = 8,       // Role option
  Option_Number = 10     // Number option
};

enum DiscordPresenceStatus
{
  Presence_Offline = 0,
  Presence_Online = 1,
  Presence_DND = 2,
  Presence_Idle = 3,
  Presence_Invisible = 4
};

enum DiscordActivityType
{
  Activity_Game = 0,
  Activity_Streaming = 1,
  Activity_Listening = 2,
  Activity_Watching = 3,
  Activity_Custom = 4,
  Activity_Competing = 5
};

/*
 * Callbacks
 */
typeset GetChannelCallback
{
  function void (Discord discord, DiscordChannel channel, any data);
};

typeset GetChannelWebhooksCallback
{
  function void (Discord discord, DiscordWebhook[] webhookMap, int count, any data);
};

typeset CreateWebhookCallback
{
  function void (Discord discord, DiscordWebhook webhook, any data);
};

/**
 * Discord bot client handle
 */
methodmap Discord < Handle {
  /**
   * Creates a new Discord bot client
   *
   * @param token     Discord bot token
   * @return          New Discord client handle, or INVALID_HANDLE on failure
   */
  public native Discord(const char[] token);

  /**
   * Starts the Discord bot
   *
   * @return          true on success, false on failure
   */
  public native bool Start();

  /**
   * Stops the Discord bot
   *
   * @return          true on success, false on failure
   */
  public native bool Stop();

  /**
   * Checks if the bot is running
   *
   * @return          true if running, false if stopped
   */
  public native bool IsRunning();

  /**
   * Gets the bot's user ID
   *
   * @param buffer    Buffer to store the ID
   * @param maxlen    Maximum length of the buffer
   * @return         True if successful, false otherwise
   */
  public native bool GetBotId(char[] buffer, int maxlen);

  /**
   * Gets the bot's username
   *
   * @param buffer    Buffer to store the username
   * @param maxlen    Maximum length of the buffer
   * @return         True if successful, false otherwise
   */
  public native bool GetBotName(char[] buffer, int maxlen);

  /**
   * Gets the bot's discriminator
   *
   * @param buffer    Buffer to store the discriminator
   * @param maxlen    Maximum length of the buffer
   * @return         True if successful, false otherwise
   */
  public native bool GetBotDiscriminator(char[] buffer, int maxlen);

  /**
   * Gets the bot's avatar URL
   *
   * @param buffer    Buffer to store the URL
   * @param maxlen    Maximum length of the buffer
   * @return         True if successful, false otherwise
   */
  public native bool GetBotAvatarUrl(char[] buffer, int maxlen);

  /**
   * Sets the bot's presence and activity.
   *
   * @param status       The online presence status of the bot
   * @param activity     The type of activity for the bot
   * @param statusText   The text of the status to set
   * @return             true on success, false on failure
   */
  public native bool SetPresence(DiscordPresenceStatus status, DiscordActivityType activity, const char[] statusText);

  /**
   * Executes the given webhook with a message
   *
   * @param wh        Target webhook
   * @param message   Message content to send
   * @return          true on success, false on failure
   */
  public native bool ExecuteWebhook(DiscordWebhook wh, const char[] message, int allowedMentionsMask = 0, const char[][] allowedUsersMentions = {}, int allowedUserSize = 0, const char[][] allowedRolesMentions = {}, int allowedRolesSize = 0);

  /**
   * Creates a webhook for a channel
   *
   * @param channelId Target channel ID
   * @param name      Name of the webhook to be created
   * @param callback  Method to run on success
   * @param data      Arbitrary value to pass to the callback
   * @return          true on success, false on failure
   */
  public native bool CreateWebhook(const char[] channelId, const char[] name, CreateWebhookCallback callback, any data = 0);

  /**
   * Gets all webhooks assigned to a channel
   *
   * @param channelId Target channel ID
   * @param callback  Method to run on success
   * @param data      Arbitrary value to pass to the callback
   * @return          true on success, false on failure
   */
  public native bool GetChannelWebhooks(const char[] channelId, GetChannelWebhooksCallback callback, any data = 0);

  /**
   * Gets a channel by it's ID
   *
   * @param channelId Target channel ID
   * @param callback  Method to run on success
   * @param data      Arbitrary value to pass to the callback
   * @return          true on success, false on failure
   */
  public native bool GetChannel(const char[] channelId, GetChannelCallback callback, any data = 0);

  /**
   * Sends a message to a specified channel
   *
   * @param channelId Target channel ID (numeric string)
   * @param message   Message content to send
   * @return          true on success, false on failure
   */
  public native bool SendMessage(const char[] channelId, const char[] message, int allowedMentionsMask = 0, const char[][] allowedUsersMentions = {}, int allowedUserSize = 0, const char[][] allowedRolesMentions = {}, int allowedRolesSize = 0);

  /**
   * Sends a message with embed to a specified channel
   *
   * @param channelId Target channel ID
   * @param message   Message content
   * @param embed     Embed object to send
   * @return          true on success, false on failure
   */
  public native bool SendMessageEmbed(const char[] channelId, const char[] message, DiscordEmbed embed, int allowedMentionsMask = 0, const char[][] allowedUsersMentions = {}, int allowedUserSize = 0, const char[][] allowedRolesMentions = {}, int allowedRolesSize = 0);

  /**
   * Edits an existing message
   *
   * @param channel_id    Channel ID
   * @param message_id    Message ID
   * @param content       New message content
   * @return              true on success, false on failure
   */
  public native bool EditMessage(const char[] channel_id, const char[] message_id, const char[] content);

  /**
   * Edits an existing message with embed
   *
   * @param channel_id    Channel ID
   * @param message_id    Message ID
   * @param content       New message content
   * @param embed         Embed object
   * @return              true on success, false on failure
   */
  public native bool EditMessageEmbed(const char[] channel_id, const char[] message_id, const char[] content, DiscordEmbed embed);

  /**
   * Deletes a message
   *
   * @param channel_id    Channel ID
   * @param message_id    Message ID
   * @return              true on success, false on failure
   */
  public native bool DeleteMessage(const char[] channel_id, const char[] message_id);

  /**
   * Registers a slash command for a specific guild
   *
   * @param guild_id      Guild ID
   * @param name          Command name
   * @param description   Command description
   * @param permissions   Default command permissions uint64
   * @return              true on success, false on failure
   */
  public native bool RegisterSlashCommand(const char[] guild_id, const char[] name, const char[] description, const char[] permissions = "");

  /**
   * Registers a global slash command
   *
   * @param name          Command name
   * @param description   Command description
   * @param permissions   Default command permissions uint64
   * @return              true on success, false on failure
   */
  public native bool RegisterGlobalSlashCommand(const char[] name, const char[] description, const char[] permissions = "");

  /**
   * Registers a slash command with options for a specific guild
   *
   * @param guild_id      		Guild ID
   * @param name          		Command name
   * @param description   		Command description
   * @param permissions   		Default command permissions uint64
   * @param option_names  		Array of option names
   * @param option_descriptions	Array of option descriptions
   * @param option_types  		Array of option types
   * @param option_required		Array of option required flags
   * @param option_autocomplete	Array of option autocomplete flags
   * @param num_options   		Number of options
   * @return             		true on success, false on failure
   */
  public native bool RegisterSlashCommandWithOptions(const char[] guild_id, 
      const char[] name, 
      const char[] description,
      const char[] permissions = "",
      const char[][] option_names,
      const char[][] option_descriptions,
      const DiscordCommandOptionType[] option_types,
      const bool[] option_required,
      const bool[] option_autocomplete,
      int num_options);

  /**
   * Registers a global slash command with options
   *
   * @param name          		Command name
   * @param description   		Command description
   * @param permissions   		Default command permissions uint64
   * @param option_names  		Array of option names
   * @param option_descriptions	Array of option descriptions
   * @param option_types  		Array of option types
   * @param option_required		Array of option required flags
   * @param option_autocomplete	Array of option autocomplete flags
   * @param num_options   		Number of options
   * @return             		true on success, false on failure
   */
  public native bool RegisterGlobalSlashCommandWithOptions(
      const char[] name, 
      const char[] description,
      const char[] permissions = "",
      const char[][] option_names,
      const char[][] option_descriptions,
      const DiscordCommandOptionType[] option_types,
      const bool[] option_required,
      const bool[] option_autocomplete,
      int num_options);

  /**
   * Deletes a slash command from a specific guild
   *
   * @param guild_id      Guild ID where the command exists
   * @param command_id    ID of the command to delete
   * @return              true on success, false on failure
   */
  public native bool DeleteGuildCommand(const char[] guild_id, const char[] command_id);

  /**
   * Deletes a global slash command
   *
   * @param command_id    ID of the command to delete
   * @return              true on success, false on failure
   */
  public native bool DeleteGlobalCommand(const char[] command_id);

  /**
   * Deletes all commands that have been registered for a specific guild
   *
   * @param guild_id     ID of the guild to delete commands for
   * @return             true on success, false on failure
   */
  public native bool BulkDeleteGuildCommands(const char[] guild_id);

  /**
   * Deletes all commands that have been registered globally
   *
   * @return             true on success, false on failure
   */
  public native bool BulkDeleteGlobalCommands();
}

/**
 * Discord user handle
 */
methodmap DiscordUser < Handle
{
  /**
   * Gets the ID of the user
   *
   * @param buffer      Buffer to store the ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetId(char[] buffer, int maxlength);

  /**
   * Gets the username of the user
   *
   * @param buffer      Buffer to store the name
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetUsername(char[] buffer, int maxlength);

  /**
   * Gets the discriminator of the user
   */
  public native int GetDiscriminator();

  /**
   * Gets the display name of the user
   *
   * @param buffer      Buffer to store the name
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetGlobalName(char[] buffer, int maxlength);

  /**
   * Gets the avatar url of the webhook
   *
   * @param preferAnimated Whether to return the gif version of animated avatars if they are available or not.
   * @param buffer         Buffer to store the url
   * @param maxlength      Maximum length of the buffer
   */
  public native void GetAvatarUrl(bool preferAnimated, char[] buffer, int maxlength);

  /**
   * Checks if the user is a bot
   *
   * @return          true if user is bot, false otherwise
   */
  public native bool IsBot();
}

/**
 * Discord message handle
 */
methodmap DiscordMessage < Handle
{
  /**
   * Gets the content of the message
   *
   * @param buffer      Buffer to store the content
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetContent(char[] buffer, int maxlength);

  /**
   * Gets the ID of the message
   *
   * @param buffer      Buffer to store the message ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetMessageId(char[] buffer, int maxlength);

  /**
   * Gets the channel ID where the message was sent
   *
   * @param buffer      Buffer to store the channel ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetChannelId(char[] buffer, int maxlength);

  /**
   * Gets the guild (server) ID where the message was sent
   *
   * @param buffer      Buffer to store the guild ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetGuildId(char[] buffer, int maxlength);

  /**
   * Gets the user that sent the message
   */
  public native DiscordUser GetAuthor();

  /**
   * @deprecated Use GetAuthor().GetId() instead
   * Gets the ID of the message author
   *
   * @param buffer      Buffer to store the author ID
   * @param maxlength   Maximum length of the buffer
   */
  #pragma deprecated Use GetAuthor().GetId() instead
  public native void GetAuthorId(char[] buffer, int maxlength);

  /**
   * @deprecated Use GetAuthor().GetUsername() instead
   * Gets the username of the message author
   *
   * @param buffer      Buffer to store the author name
   * @param maxlength   Maximum length of the buffer
   */
  #pragma deprecated Use GetAuthor().GetUsername() instead
  public native void GetAuthorName(char[] buffer, int maxlength);

  /**
   * @deprecated Use GetAuthor().GetGlobalName() instead
   * Gets the global display name of the message author
   *
   * @param buffer      Buffer to store the display name
   * @param maxlength   Maximum length of the buffer
   */
  #pragma deprecated Use GetAuthor().GetGlobalName() instead
  public native void GetAuthorDisplayName(char[] buffer, int maxlength);

  /**
   * Gets the nickname of the message author within the guild this message was sent in
   *
   * @param buffer      Buffer to store the author nickname
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetAuthorNickname(char[] buffer, int maxlength);

  /**
   * @deprecated Use GetAuthor().GetDiscriminator() instead
   * Gets the discriminator of the message author
   */
  #pragma deprecated Use GetAuthor().GetDiscriminator() instead
  public native int GetAuthorDiscriminator();

  /**
   * Checks if the message is pinned
   *
   * @return          true if pinned, false otherwise
   */
  public native bool IsPinned();

  /**
   * Checks if the message is TTS (Text-To-Speech)
   *
   * @return          true if TTS, false otherwise
   */
  public native bool IsTTS();

  /**
   * Checks if the message mentions everyone
   *
   * @return          true if mentions everyone, false otherwise
   */
  public native bool IsMentionEveryone();

  /**
   * Checks if the message author is a bot
   *
   * @return          true if author is bot, false otherwise
   */
  public native bool IsBot();

  /**
   * Gets number of characters in the content
   * @note            not including any null-termination
   * 
   * @return          Length of the message content
   */
  property int ContentLength {
    public native get();
  }
}

/**
 * Discord channel handle
 */
methodmap DiscordChannel < Handle
{
  /**
   * Gets the name of the channel
   *
   * @param buffer      Buffer to store the name
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetName(char[] buffer, int maxlength);
}

/**
 * Discord webhook handle
 */
methodmap DiscordWebhook < Handle
{
  /**
   * Creates a new Discord Webhook
   *
   * @param webhookUrl Webhook Url
   * @return           New Discord webhook handle, or INVALID_HANDLE on failure
   */
  public native DiscordWebhook(const char[] webhookUrl);

  /**
   * Gets the ID of the webhook
   *
   * @param buffer      Buffer to store the ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetId(char[] buffer, int maxlength);

  /**
   * Gets the user that created the webhook
   */
  public native DiscordUser GetUser();

  /**
   * Gets the name of the webhook
   *
   * @param buffer      Buffer to store the name
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetName(char[] buffer, int maxlength);

  /**
   * Sets the name of the webhook
   *
   * @param name		New string to set the name to
   */
  public native void SetName(char[] name);

  /**
   * Gets the avatar_url of the webhook
   *
   * @param buffer      Buffer to store the url
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetAvatarUrl(char[] buffer, int maxlength);

  /**
   * Sets the avatar_url of the webhook
   *
   * @param name		New string to set the avatar_url to
   */
  public native void SetAvatarUrl(char[] avatarUrl);

  /**
   * Gets the avatar of the webhook
   *
   * @param buffer      Buffer to store the data
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetAvatarData(char[] buffer, int maxlength);

  /**
   * Sets the avatar of the webhook
   *
   * @param name		New string to set the avatar to
   */
  public native void SetAvatarData(char[] avatar);
}

/**
 * Discord embed handle
 */
methodmap DiscordEmbed < Handle
{
  /**
   * Creates a new Discord Embed
   */
  public native DiscordEmbed();
  
  /**
   * Sets the embed title
   *
   * @param title     Title text
   */
  public native void SetTitle(const char[] title);
  
  /**
   * Sets the embed description
   *
   * @param desc      Description text
   */
  public native void SetDescription(const char[] desc);
  
  /**
   * Sets the embed color
   *
   * @param color     Color value (decimal RGB)
   */
  public native void SetColor(int color);
  
  /**
   * Sets the embed URL
   *
   * @param url       URL link
   */
  public native void SetUrl(const char[] url);
  
  /**
   * Sets the embed author
   *
   * @param name      Author name
   * @param url       Author URL (optional)
   * @param icon_url  Author icon URL (optional)
   */
  public native void SetAuthor(const char[] name, const char[] url = "", const char[] icon_url = "");
  
  /**
   * Sets the embed footer
   *
   * @param text      Footer text
   * @param icon_url  Footer icon URL (optional)
   */
  public native void SetFooter(const char[] text, const char[] icon_url = "");
  
  /**
   * Adds a field to the embed
   *
   * @param name      Field name
   * @param value     Field value
   * @param inLine    Whether to display inline
   */
  public native void AddField(const char[] name, const char[] value, bool inLine = false);
  
  /**
   * Sets the embed thumbnail
   *
   * @param url       Image URL
   */
  public native void SetThumbnail(const char[] url);
  
  /**
   * Sets the embed image
   *
   * @param url       Image URL
   */
  public native void SetImage(const char[] url);
}

/**
 * Discord interaction handle
 */
methodmap DiscordInteraction < Handle
{
  /**
   * Gets the name of the slash command
   *
   * @param buffer    Buffer to store the command name
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetCommandName(char[] buffer, int maxlen);

  /**
   * Gets the guild (server) ID where the command was used
   *
   * @param buffer    Buffer to store the guild ID
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetGuildId(char[] buffer, int maxlen);

  /**
   * Gets the channel ID where the command was used
   *
   * @param buffer    Buffer to store the channel ID
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetChannelId(char[] buffer, int maxlen);

  /**
   * Gets the user who used the command
   */
  public native DiscordUser GetUser();

  /**
   * Gets the nickname of the user who used the command relative to the guild it was used in
   *
   * @param buffer    Buffer to store the nickname
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetUserNickname(char[] buffer, int maxlen);

  /**
   * Gets the ID of the user who used the command
   *
   * @param buffer    Buffer to store the user ID
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetUserId(char[] buffer, int maxlen);

  /**
   * Gets the username of the user who used the command
   *
   * @param buffer    Buffer to store the username
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetUserName(char[] buffer, int maxlen);
  
  /**
   * Gets a string option value from the command
   *
   * @param name      Name of the option
   * @param buffer    Buffer to store the option value
   * @param maxlen    Maximum length of the buffer
   * @return          true if option exists and is string type, false otherwise
   */
  public native bool GetOptionValue(const char[] name, char[] buffer, int maxlen);

  /**
   * Gets an integer option value from the command
   *
   * @param name      Name of the option
   * @return          Integer value of the option, 0 if option doesn't exist
   */
  public native int GetOptionValueInt(const char[] name);

  /**
   * Gets a float option value from the command
   *
   * @param name      Name of the option
   * @return          Float value of the option, 0.0 if option doesn't exist
   */
  public native float GetOptionValueFloat(const char[] name);

  /**
   * Gets a boolean option value from the command
   *
   * @param name      Name of the option
   * @return          Boolean value of the option, false if option doesn't exist
   */
  public native bool GetOptionValueBool(const char[] name);
  
  /**
   * Creates an immediate response to the interaction
   *
   * @param content   Content of the response
   */
  public native void CreateResponse(const char[] content);

  /**
   * Creates an immediate response with embed to the interaction
   *
   * @param content   Content of the response
   * @param embed     Embed object to include in the response
   */
  public native void CreateResponseEmbed(const char[] content, DiscordEmbed embed);

  /**
   * Defers the response, showing a "thinking" state
   *
   * @param ephemeral Whether the response should be ephemeral (only visible to the command user)
   */
  public native void DeferReply(bool ephemeral = false);

  /**
   * Edits a previously sent response
   *
   * @param content   New content for the response
   */
  public native void EditResponse(const char[] content);

  /**
   * Edits a previously sent response with embed
   *
   * @param content   New content for the response
   * @param embed     New embed object for the response
   */
  public native void EditResponseEmbed(const char[] content, DiscordEmbed embed);

  /**
   * Creates an ephemeral response (only visible to the command user)
   *
   * @param content   Content of the response
   */
  public native void CreateEphemeralResponse(const char[] content);

  /**
   * Creates an ephemeral response with embed (only visible to the command user)
   *
   * @param content   Content of the response
   * @param embed     Embed object to include in the response
   */
  public native void CreateEphemeralResponseEmbed(const char[] content, DiscordEmbed embed);
}

methodmap DiscordAutocompleteInteraction < Handle
{
  /**
   * Gets the name of the slash command
   *
   * @param buffer    Buffer to store the command name
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetCommandName(char[] buffer, int maxlen);

  /**
   * Gets the guild (server) ID where the command was used
   *
   * @param buffer    Buffer to store the guild ID
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetGuildId(char[] buffer, int maxlen);

  /**
   * Gets the channel ID where the command was used
   *
   * @param buffer    Buffer to store the channel ID
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetChannelId(char[] buffer, int maxlen);

  /**
   * Gets the user who used the command
   */
  public native DiscordUser GetUser();

  /**
   * Gets the nickname of the user who used the command relative to the guild it was used in
   *
   * @param buffer    Buffer to store the nickname
   * @param maxlen    Maximum length of the buffer
   */
  public native void GetUserNickname(char[] buffer, int maxlen);

  /**
   * Gets a string option value from the command
   *
   * @param name      Name of the option
   * @param buffer    Buffer to store the option value
   * @param maxlen    Maximum length of the buffer
   * @return          true if option exists and is string type, false otherwise
   */
  public native bool GetOptionValue(const char[] name, char[] buffer, int maxlen);

  /**
   * Gets an integer option value from the command
   *
   * @param name      Name of the option
   * @return          Integer value of the option, 0 if option doesn't exist
   */
  public native int GetOptionValueInt(const char[] name);

  /**
   * Gets a float option value from the command
   *
   * @param name      Name of the option
   * @return          Float value of the option, 0.0 if option doesn't exist
   */
  public native float GetOptionValueFloat(const char[] name);

  /**
   * Gets a boolean option value from the command
   *
   * @param name      Name of the option
   * @return          Boolean value of the option, false if option doesn't exist
   */
  public native bool GetOptionValueBool(const char[] name);

  /**
   * Adds a choice to the autocomplete results that will be included in the response.
   *
   * @param name   	The name that will appear to the user for this autocomplete result
   * @param type    The option type of the value to be passed
   * @param value   The actual value that will be used in the option when it is sent
   */
  public native void AddAutocompleteChoice(const char[] name, DiscordCommandOptionType type, any value);

  /**
   * Adds a string-type choice to the autocomplete results that will be included in the response.
   *
   * @param name    The name that will appear to the user for this autocomplete result
   * @param value   The actual value that will be used in the option when it is sent
   */
  public native void AddAutocompleteChoiceString(const char[] name, const char[] value);

  /**
   * Creates and sends the autocomplete response.
  */
  public native void CreateAutocompleteResponse(Discord discord);
}

/**
 * Called when Discord bot is ready
 *
 * @param discord      Discord client handle
 */
forward void Discord_OnReady(Discord discord);

/**
 * Called when a message is received
 *
 * @param discord      Discord client handle
 * @param message      Message handle
 */
forward void Discord_OnMessage(Discord discord, DiscordMessage message);

/**
 * Called when a slash command is received
 *
 * @param discord      Discord client handle
 * @param interaction  Interaction handle
 */
forward void Discord_OnSlashCommand(Discord discord, DiscordInteraction interaction);

/**
 * Called when an autocomplete request for a specific option is received
 *
 * @note Discord requires this forward to give back a response for one of the options within 500ms.
 * @param discord		Discord client handle
 * @param interaction	Autocomplete Interaction handle
 * @param focused		If the current option is the one focused by the user
 * @param type			The current option type
 * @param optionName	The name of the current option
 */
forward void Discord_OnAutocomplete(Discord discord, DiscordAutocompleteInteraction interaction, bool focused, DiscordCommandOptionType type, char[] optionName);

/**
 * Called when an error occurs
 *
 * @param discord      Discord client handle
 * @param error        Error message
 */
forward void Discord_OnError(Discord discord, const char[] error);

public Extension __ext_discord = 
{
  name = "Discord",
  file = "discord.ext",
  autoload = 1,
  required = 1,
};