// 参数：
// #define ServerType 1

// 参数说明：
// ServerType: 1 - DzAPI

library LKServer requires LKString
{
  function GetPlayerServerString(player whichPlayer, string key) -> string
  {
    #if ServerType == 1
      return DzAPI_Map_GetServerValue(whichPlayer, "S" + key);
    #endif
  }

  function SetPlayerServerString(player whichPlayer, string key, string value) -> nothing
  {
    #if ServerType == 1
      DzAPI_Map_SaveServerValue(whichPlayer, "S" + key, value);
    #endif
  }

  function GetPlayerServerStringPiece(player whichPlayer, string key, integer start, integer end) -> string
  {
    string str, piece;
    str = GetPlayerServerString(whichPlayer, key);
    piece = SubStringBJ(str, start, end);
    return piece;
  }

  function SetPlayerServerStringPiece(player whichPlayer, string key, integer start, integer end, string value) -> nothing
  {
    string str = GetPlayerServerString(whichPlayer, key);
    string newStr = ReplaceStringPiece(str, value, start, end);
    SetPlayerServerString(whichPlayer, key, value);
  }
}
