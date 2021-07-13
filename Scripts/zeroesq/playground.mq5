//+------------------------------------------------------------------+
//|                                                   playground.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\MyUtils.mqh>
#include <Strings\String.mqh>

//#import "kernel32.dll"
//int      CopyFileW(string lpExistingFileName,string lpNewFileName,bool bFailIfExists);
//#import
//---

CMyUtils utils;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{

   string path = TerminalInfoString(TERMINAL_DATA_PATH);
   path = TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   Print(path);
   
   //int copy = CopyFileW("C:\\mt5_from\\CVCB3.csv", "C:\\mt5_to\\CVCB3.csv", true);
   
   Print(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   Print(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP));

}
//+------------------------------------------------------------------+
