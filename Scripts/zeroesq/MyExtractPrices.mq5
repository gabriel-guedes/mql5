//+------------------------------------------------------------------+
//|                                              MyExtractPrices.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"
#property script_show_inputs

input string file_name = "testfile.csv";  //File Name
input string dir_name = "zeroesq";        //Directory
input int bars_count = 1000;              //Number of bars

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
short delimiter = ',';              //Delimiter

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   MqlRates bars[];
   CopyRates(_Symbol, PERIOD_CURRENT, 0, bars_count, bars);
   for(int i = 0; i < ArraySize(bars); i++) {
      Print(DoubleToString(bars[i].close));
      Print(bars[i].time);
   }

   int file_handle = FileOpen(dir_name + "//" + file_name, FILE_READ | FILE_WRITE | FILE_CSV, delimiter);

   if(file_handle != INVALID_HANDLE) {
      PrintFormat("%s file available for writing", file_name);
      PrintFormat("File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));
      //--- primeiro, escreva o número de sinais
      FileWrite(file_handle, ArraySize(bars));
      //--- escrever o tempo e os valores de sinais para o arquivo
      for(int i = 0; i < ArraySize(bars); i++)
         FileWrite(file_handle, _Symbol, bars[i].time, bars[i].open, bars[i].high, bars[i].low, bars[i].close);
      //--- fechar o arquivo
      FileClose(file_handle);
      PrintFormat("Data written, %s file closed.", file_name);
   } else
      PrintFormat("Failed to open %s file, Error code = %d", file_name, GetLastError());

}
//+------------------------------------------------------------------+
