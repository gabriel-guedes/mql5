//+------------------------------------------------------------------+
//|                                        906_barbwire_reloaded.mq5 |
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
#include <zeroesq\MyConstraints.mqh>

enum myenum_directions
{
   LONG_ONLY,
   SHORT_ONLY,
   BOTH,
};

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inp_expert_name = "906_barbwire_reloaded";   //Expert Name
input uint     inp_ma_period = 20;                          //MA Period
input double   inp_deviation = 2;                           //Standard Deviation
input double   inp_buy_level = 0.6;                         //%B for buying
input double   inp_sell_level = 0.4;                        //%B for selling
input double   inp_di_limit = 30.0;                         //DI+/- limit
input bool     inp_use_SLTP = true;                         //Use function StrategySLTP
input myenum_directions inpDirection = BOTH;


//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyBars     bars;
CMyUtils    utils;
CMyReport   report;
CMyChart    chart;
MyConstraints constraints;
//+------------------------------------------------------------------+
//| Indicator handles and buffers                                    |
//+------------------------------------------------------------------+
int bands_handle, adx_handle, atr_handle, pct_b_handle;
double base_line[], lower_band[], upper_band[], adx[], di_plus[], di_minus[], atr[], pct_b[];
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

   if(!utils.IsValidExpertName(inp_expert_name)) {
      return(INIT_FAILED);
   }

   ulong magic_number = utils.StringToMagic(inp_expert_name);
   if (!utils.LockMagic(magic_number))
      return(INIT_FAILED);

   position.SetMagic(magic_number);
   
   constraints.SetDayTradeTime(9, 30, 17, 15);

   volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   adx_handle = iADXWilder(_Symbol, PERIOD_CURRENT, 14);
   ArraySetAsSeries(adx, true);
   ArraySetAsSeries(di_plus, true);
   ArraySetAsSeries(di_minus, true);
   

   bands_handle = iBands(_Symbol, PERIOD_CURRENT, inp_ma_period, 0, inp_deviation, PRICE_CLOSE);
   ArraySetAsSeries(base_line, true);
   ArraySetAsSeries(upper_band, true);
   ArraySetAsSeries(lower_band, true);
   
   atr_handle = iATR(_Symbol, PERIOD_CURRENT, inp_ma_period);
   ArraySetAsSeries(atr, true);
   
   pct_b_handle = iCustom(_Symbol, PERIOD_CURRENT, "zeroesq\\MyPercentB", inp_ma_period, inp_deviation, PRICE_CLOSE);
   ArraySetAsSeries(pct_b, true);
   
   

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

   CopyBuffer(adx_handle, 0, 1, 1, adx);
   CopyBuffer(adx_handle, PLUSDI_LINE, 1, 1, di_plus);
   CopyBuffer(adx_handle, MINUSDI_LINE, 1, 1, di_minus);
   CopyBuffer(atr_handle, 0, 0, 1, atr);
   CopyBuffer(pct_b_handle, 0, 1, 1, pct_b);
   CopyBuffer(bands_handle, BASE_LINE, 1, 3, base_line);
   CopyBuffer(bands_handle, UPPER_BAND, 1, 3, upper_band);
   CopyBuffer(bands_handle, LOWER_BAND, 1, 3, lower_band);
   

   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   double last_close = bars.GetOne(1).close;
   double B = (last_close - lower_band[0]) / (upper_band[0] - lower_band[0]);
   double buy_price = last_close - atr[0]*0.5;
   double sell_price = last_close + atr[0]*0.5;
   
   if(inp_use_SLTP) StrategySLTP();
   
   chart.SetSLTP(position.GetSL(), position.GetTP()); 

   bool go_long = false, go_short = false; 
   bool di_check = (di_plus[0] < inp_di_limit && di_minus[0] < inp_di_limit);
   bool b_long_check = pct_b[0] >= inp_buy_level;
   bool b_short_check = pct_b[0] <= inp_sell_level;
   bool price_long_check = current_price <= buy_price;
   bool price_short_check = current_price >= sell_price;
   
   if(b_long_check && di_check && price_long_check) {
      go_long = true;

   } else if(b_short_check && di_check && price_short_check) {
      go_short = true;
   }


   if(position.CloseIfSLTP(current_price)) {
      Print("Out on SLTP");
      return;
   }
   
   if(!constraints.DayTradeTimeCheck(bars.GetOne(0).time)) {
      if(position.IsOpen()) {
         position.Close(); 
      }
      return;      
   }

   if(position.IsOpen()) {                    //---positioned
   }
   else {                                     //---flat
      if(go_long && inpDirection != SHORT_ONLY) {
         position.BuyMarket(volume, 0.00, 0.00);

      } else if(go_short && inpDirection != LONG_ONLY) {
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
void StrategySLTP() {

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
   
   int sl_sign = 0, tp_sign = 0;
   if(position.GetType() == POSITION_TYPE_BUY) {
      sl_sign = -1;
      tp_sign = +1;
   } else if (position.GetType() == POSITION_TYPE_SELL) {
      sl_sign = +1;
      tp_sign = -1;
   }
   
   
   double entry_price = position.GetEntryPrice();
   double new_sl = entry_price + (atr[0] * sl_sign * 1);
   double new_tp = entry_price + (atr[0] * tp_sign * 1);
   
   position.ModifySLTP(new_sl, new_tp);
}