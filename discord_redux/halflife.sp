enum AppID
{
    App_Unknown        = 0,         /**< Unknown or unsupported */
    App_Original       = 2400,      /**< The Ship */
    App_DarkMessiah    = 2110,      /**< Dark Messiah Multiplayer */
    App_SourceSDK2006  = 380,       /**< Half-Life 2: Episode One */
    App_SourceSDK2007  = 469,       /**< The Orange Box */
    App_BloodyGoodTime = 2450,      /**< Bloody Good Time */
    App_EYE            = 91700,     /**< E.Y.E Divine Cybermancy */
    App_Portal2        = 620,       /**< Portal 2 */
    App_CSS            = 240,       /**< Counter-Strike: Source */
    App_Left4Dead      = 500,       /**< Left 4 Dead */
    App_Left4Dead2     = 550,       /**< Left 4 Dead 2 */
    App_AlienSwarm     = 630,       /**< Alien Swarm */
    App_CSGO           = 749,       /**< Counter-Strike: Global Offensive */
    App_DOTA           = 570,       /**< Dota 2 */
    App_HL2DM          = 320,       /**< Half-Life 2 Deathmatch */
    App_DODS           = 300,       /**< Day of Defeat: Source */
    App_TF2            = 440,       /**< Team Fortress 2 */
    App_NuclearDawn    = 17710,     /**< Nuclear Dawn */
    App_SDK2013        = 243750,    /**< Source SDK 2013 Multiplayer */
    App_Blade          = 225600,    /**< Blade Symphony */
    App_Insurgency     = 222880,    /**< Insurgency */
    App_Contagion      = 238430,    /**< Contagion */
    App_BlackMesa      = 362890,    /**< Black Mesa Multiplayer */
    App_DOI            = 447820,    /**< Day of Infamy */
    App_PVKII          = 17570,     /**< Pirates, Vikings, and Knights II */
    App_MCV            = 1012110    /**< Military Conflict: Vietnam */
}

stock int GetAppID()
{
    switch (GetEngineVersion())
    {
        case Engine_Original:       return App_Original;
        case Engine_DarkMessiah:    return App_DarkMessiah;
        case Engine_SourceSDK2006:  return App_SourceSDK2006;
        case Engine_SourceSDK2007:  return App_SourceSDK2007;
        case Engine_BloodyGoodTime: return App_BloodyGoodTime;
        case Engine_EYE:            return App_EYE;
        case Engine_Portal2:        return App_Portal2;
        case Engine_CSS:            return App_CSS;
        case Engine_Left4Dead:      return App_Left4Dead;
        case Engine_Left4Dead2:     return App_Left4Dead2;
        case Engine_AlienSwarm:     return App_AlienSwarm;
        case Engine_CSGO:           return App_CSGO;
        case Engine_DOTA:           return App_DOTA;
        case Engine_HL2DM:          return App_HL2DM;
        case Engine_DODS:           return App_DODS;
        case Engine_TF2:            return App_TF2;
        case Engine_NuclearDawn:    return App_NuclearDawn;
        case Engine_SDK2013:        return App_SDK2013;
        case Engine_Blade:          return App_Blade;
        case Engine_Insurgency:     return App_Insurgency;
        case Engine_Contagion:      return App_Contagion;
        case Engine_BlackMesa:      return App_BlackMesa;
        case Engine_DOI:            return App_DOI;
        case Engine_PVKII:          return App_PVKII;
        case Engine_MCV:            return App_MCV;
        default:                    return App_Unknown;
    }
}