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
            strcopy(buffer, maxlen, "Sudden Death");
        }
        case RoundState_GameOver:
        {
            strcopy(buffer, maxlen, "Game Over");
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
}