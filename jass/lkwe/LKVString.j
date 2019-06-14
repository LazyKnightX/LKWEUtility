#ifndef LKVStringIncluded
#define LKVStringIncluded

/**
 * VString.j
 *
 * Public:
 *   ConvertIntegerToVString(integer value, integer length) -> string
 *   ConvertVStringToInteger(string vstring) -> integer
 *   PickVStringValue(string vstring, integer begin, integer end) -> integer
 * Todo:
 *   Optimize debug info and overflow protection.
 *   Backward compatible feature implement.
 */

//! zinc

library LKVString
{
  // field
    private string VSTRINGCHARMAP = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()`~-_=+[]{}\\/|?;:'\",.<>"; // CHARMAP中不含"0"，但"0"会在实际使用中作为最低值的标记
    private integer VSTRINGCHARMAPLENGTH; // length: 93+1 (\\和\"对应单个字符，此外需要补充没有手动填入的“0”)
  // converter
    private function ConvertIntegerToVChar(integer value) -> string
    {
      string vchar;

      // Prevent Overflow
      if (value > VSTRINGCHARMAPLENGTH)
      {
        value = VSTRINGCHARMAPLENGTH;
      }

      if (value == 0)
      {
        vchar = "0";
      }
      else
      {
        vchar = SubStringBJ(VSTRINGCHARMAP, value, value);
      }

      // BJDebugMsg("ConvertIntegerToVChar:" + I2S(value) + " -> " + vchar);

      return vchar;
    }
    private function ConvertVCharToInteger(string vchar) -> integer
    {
      integer pos = 0;

      if (vchar == "0") return 0;

      while (pos <= VSTRINGCHARMAPLENGTH)
      {
        pos += 1;
        if (SubStringBJ(VSTRINGCHARMAP, pos, pos) == vchar)
        {
          return pos;
        }
      }

      return 0;
    }
    // length: should better be equal or lower than 4.
    public function ConvertIntegerToVString(integer value, integer length) -> string
    {
      integer posValue[];
      integer charCount = 0;
      string vString = "";
      integer padZeroCount;
      integer maxValue;
      integer index;
      string posChar;

      // length为5时maxValue就会超过INT32上限，因此防溢出功能只能在length小于或等于4时有效。
      if (length <= 4)
      {
        maxValue = R2I(Pow(I2R(VSTRINGCHARMAPLENGTH), length) - 1); // (10^4 = 10000) and need (length = 4), so, maxValue should be (10000-1 = 9999) because (length = 4).
        BJDebugMsg("maxValue:" + I2S(maxValue));
        if (value > maxValue)
        {
          value = maxValue;
        }
      }
      // maxValue does not work if length is too great, like 16, 32, 63, etc.. due to the INT32 limitation.

      while (true)
      {
        charCount += 1;
        posValue[charCount] = ModuloInteger(value, VSTRINGCHARMAPLENGTH);
        // BJDebugMsg("posValue[" + I2S(charCount) + "] = " + I2S(posValue[charCount]));
        if (value < VSTRINGCHARMAPLENGTH)
        {
          break;
        }
        else
        {
          value = (value - posValue[charCount]) / VSTRINGCHARMAPLENGTH;
        }
      }

      // BJDebugMsg("charCount: " + I2S(charCount));
      for (charCount >= index >= 1)
      {
        // BJDebugMsg("ConvertIntegerToVChar: posValue[" + I2S(index) + "] = " + I2S(posValue[index]));
        posChar = ConvertIntegerToVChar(posValue[index]);
        vString += posChar;
      }

      padZeroCount = length - charCount;
      while (padZeroCount > 0)
      {
        padZeroCount -= 1;
        vString = "0" + vString;
      }

      return vString;
    }
    public function ConvertVStringToInteger(string vstring) -> integer
    {
      integer posValue;
      integer posIndex;
      integer VSTRINGLength;
      integer value = 0;
      integer posUnit;

      while (SubStringBJ(vstring, 1, 1) == "0")
      {
        if (StringLength(vstring) == 1)
        {
          return 0;
        }

        vstring = SubStringBJ(vstring, 2, StringLength(vstring));
      }

      VSTRINGLength = StringLength(vstring);
      for (1 <= posIndex <= VSTRINGLength)
      {
        // BJDebugMsg("posIndex:" + I2S(posIndex));
        posValue = ConvertVCharToInteger(SubStringBJ(vstring, posIndex, posIndex));

        // BJDebugMsg("posValue:" + I2S(posValue));
        posUnit = R2I(Pow(I2R(VSTRINGCHARMAPLENGTH), VSTRINGLength - posIndex));

        value += posValue * posUnit;
      }

      return value;
    }
  // function
    private function GetMaxVChar() -> string
    {
      integer pos = VSTRINGCHARMAPLENGTH - 1; // -1: 最大的符号会用于进一，因此使用倒数第二个符号。
      return SubStringBJ(VSTRINGCHARMAP, pos, pos);
    }
    public function PickVStringValue(string vstring, integer begin, integer end) -> integer
    {
      return ConvertVStringToInteger(SubStringBJ(vstring, begin, end));
    }
    public function GetMaxVStringValueOfLength(integer length) -> string
    {
      string vstr = "";
      string maxchar = GetMaxVChar();

      while (StringLength(vstr) < length)
      {
        vstr = vstr + maxchar;
      }

      return vstr;
    }
  // init
    #ifdef DEBUG
    private function onInitDebug()
    {
      trigger trig;
      trig = CreateTrigger();
      TriggerRegisterPlayerChatEvent(trig, Player(0), "vstr ", false);
      TriggerAddAction(trig, function() {
        string intstr;
        intstr = SubStringBJ(GetEventPlayerChatString(), 6, StringLength(GetEventPlayerChatString()));
        BJDebugMsg(ConvertIntegerToVString(S2I(intstr), 63));
      });

      trig = CreateTrigger();
      TriggerRegisterPlayerChatEvent(trig, Player(0), "vint ", false);
      TriggerAddAction(trig, function() {
        string intstr;
        intstr = SubStringBJ(GetEventPlayerChatString(), 6, StringLength(GetEventPlayerChatString()));
        BJDebugMsg(I2S(ConvertVStringToInteger(intstr)));
      });
    }
    #endif
    private function onInit()
    {
      VSTRINGCHARMAPLENGTH = StringLength(VSTRINGCHARMAP) + 1; // +1: 缺失的“0”
      #ifdef DEBUG
      BJDebugMsg("VSTRINGCHARMAPLENGTH: " + I2S(VSTRINGCHARMAPLENGTH));
      onInitDebug();
      #endif
    }
}

//! endzinc

#endif
