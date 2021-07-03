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
   double            mEADayProfit;
   double            mEAOpenProfit;
   double            mTickSize;
   double            mTickValue;

public:
                     CMyPosition(void);
   void              CalcEADayProfit(string pSymbol, ulong pMagic);
   double            GetEADayProfit();
   void              CalcEAOpenProfit(string pSymbol, ulong pMagic);
   double            GetEAOpenProfit();
   double            GetEATotalProfit();
   double            BreakEven();
   double            CashToPoints();
   double            AdjustToTickSize(double pPoints);
   ulong             SelectPositionByMagic(ulong pMagic);
   bool              ModifySLTP(ulong pTicket, ulong pMagic, double pSL, double pTP, double pVolume);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMyPosition::CMyPosition(void)
{
   mTickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   mTickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::CalcEADayProfit(string pSymbol, ulong pMagic)
{
   MqlDateTime from_date, to_date;
   TimeCurrent(from_date);
   from_date.hour = 0;
   from_date.min = 0;
   from_date.sec = 0;
   TimeCurrent(to_date);
   to_date.hour = 23;
   to_date.min = 59;
   to_date.sec = 59;

   datetime begin = StructToTime(from_date);
   datetime end = StructToTime(to_date);

   HistorySelect(begin, end);

   uint dealsTotal = HistoryDealsTotal();
   mEADayProfit = 0;

   for(uint i = 0; i < dealsTotal; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      ulong dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
      ulong dealMagic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      string dealSymbol = HistoryDealGetString(ticket, DEAL_SYMBOL);

      if(dealType != DEAL_TYPE_BALANCE && dealMagic == pMagic && dealSymbol == pSymbol)
         mEADayProfit = mEADayProfit + (HistoryDealGetDouble(ticket, DEAL_PROFIT));
   }

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetEADayProfit()
{
   return(mEADayProfit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::CalcEAOpenProfit(string pSymbol, ulong pMagic)
{

   mEAOpenProfit = 0;

   long total = PositionsTotal();

   for(int i = 0; i < total; i++) {
      PositionSelectByTicket(i);
      ulong positionTicket = PositionGetTicket(i);
      ulong positionMagic = PositionGetInteger(POSITION_MAGIC);
      string positionSymbol = PositionGetString(POSITION_SYMBOL);

      if(positionSymbol == pSymbol && positionMagic == pMagic)
         mEAOpenProfit = mEAOpenProfit + PositionGetDouble(POSITION_PROFIT);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetEAOpenProfit()
{
   return(mEAOpenProfit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::BreakEven()
{
   return(0);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::AdjustToTickSize(double pPoints)
{
   double lAdjusted = (MathFloor(pPoints / mTickSize) * mTickSize);
   return(lAdjusted);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetEATotalProfit(void)
{
   return(mEAOpenProfit + mEADayProfit);
}
//+------------------------------------------------------------------+
//| Get First Position by magic number                               |
//+------------------------------------------------------------------+
ulong CMyPosition::SelectPositionByMagic(ulong pMagic)
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