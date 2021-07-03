//+------------------------------------------------------------------+
//|                                                  MaxMin_LONG.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <Gabriel\MyTrade.mqh>
#include <Gabriel\MyPositionInfo.mqh>
#include <Gabriel\MyPriceBars.mqh>
#include <Gabriel\MyPending.mqh>

input ulong    inpDeviation = 4;
input double   inpTradeVolume = 1.0;

#define EXPERT_MAGIC 123456

CMyPositionInfo      position;
CMyTrade             trade;
CMyBars              bars;
CMyPending           pending;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//--- create timer
   EventSetTimer(86400);

   trade.Init(EXPERT_MAGIC, inpDeviation, ORDER_FILLING_IOC);

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
