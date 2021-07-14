//+------------------------------------------------------------------+
//|                                                   tresmarias.mq5 |
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
#include <zeroesq\MyReport.mqh>

input string   inpExpertName = "tres marias";  //Expert Name

//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyTrade    trade;
CMyBars     bars;
CMyPending  pending;
CMyUtils    utils;
CMyReport   report;
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
   if (!trade.SetMagicNumber(magic_number))
      return(INIT_FAILED);
      
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

   trade.ReleaseMagicNumber();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetInfo(4);

   bool isNewBar = bars.IsNewBar();

   ulong positionTicket = position.SelectPositionByMagic(trade.GetMagic());

   if(positionTicket != NULL) {
      if(isNewBar)
         position.UpdateBarsDuration();
      
      if(position.GetBarsDuration() > 5)
         trade.Close();

   } else {
      MqlRates bar3 = bars.GetOne(3);
      MqlRates bar2 = bars.GetOne(2);
      MqlRates bar1 = bars.GetOne(1);
           
      if(bar1.low > bar2.low && bar2.low > bar3.low) {
         pending.CancelAllByMagic(trade.GetMagic());
         double sl = bar3.low;
         double tp = bar1.high + (bar1.close - bar3.low);
         bool trade_ok = trade.BuyMarket(volume, sl, tp);
         if(trade_ok)
            position.ResetBarsDuration();
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
   report.SetDeals(trade.GetMagic(), 0, TimeCurrent());
   //report.SaveDealsToCSV();

   return(ret);
}
//+------------------------------------------------------------------+
