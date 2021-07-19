//+------------------------------------------------------------------+
//|                                               MyChartObjects.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

#include <ChartObjects\ChartObjectsLines.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyChart
{
private:
   CChartObjectHLine sl_line;
   CChartObjectHLine tp_line;
public:
   void              CMyChart();
   void              SetSLTP(double pSL, double pTP);
   
};
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyChart::CMyChart(void)
{
   sl_line.Create(0, "Stop Loss", 0, 0.00);
   sl_line.SetInteger(OBJPROP_COLOR, clrRed);
   sl_line.SetInteger(OBJPROP_STYLE, STYLE_DOT);
   
   tp_line.Create(0, "Take Profit", 0, 0.00);
   tp_line.SetInteger(OBJPROP_COLOR, clrMediumBlue);
   tp_line.SetInteger(OBJPROP_STYLE, STYLE_DOT);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyChart::SetSLTP(double pSL,double pTP)
{
   sl_line.SetDouble(OBJPROP_PRICE, pSL);
   tp_line.SetDouble(OBJPROP_PRICE, pTP);
}
//+------------------------------------------------------------------+
