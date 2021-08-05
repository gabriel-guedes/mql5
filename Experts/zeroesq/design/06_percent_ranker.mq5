//+------------------------------------------------------------------+
//|                                            06_percent_ranker.mq5 |
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
input string   inpExpertName = "06_percent_ranker";       //Expert Name
input uint     inpLookback = 10;                          //Lookback period
input uint     inpMAPeriod = 15;                          //ADX MA Period
input bool     inpUseSLTP = true;                         //Use hh/ll as SLTP
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
int adxHandle;
double adx[];
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

   adxHandle = iADXWilder(_Symbol, PERIOD_CURRENT, inpMAPeriod);
   ArraySetAsSeries(adx, true);

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

   CopyBuffer(adxHandle, 0, 1, 1, adx);

   double hh = bars.GetHighest(PRICE_HIGH, 1, inpLookback - 1);
   double ll = bars.GetLowest(PRICE_LOW, 1, inpLookback - 1);
   chart.SetBuyStop(hh);
   chart.SetSellStop(ll);

   bool goLong = false, goShort = false;

   if(lastDeal >= hh && adx[0] < 30.00 && hh > 0.00) {
      goLong = true;

   } else if(lastDeal <= ll && adx[0] < 30.00 && ll > 0.00) {
      goShort = true;
   }


   if(position.IsLong()) {          //---positioned LONG
      if(inpUseSLTP) {
         position.ModifySLTP(ll, 0.00);
         if(position.CloseIfSLTP(lastDeal)) {
            Print("Exited on stop loss");
            return;
         }
      }

      if(inpDirection == BOTH  && goShort) {
         position.Reverse();
      } else if(inpDirection == LONG_ONLY && goShort) {
         position.Close();
      }

   } else if(position.IsShort()) {  //---positioned SHORT
      if(inpUseSLTP) {
         position.ModifySLTP(hh, 0.00);
         if(position.CloseIfSLTP(lastDeal)) {
            Print("Exited on stop loss");
            return;
         }
      }

      if(inpDirection == BOTH  && goLong) {
         position.Reverse();
      } else if(inpDirection == SHORT_ONLY  && goLong) {
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
