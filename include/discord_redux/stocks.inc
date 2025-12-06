#include <discord_redux/steam>
#include <discord_redux/embeds>
#include <discord_redux/shared/navmesh>

stock int GetOnlinePlayers()
{
    int playerCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsClientSourceTV(i) || IsClientReplay(i) || IsFakeClient(i))
            continue;
        playerCount++;
    }
    return playerCount;
}

stock int GetBotCount()
{
    int botCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsClientSourceTV(i) || IsClientReplay(i))
            continue;
        if (IsFakeClient(i))
            botCount++;
    }
    return botCount;
}

stock int GetMaxPlayers()
{
    int maxplayers = GetMaxHumanPlayers();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientSourceTV(i) || IsClientReplay(i))
            maxplayers--;
    }
    return maxplayers;
}

stock void TF2_GetRoundState(char[] buffer, int maxlen)
{
    switch (GameRules_GetRoundState())
    {
        case RoundState_Preround:
        {
            strcopy(buffer, maxlen, "Pre-Round");
        }
        case RoundState_RoundRunning:
        {
            strcopy(buffer, maxlen, "Round Started");
        }
        case RoundState_TeamWin:
        {
            strcopy(buffer, maxlen, "Round Ended");
        }
        case RoundState_Restart:
        {
            strcopy(buffer, maxlen, "Round Restarted");
        }
        case RoundState_Stalemate:
        {
            switch (GetEngineVersion())
            {
                case Engine_TF2: strcopy(buffer, maxlen, "Sudden Death");
                default:         strcopy(buffer, maxlen, "Stalemate");
            }
        }
        case RoundState_GameOver:
        {
            strcopy(buffer, maxlen, "Game Over");
        }
        case RoundState_Bonus:
        {
            strcopy(buffer, maxlen, "Bonus Round");
        }
        case RoundState_BetweenRounds:
        {
            strcopy(buffer, maxlen, "Between Rounds");
        }
        case RoundState_Init:
        {
            strcopy(buffer, maxlen, "Initializing");
        }
        case RoundState_Pregame:
        {
            strcopy(buffer, maxlen, "Pregame");
        }
        case RoundState_StartGame:
        {
            strcopy(buffer, maxlen, "Starting Game");
        }
        default:
        {
            strcopy(buffer, maxlen, "❓");
        }
    }

    if (GameRules_GetProp("m_bInOvertime") == 1)
    {
        strcopy(buffer, maxlen, "Overtime");
    }
    else if (GameRules_GetProp("m_bInSetup") == 1)
    {
        strcopy(buffer, maxlen, "Setup");
    }
    else if (GameRules_GetProp("m_bInWaitingForPlayers") == 1)
    {
        strcopy(buffer, maxlen, "Waiting For Players");
    }
    else if (GameRules_GetProp("m_bTruceActive") == 1)
    {
        strcopy(buffer, maxlen, "Truce");
    }
}