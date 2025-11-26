methodmap TFResource
{
    /**
     * Constructor to create a TFResource object out of a tf_objective_resource entity.
     *
     * @param entity Entity index.
     * @return       Entity index as a TFResource object.
     */
    public TFResource(int entity)
    {
        return view_as<TFResource>(entity);
    }

    property int index
    {
        public get()
        {
            return view_as<int>(this);
        }
    }

    /**
     * Gets the name of the current MvM popfile.
     *
     * @param name      The buffer to store the popfile name.
     * @param maxlen    The maximum length of the buffer.
     * @return          The length of the popfile name, returns 0 if not found.
     */
    public int GetName(char[] buffer, int maxlen)
    {
        if (this.index == -1) return 0;

        char name[128];
        GetEntPropString(this.index , Prop_Send, "m_iszMvMPopfileName", name, sizeof(name));
        return strcopy(buffer, maxlen, name[19]);
    }
}