//+------------------------------------------------------------------+
//|                                               KeltnerChannel.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"
#property indicator_chart_window

#property strict

#property description "Displays Keltner Channel technical indicator."

#property indicator_buffers 3
#property indicator_plots 3

#property indicator_width1 1
#property indicator_color1 clrRed
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "KeltnerTop"

#property indicator_width2 1
#property indicator_color2 clrOliveDrab
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_DASHDOT
#property indicator_label2 "KeltnerMiddle"

#property indicator_width3 1
#property indicator_color3 clrRed
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_label3 "KeltnerBottom"

//---- input parameters
input int      MA_Period            = 10;           // Period
input double   inpMulti             = 2.0;          // Channel multiplicator
input bool     bAtr                 = false;        // Use ATR
input ENUM_MA_METHOD     Mode       = MODE_SMA;     // MA Mode
input ENUM_APPLIED_PRICE Price_Type = PRICE_TYPICAL;// Price Type

double top[], middle[], bottom[];

int myMA, atr;
static int MINBAR = MA_Period + 1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0,top,     INDICATOR_DATA);
   SetIndexBuffer(1,middle,  INDICATOR_DATA);
   SetIndexBuffer(2,bottom,  INDICATOR_DATA);
   
   ArraySetAsSeries(top,     true);    
   ArraySetAsSeries(middle,  true);   
   ArraySetAsSeries(bottom,  true);   
   
   IndicatorSetString(INDICATOR_SHORTNAME,"KeltnerChannel" + IntegerToString(MA_Period) );
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

// To determine the position of the center line of the channel. 
   myMA = iMA(NULL, 0, MA_Period, 0, Mode, Price_Type);
   if (myMA == INVALID_HANDLE) {
      Print("Error while open iMA");
      return(INIT_FAILED);
   }      
// If specified in the input parameters, ATP is used to compute the upper and lower bounds.  
   if (bAtr) {
      atr = iATR(NULL, 0, MA_Period);
      if (atr == INVALID_HANDLE) {
         Print("Error while open iATR");
         return(INIT_FAILED);
      }       
   } else atr = INVALID_HANDLE;
   
   return INIT_SUCCEEDED;
}
  
void OnDeinit(const int reason) {
   IndicatorRelease(myMA);
   if (atr != INVALID_HANDLE)
      IndicatorRelease(atr);
}  

// Filling indicator buffers
void GetValue(const double& h[], const double& l[], int shift) {

   double ma[1];
   if (CopyBuffer(myMA, 0, shift, 1, ma) <= 0) return;

// Center line  
   middle[shift] = ma[0];

// Channel boundaries   
   double a = avg(h, l, shift);
   top[shift]    = middle[shift] + a * inpMulti;
   bottom[shift] = middle[shift] - a * inpMulti;   
}

// Calculate the value of the multiplier to calculate the position of the boundaries
double avg(const double& High[],const double& Low[], int shift) {
   
   double sum = 0.0;
// Averaging the size of the candlestick body for the MA_Period period  
   if (atr == INVALID_HANDLE) {
      for(int i = shift; i < shift + MA_Period; i++)
         sum += High[i] - Low[i];
         
   } else {
// We use ATR data for the same period
      double t[];
      ArrayResize(t, MA_Period);
      ArrayInitialize(t, 0);
      
      if (CopyBuffer(atr, 0, shift, MA_Period, t) <= 0) return sum;
      
      for(int i = 0; i < MA_Period; i++)
         sum += t[i];
   }
   
   return sum / MA_Period;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[]) {
// MINBAR - "non-computed" indicator tail               
      if(rates_total <= MINBAR) return 0;
      ArraySetAsSeries(close,true);    
      ArraySetAsSeries(high, true); 
      ArraySetAsSeries(low,  true); 
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   // A new tick
      } else if (limit == 1) {   // A new bar
// Calculations on the last closed candle     
         GetValue(high, low, 1);   
         return(rates_total);    
      } else if (limit > 1)  {   // The first call of the indicator, changing the timeframe, loading history
         ArrayInitialize(middle, EMPTY_VALUE);
         ArrayInitialize(top,    EMPTY_VALUE);
         ArrayInitialize(bottom, EMPTY_VALUE);
         limit = rates_total - MINBAR;
// Calculations on history        
         for(int i = limit; i >= 1 && !IsStopped(); i--)
            GetValue(high, low, i);
         return(rates_total);         
      }
// Calculations at each new tick. Perhaps this GetValue() call can be commented out. Then
// the indicator will be limited to work only on closed candles    
      GetValue(high, low, 0);       
         
   return(rates_total);
  }
