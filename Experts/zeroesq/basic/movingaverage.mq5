//+------------------------------------------------------------------+
//|                                                movingaverage.mq5 |
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
CMyBars     bars;
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
   report.SetStartTime();

   if(!utils.IsValidExpertName(inpExpertName)) {
      return(INIT_FAILED);
   }

   ulong magic_number = utils.StringToMagic(inpExpertName);
   if (!utils.LockMagic(magic_number))
      return(INIT_FAILED);

   position.SetMagic(magic_number);

   volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   
   maHandle = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   ArraySetAsSeries(ma, true);   

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
   bars.SetInfo(10);
   position.Update(bars.GetOne(0).time);

   double lastDeal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);

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
            position.Reverse();
         else
            position.Close();

   } else {                         //---flat
      if(canGoLong && inpDirection != SHORT_ONLY)
         position.BuyMarket(volume, 0.00, 0.00);
      if(canGoShort && inpDirection != LONG_ONLY)
         position.SellMarket(volume, 0.00, 0.00);

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
