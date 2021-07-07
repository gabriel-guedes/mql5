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
//---

CMyUtils utils;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    Print(_Symbol);
    Print(tickSize);
    Print(tickValue);
    //double adjusted = (MathFloor(96.23 / tickSize) * tickSize);
    //Print(adjusted);
    
    MqlRates bars[];
    CopyRates(_Symbol, PERIOD_CURRENT, 0, 5, bars);
    for(int i = 0; i<ArraySize(bars); i++) {
      Print(DoubleToString(bars[i].close));
      Print(bars[i].time);
    }
    
    string dir_name = "zeroesq";
    string file_name = "testfile.csv";
    short delimiter = ',';
    int file_handle = FileOpen(dir_name+"//"+ file_name,FILE_READ|FILE_WRITE|FILE_CSV, delimiter);
    
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s arquivo está disponível para ser escrito",file_name);
      PrintFormat("Caminho do arquivo: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- primeiro, escreva o número de sinais
      FileWrite(file_handle,ArraySize(bars));
      //--- escrever o tempo e os valores de sinais para o arquivo
      for(int i=0;i<ArraySize(bars);i++)
         FileWrite(file_handle,bars[i].open,bars[i].close);
      //--- fechar o arquivo
      FileClose(file_handle);
      PrintFormat("Os dados são escritos, %s arquivo esta fechado",file_name);
     }
   else
      PrintFormat("Falha para abrir %s arquivo, Código de erro = %d",file_name,GetLastError());


}
//+------------------------------------------------------------------+
