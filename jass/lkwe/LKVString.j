/**
 * VString.j
 *
 * Version: 1.0.0
 * Public:
 *   ConvertIntegerToVString(integer value, integer length) -> string
 *   ConvertVStringToInteger(string vstring) -> integer
 *   PickVStringValue(string vstring, integer begin, integer end) -> integer
 */

library LKVString
{
  // field
    private string VSTRINGCHARMAP = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()`~-_=+[]{}\\/|?;:'\",.<>";
    private integer VSTRINGCHARMAPLENGTH; // length: 95
  // converter
    private function ConvertIntegerToVChar(integer value) -> string
    {
      string vchar;

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
    public function ConvertIntegerToVString(integer value, integer length) -> string
    {
      integer posValue[];
      integer charCount = 0;
      string vString = "";
      integer padZeroCount;
      // integer maxValue = R2I(Pow(I2R(VSTRINGCHARMAPLENGTH), length) - 1); // (10^4 = 10000) and need (length = 4), so, maxValue should be (10000-1 = 9999) because (length = 4).
      integer index;
      string posChar;

      // BJDebugMsg("maxValue:" + I2S(maxValue));
      // if (value > maxValue)
      // {
      //   value = maxValue;
      // }
      // maxValue does not work if length is great like "63".

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
    public function PickVStringValue(string vstring, integer begin, integer end) -> integer
    {
      return ConvertVStringToInteger(SubStringBJ(vstring, begin, end));
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
      VSTRINGCHARMAPLENGTH = StringLength(VSTRINGCHARMAP);
      #ifdef DEBUG
      onInitDebug();
      #endif
    }
}
