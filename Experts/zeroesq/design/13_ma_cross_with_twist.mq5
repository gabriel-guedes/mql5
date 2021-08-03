//+------------------------------------------------------------------+
//|                                       13_ma_cross_with_twist.mq5 |
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
input string   inpExpertName = "13_ma_cross_with_twist";   //Expert Name
input int      inpShortMAPeriod  = 10;                     //Short MA Period
input int      inpLongMAPeriod   = 20;                     //Long  MA Period
input double   inpMaxPctDeviation = 3.0;                   //Max % Deviation
input myenum_directions inpDirection = BOTH;


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
int shortMAHandle, longMAHandle;
double shortMA[], longMA[];
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

   shortMAHandle = iMA(_Symbol, PERIOD_CURRENT, inpShortMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   longMAHandle = iMA(_Symbol, PERIOD_CURRENT, inpLongMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   ArraySetAsSeries(shortMA, true);
   ArraySetAsSeries(longMA, true);

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
   bars.SetInfo(3);
   position.Update(bars.GetOne(0).time);

   CopyBuffer(shortMAHandle, 0, 1, 2, shortMA);
   CopyBuffer(longMAHandle, 0, 1, 2, longMA);

   MqlRates bar1 = bars.GetOne(1);

   bool goLong = false, goShort = false;
   double buyThreshold = bar1.low + (bar1.low*inpMaxPctDeviation/100);
   double sellThreshold = bar1.high - (bar1.high*inpMaxPctDeviation/100);
   
   chart.SetBuyStop(buyThreshold);
   chart.SetSellStop(sellThreshold);

   if(utils.CrossAbove(shortMA, longMA) && bar1.close < buyThreshold) {
      goLong = true;

   } else if(utils.CrossBelow(shortMA, longMA) && bar1.close > sellThreshold) {
      goShort = true;
   }


   if(position.IsLong()) {          //---positioned LONG
      if(goShort && inpDirection == BOTH) {
         position.Reverse();
      } else if(goShort && inpDirection == LONG_ONLY) {
         position.Close();
      }

   } else if(position.IsShort()) {  //---positioned SHORT
      if(goLong && inpDirection == BOTH) {
         position.Reverse();
      } else if(goLong && inpDirection == SHORT_ONLY) {
         position.Close();
      }
   }

   else {                         //---flat
      if(goLong && inpDirection != SHORT_ONLY) {
         position.BuyMarket(volume, 0.00, 0.00);
      } else if(goShort && inpDirection != LONG_ONLY) {
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
