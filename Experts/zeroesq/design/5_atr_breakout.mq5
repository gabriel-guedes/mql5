//+------------------------------------------------------------------+
//|                                               5_atr_breakout.mq5 |
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
#include <zeroesq\MyPending.mqh>

enum myenum_directions
{
   LONG_ONLY,
   SHORT_ONLY,
   BOTH,
};

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inpExpertName = "5_atr_breakout";   //Expert Name
input uint     inpATRPeriod = 15;                  //ATR Period
input double   inpMult = 1.0;                      //ATR Multiplier
input myenum_directions inpDirection = BOTH;


//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyBars     bars;
CMyUtils    utils;
CMyReport   report;
CMyChart    chart;
CMyPending  pending;
//+------------------------------------------------------------------+
//| Indicator handles and buffers                                    |
//+------------------------------------------------------------------+
int atrHandle = INVALID_HANDLE;
double atr[];

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
   
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, inpATRPeriod);
   ArraySetAsSeries(atr, true);   

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
   bars.SetInfo(2);
   position.Update(bars.GetOne(0).time);

   double lastClose = bars.GetOne(1).close;
   double lastDeal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   
   CopyBuffer(atrHandle, 0, 0, 2, atr);

   double shortPrice = 0.00, longPrice = 0.00;
   
   longPrice = utils.AdjustToTick(lastClose + (atr[1]*inpMult));
   shortPrice = utils.AdjustToTick(lastClose - (atr[1]*inpMult));
   
   chart.SetBuyStop(longPrice);
   chart.SetSellStop(shortPrice);
   
        
   if(position.IsLong()) {          //---positioned LONG
      if(lastDeal <= shortPrice) position.Reverse();
   }
   else if(position.IsShort()) {    //---positioned SHORT
      if(lastDeal >= longPrice) position.Reverse();
   } 

   else {                         //---flat
      if(lastDeal >= longPrice) position.BuyMarket(volume, 0.00, 0.00);
      else if(lastDeal <= shortPrice) position.SellMarket(volume, 0.00, 0.00);
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
