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

input int bars_count = 50;                               //Number of bars
input string   InpDirectory = "C:\\mt5_ext\\";  //Directory

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
   CopyRates(_Symbol, PERIOD_CURRENT, 0, bars_count, bars);

   string file_name = _Symbol + ".csv";
   string file_path = InpDirectory + file_name;

   int file_handle = MyFileCreate(file_path);

   //int file_handle = FileOpen(file_path, FILE_WRITE | FILE_ANSI, ',');
//int file_handle = FileOpen(dir_name + "//" + file_name, FILE_READ | FILE_WRITE | FILE_CSV, delimiter);

   if(file_handle != INVALID_HANDLE) {
      PrintFormat("%s file available for writing", file_path);

      for(int i = 0; i < ArraySize(bars); i++) {
         FileWrite(file_handle, (string)_Symbol, bars[i].time, bars[i].open, bars[i].high, bars[i].low, bars[i].close);
      }

      //--- close file
      FileClose(file_handle);
      PrintFormat("Data written, %s file closed.", file_name);
   } else
      PrintFormat("Failed to open %s file, Error code = %d", file_name, GetLastError());

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long MyFileCreate(string pFilePath)
{
   PVOID security_attributes = 0;
   int result = CreateDirectoryW(pFilePath, security_attributes);
   HANDLE handle = -1;
   uint desired_access = 0;

//+------------------------------------------------------------------+
//| share_mode                                                       |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|  0x00000000 Prevents other processes from opening a file or device if they request delete, read, or write access |
//|  0x00000004 FILE_SHARE_DELETE Enables subsequent open operations on a file or device to request delete access    |
//+------------------------------------------------------------------+
   uint share_mode = 0x00000004;

//+------------------------------------------------------------------+
//| security_attributes                                              |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|   This parameter can be NULL                                     |
//+------------------------------------------------------------------+
   security_attributes = 0;

//+------------------------------------------------------------------+
//| creation_disposition                                             |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|  2 CREATE_ALWAYS                                                 |
//+------------------------------------------------------------------+
   uint creation_disposition = 2;

//+------------------------------------------------------------------+
//| flags_and_attributes                                             |
//|  https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-createfilew                               |
//|  128 (0x80) FILE_ATTRIBUTE_NORMAL                                |
//+------------------------------------------------------------------+
   uint flags_and_attributes = 0x80;
   HANDLE template_file = 0;

   handle = CreateFileW(pFilePath, desired_access, share_mode, security_attributes, creation_disposition, flags_and_attributes, template_file);

   //if(handle!=INVALID_HANDLE)
   //   FileClose(handle);
   //int d=0;

   return(handle);


}

