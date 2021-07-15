//+------------------------------------------------------------------+
//|                                                   MyPosition.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#define EXPERT_MAGIC 123456

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyPosition
{
private:
   double   mEADayProfit;
   double   mEAOpenProfit;
   uint     mBarsDuration;
   long     mType;
   ulong    mTicket;
   double   mVolume;
   long     mTime;
   datetime mLastBarTime;
   void     UpdateBarsDuration(datetime pTime);
   void     ResetBarsDuration();
   void     ResetInfo();
public:
   CMyPosition(void);
   bool              UpdateInfo(ulong pMagic, datetime pCurrentBarTime);
   bool              IsOpen();
   long              GetType();
   ulong             GetTicket();
   double            GetVolume();
   ulong             GetTicketByMagic(ulong pMagic);
   bool              ModifySLTP(ulong pTicket, ulong pMagic, double pSL, double pTP, double pVolume);
   uint              GetBarsDuration();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::CMyPosition(void)
{
   ResetInfo();
}
//+------------------------------------------------------------------+
//| Update Position Info                               |
//+------------------------------------------------------------------+
bool CMyPosition::UpdateInfo(ulong pMagic, datetime pCurrentBarTime)
{
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string positionSymbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      long typeLastChecked = PositionGetInteger(POSITION_TYPE);
      if(magic == pMagic && positionSymbol == _Symbol) {
         mTicket = PositionGetTicket(i);
         //mType = PositionGetInteger(POSITION_TYPE);
         mVolume = PositionGetDouble(POSITION_VOLUME);
         mTime = PositionGetInteger(POSITION_TIME);
         
         if(mType != typeLastChecked) //---position reversal
            ResetBarsDuration();
         mType = typeLastChecked;

         if(pCurrentBarTime > mLastBarTime && pCurrentBarTime > mTime)
            UpdateBarsDuration(pCurrentBarTime);
         return(true);
      }
   }

   ResetInfo();
   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::ResetInfo(void)
{
   mTicket = NULL;
   mType = -1;
   mVolume = 0.00;
   mTime = 0;
   mBarsDuration = 0;
   mLastBarTime = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::ResetBarsDuration(void)
{
   mBarsDuration = 0;
   mLastBarTime = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::UpdateBarsDuration(datetime pTime)
{
   mBarsDuration++;
   mLastBarTime = pTime;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsOpen(void)
{
   if(mType == POSITION_TYPE_BUY || mType == POSITION_TYPE_SELL)
      return(true);
   else
      return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CMyPosition::GetType(void)
{
   return(mType);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetTicket(void)
{
   return(mTicket);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetVolume(void)
{
   return(mVolume);
}
//+------------------------------------------------------------------+
//| Get First Position by magic number                               |
//+------------------------------------------------------------------+
ulong CMyPosition::GetTicketByMagic(ulong pMagic)
{
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string positionSymbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(magic == pMagic && positionSymbol == _Symbol) {
         return(PositionGetTicket(i));
      }
   }
   return(NULL);
}
//+------------------------------------------------------------------+
//| Change Position Take Profit                                      |
//+------------------------------------------------------------------+
bool CMyPosition::ModifySLTP(ulong pTicket, ulong pMagic, double pSL, double pTP, double pVolume)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_SLTP;
   request.position = pTicket;
   request.symbol = _Symbol;
   //request.magic = pMagic;
   request.sl = pSL;
   request.tp = pTP;
   request.volume = pVolume;

   return(OrderSend(request, result));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint CMyPosition::GetBarsDuration(void)
{
   return(mBarsDuration);
}
//+------------------------------------------------------------------+
