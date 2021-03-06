//+------------------------------------------------------------------+
//|                                              MyExtractPrices.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"
#property script_show_inputs

#include <WinAPI\fileapi.mqh>

//input string file_name = "testfile.csv";  //File Name
input string dir_name = "zeroesq";        //Directory
input int bars_count = 50;              //Number of bars
input int ma_period = 20;                 //ATR MA Period
input string   InpDirectory = "zeroesq";  //Directory under files folder

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
//short delimiter = ",";              //Delimiter

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   MqlRates bars[];
   int atr_handle = iATR(_Symbol, PERIOD_CURRENT, ma_period);
   double atr[];
   CopyBuffer(atr_handle, 0, 0, bars_count, atr);


   CopyRates(_Symbol, PERIOD_CURRENT, 0, bars_count, bars);

   string file_name = _Symbol + ".csv";

   string file_path = InpDirectory + "//" + file_name;

   if(FileIsExist(file_path)) {
      PrintFormat("%s exists. Deleting...", file_name);
      FileDelete(file_path);
   }

   int file_handle = FileOpen(file_path, FILE_WRITE | FILE_ANSI, ',');
//int file_handle = FileOpen(dir_name + "//" + file_name, FILE_READ | FILE_WRITE | FILE_CSV, delimiter);

   if(file_handle != INVALID_HANDLE) {
      PrintFormat("%s file available for writing", file_name);
      PrintFormat("File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));

      for(int i = 0; i < ArraySize(bars); i++) {
         FileWrite(file_handle, (string)_Symbol, bars[i].time, bars[i].open, bars[i].high, bars[i].low, bars[i].close, atr[i]);
      }

      //--- close file
      FileClose(file_handle);
      PrintFormat("Data written, %s file closed.", file_name);
   } else
      PrintFormat("Failed to open %s file, Error code = %d", file_name, GetLastError());

}
//+------------------------------------------------------------------+