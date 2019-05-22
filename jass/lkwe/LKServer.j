// 参数：
// #define ServerType 1

// 参数说明：
// ServerType: 1 - DzAPI, 2 - GameCache(TODO), 3 - 11API(TODO), 4 - SyAPI(TODO)

#ifndef ServerType
    [Error] Should Define "ServerType".
#endif

library LKServer requires LKData
{
    private function GetPlayerCacheStringKey(player whichPlayer) -> integer
    {
        return StringHash("PlayerCacheString" + I2S(GetPlayerId(whichPlayer)));
    }
    private function GetPlayerCacheString(player whichPlayer, string key) -> string
    {
        return LoadStr(ht, GetPlayerCacheStringKey(whichPlayer), StringHash(key));
    }
    private function SetPlayerCacheString(player whichPlayer, string key, string value)
    {
        SaveStr(ht, GetPlayerCacheStringKey(whichPlayer), StringHash(key), value);
    }
    private function HasPlayerCacheString(player whichPlayer, string key) -> boolean
    {
        string value = GetPlayerCacheString(whichPlayer, key); 
        return value != null && StringLength(value) > 0;
    }

    private function GetPlayerServerDefaultVString() -> string
    {
        return "000000000000000000000000000000000000000000000000000000000000000";
    }

    public function GetPlayerServerString(player whichPlayer, string key) -> string
    {
        string value;

        if (HasPlayerCacheString(whichPlayer, key) == false)
        {
            #if ServerType == 1
                value = DzAPI_Map_GetServerValue(whichPlayer, "S" + key);
            #endif

            SetPlayerCacheString(whichPlayer, key, value);
        }

        return GetPlayerCacheString(whichPlayer, key);
    }
    public function SetPlayerServerString(player whichPlayer, string key, string value)
    {
        #if ServerType == 1
            DzAPI_Map_SaveServerValue(whichPlayer, "S" + key, value);
        #endif

        SetPlayerCacheString(whichPlayer, key, value);
    }
    public function GetPlayerServerStringOrDefault(player whichPlayer, string key, string default) -> string
    {
        string value;

        value = GetPlayerServerString(whichPlayer, key);

        if (IsStringNullOrEmpty(value))
        {
            SetPlayerServerString(whichPlayer, key, default);

            return default;
        }
        else
        {
            return value;
        }
    }

    public function GetPlayerServerVStringPiece(player whichPlayer, string key, integer pos, integer length) -> integer
    {
        string value, piece;
        integer start, end;

        start = pos;
        end = start + (length - 1);
        value = GetPlayerServerStringOrDefault(whichPlayer, key, GetPlayerServerDefaultVString());
        piece = SubStringBJ(value, start, end);

        return ConvertVStringToInteger(piece);
    }
    public function SetPlayerServerVStringPiece(player whichPlayer, string key, integer pos, integer length, integer value)
    {
        string vstr, newVStr;
        integer start, end;

        start = pos;
        end = start + (length - 1);
        vstr = GetPlayerServerStringOrDefault(whichPlayer, key, GetPlayerServerDefaultVString());
        newVStr = ReplaceStringPiece(vstr, start, end, ConvertIntegerToVString(value, length));

        SetPlayerServerString(whichPlayer, key, newVStr);
    }
}
