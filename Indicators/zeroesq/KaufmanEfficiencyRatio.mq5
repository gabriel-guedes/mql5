//+------------------------------------------------------------------+
//|                                         KaufmanEffiencyRatio.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "Kaufman Efficiency Ratio"
//--- input parametrs
input int inp_period = 20;
//--- indicator buffer
double ker_buffer[];
//+------------------------------------------------------------------+
//| On Balance vol initialization function                        |
//+------------------------------------------------------------------+
void OnInit()
{
//--- define indicator buffer
   SetIndexBuffer(0, ker_buffer);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
//--- set plot begin
   int plot_begin = inp_period;
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, plot_begin);
}
//+------------------------------------------------------------------+
//| Price Density                                                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < inp_period+1)
      return(0);
//--- starting calculation
   int pos = prev_calculated - 1;
//--- correct position, when it's first iteration
   if(pos < 1) {
      pos = inp_period;
   }
//--- main cycle
   CalculatePriceDensity(pos, rates_total, close);
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculate Price Density                                          |
//+------------------------------------------------------------------+
void CalculatePriceDensity(int start_pos, int rates_total, const double& close[])
{


   for(int i = start_pos; i < rates_total && !IsStopped(); i++) {
      double rolling_closes[];
      int window_from = i - inp_period;
      ArrayCopy(rolling_closes, close, 0, window_from, inp_period+1);
      double first_close = rolling_closes[0];
      int last_index = ArraySize(rolling_closes)-1;
      double last_close = rolling_closes[last_index];
      double direction = MathAbs(first_close - last_close);

      double volatility = 0.00;
      for(int j = 0; j < inp_period; j++) {
         volatility = volatility + MathAbs(rolling_closes[j] - rolling_closes[j+1]);
      }

      ker_buffer[i] = direction / volatility;
   }

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
