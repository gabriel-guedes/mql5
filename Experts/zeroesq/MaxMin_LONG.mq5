//+------------------------------------------------------------------+
//|                                                  MaxMin_LONG.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\MyTrade.mqh>
#include <zeroesq\MyPosition.mqh>
#include <zeroesq\MyPriceBars.mqh>
#include <zeroesq\MyPending.mqh>
#include <zeroesq\MyUtils.mqh>

input string   inpExpertName="MaxMinLong";   //Expert Name
input double   inpTradeVolume = 1.0;         //Volume
input int      inpMAPeriod = 21;             //Moving Average Period
input double   inpKeltnerMult = 1.0;         //Keltner Multiplier

//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyTrade    trade;
CMyBars     bars;
CMyPending  pending;
CMyUtils    utils;
//+------------------------------------------------------------------+
//| Indicator handles and buffers                                    |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!utils.IsValidExpertName(inpExpertName)) {
      Print("ERROR - Init Failed - Null/Empty Expert name.");
      return(INIT_FAILED);
   }

   ulong magic_number = utils.StringToMagic(inpExpertName);
   trade.SetMagicNumber(magic_number);

   return(INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
   EventKillTimer();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetBars(3);

   if(!bars.IsNewBar()) return;

   ulong positionTicket = position.SelectPositionByMagic(trade.GetMagic());

   if(positionTicket != NULL) {
      double takeProfit = bars.GetLowestHigh();
      position.ModifySLTP(positionTicket, trade.GetMagic(), 0, takeProfit, inpTradeVolume);

   } else {
      double previousLow = bars.GetLow(1);
      double highestHigh = bars.GetHighestHigh();
      double currentOpen = bars.GetOpen(0);
      if(currentOpen > previousLow) {
         pending.CancelAllByMagic(trade.GetMagic());
         trade.BuyLimit(_Symbol, inpTradeVolume, previousLow, 0, highestHigh);
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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
