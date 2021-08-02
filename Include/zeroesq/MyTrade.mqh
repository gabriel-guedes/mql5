//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#include <zeroesq\errordescription.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyTrade
{
private:
   ENUM_ORDER_TYPE_FILLING mFillType;
   ulong             mDeviation;
   bool              OpenPosition(ENUM_ORDER_TYPE pType, ulong pMagic, double pVolume, double pStop = 0.00000, double pProfit = 0.00000, string pComment = NULL);
   bool              OpenPending(ENUM_ORDER_TYPE pType, ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, double pStoplimit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              SendAndCheckOrder(MqlTradeRequest &pRequest);
   bool              SelectPositionByMagic(ulong pMagic);
   string            GetOrderTypeDescription(ENUM_ORDER_TYPE pType);
   string            GetActionTypeDescription(ENUM_TRADE_REQUEST_ACTIONS pAction);
   int               CheckRetcode(uint pRetcode);

public:
                     CMyTrade(void);
   void              SetDeviation(ulong pDeviation);
   void              SetFillType(ENUM_ORDER_TYPE_FILLING pFilltype);
   ulong             GetMagic();
   bool              BuyMarket(ulong pMagic, double pVolume, double pStop = 0, double pProfit = 0, string pComment = NULL);
   bool              SellMarket(ulong pMagic, double pVolume, double pStop = 0, double pProfit = 0, string pComment = NULL);
   bool              BuyStop(ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              SellStop(ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              BuyLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              SellLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              BuyStopLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              SellStopLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool              Close( ulong pMagic, double pVolume = 0, string pComment = NULL);
   bool              Reverse(long pOpenPositionType, long pMagic, double pVolume, string pComment = NULL);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMyTrade::CMyTrade(void)
{
   mDeviation = 50;
   mFillType = ORDER_FILLING_IOC;
}
//+------------------------------------------------------------------+
//| Set Deviation                                                    |
//+------------------------------------------------------------------+
void CMyTrade::SetDeviation(ulong pDeviation)
{
   mDeviation = pDeviation;
}
//+------------------------------------------------------------------+
//| Set FillType                                                     |
//+------------------------------------------------------------------+
void CMyTrade::SetFillType(ENUM_ORDER_TYPE_FILLING pFilltype)
{
   mFillType = pFilltype;
}
//+------------------------------------------------------------------+
//| Open Position                                                    |
//+------------------------------------------------------------------+
bool CMyTrade::OpenPosition(ENUM_ORDER_TYPE pType, ulong pMagic, double pVolume, double pStop = 0.000000, double pProfit = 0.000000, string pComment = NULL)
{
   MqlTradeRequest request = {};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.type = pType;
   request.volume = pVolume;
   request.sl = NormalizeDouble(pStop, _Digits);
   request.tp = NormalizeDouble(pProfit, _Digits);
   request.deviation = mDeviation;
   request.type_filling = mFillType;
   request.comment = pComment;
   request.magic = pMagic;

   if(pType == ORDER_TYPE_BUY)
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   else if(pType == ORDER_TYPE_SELL)
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   bool sendResult = SendAndCheckOrder(request);

   return(sendResult);
}
//+------------------------------------------------------------------+
//| Open Pending                                                     |
//+------------------------------------------------------------------+
bool CMyTrade::OpenPending(ENUM_ORDER_TYPE pType, ulong pMagic, double pVolume, double pPrice, double pStop = 0, double pProfit = 0,
                           double pStoplimit = 0, datetime pExpiration = 0, string pComment = NULL)
{
   MqlTradeRequest request = {};

   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.type = pType;
   request.sl = NormalizeDouble(pStop, _Digits);
   request.tp = NormalizeDouble(pProfit, _Digits);
   request.comment = pComment;
   request.volume = pVolume;
   request.price = pPrice;
   request.stoplimit = pStoplimit;
   request.magic = pMagic;

   if(pExpiration > 0) {
      request.expiration = pExpiration;
      request.type_time = ORDER_TIME_SPECIFIED;
   } else request.type_time = ORDER_TIME_DAY;

   bool sendResult = SendAndCheckOrder(request);

   return(sendResult);
}
//+------------------------------------------------------------------+
//| Send and Check Order                                             |
//+------------------------------------------------------------------+
bool CMyTrade::SendAndCheckOrder(MqlTradeRequest &pRequest)
{
   MqlTradeResult result = {};

   bool sendReturn = OrderSend(pRequest, result);

   int checkCode = CheckRetcode(result.retcode);
   string retCodeDescr = TradeServerReturnCodeDescription(result.retcode);
   string orderTypeDescr = GetOrderTypeDescription(pRequest.type);
   string tradeActionDescr = GetActionTypeDescription(pRequest.action);


   if(checkCode == CHECK_RETCODE_OK) {
      Print(tradeActionDescr, " ", orderTypeDescr, " order #", result.deal, ": ", result.retcode, " - ", retCodeDescr, ", Volume: ", result.volume, ", Price: ", result.price, ", Bid: ", result.bid, ", Ask: ", result.ask);
      return(true);
   }

   else if(checkCode == CHECK_RETCODE_ERROR) {
      Alert(tradeActionDescr, " ", orderTypeDescr, ": Error ", result.retcode, " - ", retCodeDescr);
   }

   else {
      Print("Server error detected, maybe you should retry...");
   }

   return(false);
}
//+------------------------------------------------------------------+
//| Buy Market                                                       |
//+------------------------------------------------------------------+
bool CMyTrade::BuyMarket(ulong pMagic, double pVolume, double pStop = 0.000000, double pProfit = 0.000000, string pComment = NULL)
{
   bool success = OpenPosition(ORDER_TYPE_BUY, pMagic, pVolume, pStop, pProfit, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Sell Market                                                      |
//+------------------------------------------------------------------+
bool CMyTrade::SellMarket(ulong pMagic, double pVolume, double pStop = 0.000000, double pProfit = 0.000000, string pComment = NULL)
{
   bool success = OpenPosition(ORDER_TYPE_SELL, pMagic, pVolume, pStop, pProfit, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Buy Stop                                                         |
//+------------------------------------------------------------------+
bool CMyTrade::BuyStop(ulong pMagic, double pVolume, double pPrice, double pStop = 0.000000, double pProfit = 0.000000, datetime pExpiration = 0, string pComment = NULL)
{
   bool success = OpenPending(ORDER_TYPE_BUY_STOP, pMagic, pVolume, pPrice, pStop, pProfit, 0.00, pExpiration, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Sell Stop                                                        |
//+------------------------------------------------------------------+
bool CMyTrade::SellStop(ulong pMagic, double pVolume, double pPrice, double pStop = 0.000000, double pProfit = 0.000000, datetime pExpiration = 0, string pComment = NULL)
{
   bool success = OpenPending(ORDER_TYPE_SELL_STOP, pMagic, pVolume, pPrice, pStop, pProfit, 0.00, pExpiration, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Buy Limit                                                        |
//+------------------------------------------------------------------+
bool CMyTrade::BuyLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0.000000, double pProfit = 0.000000, datetime pExpiration = 0, string pComment = NULL)
{
   bool success = OpenPending(ORDER_TYPE_BUY_LIMIT, pMagic, pVolume, pPrice, pStop, pProfit, 0.00, pExpiration, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Sell Limit                                                       |
//+------------------------------------------------------------------+
bool CMyTrade::SellLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0.000000, double pProfit = 0.000000, datetime pExpiration = 0, string pComment = NULL)
{
   bool success = OpenPending(ORDER_TYPE_SELL_LIMIT, pMagic, pVolume, pPrice, pStop, pProfit, 0.00, pExpiration, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Buy Stop Limit                                                   |
//+------------------------------------------------------------------+
bool CMyTrade::BuyStopLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0.000000, double pProfit = 0.000000, datetime pExpiration = 0, string pComment = NULL)
{
   bool success = OpenPending(ORDER_TYPE_BUY_STOP_LIMIT, pMagic, pVolume, pPrice, pStop, pProfit, pPrice, pExpiration, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Sell Stop Limit                                                  |
//+------------------------------------------------------------------+
bool CMyTrade::SellStopLimit(ulong pMagic, double pVolume, double pPrice, double pStop = 0.000000, double pProfit = 0.000000, datetime pExpiration = 0, string pComment = NULL)
{
   bool success = OpenPending(ORDER_TYPE_SELL_STOP_LIMIT, pMagic, pVolume, pPrice, pStop, pProfit, pPrice, pExpiration, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Close Position                                                   |
//+------------------------------------------------------------------+
bool CMyTrade::Close(ulong pMagic, double pVolume = 0.000000, string pComment = NULL)
{
   MqlTradeRequest request = {};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.comment = pComment;
   request.magic = pMagic;

   if(!SelectPositionByMagic(pMagic)) return(false);

   request.position = PositionGetInteger(POSITION_TICKET);

   double openLots = PositionGetDouble(POSITION_VOLUME);
   if(pVolume > openLots || pVolume <= 0) request.volume = openLots;
   else request.volume = pVolume;

   long openType = PositionGetInteger(POSITION_TYPE);
   if(openType == POSITION_TYPE_BUY) {
      request.type = ORDER_TYPE_SELL;
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   if(openType == POSITION_TYPE_SELL) {
      request.type = ORDER_TYPE_BUY;
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   }


   bool sendResult = SendAndCheckOrder(request);

   return(sendResult);
}
//+------------------------------------------------------------------+
//| Reverse Position                                                   |
//+------------------------------------------------------------------+
bool CMyTrade::Reverse(long pOpenPositionType, long pMagic, double pVolume, string pComment)
{
   Close(pMagic);
   if(pOpenPositionType == POSITION_TYPE_SELL)
      return(BuyMarket(pMagic, pVolume, 0, 0, pComment));
   else if(pOpenPositionType == POSITION_TYPE_BUY)
      return(SellMarket(pMagic, pVolume, 0, 0, pComment));
   else
      return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyTrade::SelectPositionByMagic(ulong pMagic)
{
   bool res = false;
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string positionSymbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(magic == pMagic && positionSymbol == _Symbol) {
         res = true;
         break;
      }
   }
   return(res);
}
//+------------------------------------------------------------------+
//| Get order type description                                       |
//+------------------------------------------------------------------+
string CMyTrade::GetOrderTypeDescription(ENUM_ORDER_TYPE pType)
{
   string orderType;
   if(pType == ORDER_TYPE_BUY) orderType = "buy market";
   else if(pType == ORDER_TYPE_SELL) orderType = "sell market";
   else if(pType == ORDER_TYPE_BUY_STOP) orderType = "buy stop";
   else if(pType == ORDER_TYPE_BUY_LIMIT) orderType = "buy limit";
   else if(pType == ORDER_TYPE_SELL_STOP) orderType = "sell stop";
   else if(pType == ORDER_TYPE_SELL_LIMIT) orderType = "sell limit";
   else if(pType == ORDER_TYPE_BUY_STOP_LIMIT) orderType = "buy stop limit";
   else if(pType == ORDER_TYPE_SELL_STOP_LIMIT) orderType = "sell stop limit";
   else orderType = "invalid order type";
   return(orderType);
}
//+------------------------------------------------------------------+
//| Check action type                                                |
//+------------------------------------------------------------------+
string CMyTrade::GetActionTypeDescription(ENUM_TRADE_REQUEST_ACTIONS pAction)
{
   string tradeAction;
   if(pAction == TRADE_ACTION_DEAL) tradeAction = "Open";
   else if(pAction == TRADE_ACTION_PENDING) tradeAction = "Place";
   else if(pAction == TRADE_ACTION_SLTP) tradeAction = "SL/TP Modify";
   else if(pAction == TRADE_ACTION_SLTP) tradeAction = "Modify";
   else if(pAction == TRADE_ACTION_REMOVE) tradeAction = "Remove";
   else if(pAction == TRADE_ACTION_CLOSE_BY) tradeAction = "Close By";
   else tradeAction = "invalid action type";
   return(tradeAction);
}
//+------------------------------------------------------------------+
//| CheckRetcode                                                     |
//+------------------------------------------------------------------+
int CMyTrade::CheckRetcode(uint pRetcode)
{
   int status;

   switch(pRetcode) {
   case TRADE_RETCODE_REQUOTE:
   case TRADE_RETCODE_CONNECTION:
   case TRADE_RETCODE_PRICE_CHANGED:
   case TRADE_RETCODE_TIMEOUT:
   case TRADE_RETCODE_PRICE_OFF:
   case TRADE_RETCODE_REJECT:
   case TRADE_RETCODE_ERROR:
      status = CHECK_RETCODE_RETRY;
      break;
   case TRADE_RETCODE_DONE:
   case TRADE_RETCODE_DONE_PARTIAL:
   case TRADE_RETCODE_PLACED:
   case TRADE_RETCODE_NO_CHANGES:
      status = CHECK_RETCODE_OK;
      break;
   default:
      status = CHECK_RETCODE_ERROR;
   }

   return(status);
}
////+------------------------------------------------------------------+
////| Miscellaneous Functions & Enumerations                           |
////+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ENUM_CHECK_RETCODE                                               |
//+------------------------------------------------------------------+
enum ENUM_CHECK_RETCODE
{
   CHECK_RETCODE_OK,
   CHECK_RETCODE_ERROR,
   CHECK_RETCODE_RETRY,
};
//+------------------------------------------------------------------+
