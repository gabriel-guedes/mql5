//+------------------------------------------------------------------+
//|                                              18_where_you_at.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\MyTrade.mqh>
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
input string   inpExpertName = "where_you_at";        //Expert Name
input myenum_directions inpDirection = BOTH;       //Trade Direction
input double inpThresh = 0.8;                      //Threshold between 0 and 1
input uint   inpLookback = 2;                      //Lookbak N Bars


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
   bars.SetInfo(inpLookback);
   position.Update(bars.GetOne(0).time);
   double lastDeal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   chart.SetSLTP(position.GetSL(), position.GetTP());
      
   MqlRates bar1 = bars.GetOne(1);
   MqlRates barX = bars.GetOne(inpLookback);
   
   double ll = bars.GetLowest(PRICE_LOW, 1, inpLookback);
   double hh = bars.GetHighest(PRICE_HIGH, 1, inpLookback);
   
   bool canGoLong = false, canGoShort = false;
   if((bar1.close-ll)/(hh-ll+0.000001)>=inpThresh) {
      canGoShort = true;
   }
   else if((bar1.close-ll)/(hh-ll+0.000001)<=(1-inpThresh)) {
      canGoLong = true;
   }
   
   if(!bars.IsNewBar()) { //exit if it isn't new bar opening
      return;
   }

   if(position.IsOpen()) {          //---positioned
      long type = position.GetType();
      if((canGoLong && type == POSITION_TYPE_SELL)|| (canGoShort && type == POSITION_TYPE_BUY)) {
         position.Reverse();
      }

   } else {                         //---flat
      if(canGoLong && inpDirection != SHORT_ONLY) {
         position.BuyMarket(volume, 0.00, 0.00);
      }

      if(canGoShort && inpDirection != LONG_ONLY) {
         position.SellMarket(volume, 0.00, 0.00);
      }
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
