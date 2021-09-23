//+------------------------------------------------------------------+
//|                                                 PriceDensity.mq5 |
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
#property indicator_label1  "Price Density"
//--- input parametrs
input int inp_period = 20;
//--- indicator buffer
double price_density_buffer[];
//+------------------------------------------------------------------+
//| On Balance vol initialization function                        |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- define indicator buffer
   SetIndexBuffer(0, price_density_buffer);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
//--- set plot begin   
   int plot_begin = inp_period - 1;
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
   if(rates_total<inp_period)
      return(0);
//--- starting calculation
   int pos=prev_calculated-1;
//--- correct position, when it's first iteration
   if(pos<1)
     {
      pos=inp_period-1;
     }
//--- main cycle
   CalculatePriceDensity(pos, rates_total, high, low);
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Price Density                                          |
//+------------------------------------------------------------------+
void CalculatePriceDensity(int start_pos, int rates_total, const double& high[], const double& low[]) {


   for(int i=start_pos; i<rates_total && !IsStopped(); i++) {
      double window_lows[], window_highs[];
      int window_from = i-inp_period+1;
      ArrayCopy(window_highs, high, 0, window_from, inp_period);      
      ArrayCopy(window_lows, low, 0, window_from, inp_period);
      int hh_index = ArrayMaximum(window_highs);
      double highest_high = window_highs[hh_index];
      int ll_index = ArrayMinimum(window_lows);
      double lowest_low = window_lows[ll_index];
      double denominator = highest_high-lowest_low;
      
      double numerator = 0.00;
      for(int j = 0; j<inp_period; j++) {
         numerator = numerator + (window_highs[j] - window_lows[j]);
      }
      
      price_density_buffer[i] = numerator / denominator;
      //price_density_buffer[i] = double(i);
   }

}
//+------------------------------------------------------------------+
