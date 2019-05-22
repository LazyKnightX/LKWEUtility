#ifndef LKStringIncluded
#define LKStringIncluded

/**
 * StringUtility.j
 *
 * Version: 1.0.0
 * Public:
 *   ModifyStringChar(string source, integer pos, string char) -> string
 *   ReplaceStringPiece(string source, integer start, integer end, string value) -> string
 */

 //! zinc

library LKString
{
    public function ModifyStringChar(string source, integer pos, string char) -> string
    {
        string before = SubStringBJ(source, 1, pos - 1);
        string after = SubStringBJ(source, pos + 1, StringLength(source));
        return before + char + after;
    }

    public function ReplaceStringPiece(string source, integer start, integer end, string value) -> string
    {
        string before = SubStringBJ(source, 1, start - 1);
        string after = SubStringBJ(source, end + 1, StringLength(source));
        return before + value + after;
    }

    public function IsStringNullOrEmpty(string source) -> boolean
    {
        return source == null || source == "" || StringLength(source) == 0;
    }
}

//! endzinc

#endif
