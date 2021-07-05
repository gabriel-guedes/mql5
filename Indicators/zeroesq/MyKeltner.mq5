//+------------------------------------------------------------------+
//|                                                    MyKeltner.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <MovingAverages.mqh>

#property indicator_chart_window
#property  indicator_buffers 2
#property  indicator_plots 2

#property indicator_width1 1
#property indicator_color1 clrRed
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "Upper Keltner"

#property indicator_width2 1
#property indicator_color2 clrRed
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Lower Keltner"

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input int      inpMAPeriod    = 21;             // MA Period
input double   inpMultiplier  = 1;              // Channel multiplicator
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int baseMAPeriod, plotBegin;
double multiplierFactor;
int ATR_handle, MA_handle;
//+------------------------------------------------------------------+
//| Indicator Buffers                                                |
//+------------------------------------------------------------------+
double upperBuffer[], lowerBuffer[], EMABuffer[], ATRBuffer[];

//+------------------------------------------------------------------+
//| Auxiliary Arrays                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if(inpMAPeriod < 2) {
      baseMAPeriod = 20;
      PrintFormat("Incorrect value for input variable inpMAPeriod=%d. Indicator will use value=%d for calculations.", inpMAPeriod, baseMAPeriod);
   } else
      baseMAPeriod = inpMAPeriod;


   if(inpMultiplier == 0.00) {
      multiplierFactor = 1.0;
      PrintFormat("Incorrect value for input variable inpMultiplier=%d. Indicator will use value=%d for calculations.", inpMultiplier, multiplierFactor);
   } else
      multiplierFactor = inpMultiplier;

//--- define buffers
   SetIndexBuffer(0, upperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, lowerBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, EMABuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, ATRBuffer, INDICATOR_CALCULATIONS);

//--- set index labels
   PlotIndexSetString(0, PLOT_LABEL, "Keltner(" + string(baseMAPeriod) + ") Upper");
   PlotIndexSetString(1, PLOT_LABEL, "Keltner(" + string(baseMAPeriod) + ") Lower");

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Keltner Channel(" + IntegerToString(inpMAPeriod) + ")");

//--- indexes draw begin settings
   plotBegin = baseMAPeriod - 1;
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, plotBegin);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, plotBegin);

//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- copy calculations buffers
   MA_handle = iMA(_Symbol, PERIOD_CURRENT, baseMAPeriod, 0, MODE_EMA, PRICE_TYPICAL);
   ATR_handle = iATR(_Symbol, PERIOD_CURRENT, baseMAPeriod);


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
   if(rates_total < plotBegin)
      return(0);

//--- indexes draw begin settings, when we've recieved previous begin
   if(plotBegin != baseMAPeriod + begin) {
      plotBegin = baseMAPeriod + begin;
      PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, plotBegin);
      PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, plotBegin);
   }

//--- starting calculation
   int pos;
   if(prev_calculated > 1)
      pos = prev_calculated - 1;
   else
      pos = 0;

//--- main cycle
   CopyBuffer(MA_handle, 0, 0, rates_total, EMABuffer);
   CopyBuffer(ATR_handle, 0, 0, rates_total, ATRBuffer);
   for(int i = pos; i < rates_total && !IsStopped(); i++) {
      //--- upper line
      upperBuffer[i] = EMABuffer[i] + (ATRBuffer[i] * multiplierFactor);
      //--- lower line
      lowerBuffer[i] = EMABuffer[i] - (ATRBuffer[i] * multiplierFactor);
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