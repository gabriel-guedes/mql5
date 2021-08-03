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
   bool              LockMagic(ulong pMagic);
   bool              UnlockMagic(ulong pMagic);
   double            AdjustToTick(double pValue);
   int               GetDayOfWeek(datetime pDate);
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

   if(name == NULL || name == "") {
      Print("ERROR - Null/Empty Expert name.");
      return(false);
   }

   else {
      Print("OK - EA name is valid to be converted to a magic number.");
      return(true);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyUtils::LockMagic(ulong pMagic)
{
   if(!GlobalVariableCheck((string)pMagic)) {
      PrintFormat("INFO - Registering %u magic number", pMagic);
      GlobalVariableSet((string)pMagic, 0.00);
      return(true);
   }

   else {
      PrintFormat("ERROR - EA Magic Number already in use");
      return(false);
   }
}
//+------------------------------------------------------------------+
//| Release Magic Number                                             |
//+------------------------------------------------------------------+
bool CMyUtils::UnlockMagic(ulong pMagic)
{
   bool success = GlobalVariableDel((string)pMagic);
   if(success) {
      PrintFormat("INFO - Releasing %u magic number", pMagic);
   } else {
      PrintFormat("WARN - Error releasing %u magic number", pMagic);
   }

   return(success);
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
//|                                                                  |
//+------------------------------------------------------------------+
int CMyUtils::GetDayOfWeek(datetime pDate)
{
   MqlDateTime date;
   TimeToStruct(pDate, date);
   
   return(date.day_of_week);
}

//+------------------------------------------------------------------+
