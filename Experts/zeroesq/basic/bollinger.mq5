//+------------------------------------------------------------------+
//|                                                    bollinger.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

//#include <zeroesq\MyTrade.mqh>
#include <zeroesq\MyPosition.mqh>
#include <zeroesq\MyPriceBars.mqh>
//#include <zeroesq\MyPending.mqh>
#include <zeroesq\MyUtils.mqh>
#include <zeroesq\MyReport.mqh>

enum myenum_directions
{
   LONG_ONLY,
   SHORT_ONLY,
   BOTH,
};

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inpExpertName = "bollinger";        //Expert Name
input uint     inpMAPeriod = 21;                   //MA Period
input double   inpDeviation = 2;                   //Standard Deviations
input myenum_directions inpDirection = BOTH;       //Trade Direction


//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
//CMyTrade    trade;
CMyBars     bars;
//CMyPending  pending;
CMyUtils    utils;
CMyReport   report;
//+------------------------------------------------------------------+
//| Indicator handles and buffers                                    |
//+------------------------------------------------------------------+
int bbHandle = INVALID_HANDLE;
double bbUpper[], bbLower[];

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double volume = 0.00;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   bbHandle = iBands(_Symbol, PERIOD_CURRENT, inpMAPeriod, 0, inpDeviation, PRICE_CLOSE);

   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbLower, true);

   report.SetStartTime();

   if(!utils.IsValidExpertName(inpExpertName)) {
      return(INIT_FAILED);
   }

   ulong magic_number = utils.StringToMagic(inpExpertName);
   if (!position.SetMagic(magic_number))
      return(INIT_FAILED);

   volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   return(INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
   EventKillTimer();

   position.ReleaseMagic();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetInfo(10);
   position.UpdateInfo(bars.GetOne(0).time);

//if(bars.IsNewBar())
//   Print(position.GetBarsDuration());

   double lastClose = bars.GetOne(1).close;
   
   CopyBuffer(bbHandle, 1, 0, 10, bbUpper);
   CopyBuffer(bbHandle, 2, 0, 10, bbLower);


   bool canGoLong = false, canGoShort = false;
   if(lastClose <= bbLower[1])
      canGoLong = true;
   if(lastClose >= bbUpper[1])
      canGoShort = true;

   if(position.IsOpen()) {          //---positioned
      if(position.GetBarsDuration() >= 4)
         position.Close();

   } else {                         //---flat
      if(canGoLong && inpDirection != SHORT_ONLY)
         position.OpenAtMarket(POSITION_TYPE_BUY, volume, 0, 0);
      if(canGoShort && inpDirection != LONG_ONLY)
         position.OpenAtMarket(POSITION_TYPE_SELL, volume, 0, 0);

   }

}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{

}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
//---

}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{

}

//+------------------------------------------------------------------+
//| OnTester Function                                                |
//+------------------------------------------------------------------+
double OnTester()
{
   double ret = 0.0;
   report.SetEndTime();
   report.SetDeals(position.GetMagic(), 0, TimeCurrent());
//report.SaveDealsToCSV();

   return(ret);
}
//+------------------------------------------------------------------+