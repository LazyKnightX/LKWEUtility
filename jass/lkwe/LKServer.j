#ifndef LKServerIncluded
#define LKServerIncluded

#include "lkwe/LKData.j"
#include "DzAPI.j"

// 参数：
// #define ServerType 1
// #define ServerStringMaxLength 63

// 参数说明：
// ServerType: 1 - DzAPI, 2 - GameCache(TODO), 3 - 11API(TODO), 4 - SyAPI(TODO)

#ifndef ServerType
    [Error] Should Define "ServerType".
#endif

#ifndef ServerStringMaxLength
    [Error] Should Define "ServerStringMaxLength".
#endif

//! zinc

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

            return value;
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

    // startPage, endPage: 0 ~ (N - 1)
    //! textmacro serverVStringGeneralCalculatePiece

        startPos = pos;
        endPos = startPos + (length - 1);

        startPage = (startPos - 1) / ServerStringMaxLength;
        endPage = (endPos - 1) / ServerStringMaxLength;

        needNextPage = endPage > startPage;

        startPosInPage = ModuloInteger(startPos - 1, ServerStringMaxLength) + 1;
        endPosInPage = ModuloInteger(endPos - 1, ServerStringMaxLength) + 1;

    //! endtextmacro

    public function GetPlayerServerVStringPieceSource(player whichPlayer, string key, integer pos, integer length) -> string
    {
        string vstr, piece, piece1, piece2;
        integer startPos, endPos, startPage, endPage, startPosInPage, endPosInPage;
        boolean needNextPage;

        //! runtextmacro serverVStringGeneralCalculatePiece()

        if (needNextPage)
        {
            vstr = GetPlayerServerStringOrDefault(whichPlayer, key + "[" + I2S(startPage) + "]", GetPlayerServerDefaultVString());
            piece1 = SubStringBJ(vstr, startPosInPage, ServerStringMaxLength);

            vstr = GetPlayerServerStringOrDefault(whichPlayer, key + "[" + I2S(endPage) + "]", GetPlayerServerDefaultVString());
            piece2 = SubStringBJ(vstr, 1, endPosInPage);

            piece = piece1 + piece2;

            BJDebugMsg("GetPlayerServerVStringPieceSource - needNextPage");
            BJDebugMsg("startPage: " + I2S(startPage));
            BJDebugMsg("endPage: " + I2S(endPage));
            BJDebugMsg("startPosInPage: " + I2S(startPosInPage));
            BJDebugMsg("endPosInPage: " + I2S(endPosInPage));
            BJDebugMsg("piece1: " + piece1);
            BJDebugMsg("piece2: " + piece2);
            BJDebugMsg("piece: " + piece);
        }
        else
        {
            vstr = GetPlayerServerStringOrDefault(whichPlayer, key + "[" + I2S(startPage) + "]", GetPlayerServerDefaultVString());
            piece = SubStringBJ(vstr, startPosInPage, endPosInPage);
        }

        return piece;
    }
    public function GetPlayerServerVStringPiece(player whichPlayer, string key, integer pos, integer length) -> integer
    {
        return ConvertVStringToInteger(GetPlayerServerVStringPieceSource(whichPlayer, key, pos, length));
    }
    public function SetPlayerServerVStringPiece(player whichPlayer, string key, integer pos, integer length, integer value)
    {
        string vstr, vstr1, vstr2, newVStr, newVStr1, newVStr2, startPart, endPart, replace, replace1, replace2;
        integer startPos, endPos, startPage, endPage, startPosInPage, endPosInPage;
        boolean needNextPage;

        //! runtextmacro serverVStringGeneralCalculatePiece()

        replace = ConvertIntegerToVString(value, length);

        if (StringLength(replace) > length)
        {
            BJDebugMsg("错误：SetPlayerServerVStringPiece 存档失败，长度超过限制！已取消本次存档！");
            BJDebugMsg("key, pos, length, value: " + key + " " + I2S(pos) + I2S(length) + I2S(value));
            return;
        }

        if (needNextPage)
        {
            replace1 = SubStringBJ(replace, 1, ServerStringMaxLength - (startPosInPage - 1));
            replace2 = SubStringBJ(replace, StringLength(replace1) + 1, StringLength(replace));

            vstr1 = GetPlayerServerStringOrDefault(whichPlayer, key + "[" + I2S(startPage) + "]", GetPlayerServerDefaultVString());
            vstr2 = GetPlayerServerStringOrDefault(whichPlayer, key + "[" + I2S(endPage) + "]", GetPlayerServerDefaultVString());

            BJDebugMsg("SetPlayerServerVStringPiece - needNextPage");
            BJDebugMsg("startPosInPage: " + I2S(startPosInPage));
            BJDebugMsg("ServerStringMaxLength: " + I2S(ServerStringMaxLength));
            BJDebugMsg("endPosInPage: " + I2S(endPosInPage));
            BJDebugMsg("replace1: " + replace1);
            BJDebugMsg("replace2: " + replace2);
            newVStr1 = ReplaceStringPiece(vstr1, startPosInPage, ServerStringMaxLength, replace1);
            newVStr2 = ReplaceStringPiece(vstr2, 1, endPosInPage, replace2);

            SetPlayerServerString(whichPlayer, key + "[" + I2S(startPage) + "]", newVStr1);
            SetPlayerServerString(whichPlayer, key + "[" + I2S(endPage) + "]", newVStr2);
        }
        else
        {
            vstr = GetPlayerServerStringOrDefault(whichPlayer, key + "[" + I2S(startPage) + "]", GetPlayerServerDefaultVString());

            newVStr = ReplaceStringPiece(vstr, startPosInPage, endPosInPage, replace);

            SetPlayerServerString(whichPlayer, key + "[" + I2S(startPage) + "]", newVStr);
        }
    }
    public function DeletePlayerServerVStringPiece(player whichPlayer, string key, integer page)
    {
        SetPlayerServerString(whichPlayer, key + "[" + I2S(page) + "]", null);
    }
}

//! endzinc

#endif
