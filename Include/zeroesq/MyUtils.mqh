//+------------------------------------------------------------------+
//|                                                      MyUtils.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
class CMyUtils
{
private:

public:
   CMyUtils(void);
   ulong             StringToMagic(string pStringVar);
   bool              IsValidExpertName(string pExpertName);
   double            AdjustToTick(double pValue);
   double            GetAsk();
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMyUtils::CMyUtils(void)
{

}
//+------------------------------------------------------------------+
//| String to Magic Number                                           |
//+------------------------------------------------------------------+
ulong CMyUtils::StringToMagic(string pStringVar)
{
   string magicNumber;
   char charArray[];
   string magicString = pStringVar;
   int stringPositions = StringLen(magicString);

   if(stringPositions > 9)
      stringPositions = 9;

   StringToUpper(magicString);
   StringToCharArray(magicString, charArray, 0, stringPositions);

   for(int i = 0; i < ArraySize(charArray); i++)
      StringAdd(magicNumber, (string)charArray[i]);



   return (ulong)magicNumber;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyUtils::IsValidExpertName(string pExpertName)
{
   string name = pExpertName;
   StringTrimLeft(name);
   StringTrimRight(name);
   
   if(name == NULL || name == "")
      return(false);
   else
      return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyUtils::AdjustToTick(double pValue)
{
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   //double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double adjusted = NormalizeDouble((MathFloor(pValue / tickSize) * tickSize), _Digits);
   return(adjusted);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyUtils::GetAsk(void)
{
   MqlTick tick = {};
   
   return(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
}
//+------------------------------------------------------------------+

