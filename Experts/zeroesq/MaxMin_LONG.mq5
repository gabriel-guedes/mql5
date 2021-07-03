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

input string   inpExpertName;
input double   inpTradeVolume = 1.0;

CMyPosition position;
CMyTrade    trade;
CMyBars     bars;
CMyPending  pending;
CMyUtils    utils;
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

   ulong positionTicket = position.SelectPositionByMagic(EXPERT_MAGIC);

   if(positionTicket != NULL) {
      double takeProfit = bars.GetLowestHigh();
      position.ModifySLTP(positionTicket, EXPERT_MAGIC, 0, takeProfit, inpTradeVolume);

   } else {
      double previousLow = bars.GetLow(1);
      double highestHigh = bars.GetHighestHigh();
      double currentOpen = bars.GetOpen(0);
      if(currentOpen > previousLow) {
         pending.CancelOrdersByMagic(EXPERT_MAGIC);
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
