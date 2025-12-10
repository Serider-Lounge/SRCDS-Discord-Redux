#include <discord_redux/steam/apps>
#include <discord_redux/steam/clients>
#include <discord_redux/steam/workshop>

methodmap GameInfo
{
    /**
     * Gets the app id from gameinfo.txt.
     *
     * @return Game appid.
     */
    property int appid
    {
        public get()
        {
            KeyValues kv = new KeyValues("GameInfo");
            if (!kv.ImportFromFile("gameinfo.txt"))
            {
                delete kv;
                return 0;
            }
            if (!kv.JumpToKey("FileSystem"))
            {
                delete kv;
                return 0;
            }
            int appid = kv.GetNum("SteamAppId", 0);
            delete kv;
            return appid;
        }
    }



    /**
     * Gets the game name from gameinfo.txt.
     * 
     * @param buffer Buffer to store game name.
     * @param maxlen Maximum length of buffer.
     */
    public void GetKey(const char[] key, char[] buffer, int maxlen)
    {
        KeyValues kv = new KeyValues("GameInfo");
        if (!kv.ImportFromFile("gameinfo.txt"))
        {
            delete kv;
            return;
        }
        kv.GetString(key, buffer, maxlen);
        delete kv;
    }

    /**
     * Gets the game name from gameinfo.txt.
     * 
     * @param buffer Buffer to store game name.
     * @param maxlen Maximum length of buffer.
     */
    public void GetGameName(char[] buffer, int maxlen)
    {
        this.GetKey("game", buffer, maxlen);
    }

    /**
     * Gets the developer name from gameinfo.txt.
     * 
     * @param buffer Buffer to store developer name.
     * @param maxlen Maximum length of buffer.
     */
    public void GetDeveloperName(char[] buffer, int maxlen)
    {
        this.GetKey("developer", buffer, maxlen);
    }

    /**
     * Gets the developer URL from gameinfo.txt.
     * 
     * @param buffer Buffer to store developer URL.
     * @param maxlen Maximum length of buffer.
     */
    public void GetDeveloperURL(char[] buffer, int maxlen)
    {
        this.GetKey("developer_url", buffer, maxlen);
    }
}