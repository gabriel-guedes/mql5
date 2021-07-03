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
   datetime          mTime[], mLastTime;
   int               mDayBarCount;
public:
                     CMyBars(void);
   void              SetBars(int pBarsCount);
   double            GetClose(int pShift);
   double            GetHigh(int pShift);
   double            GetLow(int pShift);
   double            GetOpen(int pShift);
   datetime          GetTime(int pShift);
   long              GetTickVolume(int pShift);
   long              GetVolume(int pShift);
   double            GetVolumeAvg(int pPeriod);
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
   ArraySetAsSeries(mTime, true);
   ArraySetAsSeries(mClosedHighs, true);
   ArraySetAsSeries(mClosedLows, true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyBars::SetBars(int pBarsCount)
{
   CopyRates(_Symbol, PERIOD_CURRENT, 0, pBarsCount, mBars);
   
   if(pBarsCount > 1) {
      CopyHigh(_Symbol, PERIOD_CURRENT, 1, pBarsCount, mClosedHighs);
      CopyLow(_Symbol, PERIOD_CURRENT, 1, pBarsCount, mClosedLows);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetClose(int pShift)
{
   return(mBars[pShift].close);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetHigh(int pShift)
{
   return(mBars[pShift].high);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetLow(int pShift)
{
   return(mBars[pShift].low);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetOpen(int pShift)
{
   return(mBars[pShift].open);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CMyBars::GetTime(int pShift)
{
   return(mBars[pShift].time);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CMyBars::GetTickVolume(int pShift)
{
   return(mBars[pShift].tick_volume);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CMyBars::GetVolume(int pShift)
{
   return(mBars[pShift].real_volume);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetVolumeAvg(int pPeriod)
{
//Calculate Volume Average
   double avg = 0;
   for(int x = 1; x <= pPeriod; x++) {
      avg = avg + mBars[x].real_volume;
   }
   avg = avg / pPeriod;
   NormalizeDouble(avg, _Digits);
   return(avg);
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
   bool lFirstRun = false, lNewBar = false;

   CopyTime(_Symbol, PERIOD_CURRENT, 0, 2, mTime);

   if(mLastTime == 0) {
      lFirstRun = true;
   }

   if(mTime[0] > mLastTime) {
      if(lFirstRun == false) {
         lNewBar = true;
      }

      mLastTime = mTime[0];

   }

   return(lNewBar);
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
