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
int keltnerUpperHandle, keltnerLowerHandle, atrHandle;
double keltnerUpperBuffer[], keltnerLowerBuffer[], atrBuffer[];

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
   
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, 20);
   keltnerUpperHandle = iCustom(NULL, 0, "zeroesq\\MyKeltner", inpMAPeriod, inpKeltnerMult);
   keltnerLowerHandle = iCustom(NULL, 1, "zeroesq\\MyKeltner", inpMAPeriod, inpKeltnerMult);
   ArraySetAsSeries(keltnerUpperBuffer, true);
   ArraySetAsSeries(keltnerLowerBuffer, true);
   ArraySetAsSeries(atrBuffer, true);

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
   int barsCount = 6;
   bars.SetInfo(barsCount);

   if(!bars.IsNewBar()) return;

   ulong positionTicket = position.SelectPositionByMagic(trade.GetMagic());

   if(positionTicket != NULL) {
      //--- modify position
      //double takeProfit = bars.GetLowestHigh();
      //position.ModifySLTP(positionTicket, trade.GetMagic(), 0, takeProfit, inpTradeVolume);

   } else {
      
      //--- cancel any pending order
      pending.CancelAllByMagic(trade.GetMagic());
      
      //--- calculation
      CopyBuffer(keltnerUpperHandle, 0, 0, barsCount, keltnerUpperBuffer);
      CopyBuffer(keltnerUpperHandle, 1, 0, barsCount, keltnerLowerBuffer);
      CopyBuffer(atrHandle, 0, 0, barsCount, atrBuffer);
      
      double atr = atrBuffer[1];
      
      MqlRates bar3 = bars.GetOne(3);
      MqlRates bar2 = bars.GetOne(2);
      MqlRates bar1 = bars.GetOne(1);
      MqlRates bar0 = bars.GetOne(0);
      
      double sl = utils.AdjustToTick(bar0.open - atr*2);
      double tp = utils.AdjustToTick(bar0.open + atr*2);
      
      //--- place order
      if(bar1.close < keltnerLowerBuffer[1] && bar2.close < keltnerLowerBuffer[2] && bar3.close < keltnerLowerBuffer[3]) {
         trade.BuyMarket(_Symbol, inpTradeVolume, sl, tp);
         //trade.BuyLimit(_Symbol, inpTradeVolume, entryPrice, sl, tp);
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
