#define SERIDER_PREFIX "[{#3A68B2}Serider.TF{default}]"
#define DISCORD_INVITE "{#5865F2}https://discord.serider.net/{default}"

stock void SetNameColor(int client)
{
    int red, green, blue, alpha;
    GetEntityRenderColor(client, red, green, blue, alpha);

    int colorCode = (red << 16) | (green << 8) | blue;

    char colorString[16];
    FormatEx(colorString, sizeof(colorString), "{#%06X}", colorCode);

    if (!IsPlayerAlive(client)) return;
    
    ChatProcessor_SetNameColor(client, colorString);
}

stock char[] GetPlayerName(int client)
{
    static char buffer[MAX_NAME_LENGTH + 16]; // 16 for color codes
    char name[MAX_NAME_LENGTH];
    GetClientName(client, name, sizeof(name));

    char color[8];
    TFTeam team = TF2_GetClientTeam(client);
    switch (team)
    {
        case TFTeam_Red:
        {
            strcopy(color, sizeof(color), "{red}");
        }
        case TFTeam_Blue:
        {
            strcopy(color, sizeof(color), "{blue}");
        }
        default:
        {
            strcopy(color, sizeof(color), "{gray}");
        }
    }

    FormatEx(buffer, sizeof(buffer), "%s%s{default}", color, name);
    return buffer;
}