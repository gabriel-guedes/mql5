//+------------------------------------------------------------------+
//|                                           1_go_with_the_flow.mq5 |
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
input string   inpExpertName = "01_go_with_the_flow";   //Expert Name
input double   inpOpenLoss = 50.00;
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
   double close1 = bars.GetOne(1).close;
   double close2 = bars.GetOne(2).close;
   double drawdown = position.GetDrawdown();
   double open_profit = position.GetProfit();
   double max_profit = position.GetMaxProfit();
   
   if(bars.IsNewBar()) {
      int i = 1;
   }   
   
   bool goLong = false, goShort = false;
   
   if(close1 > close2) {
      if(drawdown < -inpOpenLoss || position.IsFlat()) {
         goLong = true;
      }
   } else if(close1 < close2) {
      if(drawdown < -inpOpenLoss || position.IsFlat()) {
         goShort = true;
      }
   }


   if(position.IsLong()) {          //---positioned LONG
      if(goShort && inpDirection == BOTH) {
         position.Reverse();
      }
      else if(goShort && inpDirection == LONG_ONLY) {
         position.Close();
      }
   
   } else if(position.IsShort()) {  //---positioned SHORT
      if(goLong && inpDirection == BOTH) {
         position.Reverse();
      }
      else if(goLong && inpDirection == SHORT_ONLY) {
         position.Close();
      }
   }

   else {                         //---flat
      if(goLong && inpDirection != SHORT_ONLY) position.BuyMarket(volume, 0.00, 0.00);
      else if(goShort && inpDirection != LONG_ONLY) position.SellMarket(volume, 0.00, 0.00);
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
