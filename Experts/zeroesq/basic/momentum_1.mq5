//+------------------------------------------------------------------+
//|                                                     momentum.mq5 |
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
input string   inpExpertName = "momentum"; //Expert Name
input uint     inpLongWindow = 10;         //Long Signal Bars Universe
input uint     inpShortWindow = 10;        //Short Signal Bars Universe
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

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double volume = 0.00;
double expectedRange = 0.00;


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
   
   int atrHandle = INVALID_HANDLE;
   atrHandle = iATR(_Symbol, PERIOD_D1, 20);

   double atr[];
   ArraySetAsSeries(atr, true);
   CopyBuffer(atrHandle, 0, 1, 1, atr);
   expectedRange = atr[0];   

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
   double lowestClose = bars.GetLowest(PRICE_CLOSE, 1, inpShortWindow);
   double highestClose = bars.GetHighest(PRICE_CLOSE, 1, inpLongWindow);

   if(lowestClose != highestClose) { //---skip dojis (they trigger consecutive reversals)
      if(lastClose == lowestClose)
         goShort = true;

      if(lastClose == highestClose)
         goLong = true;
   }


   if(position.IsOpen()) {          //---positioned
      if((position.GetType() == POSITION_TYPE_BUY && goShort) || ( position.GetType() == POSITION_TYPE_SELL && goLong))
         if(inpDirection == BOTH)
            position.Reverse();
         else
            position.Close();


   } else {                         //---flat
      if(goLong && inpDirection != SHORT_ONLY)
         position.OpenAtMarket(POSITION_TYPE_BUY, volume, 0.00, 0.00);
         //trade.BuyMarket(volume);
      if(goShort && inpDirection != LONG_ONLY)
         position.OpenAtMarket(POSITION_TYPE_SELL, volume, 0.00, 0.00);
         //trade.SellMarket(volume);

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
