//+------------------------------------------------------------------+
//|                                                    bollinger.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\MyPosition.mqh>
#include <zeroesq\MyPriceBars.mqh>
#include <zeroesq\MyUtils.mqh>
#include <zeroesq\MyReport.mqh>
#include <zeroesq\MyChart.mqh>

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
input uint     inpCloseAfter = 4;                  //Close After N Bars
input myenum_directions inpDirection = BOTH;       //Trade Direction


//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyBars     bars;
CMyUtils    utils;
CMyReport   report;
CMyChart    chart;
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
   report.SetStartTime();

   if(!utils.IsValidExpertName(inpExpertName)) {
      return(INIT_FAILED);
   }

   ulong magic_number = utils.StringToMagic(inpExpertName);
   if (!utils.LockMagic(magic_number))
      return(INIT_FAILED);

   position.SetMagic(magic_number);

   volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   
   bbHandle = iBands(_Symbol, PERIOD_CURRENT, inpMAPeriod, 0, inpDeviation, PRICE_CLOSE);
   ChartIndicatorAdd(0, 0, bbHandle);

   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbLower, true);   

   return(INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
   EventKillTimer();

   utils.UnlockMagic(position.GetMagic());

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetInfo(10);
   position.Update(bars.GetOne(0).time);

   double lastClose = bars.GetOne(1).close;
   
   CopyBuffer(bbHandle, 1, 0, 10, bbUpper);
   CopyBuffer(bbHandle, 2, 0, 10, bbLower);


   bool canGoLong = false, canGoShort = false;
   if(lastClose <= bbLower[1])
      canGoLong = true;
   if(lastClose >= bbUpper[1])
      canGoShort = true;

   if(position.IsOpen()) {          //---positioned
      if(position.GetBarsDuration() >= inpCloseAfter)
         position.Close();

   } else {                         //---flat
      if(canGoLong && inpDirection != SHORT_ONLY)
         position.BuyMarket(volume, 0.00, 0.00);
      if(canGoShort && inpDirection != LONG_ONLY)
         position.SellMarket(volume, 0.00, 0.00);

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
