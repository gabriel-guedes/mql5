//+------------------------------------------------------------------+
//|                                                   MyPosition.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#define EXPERT_MAGIC 123456

#include <zeroesq\MyTrade.mqh>

struct tyPosition
{
   ulong       magic;
   long        type;
   ulong       ticket;
   double      volume;
   long        time;
   double      entry_price;
   double      sl;
   double      tp;
   datetime    last_bar_time;
   ulong       bars_duration;
   double      open_profit;
   double      max_profit;
   datetime    last_entry;
   datetime    last_exit;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyPosition
{
private:
   tyPosition        mInfo;
   CMyTrade          trade;
   void              UpdateBarsDuration(datetime pTime);
   void              ResetBarsDuration();
   void              ResetInfo();
   void              SetSLTP(double pSL, double pTP);
public:
   CMyPosition(void);
   void              SetMagic(ulong pMagic);
   bool              Update(datetime pCurrentBarTime);
   void              UpdateLastEntry(datetime bar_open_time);
   void              UpdateLastExit(datetime bar_open_time);
   datetime          GetLastEntry(void);   
   datetime          GetLastExit(void);
   bool              IsOpen();
   bool              IsLong();
   bool              IsShort();
   bool              IsFlat();
   long              GetType();
   ulong             GetTicket();
   double            GetSL();
   double            GetTP();
   double            GetVolume();
   ulong             GetMagic();
   double            GetProfit();
   double            GetDrawdown();
   double            GetMaxProfit();
   double            GetEntryPrice();
   ulong             GetTicketByMagic(ulong pMagic);
   bool              ModifySLTP(double pSL, double pTP, bool allow_zero = false);
   bool              SetBreakevenSLTP();
   ulong             GetBarsDuration();
   bool              IsValidSLTP(ulong pPositionType, double pSL, double pTP);
   bool              IsValidSL(double stop_loss);
   bool              IsValidTP(double take_profit);
   bool              SLTPHit(double pPrice);   
   bool              CloseIfSLTP(double pPrice);
   bool              Close();
   bool              Reverse();
   bool              BuyMarket(double pVolume, double pSL, double pTP, string pComment = NULL);
   bool              SellMarket(double pVolume, double pSL, double pTP, string pComment = NULL);
   bool              BuyStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL);
   bool              SellStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL);
   bool              BuyLimit(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL);
   bool              SellLimit(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::CMyPosition(void)
{
   mInfo.last_entry = 0;
   mInfo.last_exit = 0;   
   
   ResetInfo();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::SetMagic(ulong pMagic)
{
   mInfo.magic = pMagic;
}
//+------------------------------------------------------------------+
//| Update Position Info                               |
//+------------------------------------------------------------------+
bool CMyPosition::Update(datetime pCurrentBarTime)
{
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string positionSymbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      long typeLastChecked = PositionGetInteger(POSITION_TYPE);
      if(magic == mInfo.magic && positionSymbol == _Symbol) {
         mInfo.ticket = PositionGetTicket(i);
         mInfo.volume = PositionGetDouble(POSITION_VOLUME);
         mInfo.time = PositionGetInteger(POSITION_TIME);
         mInfo.entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
         mInfo.open_profit = PositionGetDouble(POSITION_PROFIT);
         if(mInfo.open_profit > mInfo.max_profit) {
            mInfo.max_profit = mInfo.open_profit;
         }

         if(mInfo.type != typeLastChecked) { //---position reversal
            ResetBarsDuration();
            mInfo.type = typeLastChecked;
            mInfo.max_profit = 0.00;
         }      

         if(pCurrentBarTime > mInfo.last_bar_time && pCurrentBarTime > mInfo.time) {
            UpdateBarsDuration(pCurrentBarTime);
         }

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
   mInfo.ticket = NULL;
   mInfo.type = -1;
   mInfo.volume = 0.00;
   mInfo.time = 0;
   mInfo.entry_price = 0.00;
   mInfo.sl = 0.00;
   mInfo.tp = 0.00;
   mInfo.bars_duration = 0;
   mInfo.last_bar_time = 0;
   mInfo.open_profit = 0.00;
   mInfo.max_profit = 0.00;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::ResetBarsDuration(void)
{
   mInfo.bars_duration = 0;
   mInfo.last_bar_time = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::UpdateBarsDuration(datetime pTime)
{
   mInfo.bars_duration++;
   mInfo.last_bar_time = pTime;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::UpdateLastEntry(datetime bar_open_time)
{
   mInfo.last_entry = bar_open_time;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::UpdateLastExit(datetime bar_open_time)
{
   mInfo.last_exit = bar_open_time;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CMyPosition::GetLastEntry(void)
{
   return(mInfo.last_entry);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CMyPosition::GetLastExit(void)
{
   return(mInfo.last_exit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::SetSLTP(double pSL, double pTP)
{
   mInfo.sl = pSL;
   mInfo.tp = pTP;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::BuyMarket(double pVolume, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;
   success = trade.BuyMarket(mInfo.magic, pVolume, pSL, pTP, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SellMarket(double pVolume, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;
   success = trade.SellMarket(mInfo.magic, pVolume, pSL, pTP, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::BuyStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;

   success = trade.BuyStopLimit(mInfo.magic, pVolume, pPrice, pSL, pTP);

   return(success);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SellStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;

   success = trade.SellStopLimit(mInfo.magic, pVolume, pPrice, pSL, pTP);

   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::BuyLimit(double pVolume,double pPrice,double pSL,double pTP,string pComment=NULL)
{
   bool success = false;
   
   success = trade.BuyLimit(mInfo.magic, pVolume, pPrice, pSL, pTP, 50, 0, pComment);
   
   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SellLimit(double pVolume,double pPrice,double pSL,double pTP,string pComment=NULL)
{
   bool success = false;
   
   success = trade.SellLimit(mInfo.magic, pVolume, pPrice, pSL, pTP, 50, 0, pComment);
      
   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::CloseIfSLTP(double pPrice)
{
   long   positionType = GetType();
   ulong   magic = GetMagic();
   double sl = GetSL();
   double tp = GetTP();

   if(StopLossHit(positionType, sl, pPrice)) {
      return(trade.Close(magic, 0, "SL zeroesq"));
   }

   if(TakeProfitHit(positionType, tp, pPrice)) {
      return(trade.Close(magic, 0, "TP zeroesq"));
   }

   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SLTPHit(double pPrice)
{
   long   positionType = GetType();
   ulong   magic = GetMagic();
   double sl = GetSL();
   double tp = GetTP();

   if(StopLossHit(positionType, sl, pPrice)) {
      return(true);
   }

   if(TakeProfitHit(positionType, tp, pPrice)) {
      return(true);
   }

   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::Close(void)
{
   ulong magic = GetMagic();
   return(trade.Close(magic));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::Reverse(void)
{
   bool success = trade.Reverse(GetType(), GetMagic(), GetVolume());

   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsOpen(void)
{
   if(mInfo.type == POSITION_TYPE_BUY || mInfo.type == POSITION_TYPE_SELL)
      return(true);
   else
      return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsLong(void)
{
   return(mInfo.type == POSITION_TYPE_BUY);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsShort(void)
{
   return(mInfo.type == POSITION_TYPE_SELL);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsFlat(void)
{
   return(mInfo.type == -1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CMyPosition::GetType(void)
{
   return(mInfo.type);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetTicket(void)
{
   return(mInfo.ticket);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetVolume(void)
{
   return(mInfo.volume);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetSL(void)
{
   return(mInfo.sl);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetTP(void)
{
   return(mInfo.tp);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetMagic(void)
{
   return(mInfo.magic);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetProfit(void)
{
   return(mInfo.open_profit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetDrawdown(void)
{
   if(mInfo.max_profit > 0.00) {
   }
   return(mInfo.open_profit - mInfo.max_profit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetMaxProfit(void)
{
   return(mInfo.max_profit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetEntryPrice(void) 
{
   return(mInfo.entry_price);
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
bool CMyPosition::ModifySLTP(double stop_loss, double take_profit, bool allow_zero = false)
{
     
   if(!allow_zero && stop_loss == 0.00) {
      Print("WARN - SL should not be 0.00");
      return(false);
   }
   
   if(!allow_zero && take_profit == 0.00) {
      Print("WARN - TP should not be 0.00");
      return(false);
   }
   
   if(!IsValidSL(stop_loss)) {
      PrintFormat("WARN - SL(%.2f) is invalid", stop_loss);
      return(false);
   }
   
   if(!IsValidTP(take_profit)) {
      PrintFormat("WARN - TP(%.2f) is invalid", take_profit);
      return(false);
   }
   
   SetSLTP(stop_loss, take_profit);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsValidSLTP(ulong pType, double pSL, double pTP)
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_LAST);


   if(pType == POSITION_TYPE_BUY) {
      if((pSL >= currentPrice && pSL != 0.00) || (pTP <= currentPrice && pTP != 0.00)) {
         PrintFormat("WARN - SL(%.2f) or TP(%.2f) out of bounds", pSL, pTP);
         return(false);
      }
   }

   if(pType == POSITION_TYPE_SELL) {
      if((pSL <= currentPrice && pSL != 0.00) || (pTP >= currentPrice && pTP != 0.00)) {
         PrintFormat("WARN - SL(%.2f) or TP(%.2f) out of bounds", pSL, pTP);
         return(false);
      }
   }

   //PrintFormat("INFO - OK validity check - SL(%.2f) and/or TP(%.2f).", pSL, pTP);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsValidSL(double stop_loss)
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   
   if(GetType() !=POSITION_TYPE_BUY && GetType() != POSITION_TYPE_SELL) {
      Print("WARN - SL validation - Position not Open");
      return(false);
   }
   
   if(GetType() == POSITION_TYPE_BUY && stop_loss >= current_price && stop_loss != 0.00) {
      PrintFormat("WARN - SL(%.2f) is invalid", stop_loss);
      return(false);
   }
   
   if(GetType() == POSITION_TYPE_SELL && stop_loss <= current_price && stop_loss != 0.00) {
      PrintFormat("WARN - SL(%.2f) is invalid", stop_loss);
      return(false);
   }
   
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsValidTP(double take_profit)
{
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   
   if(GetType() !=POSITION_TYPE_BUY && GetType() != POSITION_TYPE_SELL) {
      Print("WARN - SL validation - Position not Open");
      return(false);
   }
   
   if(GetType() == POSITION_TYPE_BUY && take_profit <= current_price && take_profit != 0.00) {
      PrintFormat("WARN - TP(%.2f) is invalid", take_profit);
      return(false);
   }
   
   if(GetType() == POSITION_TYPE_SELL && take_profit >= current_price && take_profit != 0.00) {
      PrintFormat("WARN - TP(%.2f) is invalid", take_profit);
      return(false);
   }
   
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SetBreakevenSLTP(void)
{
   double lastTick = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   double sl = mInfo.sl, tp = mInfo.tp;

   if(mInfo.type == POSITION_TYPE_BUY && lastTick > mInfo.entry_price && mInfo.sl != mInfo.entry_price)
      sl = mInfo.entry_price;
   else if(mInfo.type == POSITION_TYPE_BUY && lastTick <= mInfo.entry_price && mInfo.tp != mInfo.entry_price)
      tp = mInfo.entry_price;
   else if(mInfo.type == POSITION_TYPE_SELL && lastTick < mInfo.entry_price && mInfo.sl != mInfo.entry_price)
      sl = mInfo.entry_price;
   else if(mInfo.type == POSITION_TYPE_SELL && lastTick >= mInfo.entry_price && mInfo.tp != mInfo.entry_price)
      tp = mInfo.entry_price;
   else {
      return(false);
   }

   return(ModifySLTP(sl, tp));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetBarsDuration(void)
{
   return(mInfo.bars_duration);
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Misc Functions                                                                 |
//+------------------------------------------------------------------+
bool StopLossHit(long pType, double pStopLoss, double pLastDeal)
{
   if(pStopLoss == 0.0) {
      return(false);
   }

   if(pType == POSITION_TYPE_BUY && pLastDeal <= pStopLoss) {
      return(true);
   }

   if(pType == POSITION_TYPE_SELL && pLastDeal >= pStopLoss) {
      return(true);
   }

   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TakeProfitHit(long pType, double pTakeProfit, double pLastDeal)
{
   if(pTakeProfit == 0.0) {
      return(false);
   }

   if(pType == POSITION_TYPE_BUY && pLastDeal >= pTakeProfit) {
      return(true);
   }

   if(pType == POSITION_TYPE_SELL && pLastDeal <= pTakeProfit) {
      return(true);
   }

   return(false);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
