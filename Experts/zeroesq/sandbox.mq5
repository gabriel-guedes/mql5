//+------------------------------------------------------------------+
//|                                                      sandbox.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

input int inp_period=20;

double price_density_buffer[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double highs[], lows[];
   CopyHigh(_Symbol, PERIOD_CURRENT, 0, 1000, highs);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, 1000, lows);
   int rates_total = ArraySize(highs);
   ArrayResize(price_density_buffer, rates_total);
   int pos = inp_period-1;
   CalculatePriceDensity(pos, rates_total, highs, lows);   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
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

   }

}
