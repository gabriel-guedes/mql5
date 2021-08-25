//+------------------------------------------------------------------+
//|                                       903_bb_mean_regression.mq5 |
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
input string   inpExpertName = "903_bb_mean_regression";  //Expert Name
input uint     inpMAPeriod = 20;                          //MA Period
input double   inpStdev = 2;                              //Standard Deviation
input bool     inpUseSLTP = true;                         //Use some kind of SLTP
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
int bands_handle, adx_handle, atr_handle;
double base_line[], lower_band[], upper_band[], adx[], atr[];
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

   adx_handle = iADXWilder(_Symbol, PERIOD_CURRENT, 14);
   ArraySetAsSeries(adx, true);

   bands_handle = iBands(_Symbol, PERIOD_CURRENT, inpMAPeriod, 0, inpStdev, PRICE_CLOSE);
   ArraySetAsSeries(base_line, true);
   ArraySetAsSeries(upper_band, true);
   ArraySetAsSeries(lower_band, true);
   
   atr_handle = iATR(_Symbol, PERIOD_CURRENT, inpMAPeriod);
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
   bars.SetInfo(3);
   position.Update(bars.GetOne(0).time);
   double lastDeal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);

   CopyBuffer(adx_handle, 0, 1, 1, adx);
   CopyBuffer(atr_handle, 0, 0, 1, atr);
   CopyBuffer(bands_handle, BASE_LINE, 1, 3, base_line);
   CopyBuffer(bands_handle, UPPER_BAND, 1, 3, upper_band);
   CopyBuffer(bands_handle, LOWER_BAND, 1, 3, lower_band);
   
   StrategySLTP(inpUseSLTP);
   
   chart.SetSLTP(position.GetSL(), position.GetTP());   

   MqlRates lastBar = bars.GetOne(1);

   bool goLong = false, goShort = false;

   if(lastBar.close < lower_band[0]) {
      goLong = true;

   } else if(lastBar.close > upper_band[0]) {
      goShort = true;
   }
   
   if(position.CloseIfSLTP(lastDeal)) {
      Print("Saiu no SLTP");
      return;
   }


   if(position.IsLong()) {          //---positioned LONG
      if(inpDirection == BOTH  && goShort) {
         position.Reverse();
      } else if(inpDirection == LONG_ONLY && goShort) {
         position.Close();
      }

   } else if(position.IsShort()) {  //---positioned SHORT
      if(inpDirection == BOTH  && goLong) {
         position.Reverse();
      } else if(inpDirection == SHORT_ONLY  && goLong) {
         position.Close();
      }
   }

   else {                         //---flat
      if(goLong && inpDirection != SHORT_ONLY) {
         position.BuyMarket(volume, 0.00, 0.00);

      } else if(goShort && inpDirection != LONG_ONLY) {
         position.SellMarket(volume, 0.00, 0.00);

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategySLTP(bool set_sltp = true) {
   if(!set_sltp) {
      return;
   }
   
   if(!position.IsOpen()) {
      return;
   }
   
   double current_sl = 0.00, current_tp = 0.00;
   current_sl = position.GetSL();
   current_tp = position.GetTP();
   
   if(current_sl != 0.00 && current_tp != 0.00) {
      return;
   }
   
   CopyBuffer(atr_handle, 0, 0, 1, atr);
   
   int sl_sign, tp_sign;
   if(position.GetType() == POSITION_TYPE_BUY) {
      sl_sign = -1;
      tp_sign = +1;
   } else if (position.GetType() == POSITION_TYPE_SELL) {
      sl_sign = +1;
      tp_sign = -1;
   }
   
   
   double entry_price = position.GetEntryPrice();
   double new_sl = entry_price + (atr[0] * sl_sign * 2);
   double new_tp = entry_price + (atr[0] * tp_sign * 2);
   
   position.ModifySLTP(new_sl, new_tp);
}