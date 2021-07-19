//+------------------------------------------------------------------+
//|                                                   tresmarias.mq5 |
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

input string   inpExpertName = "tres marias";  //Expert Name

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
   if (!position.SetMagic(magic_number))
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

   position.ReleaseMagic();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetInfo(4);
   position.UpdateInfo(bars.GetOne(0).time);
   
   double lastDeal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);

   MqlRates bar3 = bars.GetOne(3);
   MqlRates bar2 = bars.GetOne(2);
   MqlRates bar1 = bars.GetOne(1);
   
   chart.SetSLTP(position.GetSL(), position.GetTP());

   bool canGoLong = false;
   if(bar1.low > bar2.low && bar2.low > bar3.low && !bars.IsFirstOfTheDay()) {
      canGoLong = true;
   }

   if(position.IsOpen()) {
      if(position.GetBarsDuration() == 4) {
         position.SetBreakevenSLTP();
      }
      
      position.CloseIfSLTP(lastDeal);

   } else {
      if(canGoLong && bars.IsNewBar()) {
         double sl = utils.AdjustToTick(bar3.low);
         double tp = utils.AdjustToTick(bar1.high + (bar1.close - bar3.low));
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         tp = utils.AdjustToTick(ask + 1500);
         sl = utils.AdjustToTick(ask - 3500);
         position.OpenAtMarket(POSITION_TYPE_BUY, volume, sl, tp);
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
