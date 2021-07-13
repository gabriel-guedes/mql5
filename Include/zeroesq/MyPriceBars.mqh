//+------------------------------------------------------------------+
//|                                                        Price.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
//#define MAX_BARS 100

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyBars
{
protected:
   MqlRates          mBars[];
   double            mClosedHighs[], mClosedLows[];
   datetime          mLastBarTime;
   uint              mDayBarCount;
public:
                     CMyBars(void);
   void              SetInfo(int pBarsCount);
   MqlRates          GetOne(int pShift);
   double            GetBarSize(int pShift);
   double            GetHighestHigh();
   double            GetLowestLow();
   double            GetLowestHigh();
   double            GetHighestLow();   
   int               GetDayBarCount(string pSymbol, ENUM_TIMEFRAMES pTimeframe);
   bool              IsNewBar();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMyBars::CMyBars(void)
{
   ArraySetAsSeries(mBars, true);
   ArraySetAsSeries(mClosedHighs, true);
   ArraySetAsSeries(mClosedLows, true);
   
   mLastBarTime = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyBars::SetInfo(int pBarsCount)
{
   CopyRates(_Symbol, PERIOD_CURRENT, 0, pBarsCount, mBars);
   
   if(pBarsCount > 1) {
      CopyHigh(_Symbol, PERIOD_CURRENT, 1, pBarsCount, mClosedHighs);
      CopyLow(_Symbol, PERIOD_CURRENT, 1, pBarsCount, mClosedLows);
   }
}
//+------------------------------------------------------------------+
//| Get Bar                                                          |
//+------------------------------------------------------------------+
MqlRates CMyBars::GetOne(int pShift)
{
   return mBars[pShift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetBarSize(int pShift)
{
   double barSize = mBars[pShift].high - mBars[pShift].low;
   NormalizeDouble(barSize, _Digits);
   return(barSize);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetHighestHigh()
{   
   int i = ArrayMaximum(mClosedHighs);
   return(mClosedHighs[i]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetHighestLow()
{
   int i = ArrayMaximum(mClosedLows);
   return(mClosedLows[i]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetLowestLow()
{
   int i = ArrayMinimum(mClosedLows);
   return(mClosedLows[i]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetLowestHigh()
{
   int i = ArrayMinimum(mClosedHighs);
   return(mClosedHighs[i]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyBars::IsNewBar()
{
   bool firstRun = false, newBar = false;
   datetime openingTimes[];
   ArraySetAsSeries(openingTimes, true);

   CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, openingTimes);
   
   if(mLastBarTime == 0)
      firstRun = true;

   if(openingTimes[0] > mLastBarTime) {
      if(firstRun == false) {
         newBar = true;
      }

      mLastBarTime = openingTimes[0];

   }

   return(newBar);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyBars::GetDayBarCount(string pSymbol, ENUM_TIMEFRAMES pTimeframe)
{

   MqlDateTime lNow, lZero;

   datetime lStop = TimeCurrent(lNow);

   lNow.hour = lNow.min = lNow.sec = 0;
   datetime lStart = StructToTime(lNow);

   return(Bars(pSymbol, pTimeframe, lStart, lStop));
}
//+------------------------------------------------------------------+

