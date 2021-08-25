//+------------------------------------------------------------------+
//|                                                    MyPercentB.mq5|
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#property indicator_separate_window
#property  indicator_buffers 1
#property  indicator_plots 1

#property indicator_width1 1
#property indicator_color1 clrRed
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "%B"


//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input int      inp_ma_period    = 20;             // MA Period
input double   inp_deviation    = 2;              // Standard Deviation
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int bb_handle, plot_begin;
//+------------------------------------------------------------------+
//| Indicator Buffers                                                |
//+------------------------------------------------------------------+
double pct_b[];

//+------------------------------------------------------------------+
//| Auxiliary Arrays                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if(inp_ma_period < 2) {
      PrintFormat("Incorrect value for input variable inpMAPeriod=%d. Indicator will use value=%d for calculations.", inp_ma_period);
      return(INIT_FAILED);
   }

//--- define buffers
   SetIndexBuffer(0, pct_b, INDICATOR_DATA);

//--- set index labels
   PlotIndexSetString(0, PLOT_LABEL, "%B(" + string(inp_ma_period) + "-ema " + string(inp_deviation) + "-stdev)");

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "%B");

//--- indexes draw begin settings
   plot_begin = inp_ma_period + 1;
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, plot_begin);

//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

//--- copy calculations buffers
   bb_handle = iBands(_Symbol, PERIOD_CURRENT, inp_ma_period, 0, inp_deviation, PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}
//+------------------------------------------------------------------+
//| Keltner Channel                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if(rates_total < plot_begin)
      return(0);

//--- indexes draw begin settings, when we've recieved previous begin
   if(plot_begin != inp_ma_period + begin) {
      plot_begin = inp_ma_period + begin;
      PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, plot_begin);
   }

//--- starting calculation
   int pos;
   if(prev_calculated > 1)
      pos = prev_calculated - 1;
   else
      pos = 0;

//--- main cycle
   double bb_upper[], bb_lower[];
   CopyBuffer(bb_handle, 1, 0, rates_total, bb_upper);
   CopyBuffer(bb_handle, 2, 0, rates_total, bb_lower);
   
   for(int i = pos; i < rates_total && !IsStopped(); i++) {
      //--- %b
      double bandwidth = (bb_upper[i] - bb_lower[i]);
      if(bandwidth != 0.00) {
         pct_b[i] = (price[i] - bb_lower[i]) / bandwidth;
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+