stock bool IsNavLoaded(bool file_detection=false)
{
    if (file_detection)
    {
        char navPath[PLATFORM_MAX_PATH];
        char mapName[PLATFORM_MAX_PATH];
        GetCurrentMap(mapName, sizeof(mapName));
        Format(navPath, sizeof(navPath), "maps/%s.nav", mapName);
        
        return FileExists(navPath, true);
    }

    // Thanks Dysphie‼
    int navMeshCheck = CreateEntityByName("info_target");
    SetVariantString("NetProps.SetPropInt(self, \"m_spawnflags\", NavMesh.GetNavAreaCount())");
    AcceptEntityInput(navMeshCheck, "RunScriptCode");
    int flags = GetEntProp(navMeshCheck, Prop_Data, "m_spawnflags");
    bool navMeshLoaded = flags > 0;
    RemoveEntity(navMeshCheck);

    return navMeshLoaded;
}