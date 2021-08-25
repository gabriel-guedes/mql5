//+------------------------------------------------------------------+
//|                                              904_opening_gap.mq5 |
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
input string   inpExpertName = "904_opening_gap";         //Expert Name
input double   inpSLTP = 100.00;
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

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double volume = 0.00;
bool allow_open_position = true;

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
   bars.SetInfo(3);
   position.Update(bars.GetOne(0).time);
   double lastDeal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   
   MqlRates lastBar = bars.GetOne(1);
   MqlRates currentBar = bars.GetOne(0);
   
   if(bars.IsFirstOfTheDay() && bars.IsNewBar()) {
      allow_open_position = true;
   }
   else {
      allow_open_position = false;
   }

   bool goLong = false, goShort = false;
   double stop_loss = 0.00, take_profit = 0.00;

   if(currentBar.open > lastBar.close) {
      goLong = true;
      stop_loss = lastDeal - inpSLTP;
      take_profit = lastDeal + 2*inpSLTP;
   } 
   
   else if(currentBar.open < lastBar.close) {
      goShort = true;
      stop_loss = lastDeal + inpSLTP;
      take_profit = lastDeal - 2*inpSLTP;
   }
   
   if(position.IsOpen()) {        //---positioned
      allow_open_position = false;
   }

   else {                         //---flat
      if(goLong && inpDirection != SHORT_ONLY && allow_open_position) {
         position.BuyMarket(volume, stop_loss, take_profit);

      } else if(goShort && inpDirection != LONG_ONLY && allow_open_position) {
         position.SellMarket(volume, stop_loss, take_profit);

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
