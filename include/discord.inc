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

#define PARSE_USERS    (1 << 0)
#define PARSE_EVERYONE (1 << 1)
#define PARSE_ROLES    (1 << 2)
#define REPLIED_USER   (1 << 3)

// Discord permissions enum
enum DiscordPermission
{
  Permission_CreateInstantInvite = 0,               // Allows creation of instant invites
  Permission_KickMembers = 1,                       // Allows kicking members from the guild
  Permission_BanMembers = 2,                        // Allows banning members from the guild
  Permission_Administrator = 3,                     // Administrator permissions (all permissions)
  Permission_ManageChannels = 4,                    // Allows management and editing of channels
  Permission_ManageGuild = 5,                       // Allows management and editing of the guild
  Permission_AddReactions = 6,                      // Allows adding reactions to messages
  Permission_ViewAuditLog = 7,                      // Allows viewing audit logs
  Permission_PrioritySpeaker = 8,                   // Allows using priority speaker in voice channels
  Permission_Stream = 9,                            // Allows the user to go live
  Permission_ViewChannel = 10,                      // Allows viewing channels (read messages/join voice)
  Permission_SendMessages = 11,                     // Allows sending messages in channels
  Permission_SendTTSMessages = 12,                  // Allows sending text-to-speech messages
  Permission_ManageMessages = 13,                   // Allows deleting other users' messages
  Permission_EmbedLinks = 14,                       // Allows links to be auto-embedded
  Permission_AttachFiles = 15,                      // Allows uploading files and images
  Permission_ReadMessageHistory = 16,               // Allows reading message history
  Permission_MentionEveryone = 17,                  // Allows using @everyone and @here mentions
  Permission_UseExternalEmojis = 18,                // Allows using emojis from other servers
  Permission_ViewGuildInsights = 19,                // Allows viewing guild insights
  Permission_Connect = 20,                          // Allows joining voice channels
  Permission_Speak = 21,                            // Allows speaking in voice channels
  Permission_MuteMembers = 22,                      // Allows muting members in voice channels
  Permission_DeafenMembers = 23,                    // Allows deafening members in voice channels
  Permission_MoveMembers = 24,                      // Allows moving members between voice channels
  Permission_UseVAD = 25,                           // Allows using voice activity detection
  Permission_ChangeNickname = 26,                   // Allows changing own nickname
  Permission_ManageNicknames = 27,                  // Allows managing others' nicknames
  Permission_ManageRoles = 28,                      // Allows managing roles
  Permission_ManageWebhooks = 29,                   // Allows managing webhooks
  Permission_ManageEmojis = 30,                     // Allows managing emojis and stickers
  Permission_UseSlashCommands = 31,                 // Allows using slash commands
  Permission_RequestToSpeak = 32,                   // Allows requesting to speak in stage channels
  Permission_ManageEvents = 33,                     // Allows managing scheduled events
  Permission_ManageThreads = 34,                    // Allows managing threads
  Permission_CreatePublicThreads = 35,              // Allows creating public threads
  Permission_CreatePrivateThreads = 36,             // Allows creating private threads
  Permission_UseExternalStickers = 37,              // Allows using stickers from other servers
  Permission_SendMessagesInThreads = 38,            // Allows sending messages in threads
  Permission_UseEmbeddedActivities = 39,            // Allows using embedded activities
  Permission_ModerateMembers = 40,                  // Allows timing out members
  Permission_ViewCreatorMonetizationAnalytics = 41, // Allows viewing monetization analytics
  Permission_UseSoundboard = 42,                    // Allows using soundboard
  Permission_CreateGuildExpressions = 43,           // Allows creating guild expressions
  Permission_CreateEvents = 44,                     // Allows creating events
  Permission_UseExternalSounds = 45,                // Allows using sounds from other servers
  Permission_SendVoiceMessages = 46,                // Allows sending voice messages
  Permission_UseClydeAI = 47                        // Allows using Clyde AI
};

// Discord webhook types enum
enum DiscordWebhookType
{
  WebhookType_Incoming = 1,        // Incoming webhook (created by user in Discord)
  WebhookType_ChannelFollower = 2, // Channel follower webhook (follows another channel)
  WebhookType_Application = 3      // Application webhook (created by application)
};

// Discord user flags enum (based on DPP user_flags)
enum DiscordUserFlags
{
  UserFlag_Bot = (1 << 0),                  // User is a bot.
  UserFlag_System = (1 << 1),               // User is a system user (Clyde!)
  UserFlag_MfaEnabled = (1 << 2),           // User has multi-factor authentication enabled
  UserFlag_Verified = (1 << 3),             // User is verified (verified email address)
  UserFlag_NitroFull = (1 << 4),            // User has full nitro
  UserFlag_NitroClassic = (1 << 5),         // User has nitro classic
  UserFlag_DiscordEmployee = (1 << 6),      // User is discord staff
  UserFlag_PartneredOwner = (1 << 7),       // User owns a partnered server
  UserFlag_HypesquadEvents = (1 << 8),      // User is a member of hypesquad events
  UserFlag_BugHunter1 = (1 << 9),           // User has BugHunter level 1
  UserFlag_HouseBravery = (1 << 10),        // User is a member of House Bravery
  UserFlag_HouseBrilliance = (1 << 11),     // User is a member of House Brilliance
  UserFlag_HouseBalance = (1 << 12),        // User is a member of House Balance
  UserFlag_EarlySupporter = (1 << 13),      // User is an early supporter
  UserFlag_TeamUser = (1 << 14),            // User is a team user
  UserFlag_BugHunter2 = (1 << 15),          // User is has Bug Hunter level 2
  UserFlag_VerifiedBot = (1 << 16),         // User is a verified bot
  UserFlag_VerifiedBotDev = (1 << 17),      // User has the Early Verified Bot Developer badge
  UserFlag_AnimatedIcon = (1 << 18),        // User's icon is animated
  UserFlag_CertifiedModerator = (1 << 19),  // User is a certified moderator
  UserFlag_BotHttpInteractions = (1 << 20), // User is a bot using HTTP interactions
  UserFlag_NitroBasic = (1 << 21),          // User has nitro basic
  UserFlag_ActiveDeveloper = (1 << 22),     // User has the active developer badge
  UserFlag_AnimatedBanner = (1 << 23)       // User's banner is animated
};

enum DiscordChannelType
{
  ChannelType_Text = 0,                // Text channel
  ChannelType_DM = 1,                  // Direct message
  ChannelType_Voice = 2,               // Voice channel
  ChannelType_GroupDM = 3,             // Group DM (deprecated)
  ChannelType_Category = 4,            // Category channel
  ChannelType_Announcement = 5,        // Announcement channel
  ChannelType_Store = 6,               // Store channel (deprecated)
  ChannelType_AnnouncementThread = 10, // Announcement thread
  ChannelType_PublicThread = 11,       // Public thread
  ChannelType_PrivateThread = 12,      // Private thread
  ChannelType_Stage = 13,              // Stage channel
  ChannelType_Directory = 14,          // Directory channel
  ChannelType_Forum = 15,              // Forum channel
  ChannelType_Media = 16               // Media channel
};

enum DiscordCommandOptionType
{
  Option_String = 3,  // String option
  Option_Integer = 4, // Integer option
  Option_Boolean = 5, // Boolean option
  Option_User = 6,    // User option
  Option_Channel = 7, // Channel option
  Option_Role = 8,    // Role option
  Option_Number = 10  // Number option
};

// Discord slash command context menu types
enum DiscordContextMenuType
{
  ContextMenu_None = 0,      // Undefined context menu type
  ContextMenu_ChatInput = 1, // Default slash commands (/ping, /pong, etc)
  ContextMenu_User = 2,      // User context menu command  
  ContextMenu_Message = 3    // Message context menu command
};

// Discord interaction context types
enum DiscordInteractionContextType
{
  InteractionContext_Guild = 0,         // Can be used within servers
  InteractionContext_BotDM = 1,         // Can be used within DMs with bot
  InteractionContext_PrivateChannel = 2 // Can be used within Group DMs and other DMs
};

// Discord application integration types  
enum DiscordIntegrationType
{
  IntegrationType_GuildInstall = 0, // App installed to a guild
  IntegrationType_UserInstall = 1   // App installed to a user
};

// Discord command permission types
enum DiscordCommandPermissionType
{
  CommandPermission_Role = 1,    // Permission for a role
  CommandPermission_User = 2,    // Permission for a user
  CommandPermission_Channel = 3  // Permission for a channel
};

enum DiscordPresenceStatus
{
  Presence_Offline = 0,   // Status is offline
  Presence_Online = 1,    // Status is online
  Presence_DND = 2,       // Status is busy (Do Not Disturb)
  Presence_Idle = 3,      // Status is idle (away)
  Presence_Invisible = 4  // Status is invisible (not shown as online)
};

enum DiscordActivityType
{
  Activity_Game = 0,      // Playing a game
  Activity_Streaming = 1, // Streaming a game
  Activity_Listening = 2, // Listening to music
  Activity_Watching = 3,  // Watching something
  Activity_Custom = 4,    // Custom activity (not a game)
  Activity_Competing = 5  // Competing in a game
};

/**
 * Message flags bitmask
 */
enum MessageFlags {
  MessageFlag_Crossposted = (1 << 0),            // This message has been published to subscribed channels (via Channel Following)
  MessageFlag_IsCrosspost = (1 << 1),            // This message originated from a message in another channel (via Channel Following)
  MessageFlag_SuppressEmbeds = (1 << 2),         // Do not include any embeds when serializing this message
  MessageFlag_SourceMessageDeleted = (1 << 3),   // The source message for this crosspost has been deleted (via Channel Following)
  MessageFlag_Urgent = (1 << 4),                 // This message came from the urgent message system
  MessageFlag_HasThread = (1 << 5),              // his message has an associated thread, with the same id as the message
  MessageFlag_Ephemeral = (1 << 6),              // This message is only visible to the user who invoked the Interaction
  MessageFlag_Loading = (1 << 7),                // This message is an Interaction Response and the bot is "thinking"
  MessageFlag_ThreadMentionFailed = (1 << 8),    // This message failed to mention some roles and add their members to the thread
  MessageFlag_SuppressNotifications = (1 << 12), // This message will not trigger push and desktop notifications
  MessageFlag_IsVoiceMessage = (1 << 13),        // This message is a voice message
  MessageFlag_HasSnapshot = (1 << 14),           // Contains forwarded snapshot
  MessageFlag_UsingComponentsV2 = (1 << 15)      // Message components vector contains v2 components
};

/**
 * Channel flags bitmask
 */
enum ChannelFlags {
  ChannelFlag_NSFW = (1 << 4),                     // NSFW Gated Channel
  ChannelFlag_VideoQuality720p = (1 << 5),         // Video quality forced to 720p
  ChannelFlag_LockPermissions = (1 << 6),          // Lock permissions (only used when updating channel positions)
  ChannelFlag_PinnedThread = (1 << 7),             // Thread is pinned to the top of its parent forum or media channel
  ChannelFlag_RequireTag = (1 << 8),               // Whether a tag is required to be specified when creating a thread in a forum or media channel
  ChannelFlag_HideMediaDownloadOptions = (1 << 12) // When set hides the embedded media download options. Available only for media channels
};

/**
 * Types for sort posts in a forum channel
 */
enum ForumSortOrder {
  ForumSort_LatestActivity = 0, // Sort forum posts by activity (default)
  ForumSort_CreationDate = 1    // Sort forum posts by creation time (from most recent to oldest)
};

/**
 * Types of forum layout views that indicates how the threads in a forum channel will be displayed for users by default
 */
enum ForumLayoutType {
  ForumLayout_NotSet = 0,     // No default has been set for the forum channel
  ForumLayout_ListView = 1,   // Display posts as a list 
  ForumLayout_GalleryView = 2 // Display posts as a collection of tiles
};

/**
 * Auto archive duration of threads
 */
enum AutoArchiveDuration {
  AutoArchive_1Hour = 1, // Auto archive duration of 1 hour (60 minutes)
  AutoArchive_1Day = 2,  // Auto archive duration of 1 day (1440 minutes)
  AutoArchive_3Days = 3, // Auto archive duration of 3 days (4320 minutes)
  AutoArchive_1Week = 4  // Auto archive duration of 1 week (10080 minutes)
};

/**
 * Channel permission overwrite types
 */
enum OverwriteType {
  Overwrite_Role = 0,  // Role overwrite
  Overwrite_Member = 1 // Member overwrite
};

enum MessageType {
  MessageType_Default = 0,                                  // Default message type
  MessageType_RecipientAdd = 1,                             // Add recipient
  MessageType_RecipientRemove = 2,                          // Remove recipient
  MessageType_Call = 3,                                     // Call
  MessageType_ChannelNameChange = 4,                        // Channel name change
  MessageType_ChannelIconChange = 5,                        // Channel icon change
  MessageType_ChannelPinnedMessage = 6,                     // Message pinned
  MessageType_GuildMemberJoin = 7,                          // Member joined
  MessageType_UserPremiumGuildSubscription = 8,             // Boost
  MessageType_UserPremiumGuildSubscriptionTier1 = 9,        // Boost level 1
  MessageType_UserPremiumGuildSubscriptionTier2 = 10,       // Boost level 2
  MessageType_UserPremiumGuildSubscriptionTier3 = 11,       // Boost level 3
  MessageType_ChannelFollowAdd = 12,                        // Follow channel
  MessageType_GuildDiscoveryDisqualified = 14,              // Disqualified from discovery
  MessageType_GuildDiscoveryRequalified = 15,               // Re-qualified for discovery
  MessageType_GuildDiscoveryGracePeriodInitialWarning = 16, // Discovery grace period warning 1
  MessageType_GuildDiscoveryGracePeriodFinalWarning  = 17,  // Discovery grace period warning 2
  MessageType_ThreadCreated = 18,                           // Thread Created
  MessageType_Reply = 19,                                   // Reply
  MessageType_ApplicationCommand = 20,                      // Application command
  MessageType_ThreadStarterMessage = 21,                    // Thread starter message
  MessageType_GuildInviteReminder = 22,                     // Invite reminder
  MessageType_ContextMenuCommand = 23,                      // Context Menu Command
  MessageType_AutoModerationAction = 24,                    // Auto moderation action
  MessageType_RoleSubscriptionPurchase = 25,                // Role subscription purchase
  MessageType_InteractionPremiumUpsell = 26,                // Interaction premium upsell
  MessageType_StageStart = 27,                              // Stage start
  MessageType_StageEnd = 28,                                // Stage end
  MessageType_StageSpeaker = 29,                            // Stage speaker
  MessageType_StageTopic = 31,                              // Stage topic
  MessageType_ApplicationPremiumSubscription = 32           // Guild application premium subscription
};

/**
 * Guild flags enum - matches DPP guild_flags
 */
enum GuildFlags {
  GuildFlag_Large = (1 << 0),                    // Large guild
  GuildFlag_Unavailable = (1 << 1),              // Unavailable due to outage
  GuildFlag_WidgetEnabled = (1 << 2),            // Widget enabled
  GuildFlag_InviteSplash = (1 << 3),             // Can have invite splash
  GuildFlag_VipRegions = (1 << 4),               // Can have VIP regions
  GuildFlag_VanityUrl = (1 << 5),                // Can have vanity URL
  GuildFlag_Verified = (1 << 6),                 // Verified server
  GuildFlag_Partnered = (1 << 7),                // Partnered server
  GuildFlag_Community = (1 << 8),                // Community features enabled
  GuildFlag_RoleSubscriptionEnabled = (1 << 9),  // Role subscriptions enabled
  GuildFlag_News = (1 << 10),                    // Has news channels
  GuildFlag_Discoverable = (1 << 11),            // Discoverable in discovery
  GuildFlag_Featureable = (1 << 12),             // Featureable
  GuildFlag_AnimatedIcon = (1 << 13),            // Can have animated icon
  GuildFlag_Banner = (1 << 14),                  // Can have banner
  GuildFlag_WelcomeScreenEnabled = (1 << 15),    // Has welcome screen
  GuildFlag_MemberVerificationGate = (1 << 16),  // Has member verification
  GuildFlag_PreviewEnabled = (1 << 17),          // Has preview enabled
  GuildFlag_NoJoinNotifications = (1 << 18),     // Join notifications off
  GuildFlag_NoBoostNotifications = (1 << 19),    // Boost notifications off
  GuildFlag_HasAnimatedIcon = (1 << 20),         // Has animated icon
  GuildFlag_HasAnimatedBanner = (1 << 21),       // Has animated banner
  GuildFlag_NoSetupTips = (1 << 22),             // Setup tips off
  GuildFlag_NoStickerGreeting = (1 << 23),       // Sticker greeting off
  GuildFlag_MonetizationEnabled = (1 << 24),     // Monetization enabled
  GuildFlag_MoreStickers = (1 << 25),            // More sticker slots
  GuildFlag_CreatorStorePageEnabled = (1 << 26), // Creator store page enabled
  GuildFlag_RoleIcons = (1 << 27),               // Can set role icons
  GuildFlag_SevenDayThreadArchive = (1 << 28),   // Seven day thread archive (deprecated)
  GuildFlag_ThreeDayThreadArchive = (1 << 29),   // Three day thread archive (deprecated)
  GuildFlag_TicketedEvents = (1 << 30),          // Ticketed events enabled
  GuildFlag_ChannelBanners = (1 << 31)           // Channel banners (deprecated)
};

/**
 * Additional guild flags enum - matches DPP guild_flags_extra
 */
enum GuildFlagsExtra {
  GuildFlagExtra_PremiumProgressBarEnabled = (1 << 0),             // Premium progress bar enabled
  GuildFlagExtra_AnimatedBanner = (1 << 1),                        // Can have animated banner
  GuildFlagExtra_AutoModeration = (1 << 2),                        // Auto moderation enabled
  GuildFlagExtra_InvitesDisabled = (1 << 3),                       // Invites disabled
  GuildFlagExtra_DeveloperSupportServer = (1 << 4),                // Developer support server
  GuildFlagExtra_NoRoleSubscriptionNotifications = (1 << 5),       // Role subscription notifications off
  GuildFlagExtra_NoRoleSubscriptionNotificationReplies = (1 << 6), // Role subscription notification replies off
  GuildFlagExtra_RoleSubscriptionsAvailableForPurchase = (1 << 7), // Role subscriptions available for purchase
  GuildFlagExtra_RaidAlertsDisabled = (1 << 8)                     // Raid alerts disabled
};

/**
 * Guild verification levels
 */
enum GuildVerificationLevel {
  GuildVerification_None = 0,    // Unrestricted
  GuildVerification_Low = 1,     // Must have verified email
  GuildVerification_Medium = 2,  // Must be registered for 5+ minutes
  GuildVerification_High = 3,    // Must be member for 10+ minutes
  GuildVerification_VeryHigh = 4 // Must have verified phone
};

/**
 * Guild explicit content filter levels
 */
enum GuildExplicitContentFilter {
  GuildExplicitContent_Disabled = 0,            // No scanning
  GuildExplicitContent_MembersWithoutRoles = 1, // Scan members without roles
  GuildExplicitContent_AllMembers = 2           // Scan all members
};

/**
 * Guild MFA levels
 */
enum GuildMfaLevel {
  GuildMfa_None = 0,    // MFA not required
  GuildMfa_Elevated = 1 // MFA required for moderation actions
};

/**
 * Guild NSFW levels
 */
enum GuildNsfwLevel {
  GuildNsfw_Default = 0,      // Default setting
  GuildNsfw_Explicit = 1,     // Explicit content may be present
  GuildNsfw_Safe = 2,         // Safe for work content only
  GuildNsfw_AgeRestricted = 3 // Age restricted (18+)
};

/**
 * Guild premium tiers (boost levels)
 */
enum GuildPremiumTier {
  GuildPremium_None = 0,  // No boosts
  GuildPremium_Tier1 = 1, // Tier 1 perks
  GuildPremium_Tier2 = 2, // Tier 2 perks  
  GuildPremium_Tier3 = 3  // Tier 3 perks
};

/**
 * Guild default message notification levels
 */
enum GuildDefaultMessageNotifications {
  GuildNotifications_AllMessages = 0, // All messages
  GuildNotifications_OnlyMentions = 1 // Only @mentions
};

/**
 * Guild AFK timeout values (in seconds)
 */
enum GuildAfkTimeout {
  GuildAfk_Off = 0,     // Disabled
  GuildAfk_60 = 60,     // 1 minute
  GuildAfk_300 = 300,   // 5 minutes
  GuildAfk_900 = 900,   // 15 minutes
  GuildAfk_1800 = 1800, // 30 minutes
  GuildAfk_3600 = 3600  // 1 hour
};

/**
 * Discord intents - controls what events the bot receives
 * Use bitwise OR to combine multiple intents
 * Reference: https://discord.com/developers/docs/topics/gateway#list-of-intents
 */
enum DiscordIntents {
  Intent_Guilds = (1 << 0),                       // Guild create/update/delete, role create/update/delete, channel create/update/delete
  Intent_GuildMembers = (1 << 1),                 // Guild member add/update/remove (PRIVILEGED)
  Intent_GuildBans = (1 << 2),                    // Guild ban add/remove
  Intent_GuildEmojis = (1 << 3),                  // Guild emoji/sticker create/update/delete
  Intent_GuildIntegrations = (1 << 4),            // Guild integration create/update/delete
  Intent_GuildWebhooks = (1 << 5),                // Guild webhook create/update/delete
  Intent_GuildInvites = (1 << 6),                 // Guild invite create/delete
  Intent_GuildVoiceStates = (1 << 7),             // Guild voice state update
  Intent_GuildPresences = (1 << 8),               // Guild presence update (PRIVILEGED)
  Intent_GuildMessages = (1 << 9),                // Guild message create/update/delete
  Intent_GuildMessageReactions = (1 << 10),       // Guild message reaction add/remove/clear
  Intent_GuildMessageTyping = (1 << 11),          // Guild typing start
  Intent_DirectMessages = (1 << 12),              // DM message create/update/delete
  Intent_DirectMessageReactions = (1 << 13),      // DM message reaction add/remove/clear
  Intent_DirectMessageTyping = (1 << 14),         // DM typing start
  Intent_MessageContent = (1 << 15),              // Message content access (PRIVILEGED)
  Intent_GuildScheduledEvents = (1 << 16),        // Guild scheduled event create/update/delete
  Intent_AutoModerationConfiguration = (1 << 20), // Auto moderation rule create/update/delete
  Intent_AutoModerationExecution = (1 << 21)      // Auto moderation action execution
};

// Pre-defined intent combinations
#define DISCORD_INTENTS_DEFAULT                                               \
  (Intent_Guilds | Intent_GuildBans | Intent_GuildEmojis |                    \
  Intent_GuildIntegrations | Intent_GuildWebhooks | Intent_GuildInvites |     \
  Intent_GuildVoiceStates | Intent_GuildMessages |                            \
  Intent_GuildMessageReactions | Intent_GuildMessageTyping |                  \
  Intent_DirectMessages | Intent_DirectMessageTyping |                        \
  Intent_DirectMessageReactions | Intent_GuildScheduledEvents |               \
  Intent_AutoModerationConfiguration | Intent_AutoModerationExecution)
#define DISCORD_INTENTS_PRIVILEGED (Intent_GuildMembers | Intent_GuildPresences | Intent_MessageContent)
#define DISCORD_INTENTS_ALL (DISCORD_INTENTS_DEFAULT | DISCORD_INTENTS_PRIVILEGED)
#define DISCORD_INTENTS_UNVERIFIED_DEFAULT (DISCORD_INTENTS_DEFAULT | Intent_MessageContent)

/**
 * Usage examples:
 *
 * // Check single permission using enum
 * if (user.HasPermissionEnum(Permission_Administrator))
 * {
 *   // User is admin
 * }
 *
 * // Check permission in channel using enum
 * if (user.HasPermissionInChannelEnum("123456789", Permission_SendMessages))
 * {
 *   // User can send messages in this channel
 * }
 *
 * // Set slash command default permission using enum
 * command.SetDefaultPermissionsEnum(Permission_Administrator);
 *
 * // Set multiple permissions for slash command
 * DiscordPermission perms[] = {Permission_ManageChannels, Permission_ManageMessages};
 * command.SetDefaultPermissionsMultiple(perms, sizeof(perms));
 */

// Helper function to convert permission enum to string
stock void DiscordPermissionToString(DiscordPermission perm, char[] buffer, int maxlen)
{
  if (perm < Permission_CreateInstantInvite || perm > Permission_UseClydeAI)
  {
    strcopy(buffer, maxlen, "0");
    return;
  }
  
  int result[2];
  int permInt = view_as<int>(perm);
  
  if (permInt < 32)
  {
    // Permission fits in lower 32 bits
    result[0] = 1 << permInt;
    result[1] = 0;
  }
  else
  {
    // Permission requires upper 32 bits
    result[0] = 0;
    result[1] = 1 << (permInt - 32);
  }
  
  // Convert 64-bit result to string
  Int64ToString(result, buffer, maxlen);
}

// helper function to combine multiple permissions into a bitmask string
stock void DiscordCombinePermissions(const DiscordPermission[] permissions, int numPermissions, char[] buffer, int maxlen)
{
  int combinedValue[2] = {0, 0}; // 64-bit integer as [lower32, upper32]
  
  for (int i = 0; i < numPermissions; i++)
  {
    DiscordPermission perm = permissions[i];
    
    // Skip invalid permissions
    if (perm < Permission_CreateInstantInvite || perm > Permission_UseClydeAI)
      continue;
    
    int permInt = view_as<int>(perm);
    
    if (permInt < 32)
    {
      combinedValue[0] |= (1 << permInt); // Set bit in lower 32 bits
    }
    else
    {
      combinedValue[1] |= (1 << (permInt - 32)); // Set bit in upper 32 bits
    }
  }
  
  // Convert 64-bit result back to string
  Int64ToString(combinedValue, buffer, maxlen);
}

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

typeset GetWebhookCallback
{
  function void (Discord discord, DiscordWebhook webhook, any data);
};

typeset GetUserCallback
{
  function void (Discord discord, DiscordUser user, any data);
};

typeset GetGuildCallback
{
  function void (Discord discord, DiscordGuild guild, any data);
};

typeset GetMessageCallback
{
  function void (Discord discord, DiscordMessage message, any data);
};

// Callback types for various Discord events
typeset DiscordReadyCallback
{
  function void (Discord discord, any data);
};

typeset DiscordMessageCallback
{
  function void (Discord discord, DiscordMessage message, any data);
};

typeset DiscordErrorCallback
{
  function void (Discord discord, const char[] error, any data);
};

typeset DiscordSlashCommandCallback
{
  function void (Discord discord, DiscordInteraction interaction, any data);
};

typeset DiscordAutocompleteCallback
{
  function void (Discord discord, DiscordAutocompleteInteraction interaction, bool focused, DiscordCommandOptionType type, const char[] name, any data);
};

/**
 * Discord bot client handle
 */
methodmap Discord < Handle {
  /**
   * Creates a new Discord bot client
   *
   * @param token     Discord bot token
   * @param intents   Optional Discord intents bitmask to control what events the bot receives (default: DISCORD_INTENTS_DEFAULT | Intent_MessageContent)
   * @return          New Discord client handle, or INVALID_HANDLE on failure
   * @note            If no intents specified, the bot will use all available intents for backward compatibility.
   *                  For better performance and compliance, specify only the intents you need.
   */
  public native Discord(const char[] token, DiscordIntents intents = DISCORD_INTENTS_DEFAULT | Intent_MessageContent);

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
  property bool IsRunning {
    public native get();
  }

  /**
   * Gets the uptime of the Discord bot in seconds
   *
   * @return             Bot uptime in seconds since connection
   */
  property int Uptime {
    public native get();
  }

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
   * @return          True if successful, false otherwise
   */
  property int BotDiscriminator {
    public native get();
  }

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
   * Sends a DiscordMessage object
   *
   * @param message   DiscordMessage object to send
   * @return          true on success, false on failure
   * @note            The message must have a channel ID set
   */
  public native bool SendDiscordMessage(DiscordMessage message);

  /**
   * Sends a DiscordMessage object to a specific channel
   *
   * @param channelId Target channel ID
   * @param message   DiscordMessage object to send
   * @return          true on success, false on failure
   * @note            This will override the channel ID in the message object
   */
  public native bool SendDiscordMessageToChannel(const char[] channelId, DiscordMessage message);

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

  /**
   * Sets the Ready callback for this bot instance
   *
   * @param callback   Callback function to call when bot is ready
   * @param data       Optional data to pass to callback
   */
  public native void SetReadyCallback(DiscordReadyCallback callback, any data = 0);

  /**
   * Sets the Message callback for this bot instance
   *
   * @param callback   Callback function to call when message is received
   * @param data       Optional data to pass to callback
   */
  public native void SetMessageCallback(DiscordMessageCallback callback, any data = 0);

  /**
   * Sets the Error callback for this bot instance
   *
   * @param callback   Callback function to call when error occurs
   * @param data       Optional data to pass to callback
   */
  public native void SetErrorCallback(DiscordErrorCallback callback, any data = 0);

  /**
   * Sets the Slash Command callback for this bot instance
   *
   * @param callback   Callback function to call when slash command is used
   * @param data       Optional data to pass to callback
   */
  public native void SetSlashCommandCallback(DiscordSlashCommandCallback callback, any data = 0);

  /**
   * Sets the Autocomplete callback for this bot instance
   *
   * @param callback   Callback function to call when autocomplete is requested
   * @param data       Optional data to pass to callback
   */
  public native void SetAutocompleteCallback(DiscordAutocompleteCallback callback, any data = 0);
}

/**
 * Discord user handle
 */
methodmap DiscordUser < Handle
{
  /**
   * Creates a DiscordUser object from user ID
   *
   * @param discord     Discord client handle to bind to this user
   * @param userId      User ID as string
   * @param guildId     Guild ID as string (optional, for member info)
   * @return            DiscordUser handle or INVALID_HANDLE on failure
   * @note              This creates a minimal user object. Use FetchUser for complete info.
   */
  public native DiscordUser(Discord discord, const char[] userId, const char[] guildId = "");
  
  /**
   * Fetches full user information from Discord API asynchronously
   *
   * @param discord     Discord client handle
   * @param userId      User ID as string
   * @param guildId     Guild ID as string (optional, for member info)
   * @param callback    Function to call when user info is received
   * @param data        Optional data to pass to callback
   * @return            true if request was sent, false on failure
   * @note              Available information: username, avatar, discriminator, public flags
   * @note              Limited information: MFA status and email verification are not available
   *                    to bots due to Discord privacy restrictions. Flags = 0 is normal for
   *                    regular users without special Discord badges.
   * @note              This method first checks the cache for user data. If found in cache,
   *                    the callback is called immediately. If not cached, an API request is made.
   */
  public static native bool FetchUser(Discord discord, const char[] userId, const char[] guildId = "", GetUserCallback callback, any data = 0);

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
  public native void GetUserName(char[] buffer, int maxlength);

  /**
   * Gets the discriminator of the user
   */
  property int Discriminator {
    public native get();
  }

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
   * Gets the default avatar url of the user
   *
   * @param buffer         Buffer to store the url
   * @param maxlength      Maximum length of the buffer
   */
  public native void GetDefaultAvatarUrl(char[] buffer, int maxlength);

  /**
   * Gets the avatar decoration url of the user (if they have one)
   *
   * @param size           Size of the avatar decoration in pixels (16-4096, power of 2)
   * @param buffer         Buffer to store the url
   * @param maxlength      Maximum length of the buffer
   */
  public native void GetAvatarDecorationUrl(int size, char[] buffer, int maxlength);

  /**
   * Gets the mention string for the user
   *
   * @param buffer         Buffer to store the mention
   * @param maxlength      Maximum length of the buffer
   */
  public native void GetMention(char[] buffer, int maxlength);

  /**
   * Gets the URL for the user's profile
   *
   * @param buffer         Buffer to store the url
   * @param maxlength      Maximum length of the buffer
   */
  public native void GetUrl(char[] buffer, int maxlength);

  /**
   * Gets the formatted username (username#discriminator or just username)
   *
   * @param buffer         Buffer to store the formatted username
   * @param maxlength      Maximum length of the buffer
   */
  public native void GetFormattedUsername(char[] buffer, int maxlength);

  /**
   * Gets the user's flags as a bitmask
   * @note flags = 0 is normal for regular users who don't have special Discord badges
   *       (Staff, VerifiedBot, ActiveDeveloper, etc.). Only users with special roles
   *       or achievements will have non-zero flag values.
   */
  property DiscordUserFlags Flags {
    public native get();
  }

  /**
   * Checks if the user has a specific flag
   *
   * @param flag          Flag to check from DiscordUserFlags enum
   * @return              true if user has the flag, false otherwise
   */
  public native bool HasFlag(DiscordUserFlags flag);

  /**
   * Checks if the user is a system user (Clyde)
   */
  property bool IsSystem {
    public native get();
  }

  /**
   * Checks if the user has multi-factor authentication enabled
   * @note May return false for users fetched via API due to Discord privacy restrictions
   */
  property bool IsMfaEnabled {
    public native get();
  }

  /**
   * Checks if the user is verified (verified email address)
   * @note May return false for users fetched via API due to Discord privacy restrictions
   */
  property bool IsVerified {
    public native get();
  }

  /**
   * Checks if the user has full nitro
   */
  property bool HasNitroFull {
    public native get();
  }

  /**
   * Checks if the user has nitro classic
   */
  property bool HasNitroClassic {
    public native get();
  }

  /**
   * Checks if the user has nitro basic
   */
  property bool HasNitroBasic {
    public native get();
  }

  /**
   * Checks if the user is a Discord employee
   */
  property bool IsDiscordEmployee {
    public native get();
  }

  /**
   * Checks if the user owns a partnered server
   */
  property bool IsPartneredOwner {
    public native get();
  }

  /**
   * Checks if the user has HypeSquad Events
   */
  property bool HasHypesquadEvents {
    public native get();
  }

  /**
   * Checks if the user has Bug Hunter level 1 badge
   */
  property bool IsBughunter1 {
    public native get();
  }

  /**
   * Checks if the user is in House Bravery
   */
  property bool IsHouseBravery {
    public native get();
  }

  /**
   * Checks if the user is in House Brilliance
   */
  property bool IsHouseBrilliance {
    public native get();
  }

  /**
   * Checks if the user is in House Balance
   */
  property bool IsHouseBalance {
    public native get();
  }

  /**
   * Checks if the user is an early supporter
   */
  property bool IsEarlySupporter {
    public native get();
  }

  /**
   * Checks if the user is a team user
   */
  property bool IsTeamUser {
    public native get();
  }

  /**
   * Checks if the user has Bug Hunter level 2 badge
   */
  property bool IsBughunter2 {
    public native get();
  }

  /**
   * Checks if the user is a verified bot
   */
  property bool IsVerifiedBot {
    public native get();
  }

  /**
   * Checks if the user is a verified bot developer
   */
  property bool IsVerifiedBotDev {
    public native get();
  }

  /**
   * Checks if the user is a certified moderator
   */
  property bool IsCertifiedModerator {
    public native get();
  }

  /**
   * Checks if the user is a bot using HTTP interactions
   */
  property bool IsBotHttpInteractions {
    public native get();
  }

  /**
   * Checks if the user has an animated icon
   */
  property bool HasAnimatedIcon {
    public native get();
  }

  /**
   * Checks if the user has the active developer badge
   */
  property bool IsActiveDeveloper {
    public native get();
  }

  /**
   * Checks if the user is a bot
   *
   * @return          true if user is bot, false otherwise
   */
  property bool IsBot {
    public native get();
  }

  /**
   * Checks if this user has guild member information available
   *
   * @return          true if guild member info is available, false otherwise
   */
  property bool HasGuildMember {
    public native get();
  }

  /**
   * Gets the nickname of the user in the guild
   *
   * @param buffer    Buffer to store the nickname
   * @param maxlength Maximum length of the buffer
   */
  public native void GetNickName(char[] buffer, int maxlength);

  /**
   * Gets the timestamp when the user joined the guild
   *
   * @param buffer    Buffer to store the timestamp
   * @param maxlength Maximum length of the buffer
   */
  public native void GetJoinedAt(char[] buffer, int maxlength);

  /**
   * Checks if the user is pending verification
   *
   * @return          true if user is pending, false otherwise
   */
  property bool IsPending {
    public native get();
  }

  /**
   * Checks if the user has a specific permission
   *
   * @param permission  Permission to check as string (e.g., "8" for administrator)
   * @return           true if user has permission, false otherwise
   */
  public native bool HasPermission(const char[] permission);

  /**
   * Checks if the user has a specific permission (enum version)
   *
   * @param permission  Permission to check from DiscordPermission enum
   * @return           true if user has permission, false otherwise
   */
  public bool HasPermissionEnum(DiscordPermission permission)
  {
    char permStr[32];
    DiscordPermissionToString(permission, permStr, sizeof(permStr));
    return this.HasPermission(permStr);
  }

  /**
   * Gets all permissions for the user
   *
   * @param buffer    Buffer to store the permissions as string
   * @param maxlength Maximum length of the buffer
   */
  public native void GetPermissions(char[] buffer, int maxlength);

  /**
   * Checks if the user has a specific permission in a channel
   *
   * @param channelId   Channel ID to check permissions in
   * @param permission  Permission to check as string
   * @return           true if user has permission in channel, false otherwise
   */
  public native bool HasPermissionInChannel(const char[] channelId, const char[] permission);

  /**
   * Checks if the user has a specific permission in a channel (enum version)
   *
   * @param channelId   Channel ID to check permissions in
   * @param permission  Permission to check from DiscordPermission enum
   * @return           true if user has permission in channel, false otherwise
   */
  public bool HasPermissionInChannelEnum(const char[] channelId, DiscordPermission permission)
  {
    char permStr[32];
    DiscordPermissionToString(permission, permStr, sizeof(permStr));
    return this.HasPermissionInChannel(channelId, permStr);
  }

  /**
   * Gets all permissions for the user in a specific channel
   *
   * @param channelId  Channel ID to check permissions in
   * @param buffer    Buffer to store the permissions as string
   * @param maxlength Maximum length of the buffer
   */
  public native void GetPermissionsInChannel(const char[] channelId, char[] buffer, int maxlength);

  /**
   * Gets all roles of the user
   *
   * @param roles     Array to store role IDs
   * @param maxSize   Maximum number of roles to retrieve
   * @return         Number of roles retrieved
   */
  public native int GetRoles(char[][] roles, int maxSize);

  /**
   * Checks if the user has a specific role
   *
   * @param roleId    Role ID to check
   * @return         true if user has role, false otherwise
   */
  public native bool HasRole(const char[] roleId);

  /**
   * Gets the highest role of the user
   *
   * @param buffer    Buffer to store the role ID
   * @param maxlength Maximum length of the buffer
   */
  public native void GetHighestRole(char[] buffer, int maxlength);

  /**
   * Gets the name of a specific role by role ID
   *
   * @param roleId    Role ID to get name for
   * @param buffer    Buffer to store the role name
   * @param maxlength Maximum length of the buffer
   * @return         true if role found, false otherwise
   */
  public native bool GetRoleName(const char[] roleId, char[] buffer, int maxlength);

  /**
   * Gets the names of all roles the user has
   *
   * @param roleNames Array to store role names
   * @param maxSize   Maximum number of role names to retrieve
   * @return         Number of role names retrieved
   */
  public native int GetRoleNames(char[][] roleNames, int maxSize);

  /**
   * Sets the nickname of the user in the guild
   *
   * @param nickname  New nickname to set (empty string to remove)
   * @return         true on success, false on failure
   */
  public native bool SetNickName(const char[] nickname);

  /**
   * Adds a role to the user
   *
   * @param roleId    Role ID to add
   * @return         true on success, false on failure
   */
  public native bool AddRole(const char[] roleId);

  /**
   * Removes a role from the user
   *
   * @param roleId    Role ID to remove
   * @return         true on success, false on failure
   */
  public native bool RemoveRole(const char[] roleId);

  /**
   * Kicks the user from the guild
   *
   * @return         true on success, false on failure
   */
  public native bool KickFromGuild();

  /**
   * Bans the user from the guild
   *
   * @param reason        Ban reason (optional)
   * @param delete_days   Days of messages to delete (0-7)
   * @return             true on success, false on failure
   */
  public native bool BanFromGuild(const char[] reason = "", int delete_days = 0);

  /**
   * Unbans the user from the guild
   *
   * @return         true on success, false on failure
   */
  public native bool UnbanFromGuild();

  /**
   * Sets a timeout for the user
   *
   * @param timeout_until Unix timestamp when timeout expires
   * @return             true on success, false on failure
   */
  public native bool SetTimeout(int timeout_until);

  /**
   * Removes timeout from the user
   *
   * @return         true on success, false on failure
   */
  public native bool RemoveTimeout();
}

/**
 * Discord guild handle
 */
methodmap DiscordGuild < Handle
{
  /**
   * Fetches guild information from Discord API asynchronously
   *
   * @param discord      Discord bot handle
   * @param guild_id     Guild ID to fetch
   * @param callback     Callback function to handle the response
   * @param data         Additional data to pass to callback
   * @return             true on success, false on failure
   * @note               This method first checks the cache for guild data. If found in cache,
   *                     the callback is called immediately. If not cached, an API request is made.
   */
  public static native bool FetchGuild(Discord discord, const char[] guild_id, GetGuildCallback callback, any data = 0);

  /**
   * Gets the guild ID
   *
   * @param buffer       Buffer to store the ID
   * @param maxlength    Maximum length of the buffer
   */
  public native void GetId(char[] buffer, int maxlength);

  /**
   * Gets the guild name
   *
   * @param buffer       Buffer to store the name
   * @param maxlength    Maximum length of the buffer
   */
  public native void GetName(char[] buffer, int maxlength);

  /**
   * Gets the guild description
   *
   * @param buffer       Buffer to store the description
   * @param maxlength    Maximum length of the buffer
   */
  public native void GetDescription(char[] buffer, int maxlength);

  /**
   * Gets the guild owner ID
   *
   * @param buffer       Buffer to store the owner ID
   * @param maxlength    Maximum length of the buffer
   */
  public native void GetOwnerId(char[] buffer, int maxlength);

  /**
   * Gets the guild member count
   *
   * @return             Member count
   */
  property int MemberCount {
    public native get();
  }

  /**
   * Gets the guild verification level
   *
   * @return             Verification level (0-4)
   */
  property GuildVerificationLevel VerificationLevel {
    public native get();
  }

  /**
   * Gets the guild premium tier (boost level)
   *
   * @return             Premium tier (0-3)
   */
  property GuildPremiumTier PremiumTier {
    public native get();
  }

  /**
   * Checks if the guild is large (over 250 members)
   *
   * @return             true if large, false otherwise
   */
  property bool IsLarge {
    public native get();
  }

  /**
   * Checks if the guild is verified
   *
   * @return             true if verified, false otherwise
   */
  property bool IsVerified {
    public native get();
  }

  /**
   * Checks if the guild is partnered
   *
   * @return             true if partnered, false otherwise
   */
  property bool IsPartnered {
    public native get();
  }

  /**
   * Gets the guild icon URL
   *
   * @param buffer           Buffer to store the URL
   * @param maxlength        Maximum length of the buffer
   * @param size             Icon size (default: 0 for default size)
   * @param prefer_animated  Whether to prefer animated version if available
   */
  public native void GetIconUrl(char[] buffer, int maxlength, int size = 0, bool prefer_animated = true);

  /**
   * Gets the guild banner URL
   *
   * @param buffer           Buffer to store the URL
   * @param maxlength        Maximum length of the buffer
   * @param size             Banner size (default: 0 for default size)
   * @param prefer_animated  Whether to prefer animated version if available
   */
  public native void GetBannerUrl(char[] buffer, int maxlength, int size = 0, bool prefer_animated = true);

  /**
   * Gets the guild splash URL
   *
   * @param buffer           Buffer to store the URL
   * @param maxlength        Maximum length of the buffer
   * @param size             Splash size (default: 0 for default size)
   */
  public native void GetSplashUrl(char[] buffer, int maxlength, int size = 0);

  /**
   * Gets the guild discovery splash URL
   *
   * @param buffer           Buffer to store the URL
   * @param maxlength        Maximum length of the buffer
   * @param size             Splash size (default: 0 for default size)
   */
  public native void GetDiscoverySplashUrl(char[] buffer, int maxlength, int size = 0);

  /**
   * Gets the guild vanity URL code
   *
   * @param buffer           Buffer to store the vanity URL code
   * @param maxlength        Maximum length of the buffer
   */
  public native void GetVanityUrlCode(char[] buffer, int maxlength);

  /**
   * Gets the maximum number of members for the guild
   */
  property int MaxMembers {
    public native get();
  }

  /**
   * Gets the maximum number of presences for the guild
   */
  property int MaxPresences {
    public native get();
  }

  /**
   * Gets the number of premium subscriptions (boosts)
   */
  property int PremiumSubscriptionCount {
    public native get();
  }

  /**
   * Gets the explicit content filter level
   */
  property GuildExplicitContentFilter ExplicitContentFilter {
    public native get();
  }

  /**
   * Gets the MFA level required for moderation actions  
   */
  property GuildMfaLevel MfaLevel {
    public native get();
  }

  /**
   * Gets the NSFW level of the guild
   */
  property GuildNsfwLevel NsfwLevel {
    public native get();
  }

  /**
   * Gets the AFK timeout in seconds
   */
  property GuildAfkTimeout AfkTimeout {
    public native get();
  }

  /**
   * Gets the default message notification level
   */
  property GuildDefaultMessageNotifications DefaultMessageNotifications {
    public native get();
  }

  /**
   * Gets the shard ID this guild is on
   */
  property int ShardId {
    public native get();
  }

  /**
   * Gets the guild flags bitmask
   */
  property GuildFlags Flags {
    public native get();
  }

  /**
   * Gets the additional guild flags bitmask
   */
  property GuildFlagsExtra FlagsExtra {
    public native get();
  }

  /**
   * Gets the AFK channel ID
   *
   * @param buffer           Buffer to store the channel ID
   * @param maxlength        Maximum length of the buffer
   */
  public native void GetAfkChannelId(char[] buffer, int maxlength);

  /**
   * Gets the system channel ID
   *
   * @param buffer           Buffer to store the channel ID
   * @param maxlength        Maximum length of the buffer
   */
  public native void GetSystemChannelId(char[] buffer, int maxlength);

  /**
   * Gets the rules channel ID
   *
   * @param buffer           Buffer to store the channel ID
   * @param maxlength        Maximum length of the buffer
   */
  public native void GetRulesChannelId(char[] buffer, int maxlength);

  /**
   * Gets the public updates channel ID
   *
   * @param buffer           Buffer to store the channel ID
   * @param maxlength        Maximum length of the buffer
   */
  public native void GetPublicUpdatesChannelId(char[] buffer, int maxlength);

  /**
   * Gets the safety alerts channel ID
   *
   * @param buffer           Buffer to store the channel ID
   * @param maxlength        Maximum length of the buffer
   */
  public native void GetSafetyAlertsChannelId(char[] buffer, int maxlength);

  /**
   * Checks if the guild is unavailable due to outage
   */
  property bool IsUnavailable {
    public native get();
  }

  /**
   * Checks if the guild widget is enabled
   */
  property bool WidgetEnabled {
    public native get();
  }

  /**
   * Checks if the guild has invite splash capability
   */
  property bool HasInviteSplash {
    public native get();
  }

  /**
   * Checks if the guild has VIP voice regions
   */
  property bool HasVipRegions {
    public native get();
  }

  /**
   * Checks if the guild has vanity URL capability
   */
  property bool HasVanityUrl {
    public native get();
  }

  /**
   * Checks if the guild is a community guild
   */
  property bool IsCommunity {
    public native get();
  }

  /**
   * Checks if the guild has role subscriptions enabled
   */
  property bool HasRoleSubscriptions {
    public native get();
  }

  /**
   * Checks if the guild has news channel capability
   */
  property bool HasNews {
    public native get();
  }

  /**
   * Checks if the guild is discoverable
   */
  property bool IsDiscoverable {
    public native get();
  }

  /**
   * Checks if the guild is featureable
   */
  property bool IsFeatureable {
    public native get();
  }

  /**
   * Checks if the guild has animated icon capability
   */
  property bool HasAnimatedIcon {
    public native get();
  }

  /**
   * Checks if the guild has banner capability
   */
  property bool HasBanner {
    public native get();
  }

  /**
   * Checks if the guild has welcome screen enabled
   */
  property bool IsWelcomeScreenEnabled {
    public native get();
  }

  /**
   * Checks if the guild has member verification gate
   */
  property bool HasMemberVerificationGate {
    public native get();
  }

  /**
   * Checks if the guild has preview enabled
   */
  property bool IsPreviewEnabled {
    public native get();
  }

  /**
   * Checks if the guild icon is animated
   */
  property bool HasAnimatedIconHash {
    public native get();
  }

  /**
   * Checks if the guild banner is animated
   */
  property bool HasAnimatedBannerHash {
    public native get();
  }

  /**
   * Checks if the guild has monetization enabled
   */
  property bool HasMonetizationEnabled {
    public native get();
  }

  /**
   * Checks if the guild has increased custom sticker slots
   */
  property bool HasMoreStickers {
    public native get();
  }

  /**
   * Checks if the guild has creator store page enabled
   */
  property bool HasCreatorStorePage {
    public native get();
  }

  /**
   * Checks if the guild can set role icons
   */
  property bool HasRoleIcons {
    public native get();
  }

  /**
   * Checks if the guild has seven day thread archive capability (deprecated)
   */
  property bool HasSevenDayThreadArchive {
    public native get();
  }

  /**
   * Checks if the guild has three day thread archive capability (deprecated)
   */
  property bool HasThreeDayThreadArchive {
    public native get();
  }

  /**
   * Checks if the guild has ticketed events enabled
   */
  property bool HasTicketedEvents {
    public native get();
  }

  /**
   * Checks if the guild has channel banners capability (deprecated)
   */
  property bool HasChannelBanners {
    public native get();
  }

  /**
   * Checks if the guild has premium progress bar enabled
   */
  property bool HasPremiumProgressBarEnabled {
    public native get();
  }

  /**
   * Checks if the guild has animated banner capability
   */
  property bool HasAnimatedBanner {
    public native get();
  }

  /**
   * Checks if the guild has auto moderation enabled
   */
  property bool HasAutoModeration {
    public native get();
  }

  /**
   * Checks if the guild has invites disabled
   */
  property bool HasInvitesDisabled {
    public native get();
  }

  /**
   * Checks if the guild is set as a support server
   */
  property bool HasSupportServer {
    public native get();
  }

  /**
   * Checks if the guild has role subscriptions available for purchase
   */
  property bool HasRoleSubscriptionsAvailableForPurchase {
    public native get();
  }

  /**
   * Checks if the guild has raid alerts disabled
   */
  property bool HasRaidAlertsDisabled {
    public native get();
  }

  // Notification settings (these check for DISABLED notifications)

  /**
   * Checks if join notifications are disabled
   */
  property bool NoJoinNotifications {
    public native get();
  }

  /**
   * Checks if boost notifications are disabled
   */
  property bool NoBoostNotifications {
    public native get();
  }

  /**
   * Checks if setup tips are disabled
   */
  property bool NoSetupTips {
    public native get();
  }

  /**
   * Checks if sticker greeting is disabled  
   */
  property bool NoStickerGreeting {
    public native get();
  }

  /**
   * Checks if role subscription notifications are disabled
   */
  property bool NoRoleSubscriptionNotifications {
    public native get();
  }

  /**
   * Checks if role subscription notification replies are disabled
   */
  property bool NoRoleSubscriptionNotificationReplies {
    public native get();
  }
  
  // Collection counts
  
  /**
   * Gets the number of roles in the guild
   */
  property int RoleCount {
    public native get();
  }
  
  /**
   * Gets the number of channels in the guild
   */
  property int ChannelCount {
    public native get();
  }
  
  /**
   * Gets the number of threads in the guild
   */
  property int ThreadCount {
    public native get();
  }
  
  /**
   * Gets the number of emojis in the guild
   */
  property int EmojiCount {
    public native get();
  }
  
  /**
   * Gets the number of members currently in voice channels
   */
  property int VoiceMemberCount {
    public native get();
  }
}

/**
 * Discord slash command handle
 */
methodmap DiscordSlashCommand < Handle
{
  /**
   * Creates a new Discord slash command
   *
   * @param discord     Discord client handle to bind to this command
   */
  public native DiscordSlashCommand(Discord discord);

  /**
   * Creates a DiscordSlashCommand from an existing global command ID
   *
   * @param discord     Discord client handle to bind to this command
   * @param commandId   Existing command ID to load
   */
  public static native DiscordSlashCommand FromGlobalCommand(Discord discord, const char[] commandId);

  /**
   * Creates a DiscordSlashCommand from an existing guild command ID
   *
   * @param discord     Discord client handle to bind to this command
   * @param commandId   Existing command ID to load
   * @param guildId     Guild ID where the command exists
   */
  public static native DiscordSlashCommand FromGuildCommand(Discord discord, const char[] commandId, const char[] guildId);

  /**
   * Sets the name of the slash command
   *
   * @param name      Command name
   */
  public native void SetName(const char[] name);

  /**
   * Sets the description of the slash command
   *
   * @param description Command description
   */
  public native void SetDescription(const char[] description);

  /**
   * Sets the default permissions for the slash command
   *
   * @param permissions Permission bitmask as string
   */
  public native void SetDefaultPermissions(const char[] permissions);

  /**
   * Sets the default permissions for the slash command (enum version)
   *
   * @param permission Permission from DiscordPermission enum
   */
  public void SetDefaultPermissionsEnum(DiscordPermission permission)
  {
    char permStr[32];
    DiscordPermissionToString(permission, permStr, sizeof(permStr));
    this.SetDefaultPermissions(permStr);
  }

  /**
   * Sets the default permissions for the slash command (multiple permissions)
   *
   * @param permissions Array of permissions from DiscordPermission enum
   * @param numPermissions Number of permissions in the array
   */
  public void SetDefaultPermissionsMultiple(const DiscordPermission[] permissions, int numPermissions)
  {
    char permStr[64];
    DiscordCombinePermissions(permissions, numPermissions, permStr, sizeof(permStr));
    this.SetDefaultPermissions(permStr);
  }

  /**
   * Gets the name of the slash command
   *
   * @param buffer    Buffer to store the name
   * @param maxlength Maximum length of buffer
   */
  public native void GetName(char[] buffer, int maxlength);

  /**
   * Gets the description of the slash command
   *
   * @param buffer    Buffer to store the description
   * @param maxlength Maximum length of buffer
   */
  public native void GetDescription(char[] buffer, int maxlength);

  /**
   * Gets the default permissions of the slash command
   *
   * @param buffer    Buffer to store the permissions
   * @param maxlength Maximum length of buffer
   */
  public native void GetDefaultPermissions(char[] buffer, int maxlength);

  /**
   * Adds an option to the slash command
   *
   * @param name         Option name
   * @param description  Option description
   * @param type         Option type from DiscordCommandOptionType enum
   * @param required     Whether the option is required
   * @param autocomplete Whether the option supports autocomplete
   */
  public native void AddOption(const char[] name, const char[] description, DiscordCommandOptionType type, bool required = false, bool autocomplete = false);

  /**
   * Adds a choice-based option to the slash command
   *
   * @param name        Option name
   * @param description Option description
   * @param type        Option type from DiscordCommandOptionType enum
   * @param required    Whether the option is required
   */
  public native void AddChoiceOption(const char[] name, const char[] description, DiscordCommandOptionType type, bool required = false);

  /**
   * Adds a string choice to the last added choice option
   *
   * @param choice_name  Display name of the choice
   * @param choice_value Value of the choice
   */
  public native void AddStringChoice(const char[] choice_name, const char[] choice_value);

  /**
   * Adds an integer choice to the last added choice option
   *
   * @param choice_name  Display name of the choice
   * @param choice_value Integer value of the choice
   */
  public native void AddIntChoice(const char[] choice_name, int choice_value);

  /**
   * Adds a float choice to the last added choice option
   *
   * @param choice_name  Display name of the choice
   * @param choice_value Float value of the choice
   */
  public native void AddFloatChoice(const char[] choice_name, float choice_value);

  /**
   * Registers the slash command to a specific guild
   *
   * @param guild_id  Guild ID to register the command to
   * @return         true on success, false otherwise
   */
  public native bool RegisterToGuild(const char[] guild_id);

  /**
   * Registers the slash command globally
   *
   * @return         true on success, false otherwise
   */
  public native bool RegisterGlobally();

  /**
   * Updates an existing slash command
   *
   * @param guild_id  Guild ID (empty string for global command)
   * @return         true on success, false otherwise
   */
  public native bool Update(const char[] guild_id = "");

  /**
   * Deletes a slash command
   *
   * @param guild_id  Guild ID (empty string for global command)
   * @return         true on success, false otherwise
   */
  public native bool Delete(const char[] guild_id = "");

  /**
   * Adds a permission override for the slash command
   * This overrides the default permissions for specific roles/users/channels
   *
   * @param target_id    ID of the role/user/channel
   * @param type        Permission type (role, user, or channel)
   * @param permission  Whether to allow (true) or deny (false) access
   */
  public native void AddPermissionOverride(const char[] target_id, DiscordCommandPermissionType type, bool permission);

  /**
   * Removes a permission override for the slash command
   *
   * @param target_id    ID of the role/user/channel
   * @param type        Permission type (role, user, or channel)
   */
  public native void RemovePermissionOverride(const char[] target_id, DiscordCommandPermissionType type);

  /**
   * Clears all permission overrides for the slash command
   * This removes all custom permission settings, reverting to default permissions
   */
  public native void ClearPermissionOverrides();

  /**
   * Number of permission overrides for the slash command
   */
  property int PermissionOverrideCount {
    public native get();
  }

  /**
   * Gets a permission override entry by index
   *
   * @param index       Permission override entry index
   * @param target_id   Buffer to store target ID
   * @param maxlen      Maximum length of target_id buffer
   * @param type        Variable to store permission type
   * @param permission  Variable to store permission value
   * @return           true if entry exists, false otherwise
   */
  public native bool GetPermissionOverride(int index, char[] target_id, int maxlen, DiscordCommandPermissionType &type, bool &permission);

  /**
   * Applies permission overrides to the slash command
   *
   * @param guild_id  Guild ID where the command exists
   * @return         true on success, false otherwise
   */
  public native bool ApplyPermissionOverrides(const char[] guild_id);

  /**
   * Controls the context menu type of the slash command
   */
  property DiscordContextMenuType ContextMenuType {
    public native get();
    public native set(DiscordContextMenuType type);
  }

  /**
   * Controls whether the command is age-restricted (NSFW)
   */
  property bool IsNSFW {
    public native get();
    public native set(bool nsfw);
  }

  /**
   * Controls whether the command can be used in DMs
   */
  property bool DMPermission {
    public native get();
    public native set(bool dm_permission);
  }

  /**
   * Adds a localization for the command name and description
   *
   * @param language     Language code (e.g., "en-US", "zh-CN")
   * @param name         Localized command name
   * @param description  Localized command description (optional)
   */
  public native void AddLocalization(const char[] language, const char[] name, const char[] description = "");

  /**
   * Sets interaction contexts where the command can be used
   *
   * @param contexts      Array of interaction context types
   * @param numContexts   Number of contexts in the array
   */
  public native void SetInteractionContexts(const DiscordInteractionContextType[] contexts, int numContexts);

  /**
   * Sets integration types for the command
   *
   * @param types     Array of integration types  
   * @param numTypes  Number of types in the array
   */
  public native void SetIntegrationTypes(const DiscordIntegrationType[] types, int numTypes);

  /**
   * Sets minimum value for numeric options (co_number/co_integer)
   *
   * @param min_value  Minimum value
   */
  public native void SetOptionMinValue(float min_value);

  /**
   * Sets maximum value for numeric options (co_number/co_integer)  
   *
   * @param max_value  Maximum value
   */
  public native void SetOptionMaxValue(float max_value);

  /**
   * Sets minimum length for string options (co_string)
   *
   * @param min_length  Minimum string length (0-6000)
   */
  public native void SetOptionMinLength(int min_length);

  /**
   * Sets maximum length for string options (co_string)
   *
   * @param max_length  Maximum string length (1-6000)  
   */
  public native void SetOptionMaxLength(int max_length);

  /**
   * Adds a channel type filter for channel options (co_channel)
   *
   * @param channel_type  Channel type from DiscordChannelType enum
   */
  public native void AddOptionChannelType(DiscordChannelType channel_type);

  /**
   * Gets the mention string for this slash command
   *
   * @param buffer     Buffer to store the mention string
   * @param maxlength  Maximum length of buffer
   */
  public native void GetMention(char[] buffer, int maxlength);

  /**
   * Gets the command ID (if created from existing command)
   *
   * @param buffer     Buffer to store the command ID
   * @param maxlength  Maximum length of buffer
   */
  public native void GetCommandId(char[] buffer, int maxlength);

  /**
   * Gets the guild ID (if this is a guild command)
   *
   * @param buffer     Buffer to store the guild ID
   * @param maxlength  Maximum length of buffer
   */
  public native void GetGuildId(char[] buffer, int maxlength);
}

/**
 * Discord message handle
 */
methodmap DiscordMessage < Handle
{
  /**
   * Creates a DiscordMessage object from message and channel IDs
   *
   * @param discord     Discord client handle to bind to this message
   * @param messageId   Message ID as string
   * @param channelId   Channel ID as string
   * @return            DiscordMessage handle or INVALID_HANDLE on failure
   * @note              This creates a minimal message object. Use FetchMessage for complete info.
   */
  public native DiscordMessage(Discord discord, const char[] messageId, const char[] channelId);

  /**
   * Creates an empty DiscordMessage object
   *
   * @param discord     Discord client handle to bind to this message
   * @return            DiscordMessage handle or INVALID_HANDLE on failure
   */
  public static native DiscordMessage CreateEmpty(Discord discord);

  /**
   * Creates a DiscordMessage object with content
   *
   * @param discord     Discord client handle
   * @param content     Message content
   * @return            DiscordMessage handle or INVALID_HANDLE on failure
   */
  public static native DiscordMessage CreateWithContent(Discord discord, const char[] content);

  /**
   * Creates a DiscordMessage object with channel and content
   *
   * @param discord     Discord client handle
   * @param channelId   Channel ID as string
   * @param content     Message content
   * @return            DiscordMessage handle or INVALID_HANDLE on failure
   */
  public static native DiscordMessage CreateWithChannel(Discord discord, const char[] channelId, const char[] content);

  /**
   * Creates a DiscordMessage object with an embed
   *
   * @param discord     Discord client handle
   * @param embed       DiscordEmbed handle
   * @return            DiscordMessage handle or INVALID_HANDLE on failure
   */
  public static native DiscordMessage CreateWithEmbed(Discord discord, DiscordEmbed embed);

  /**
   * Creates a DiscordMessage object with channel and embed
   *
   * @param discord     Discord client handle
   * @param channelId   Channel ID as string
   * @param embed       DiscordEmbed handle
   * @return            DiscordMessage handle or INVALID_HANDLE on failure
   */
  public static native DiscordMessage CreateWithChannelEmbed(Discord discord, const char[] channelId, DiscordEmbed embed);
  
  /**
   * Fetches full message information from Discord API asynchronously
   *
   * @param discord     Discord client handle
   * @param messageId   Message ID as string
   * @param channelId   Channel ID as string
   * @param callback    Function to call when message info is received
   * @param data        Optional data to pass to callback
   * @return            true if request was sent, false on failure
   * @note              Available information: content, author, timestamp, embeds, reactions, etc.
   * @note              This method makes an API request to fetch message data. Messages are not cached
   *                    by the Discord library due to memory constraints and privacy considerations.
   */
  public static native bool FetchMessage(Discord discord, const char[] messageId, const char[] channelId, GetMessageCallback callback, any data = 0);

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
   * @note Automatically managed - no need to manually free this handle
   */
  property DiscordUser Author {
    public native get();
  }

  /**
   * Gets the nickname of the message author within the guild this message was sent in
   *
   * @param buffer      Buffer to store the author nickname
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetAuthorNickname(char[] buffer, int maxlength);

  /**
   * Checks if the message is pinned
   *
   * @return          true if pinned, false otherwise
   */
  property bool IsPinned {
    public native get();
  }

  /**
   * Checks or set the message is TTS (Text-To-Speech)
   *
   * @return          true if TTS, false otherwise
   */
  property bool IsTTS {
    public native get();
    public native set(bool tts)
  }

  /**
   * Checks if the message mentions everyone
   *
   * @return          true if mentions everyone, false otherwise
   */
  property bool IsMentionEveryone {
    public native get();
  }

  /**
   * Checks if the message author is a bot
   *
   * @return          true if author is bot, false otherwise
   */
  property bool IsBot {
    public native get();
  }

  /**
   * Gets number of characters in the content
   * @note            not including any null-termination
   * 
   * @return          Length of the message content
   */
  property int ContentLength {
    public native get();
  }

  /**
   * Get or set message type
   * 
   * @return          Message type
   */
  property MessageType Type {
    public native get();
    public native set(MessageType Type);
  }

  /**
   * Edits this message content
   *
   * @param content   New message content
   * @return         true on success, false on failure
   */
  public native bool Edit(const char[] content);

  /**
   * Edits this message with embed
   *
   * @param content   New message content
   * @param embed     Embed object
   * @return         true on success, false on failure
   */
  public native bool EditEmbed(const char[] content, DiscordEmbed embed);

  /**
   * Deletes this message
   *
   * @return         true on success, false on failure
   */
  public native bool Delete();

  /**
   * Pins this message
   *
   * @return         true on success, false on failure
   */
  public native bool Pin();

  /**
   * Unpins this message
   *
   * @return         true on success, false on failure
   */
  public native bool Unpin();

  /**
   * Adds a reaction to this message
   *
   * @param emoji     Emoji to add (e.g., "👍" or "custom:123456789")
   * @return         true on success, false on failure
   */
  public native bool AddReaction(const char[] emoji);

  /**
   * Removes a reaction from this message
   *
   * @param emoji     Emoji to remove
   * @return         true on success, false on failure
   */
  public native bool RemoveReaction(const char[] emoji);

  /**
   * Removes all reactions from this message
   *
   * @return         true on success, false on failure
   */
  public native bool RemoveAllReactions();
  
  // Message flag properties
  /**
   * Gets or set the message flags
   */
  property MessageFlags Flags {
    public native get();
    public native set(MessageFlags Flags);
  }
  
  /**
   * Returns true if the message was crossposted to other servers
   */
  property bool IsCrossposted {
    public native get();
  }
  
  /**
   * Returns true if posted from other servers announcement channel via webhook
   */
  property bool IsCrosspost {
    public native get();
  }
  
  /**
   * True if embeds have been removed
   */
  property bool EmbedsSuppressed {
    public native get();
  }
  
  /**
   * True if source message was deleted
   */
  property bool IsSourceMessageDeleted {
    public native get();
  }
  
  /**
   * True if urgent
   */
  property bool IsUrgent {
    public native get();
  }
  
  /**
   * True if has thread attached
   */
  property bool HasThread {
    public native get();
  }
  
  /**
   * True if ephemeral (visible only to issuer of a slash command)
   */
  property bool IsEphemeral {
    public native get();
  }
  
  /**
   * True if loading
   */
  property bool IsLoading {
    public native get();
  }
  
  /**
   * Returns true if this message failed to mention some roles and add their members to the thread
   */
  property bool IsThreadMentionFailed {
    public native get();
  }
  
  /**
   * True if the message will not trigger push and desktop notifications
   */
  property bool NotificationsSuppressed {
    public native get();
  }
  
  /**
   * True if the message is a voice message
   */
  property bool IsVoiceMessage {
    public native get();
  }
  
  /**
   * True if the message has a snapshot
   */
  property bool HasSnapshot {
    public native get();
  }
  
  /**
   * True if the message is using components v2
   */
  property bool IsUsingComponentsV2 {
    public native get();
  }
  
  /**
   * Gets when this message was sent (timestamp)
   */
  property int Timestamp {
    public native get();
  }
  
  /**
   * Gets when this message was edited (timestamp, 0 if never edited)
   */
  property int EditedTimestamp {
    public native get();
  }
  
  /**
   * Gets the nonce used for message validation
   */
  public native void GetNonce(char[] buffer, int maxlength);
  
  /**
   * Returns true if the message is from a DM
   */
  property bool IsDM {
    public native get();
  }
  
  /**
   * Returns true if message has remixed attachment
   */
  property bool HasRemixAttachment {
    public native get();
  }
  
  /**
   * Gets the URL to this message
   */
  public native void GetURL(char[] buffer, int maxlength);
  
  /**
   * Gets the number of attachments
   */
  property int AttachmentCount {
    public native get();
  }
  
  /**
   * Gets the number of embeds  
   */
  property int EmbedCount {
    public native get();
  }
  
  /**
   * Gets the number of reactions
   */
  property int ReactionCount {
    public native get();
  }
  
  /**
   * Gets the number of stickers
   */
  property int StickerCount {
    public native get();
  }
  
  /**
   * Gets the number of mentioned users
   */
  property int MentionedUserCount {
    public native get();
  }
  
  /**
   * Gets the number of mentioned roles
   */
  property int MentionedRoleCount {
    public native get();
  }
  
  /**
   * Gets the number of mentioned channels
   */
  property int MentionedChannelCount {
    public native get();
  }
  
  /**
   * Gets attachment filename by index
   */
  public native void GetAttachmentFilename(int index, char[] buffer, int maxlength);
  
  /**
   * Gets attachment URL by index
   */
  public native void GetAttachmentURL(int index, char[] buffer, int maxlength);
  
  /**
   * Gets attachment size by index (in bytes)
   */
  public native int GetAttachmentSize(int index);
  
  /**
   * Gets mentioned user ID by index
   */
  public native void GetMentionedUserId(int index, char[] buffer, int maxlength);
  
  /**
   * Gets mentioned role ID by index
   */
  public native void GetMentionedRoleId(int index, char[] buffer, int maxlength);

  /**
   * Gets the webhook ID if message was sent by webhook
   */
  public native void GetWebhookId(char[] buffer, int maxlength);

  /**
   * Sets the message content
   *
   * @param content     New message content
   */
  public native void SetContent(const char[] content);

  /**
   * Sets the channel ID for this message
   *
   * @param channelId   Channel ID as string
   */
  public native void SetChannelId(const char[] channelId);

  /**
   * Sets the nonce for message validation
   *
   * @param nonce       Nonce string
   */
  public native void SetNonce(const char[] nonce);

  /**
   * Adds an embed to this message
   *
   * @param embed       DiscordEmbed handle to add
   */
  public native void AddEmbed(DiscordEmbed embed);

  /**
   * Clears all embeds from this message
   */
  public native void ClearEmbeds();

  /**
   * Sends this message to its channel
   *
   * @return           true on success, false on failure
   */
  public native bool Send();
  
  /**
   * Creates a reply to this message
   */
  public native bool Reply(const char[] content);
  
  /**
   * Creates a reply to this message with embed
   */
  public native bool ReplyEmbed(const char[] content, DiscordEmbed embed);
  
  /**
   * Crossposts this message (publish to following channels)
   */
  public native bool Crosspost();
  
  /**
   * Creates a thread from this message
   */
  public native bool CreateThread(const char[] name, int auto_archive_duration = 60);
}

/**
 * Discord channel handle
 */
methodmap DiscordChannel < Handle
{
  /**
   * Creates a new Discord Channel handle from channel ID
   *
   * @param discord     Discord client handle to bind to this channel
   * @param channelId   Channel ID
   * @return            New Discord channel handle, or INVALID_HANDLE on failure
   * @note              This creates a minimal channel object. Use FetchChannel for complete info.
   */
  public native DiscordChannel(Discord discord, const char[] channelId);
  
  /**
   * Fetches full channel information from Discord API asynchronously
   *
   * @param discord     Discord client handle
   * @param channelId   Channel ID as string
   * @param callback    Function to call when channel info is received
   * @param data        Optional data to pass to callback
   * @return            true if request was sent, false on failure
   * @note              Callback signature: void MyCallback(Discord discord, DiscordChannel channel, any data)
   * @note              Available information: name, type, topic, permissions, parent category, etc.
   * @note              This method first checks the cache for channel data. If found in cache,
   *                    the callback is called immediately. If not cached, an API request is made.
   */
  public static native bool FetchChannel(Discord discord, const char[] channelId, GetChannelCallback callback, any data = 0);

  /**
   * Gets the name of the channel
   *
   * @param buffer      Buffer to store the name
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetName(char[] buffer, int maxlength);
  
  /**
   * Gets the ID of the channel
   *
   * @param buffer      Buffer to store the ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetId(char[] buffer, int maxlength);
  
  /**
   * Gets the guild (server) ID of the channel
   *
   * @param buffer      Buffer to store the guild ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetGuildId(char[] buffer, int maxlength);
  
  /**
   * Gets the parent ID of the channel (category for channels, channel for threads)
   *
   * @param buffer      Buffer to store the parent ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetParentId(char[] buffer, int maxlength);
  
  /**
   * Gets the topic of the channel
   *
   * @param buffer      Buffer to store the topic
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetTopic(char[] buffer, int maxlength);
  
  /**
   * Gets the type of the channel
   *
   * @return           Channel type from DiscordChannelType enum
   */
  property DiscordChannelType Type {
    public native get();
  }
  
  /**
   * Controls the position of the channel
   */
  property int Position {
    public native get();
    public native set(int position);
  }
  
  /**
   * Controls whether the channel is NSFW
   */
  property bool IsNSFW {
    public native get();
    public native set(bool nsfw);
  }
  
  /**
   * Checks if the channel is a text channel
   *
   * @return           true if text channel, false otherwise
   */
  property bool IsTextChannel {
    public native get();
  }
  
  /**
   * Checks if the channel is a voice channel
   *
   * @return           true if voice channel, false otherwise
   */
  property bool IsVoiceChannel {
    public native get();
  }
  
  /**
   * Checks if the channel is a category
   *
   * @return           true if category, false otherwise
   */
  property bool IsCategory {
    public native get();
  }
  
  /**
   * Checks if the channel is a thread
   *
   * @return           true if thread, false otherwise
   */
  property bool IsThread {
    public native get();
  }
  
  /**
   * Checks if the channel is a forum
   *
   * @return           true if forum, false otherwise
   */
  property bool IsForum {
    public native get();
  }
  
  /**
   * Checks if the channel is a news/announcement channel
   *
   * @return           true if news channel, false otherwise
   */
  property bool IsNewsChannel {
    public native get();
  }
  
  /**
   * Checks if the channel is a stage channel
   *
   * @return           true if stage channel, false otherwise
   */
  property bool IsStageChannel {
    public native get();
  }
  
  /**
   * Controls the bitrate of the voice channel (voice channels only)
   */
  property int Bitrate {
    public native get();
    public native set(int bitrate);
  }
  
  /**
   * Controls the user limit of the voice channel (voice channels only)
   */
  property int UserLimit {
    public native get();
    public native set(int limit);
  }
  
  /**
   * Controls the rate limit per user (slowmode) in seconds
   */
  property int RateLimitPerUser {
    public native get();
    public native set(int seconds);
  }
  
  /**
   * Gets the mention string for this channel
   *
   * @param buffer      Buffer to store the mention string
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetMention(char[] buffer, int maxlength);
  
  /**
   * Gets the URL for this channel
   *
   * @param buffer      Buffer to store the URL
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetUrl(char[] buffer, int maxlength);

  /**
   * Sets the name of the channel
   *
   * @param name      New channel name
   * @return         true on success, false on failure
   */
  public native bool SetName(const char[] name);
  
  // Additional channel properties and flags
  /**
   * Gets the channel flags
   */
  property ChannelFlags Flags {
    public native get();
  }
  
  /**
   * Gets the owner ID (for group DMs or threads)
   */
  public native void GetOwnerId(char[] buffer, int maxlength);
  
  /**
   * Gets the last message ID
   */
  public native void GetLastMessageId(char[] buffer, int maxlength);
  
  /**
   * Gets the last pin timestamp
   */
  property int LastPinTimestamp {
    public native get();
  }
  
  /**
   * Gets the default thread rate limit per user
   */
  property int DefaultThreadRateLimitPerUser {
    public native get();
  }
  
  /**
   * Gets the default auto archive duration for threads
   */
  property AutoArchiveDuration DefaultAutoArchiveDuration {
    public native get();
  }
  
  /**
   * Gets the default forum sort order
   */
  property ForumSortOrder DefaultSortOrder {
    public native get();
  }
  
  /**
   * Gets the forum layout type
   */
  property ForumLayoutType ForumLayout {
    public native get();
  }
  
  /**
   * Gets the RTC region for voice channels
   */
  public native void GetRTCRegion(char[] buffer, int maxlength);
  
  /**
   * Returns true if the channel is a DM
   */
  property bool IsDM {
    public native get();
  }
  
  /**
   * Returns true if the channel is a group DM
   */
  property bool IsGroupDM {
    public native get();
  }
  
  /**
   * Returns true if the channel is a media channel
   */
  property bool IsMediaChannel {
    public native get();
  }
  
  /**
   * Returns true if video quality is 720p
   */
  property bool IsVideo720p {
    public native get();
  }
  
  /**
   * Returns true if video quality is auto
   */
  property bool IsVideoAuto {
    public native get();
  }
  
  /**
   * Returns true if thread is pinned in forum
   */
  property bool IsPinnedThread {
    public native get();
  }
  
  /**
   * Returns true if tag is required for forum threads
   */
  property bool IsTagRequired {
    public native get();
  }
  
  /**
   * Returns true if download options are hidden in media channel
   */
  property bool IsDownloadOptionsHidden {
    public native get();
  }
  
  /**
   * Returns true if permissions are locked (inherit from category)
   */
  property bool IsLockedPermissions {
    public native get();
  }
  
  // Channel modification methods
  /**
   * Sets the topic of the channel
   */
  public native bool SetTopic(const char[] topic);
  
  /**
   * Sets the bitrate of voice channel (in kbps)
   */
  public native bool SetBitrate(int bitrate);
  
  /**
   * Sets the parent ID (category for channels)
   */
  public native bool SetParentId(const char[] parent_id);
  
  /**
   * Sets the RTC region for voice channels
   */
  public native bool SetRTCRegion(const char[] region);
  
  // Permission management
  /**
   * Adds permission overwrite for a user or role
   */
  public native bool AddPermissionOverwrite(const char[] target_id, OverwriteType type, const char[] allowed, const char[] denied);
  
  /**
   * Sets permission overwrite for a user or role (replaces existing)
   */
  public native bool SetPermissionOverwrite(const char[] target_id, OverwriteType type, const char[] allowed, const char[] denied);
  
  /**
   * Removes permission overwrite for a user or role
   */
  public native bool RemovePermissionOverwrite(const char[] target_id, OverwriteType type);
  
  /**
   * Gets user permissions in this channel
   */
  public native void GetUserPermissions(const char[] user_id, char[] buffer, int maxlength);
  
  // Channel actions
  /**
   * Deletes the channel
   */
  public native bool Delete();
  
  /**
   * Creates an invite for the channel
   */
  public native bool CreateInvite(int max_age = 86400, int max_uses = 0, bool temporary = false, bool unique = false);
  
  /**
   * Sends a message to the channel
   */
  public native bool SendMessage(const char[] content);
  
  /**
   * Sends a message with embed to the channel
   */
  public native bool SendMessageEmbed(const char[] content, DiscordEmbed embed);

  /**
   * Sends a DiscordMessage object to this channel
   *
   * @param message   DiscordMessage object to send
   * @return          true on success, false on failure
   * @note            This will set the channel ID in the message object to this channel
   */
  public native bool SendDiscordMessage(DiscordMessage message);
  
  /**
   * Gets the icon URL for group DM channels
   */
  public native void GetIconUrl(char[] buffer, int maxlength, int size = 0);
  
  /**
   * Gets the number of permission overwrites
   */
  property int PermissionOverwriteCount {
    public native get();
  }
  
  /**
   * Gets permission overwrite target ID by index
   */
  public native void GetPermissionOverwriteTargetId(int index, char[] buffer, int maxlength);
  
  /**
   * Gets permission overwrite type by index
   */
  public native OverwriteType GetPermissionOverwriteType(int index);
  
  /**
   * Gets the number of available tags (forum channels)
   */
  property int AvailableTagCount {
    public native get();
  }
  
  /**
   * Gets available tag name by index
   */
  public native void GetAvailableTagName(int index, char[] buffer, int maxlength);
  
  /**
   * Gets available tag ID by index
   */
  public native void GetAvailableTagId(int index, char[] buffer, int maxlength);

  /**
   * Gets available tag emoji by index (returns emoji ID for custom emojis, unicode for standard emojis)
   */
  public native void GetAvailableTagEmoji(int index, char[] buffer, int maxlength);

  /**
   * Checks if available tag is moderated by index (requires MANAGE_THREADS permission to add/remove)
   */
  public native bool GetAvailableTagModerated(int index);

  /**
   * Checks if available tag emoji is custom (has ID) vs unicode
   */
  public native bool GetAvailableTagEmojiIsCustom(int index);

  /**
   * Creates a new forum tag
   *
   * @param name         Tag name (max 20 characters)
   * @param emoji        Tag emoji (custom emoji ID or unicode character, optional)
   * @param moderated    Whether tag requires MANAGE_THREADS permission to add/remove
   * @return            true on success, false on failure
   */
  public native bool CreateForumTag(const char[] name, const char[] emoji = "", bool moderated = false);

  /**
   * Edits an existing forum tag
   *
   * @param tag_id       Tag ID to edit
   * @param name         New tag name (max 20 characters)
   * @param emoji        New tag emoji (custom emoji ID or unicode character, optional)  
   * @param moderated    Whether tag requires MANAGE_THREADS permission to add/remove
   * @return            true on success, false on failure
   */
  public native bool EditForumTag(const char[] tag_id, const char[] name, const char[] emoji = "", bool moderated = false);

  /**
   * Deletes a forum tag
   *
   * @param tag_id       Tag ID to delete
   * @return            true on success, false on failure
   */
  public native bool DeleteForumTag(const char[] tag_id);

  /**
   * Creates a new thread in this forum channel
   *
   * @param name              Thread name
   * @param message           Initial message content
   * @param tag_ids           Array of tag IDs to apply to the thread
   * @param tag_count         Number of tags in the array
   * @param auto_archive      Auto archive duration in minutes (60, 1440, 4320, 10080)
   * @param rate_limit        Rate limit per user in seconds (0-21600)
   * @return                 true on success, false on failure
   */
  public native bool CreateForumThread(const char[] name, const char[] message, const char[][] tag_ids = {}, int tag_count = 0, int auto_archive = 1440, int rate_limit = 0);

  /**
   * Creates a new thread in this forum channel with embed
   *
   * @param name              Thread name
   * @param message           Initial message content
   * @param embed             Embed to include in initial message
   * @param tag_ids           Array of tag IDs to apply to the thread
   * @param tag_count         Number of tags in the array
   * @param auto_archive      Auto archive duration in minutes (60, 1440, 4320, 10080)
   * @param rate_limit        Rate limit per user in seconds (0-21600)
   * @return                 true on success, false on failure
   */
  public native bool CreateForumThreadEmbed(const char[] name, const char[] message, DiscordEmbed embed, const char[][] tag_ids = {}, int tag_count = 0, int auto_archive = 1440, int rate_limit = 0);

  /**
   * Sets the parent category of the channel
   *
   * @param parent_id Parent category ID
   * @return         true on success, false on failure
   */
  public native bool SetParent(const char[] parent_id);
}

/**
 * Discord forum tag handle
 */
methodmap DiscordForumTag < Handle
{
  /**
   * Creates a new Discord Forum Tag object
   *
   * @param name         Tag name (max 20 characters)
   * @param emoji        Tag emoji (custom emoji ID or unicode character, optional)
   * @param moderated    Whether tag requires MANAGE_THREADS permission to add/remove
   * @return            New DiscordForumTag handle, or INVALID_HANDLE on failure
   */
  public native DiscordForumTag(const char[] name, const char[] emoji = "", bool moderated = false);

  /**
   * Gets the ID of the forum tag
   *
   * @param buffer      Buffer to store the tag ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetId(char[] buffer, int maxlength);

  /**
   * Gets the name of the forum tag
   *
   * @param buffer      Buffer to store the tag name
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetName(char[] buffer, int maxlength);

  /**
   * Sets the name of the forum tag
   *
   * @param name        New tag name (max 20 characters)
   */
  public native void SetName(const char[] name);

  /**
   * Gets the emoji of the forum tag
   *
   * @param buffer      Buffer to store the emoji (ID for custom, unicode for standard)
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetEmoji(char[] buffer, int maxlength);

  /**
   * Sets the emoji of the forum tag
   *
   * @param emoji       Tag emoji (custom emoji ID or unicode character)
   */
  public native void SetEmoji(const char[] emoji);

  /**
   * Checks if the forum tag is moderated
   */
  property bool IsModerated {
    public native get();
    public native set(bool moderated);
  }

  /**
   * Checks if the tag emoji is a custom emoji (has ID) vs unicode
   */
  property bool EmojiIsCustom {
    public native get();
  }

  /**
   * Applies this tag to a channel (used when creating/editing forum channels)
   *
   * @param channel     Forum channel to apply the tag to
   * @return           true on success, false on failure
   */
  public native bool ApplyToChannel(DiscordChannel channel);
}

/**
 * Discord webhook handle
 */
methodmap DiscordWebhook < Handle
{
  /**
   * Creates a new Discord Webhook
   *
   * @param webhookUrl  Webhook Url
   * @return            New Discord webhook handle, or INVALID_HANDLE on failure
   */
  public native DiscordWebhook(const char[] webhookUrl);

  /**
   * Creates a new Discord Webhook from ID and Token (Static method)
   *
   * @param webhookId   Webhook ID
   * @param webhookToken Webhook Token
   * @return            New Discord webhook handle, or INVALID_HANDLE on failure
   * @note              This creates a minimal webhook object. Use GetWebhook for complete info.
   */
  public static native DiscordWebhook CreateFromIdToken(const char[] webhookId, const char[] webhookToken);

  /**
   * Fetches full webhook information from Discord API asynchronously
   *
   * @param discord     Discord client handle
   * @param webhookId   Webhook ID
   * @param callback    Function to call when webhook info is received
   * @param data        Optional data to pass to callback
   * @return            DiscordWebhook handle with complete info, or INVALID_HANDLE on failure
   * @note              This method first checks the cache for webhook data. If found in cache,
   *                    the handle is returned immediately. If not cached, an API request is made.
   */
  public static native bool FetchWebhook(Discord discord, const char[] webhookId, GetWebhookCallback callback, any data = 0);

  /**
   * Gets the ID of the webhook
   *
   * @param buffer      Buffer to store the ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetId(char[] buffer, int maxlength);

  /**
   * Gets the user that created the webhook
   * @note Automatically managed - no need to manually free this handle
   */
  property DiscordUser User {
    public native get();
  }

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
   * @param name    New string to set the name to
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
   * @param name    New string to set the avatar_url to
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
   * @param name    New string to set the avatar to
   */
  public native void SetAvatarData(char[] avatar);

  /**
   * Gets the webhook type
   */
  property DiscordWebhookType Type {
    public native get();
  }

  /**
   * Gets the guild ID of the webhook
   *
   * @param buffer      Buffer to store the guild ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetGuildId(char[] buffer, int maxlength);

  /**
   * Gets the channel ID of the webhook
   *
   * @param buffer      Buffer to store the channel ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetChannelId(char[] buffer, int maxlength);

  /**
   * Gets the token of the webhook
   *
   * @param buffer      Buffer to store the token
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetToken(char[] buffer, int maxlength);

  /**
   * Gets the application ID of the webhook
   *
   * @param buffer      Buffer to store the application ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetApplicationId(char[] buffer, int maxlength);

  /**
   * Gets the source guild ID of the webhook (for channel follower webhooks)
   *
   * @param buffer      Buffer to store the source guild ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetSourceGuildId(char[] buffer, int maxlength);

  /**
   * Gets the source channel ID of the webhook (for channel follower webhooks)
   *
   * @param buffer      Buffer to store the source channel ID
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetSourceChannelId(char[] buffer, int maxlength);

  /**
   * Gets the URL of the webhook (read-only)
   *
   * @param buffer      Buffer to store the URL
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetUrl(char[] buffer, int maxlength);

  /**
   * Gets the image data of the webhook (read-only)
   *
   * @param buffer      Buffer to store the image data
   * @param maxlength   Maximum length of the buffer
   */
  public native void GetImageData(char[] buffer, int maxlength);

  /**
   * Modifies this webhook
   *
   * @return         true on success, false on failure
   */
  public native bool Modify();

  /**
   * Deletes this webhook
   *
   * @return         true on success, false on failure
   */
  public native bool Delete();

  /**
   * Executes this webhook with a message
   *
   * @param message   Message content to send
   * @param allowed_mentions_mask  Allowed mentions mask
   * @param allowed_users_mentions Array of allowed user mentions
   * @param allowed_user_size      Size of allowed users array
   * @param allowed_roles_mentions Array of allowed role mentions
   * @param allowed_roles_size     Size of allowed roles array
   * @return         true on success, false on failure
   */
  public native bool Execute(const char[] message, int allowed_mentions_mask = 0, const char[][] allowed_users_mentions = {}, int allowed_user_size = 0, const char[][] allowed_roles_mentions = {}, int allowed_roles_size = 0);

  /**
   * Executes this webhook with a message and embed
   *
   * @param message   Message content to send
   * @param embed     Embed object to include
   * @param allowed_mentions_mask  Allowed mentions mask
   * @param allowed_users_mentions Array of allowed user mentions
   * @param allowed_user_size      Size of allowed users array
   * @param allowed_roles_mentions Array of allowed role mentions
   * @param allowed_roles_size     Size of allowed roles array
   * @return         true on success, false on failure
   */
  public native bool ExecuteEmbed(const char[] message, DiscordEmbed embed, int allowed_mentions_mask = 0, const char[][] allowed_users_mentions = {}, int allowed_user_size = 0, const char[][] allowed_roles_mentions = {}, int allowed_roles_size = 0);

  /**
   * Creates a webhook for a channel (Static method)
   *
   * @param discord     Discord client handle
   * @param channelId   Target channel ID
   * @param name        Name of the webhook to be created
   * @param callback    Method to run on success
   * @param data        Arbitrary value to pass to the callback
   * @return            true on success, false on failure
   */
  public static native bool CreateWebhook(Discord discord, const char[] channelId, const char[] name, CreateWebhookCallback callback, any data = 0);

  /**
   * Gets all webhooks assigned to a channel (Static method)
   *
   * @param discord     Discord client handle
   * @param channelId   Target channel ID
   * @param callback    Method to run on success
   * @param data        Arbitrary value to pass to the callback
   * @return            true on success, false on failure
   */
  public static native bool GetChannelWebhooks(Discord discord, const char[] channelId, GetChannelWebhooksCallback callback, any data = 0);
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

  /**
   * Sets the embed video URL
   *
   * @param url       Video URL
   */
  public native void SetVideo(const char[] url);

  /**
   * Sets the embed provider information
   *
   * @param name      Provider name
   * @param url       Provider URL (optional)
   */
  public native void SetProvider(const char[] name, const char[] url = "");

  /**
   * Gets the embed title
   *
   * @param buffer    Buffer to store the title
   * @param maxlength Maximum length of the buffer
   */
  public native void GetTitle(char[] buffer, int maxlength);

  /**
   * Gets the embed description
   *
   * @param buffer    Buffer to store the description
   * @param maxlength Maximum length of the buffer
   */
  public native void GetDescription(char[] buffer, int maxlength);

  /**
   * Controls the embed color
   */
  property int Color {
    public native get();
    public native set(int color);
  }

  /**
   * Gets or sets the embed timestamp (Unix timestamp)
   */
  property int Timestamp {
    public native get();
    public native set(int timestamp);
  }

  /**
   * Gets the embed type
   *
   * @param buffer    Buffer to store the type
   * @param maxlength Maximum length of the buffer
   */
  public native void GetType(char[] buffer, int maxlength);

  /**
   * Gets the embed URL
   *
   * @param buffer    Buffer to store the URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed author name
   *
   * @param buffer    Buffer to store the author name
   * @param maxlength Maximum length of the buffer
   */
  public native void GetAuthorName(char[] buffer, int maxlength);

  /**
   * Gets the embed author URL
   *
   * @param buffer    Buffer to store the author URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetAuthorUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed author icon URL
   *
   * @param buffer    Buffer to store the author icon URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetAuthorIconUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed author proxy icon URL
   *
   * @param buffer    Buffer to store the author proxy icon URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetAuthorProxyIconUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed footer text
   *
   * @param buffer    Buffer to store the footer text
   * @param maxlength Maximum length of the buffer
   */
  public native void GetFooterText(char[] buffer, int maxlength);

  /**
   * Gets the embed footer icon URL
   *
   * @param buffer    Buffer to store the footer icon URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetFooterIconUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed footer proxy URL
   *
   * @param buffer    Buffer to store the footer proxy URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetFooterProxyUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed thumbnail URL
   *
   * @param buffer    Buffer to store the thumbnail URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetThumbnailUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed thumbnail proxy URL
   *
   * @param buffer    Buffer to store the thumbnail proxy URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetThumbnailProxyUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed thumbnail width
   */
  property int ThumbnailWidth {
    public native get();
  }

  /**
   * Gets the embed thumbnail height
   */
  property int ThumbnailHeight {
    public native get();
  }

  /**
   * Gets the embed image URL
   *
   * @param buffer    Buffer to store the image URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetImageUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed image proxy URL
   *
   * @param buffer    Buffer to store the image proxy URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetImageProxyUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed image width
   */
  property int ImageWidth {
    public native get();
  }

  /**
   * Gets the embed image height
   */
  property int ImageHeight {
    public native get();
  }

  /**
   * Gets the embed video URL
   *
   * @param buffer    Buffer to store the video URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetVideoUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed video proxy URL
   *
   * @param buffer    Buffer to store the video proxy URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetVideoProxyUrl(char[] buffer, int maxlength);

  /**
   * Gets the embed video width
   */
  property int VideoWidth {
    public native get();
  }

  /**
   * Gets the embed video height
   */
  property int VideoHeight {
    public native get();
  }

  /**
   * Gets the embed provider name
   *
   * @param buffer    Buffer to store the provider name
   * @param maxlength Maximum length of the buffer
   */
  public native void GetProviderName(char[] buffer, int maxlength);

  /**
   * Gets the embed provider URL
   *
   * @param buffer    Buffer to store the provider URL
   * @param maxlength Maximum length of the buffer
   */
  public native void GetProviderUrl(char[] buffer, int maxlength);

  /**
   * Number of fields in the embed
   */
  property int FieldCount {
    public native get();
  }

  /**
   * Gets the name of a field by index
   *
   * @param index     Field index (0-based)
   * @param buffer    Buffer to store the field name
   * @param maxlength Maximum length of the buffer
   * @return         true if field exists, false otherwise
   */
  public native bool GetFieldName(int index, char[] buffer, int maxlength);

  /**
   * Gets the value of a field by index
   *
   * @param index     Field index (0-based)
   * @param buffer    Buffer to store the field value
   * @param maxlength Maximum length of the buffer
   * @return         true if field exists, false otherwise
   */
  public native bool GetFieldValue(int index, char[] buffer, int maxlength);

  /**
   * Gets whether a field is inline by index
   *
   * @param index     Field index (0-based)
   * @return         true if field is inline, false otherwise
   */
  public native bool GetFieldInline(int index);

  /**
   * Removes a field by index
   *
   * @param index     Field index (0-based)
   * @return         true if field was removed, false otherwise
   */
  public native bool RemoveField(int index);

  /**
   * Clears all fields from the embed
   */
  public native void ClearFields();

  /**
   * Checks if the embed has a thumbnail set
   */
  property bool HasThumbnail {
    public native get();
  }

  /**
   * Checks if the embed has an image set
   */
  property bool HasImage {
    public native get();
  }

  /**
   * Checks if the embed has a video set
   */
  property bool HasVideo {
    public native get();
  }

  /**
   * Checks if the embed has provider information set
   */
  property bool HasProvider {
    public native get();
  }

  /**
   * Checks if the embed has author information set
   */
  property bool HasAuthor {
    public native get();
  }

  /**
   * Checks if the embed has footer information set
   */
  property bool HasFooter {
    public native get();
  }

  /**
   * Checks if the embed has a timestamp set
   */
  property bool HasTimestamp {
    public native get();
  }
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
   * @note Automatically managed - no need to manually free this handle
   */
  property DiscordUser User {
    public native get();
  }

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
   * @note Automatically managed - no need to manually free this handle
   */
  property DiscordUser User {
    public native get();
  }

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
   * @param name    The name that will appear to the user for this autocomplete result
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
  public native void CreateAutocompleteResponse();
}

public Extension __ext_discord = 
{
  name = "Discord",
  file = "discord.ext",
  autoload = 1,
  required = 1,
};