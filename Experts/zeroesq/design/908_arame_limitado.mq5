//+------------------------------------------------------------------+
//|                                           908_arame_limitado.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\Position.mqh>
#include <zeroesq\History.mqh>
#include <zeroesq\MyPriceBars.mqh>
#include <zeroesq\MyUtils.mqh>
#include <zeroesq\MyChart.mqh>
#include <zeroesq\MyConstraints.mqh>
#include <zeroesq\MyPending.mqh>
#include <zeroesq\MyTrade.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input ulong    inp_magic = 123456789;  //Magic Number
input uint     inp_ma_period = 20;     //MA Period
input double   inp_deviation = 2;      //Standard Deviation
input double   inp_buy_level = 0.6;    //%B for buying
input double   inp_sell_level = 0.4;   //%B for selling
input double   inp_di_limit = 30.0;    //DI+/DI- limit
input double   inp_risk_reward_ratio = 2.0;
input bool     inp_day_trade = false;
input myenum_directions inpDirection = BOTH;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double volume = 0.00;

//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
Position position(inp_magic);
History history;
CMyUtils    utils;
CMyBars     bars;
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   if(!utils.LockMagic(inp_magic))
      return(INIT_FAILED);

   if(inp_day_trade)
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
   EventKillTimer();

   utils.UnlockMagic(inp_magic);

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetInfo(3);
   MqlRates current_bar = bars.GetOne(0);
   MqlRates last_bar = bars.GetOne(1);
   bool is_trade_time = constraints.DayTradeTimeCheck(current_bar.time);
   
   position.update_profit();
   
   GetIndicators();
     
   double entry = 0.00, sl = 0.00, tp = 0.00;
   myenum_action action = DO_NOTHING;
   if(bars.IsNewBar() && is_trade_time) {
      action = Brain(last_bar, current_bar, entry, sl, tp);
   }

   

   if(position.is_flat()){                                   //---flat
      if(action != DO_NOTHING) {
         pending.CancelAllByMagic(inp_magic);
      }
      
      if(action == GO_LONG && inpDirection != SHORT_ONLY) {
         trade.BuyLimit(inp_magic, volume, entry, sl, tp);
      } 
      
      else if(action == GO_SHORT && inpDirection != LONG_ONLY) {
         trade.SellLimit(inp_magic, volume, entry, sl, tp);
      }
   }
   
   else {                                                   //---positioned
      if(!is_trade_time) trade.Close(inp_magic);
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

}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD){
      position.update();
      history.update_deals_of_the_day(inp_magic);
   }
}

//+------------------------------------------------------------------+
//| OnTester Function                                                |
//+------------------------------------------------------------------+
double OnTester()
{
   double ret = 0.0;
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
   tp = utils.AdjustToTick(entry_price + (atr[0] * tp_sign * inp_risk_reward_ratio));
   
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
myenum_action Brain(MqlRates &last_bar, MqlRates &current_bar, double &entry_price, double &sl, double &tp) {

   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   
   double buy_price = last_bar.close - atr[1]*0.6;
   double sell_price = last_bar.close + atr[1]*0.6;
   
   bool di_check = (di_plus[1] < inp_di_limit && di_minus[1] < inp_di_limit);
   bool b_long_check = pct_b[1] >= inp_buy_level;
   bool b_short_check = pct_b[1] <= inp_sell_level;
   
   bool bar_is_tradable = (current_bar.time != history.get_last_deal_time());
   bool can_sell_limit = current_price < sell_price;
   bool can_buy_limit = current_price > buy_price;
   
   if(di_check && b_long_check && can_buy_limit && bar_is_tradable) {
      entry_price = utils.AdjustToTick(buy_price);
      CalcSLTP(POSITION_TYPE_BUY, entry_price, sl, tp);
      return(GO_LONG);
   }
   else if(di_check && b_short_check && can_sell_limit && bar_is_tradable) {
      entry_price = utils.AdjustToTick(sell_price);
      CalcSLTP(POSITION_TYPE_SELL, entry_price, sl, tp);
      return(GO_SHORT);
   }
    
   return(WAIT_NEXT_SIGNAL);
}