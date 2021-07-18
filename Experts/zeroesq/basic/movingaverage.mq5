//+------------------------------------------------------------------+
//|                                                movingaverage.mq5 |
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

enum myenum_directions
{
   LONG_ONLY,
   SHORT_ONLY,
   BOTH,
};

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inpExpertName = "moving average";   //Expert Name
input uint     inpMAPeriod = 9;                    //Long Signal Bars Universe
input myenum_directions inpDirection = BOTH;


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
int maHandle = INVALID_HANDLE;
double ma[];

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double volume = 0.00;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   maHandle = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod, 0, MODE_EMA, PRICE_CLOSE);

   ArraySetAsSeries(ma, true);

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
   bars.SetInfo(10);
   position.UpdateInfo(trade.GetMagic(), bars.GetOne(0).time);

   //if(bars.IsNewBar())
   //   Print(position.GetBarsDuration());

   bool goLong = false, goShort = false;
   double lastClose = bars.GetOne(1).close;
   double closeBeforeLast = bars.GetOne(2).close;
   CopyBuffer(maHandle, 0, 0, 2, ma);
   
   
   bool canGoLong = false, canGoShort = false;
   if(lastClose > ma[1] && closeBeforeLast <= ma[1])
      canGoLong = true;
   if(lastClose < ma[1] && closeBeforeLast >= ma[1])
      canGoShort = true;
      
   if(position.IsOpen()) {          //---positioned
      if((position.GetType() == POSITION_TYPE_BUY && canGoShort) || ( position.GetType() == POSITION_TYPE_SELL && canGoLong))
         if(inpDirection == BOTH)
            trade.Reverse(position.GetType(), position.GetVolume());
         else
            trade.Close();

   } else {                         //---flat
      if(canGoLong && inpDirection != SHORT_ONLY)
         trade.BuyMarket(volume);
      if(canGoShort && inpDirection != LONG_ONLY)
         trade.SellMarket(volume);

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
