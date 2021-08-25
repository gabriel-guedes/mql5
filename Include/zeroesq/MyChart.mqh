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
   CChartObjectHLine buy_stop_line;
   CChartObjectHLine sell_stop_line;
   CChartObjectHLine buy_limit_line;
   CChartObjectHLine sell_limit_line;   
public:
   void              CMyChart();
   void              SetSLTP(double pSL, double pTP);
   void              SetBuyStop(double price);
   void              SetSellStop(double price);
   void              SetBuyLimit(double price);
   void              SetSellLimit(double price);   
   
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
   
   buy_stop_line.Create(0, "Buy Stop", 0, 0.00);
   buy_stop_line.SetInteger(OBJPROP_COLOR, clrBlack);
   buy_stop_line.SetInteger(OBJPROP_STYLE, STYLE_SOLID);
   
   sell_stop_line.Create(0, "Sell Stop", 0, 0.00);
   sell_stop_line.SetInteger(OBJPROP_COLOR, clrBlack);
   sell_stop_line.SetInteger(OBJPROP_STYLE, STYLE_SOLID);
   
   buy_limit_line.Create(0, "Buy Limit", 0, 0.00);
   buy_limit_line.SetInteger(OBJPROP_COLOR, clrLightSkyBlue);
   buy_limit_line.SetInteger(OBJPROP_STYLE, STYLE_SOLID);
   
   sell_limit_line.Create(0, "Sell Limit", 0, 0.00);
   sell_limit_line.SetInteger(OBJPROP_COLOR, clrLightSkyBlue);
   sell_limit_line.SetInteger(OBJPROP_STYLE, STYLE_SOLID);   
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
//|                                                                  |
//+------------------------------------------------------------------+
void CMyChart::SetBuyStop(double price)
{
   buy_stop_line.SetDouble(OBJPROP_PRICE, price);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyChart::SetSellStop(double price)
{
   sell_stop_line.SetDouble(OBJPROP_PRICE, price);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyChart::SetBuyLimit(double price)
{
   buy_limit_line.SetDouble(OBJPROP_PRICE, price);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyChart::SetSellLimit(double price)
{
   sell_limit_line.SetDouble(OBJPROP_PRICE, price);
}
//+------------------------------------------------------------------+

