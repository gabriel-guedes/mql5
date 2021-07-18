//+------------------------------------------------------------------+
//|                                                        Price.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyBars
{
protected:
   MqlRates          mBars[];
   datetime          mLastClosedBarTime;
   bool              mIsNewBar;
   bool              mIsFirstOfTheDay;
   uint              mDayBarCount;
   void              GetSlice(int pAppliedPrice, double &prices[], int pStartPos, int pCount);
   bool              CheckIfNewDay(datetime pLast, datetime pCurrent);
public:
                     CMyBars(void);
   void              SetInfo(int pBarsCount);
   MqlRates          GetOne(int pShift);
   double            GetBarSize(int pShift);
   double            GetHighest(int pAppliedPrice, int pStartPos, int pCount);
   double            GetLowest(int pAppliedPrice, int pStartPos, int pCount);
   int               GetDayBarCount(string pSymbol, ENUM_TIMEFRAMES pTimeframe);
   bool              IsNewBar();
   bool              IsFirstOfTheDay();   
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMyBars::CMyBars(void)
{
   ArraySetAsSeries(mBars, true);
   mLastClosedBarTime = 0;
   mIsNewBar = false;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyBars::SetInfo(int pBarsCount)
{
   int barsTo = 2;

   if(pBarsCount > barsTo)
      barsTo = pBarsCount;

   CopyRates(_Symbol, PERIOD_CURRENT, 0, barsTo, mBars);

   if(mLastClosedBarTime < mBars[1].time) {
      mIsNewBar = true;
      mLastClosedBarTime = mBars[1].time;

   } else {
      mIsNewBar = false;
   }
   
   mIsFirstOfTheDay = CheckIfNewDay(mBars[1].time, mBars[0].time);   

}
//+------------------------------------------------------------------+
//| Get One Bar                                                      |
//+------------------------------------------------------------------+
MqlRates CMyBars::GetOne(int pShift)
{
   return mBars[pShift];
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyBars::GetSlice(int pAppliedPrice, double &prices[], int pStartPos, int pCount)
{

   if(pCount <= 0)
      PrintFormat("ERROR - %s bar count must be greater then 0", __FILE__);

   if(pAppliedPrice == PRICE_CLOSE)
      CopyClose(_Symbol, PERIOD_CURRENT, pStartPos, pCount, prices);
   else if (pAppliedPrice == PRICE_OPEN)
      CopyOpen(_Symbol, PERIOD_CURRENT, pStartPos, pCount, prices);
   else if(pAppliedPrice == PRICE_LOW)
      CopyLow(_Symbol, PERIOD_CURRENT, pStartPos, pCount, prices);
   else if(pAppliedPrice == PRICE_HIGH)
      CopyHigh(_Symbol, PERIOD_CURRENT, pStartPos, pCount, prices);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetHighest(int pAppliedPrice, int pStartPos, int pCount)
{
   double prices[];
   GetSlice(pAppliedPrice, prices, pStartPos, pCount);

   int i = ArrayMaximum(prices);
   return(prices[i]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyBars::GetLowest(int pAppliedPrice, int pStartPos = 0, int pCount = 0)
{
   double prices[];
   GetSlice(pAppliedPrice, prices, pStartPos, pCount);

   int i = ArrayMinimum(prices);
   return(prices[i]);
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
bool CMyBars::IsNewBar()
{
   if(mLastClosedBarTime == 0) {
      Print("ERROR - Bars not set. Use meth CMyBars.SetInfo");
   }

   return(mIsNewBar);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyBars::IsFirstOfTheDay(void)
{
   return(mIsFirstOfTheDay);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyBars::CheckIfNewDay(datetime pLast,datetime pCurrent)
{
   MqlDateTime last, current;
   
   TimeToStruct(pLast, last);
   TimeToStruct(pCurrent, current);
   
   if(current.day > last.day || current.mon > last.mon || current.year > last.year)
      return(true);
   else
      return(false);
   
   
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
