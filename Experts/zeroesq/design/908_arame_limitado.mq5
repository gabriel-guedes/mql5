//+------------------------------------------------------------------+
//|                                           908_arame_limitado.mq5 |
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
#include <zeroesq\MyPending.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inp_expert_name = "908_arame_limitado";      //Expert Name
input uint     inp_ma_period = 20;                          //MA Period
input double   inp_deviation = 2;                           //Standard Deviation
input double   inp_buy_level = 0.6;                         //%B for buying
input double   inp_sell_level = 0.4;                        //%B for selling
input double   inp_di_limit = 30.0;                         //DI+/DI- limit
input myenum_directions inpDirection = BOTH;


//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyBars     bars;
CMyUtils    utils;
CMyReport   report;
CMyChart    chart;
CMyTrade    trade;
MyConstraints constraints;
CMyPending  pending;
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
   MqlRates current_bar = bars.GetOne(0);
   MqlRates last_bar = bars.GetOne(1);
   double last_deal = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   
   position.Update(current_bar.time);
   
   GetIndicators();
     
   double entry = 0.00, sl = 0.00, tp = 0.00;
   myenum_action action = DO_NOTHING;
   if(bars.IsNewBar()) {
      action = Brain(last_bar.close, last_deal, current_bar.time, entry, sl, tp);
   }

   
   if(position.IsOpen()) {                    //---positioned

   }
   else {                                     //---flat
      if(action != DO_NOTHING) {
         pending.CancelAllByMagic(position.GetMagic());
      }
      
      if(action == GO_LONG && inpDirection != SHORT_ONLY) {
         position.BuyLimit(volume, entry, sl, tp);
      } 
      
      else if(action == GO_SHORT && inpDirection != LONG_ONLY) {
         position.SellLimit(volume, entry, sl, tp);
      }
   }
   
//   if(entry_occurred) {
//      position.Update(current_bar.time);
//      position.UpdateLastEntry(current_bar.time);
//      if(inp_use_SLTP) CalcSLTP();
//   }
//   
//   if(exit_occurred) {
//      position.Update(current_bar.time);
//      position.UpdateLastExit(current_bar.time);
//   }
 
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
void CalcSLTP(ENUM_POSITION_TYPE type, double entry_price, double &sl, double &tp) {

   int sl_sign = 0, tp_sign = 0;
   if(type == POSITION_TYPE_BUY) {
      sl_sign = -1;
      tp_sign = +1;
   } else if (type == POSITION_TYPE_SELL) {
      sl_sign = +1;
      tp_sign = -1;
   }
   
   sl = utils.AdjustToTick(entry_price + (atr[0] * sl_sign * 1));
   tp = utils.AdjustToTick(entry_price + (atr[0] * tp_sign * 1));
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetIndicators(void)
{
   CopyBuffer(adx_handle, 0, 0, 2, adx);
   CopyBuffer(adx_handle, PLUSDI_LINE, 0, 2, di_plus);
   CopyBuffer(adx_handle, MINUSDI_LINE, 0, 2, di_minus);
   CopyBuffer(atr_handle, 0, 0, 2, atr);
   CopyBuffer(pct_b_handle, 0, 0, 2, pct_b);
   CopyBuffer(bands_handle, BASE_LINE, 0, 2, base_line);
   CopyBuffer(bands_handle, UPPER_BAND, 0, 2, upper_band);
   CopyBuffer(bands_handle, LOWER_BAND, 0, 2, lower_band);   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
myenum_action Brain(double last_close, double current_price, datetime current_bar_time, double &entry_price, double &sl, double &tp) {

   double buy_price = last_close - atr[1]*0.5;
   double sell_price = last_close + atr[1]*0.5;
   
   //bool di_check = (di_plus[1] < inp_di_limit && di_minus[1] < inp_di_limit);
   bool di_check = true;
   bool b_long_check = pct_b[1] >= inp_buy_level;
   bool b_short_check = pct_b[1] <= inp_sell_level;
   bool bar_is_clear = (current_bar_time != position.GetLastEntry() && current_bar_time != position.GetLastExit());
   bool can_sell_limit = current_price < sell_price;
   bool can_buy_limit = current_price > buy_price;
   
   if(di_check && b_long_check && can_buy_limit && bar_is_clear) {
      entry_price = utils.AdjustToTick(buy_price);
      CalcSLTP(POSITION_TYPE_BUY, entry_price, sl, tp);
      return(GO_LONG);
   }
   else if(di_check && b_short_check && can_sell_limit && bar_is_clear) {
      entry_price = utils.AdjustToTick(sell_price);
      CalcSLTP(POSITION_TYPE_SELL, entry_price, sl, tp);
      return(GO_SHORT);
   }
    
   return(DO_NOTHING);
}