#include <regex>

Handle g_hWordFilterRegex = INVALID_HANDLE;

// Call this after g_WordBlacklist is set/changed
void WordFilter_Compile()
{
    if (g_hWordFilterRegex != INVALID_HANDLE)
    {
        CloseHandle(g_hWordFilterRegex);
        g_hWordFilterRegex = INVALID_HANDLE;
    }

    // Only compile if blacklist is not empty
    if (g_WordBlacklist[0] == '\0')
    {
        // No pattern, nothing to filter
        return;
    }

    char error[128];
    RegexError errcode;
    g_hWordFilterRegex = CompileRegex(g_WordBlacklist, PCRE_CASELESS, error, sizeof(error), errcode);
    if (g_hWordFilterRegex == INVALID_HANDLE)
    {
        PrintToServer("[Discord | WordFilter] Failed to compile regex: %s", error);
    }
}

// Returns true if the text matches the blacklist regex, optionally outputs the detected word
bool WordFilter_IsBlocked(const char[] text, char[] detectedWord = "")
{
    if (g_WordBlacklist[0] == '\0' || g_hWordFilterRegex == INVALID_HANDLE)
        return false;
    RegexError err;
    int matches = MatchRegex(g_hWordFilterRegex, text, err);
    if (matches > 0)
    {
        // Extract the first match (group 0)
        char match[256];
        if (GetRegexSubString(g_hWordFilterRegex, 0, match, sizeof(match)))
        {
            strcopy(detectedWord, 256, match);
        }
        else
        {
            detectedWord[0] = '\0';
        }
        return true;
    }
    return false;
}