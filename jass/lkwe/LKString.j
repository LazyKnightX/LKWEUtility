/**
 * StringUtility.j
 *
 * Version: 1.0.0
 * Public:
 *   ModifyStringChar(string source, integer pos, string char) -> string
 *   ReplaceStringPiece(string source, integer posStart, integer posEnd, string value) -> string
 */

library LKString
{
  public function ModifyStringChar(string source, integer pos, string char) -> string
  {
    string before = SubStringBJ(source, 1, pos - 1);
    string after = SubStringBJ(source, pos + 1, StringLength(source));
    return before + char + after;
  }

  public function ReplaceStringPiece(string source, integer posStart, integer posEnd, string value) -> string
  {
    string before = SubStringBJ(source, 1, posStart - 1);
    string after = SubStringBJ(source, posEnd + 1, StringLength(source));
    return before + value + after;
  }
}
