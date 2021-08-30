//+------------------------------------------------------------------+
//|                                            907_arame_farpado.mq5 |
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

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inp_expert_name = "907_arame_farpado";       //Expert Name
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
myenum_action action;
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
   
   action = Brain(last_bar.close, last_deal, current_bar.time);
   
   chart.SetSLTP(position.GetSL(), position.GetTP());
   
   bool tradable_time = constraints.DayTradeTimeCheck(current_bar.time);
   bool sltp_hit = position.SLTPHit(last_deal);

   bool entry_occurred = false, exit_occurred = false;

   if(position.IsOpen()) {                    //---positioned
      if(sltp_hit || !tradable_time)
         exit_occurred = position.Close();
   }
   else {                                     //---flat
      if(action == GO_LONG && tradable_time && inpDirection != SHORT_ONLY) {
         entry_occurred = position.BuyMarket(volume, 0.00, 0.00);         
      } 
      
      else if(action == GO_SHORT && tradable_time && inpDirection != LONG_ONLY) {
         entry_occurred = position.SellMarket(volume, 0.00, 0.00);
      }
   }
   
   if(entry_occurred) {
      position.Update(current_bar.time);
      position.UpdateLastEntry(current_bar.time);
      if(inp_use_SLTP) CalcSLTP();
   }
   
   if(exit_occurred) {
      position.Update(current_bar.time);
      position.UpdateLastExit(current_bar.time);
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
void CalcSLTP() {

   if(!position.IsOpen()) {
      return;
   }
   
   double current_sl = 0.00, current_tp = 0.00;
   current_sl = position.GetSL();
   current_tp = position.GetTP();
   
   if(current_sl != 0.00 && current_tp != 0.00) {
      return;
   }
   
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
myenum_action Brain(double last_close, double current_price, datetime current_bar_time) {

   double buy_price = last_close - atr[1]*0.5;
   double sell_price = last_close + atr[1]*0.5;
   
   double buy_line = 0.00, sell_line = 0.00;
   if(position.IsFlat()) {
      buy_line = buy_price;
      sell_line = sell_price;
   }
   chart.SetBuyLimit(buy_line);
   chart.SetSellLimit(sell_line);
   
   bool di_check = (di_plus[1] < inp_di_limit && di_minus[1] < inp_di_limit);
   bool b_long_check = pct_b[1] >= inp_buy_level;
   bool b_short_check = pct_b[1] <= inp_sell_level;
   bool price_long_check = current_price <= buy_price;
   bool price_short_check = current_price >= sell_price;
   bool bar_is_clear = (current_bar_time != position.GetLastEntry() && current_bar_time != position.GetLastExit());   
   
   if(di_check && b_long_check && price_long_check && bar_is_clear) {
      return(GO_LONG);
   }
   else if(di_check && b_short_check && price_short_check && bar_is_clear) {
      return(GO_SHORT);
   }
    
   return(DO_NOTHING);
}