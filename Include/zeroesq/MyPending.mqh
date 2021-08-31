//+------------------------------------------------------------------+
//|                                                    MyPending.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

class CMyPending
{
  private:
    void OrderCount(string pSymbol);
    int BuyLimitCount, SellLimitCount, BuyStopCount, SellStopCount, BuyStopLimitCount, SellStopLimitCount, TotalPendingCount;
    ulong PendingTickets[];
  
  public:
        CMyPending(void);
    int BuyLimit(string pSymbol); 
    int SellLimit(string pSymbol); 
    int BuyStop(string pSymbol); 
    int SellStop(string pSymbol); 
    int BuyStopLimit(string pSymbol); 
    int SellStopLimit(string pSymbol);
    int TotalPending(string pSymbol);
    void GetTickets(string pSymbol, ulong &pTickets[]);
    bool GetAllByMagic(ulong pMagic, ulong &tickets[]);    
    bool CancelAllByMagic(ulong pMagic);
    bool IsPending(ulong pTicket);
    bool DeleteOrder(ulong pTicket, ulong pMagic);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMyPending::CMyPending()
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPending::OrderCount(string pSymbol)
{
  BuyLimitCount = 0; 
  SellLimitCount = 0; 
  BuyStopCount = 0; 
  SellStopCount = 0; 
  BuyStopLimitCount = 0; 
  SellStopLimitCount = 0; 
  TotalPendingCount = 0; 
  ArrayFree(PendingTickets);
  
  for(int i = 0; i < OrdersTotal(); i++)
  {
    ulong ticket = OrderGetTicket(i);
    if(OrderGetString(ORDER_SYMBOL) == pSymbol)
    {
      long type = OrderGetInteger(ORDER_TYPE);
      switch(int(type))
      {
        case ORDER_TYPE_BUY_STOP: 
        BuyStopCount++; break;

        case ORDER_TYPE_SELL_STOP: 
        SellStopCount++; break;
        
        case ORDER_TYPE_BUY_LIMIT: 
        BuyLimitCount++; break;

        case ORDER_TYPE_SELL_LIMIT: 
        SellLimitCount++; break;

        case ORDER_TYPE_BUY_STOP_LIMIT: 
        BuyStopLimitCount++; break;
        
        case ORDER_TYPE_SELL_STOP_LIMIT:
        SellStopLimitCount++; break;
      }
      TotalPendingCount++;
      ArrayResize(PendingTickets,TotalPendingCount);
      PendingTickets[ArraySize(PendingTickets)-1] = ticket;
    }
  }
}
//+------------------------------------------------------------------+
//|  Set Pending by Magic                                            |
//+------------------------------------------------------------------+
bool CMyPending::GetAllByMagic(ulong pMagic, ulong &tickets[])
{
   bool orderFound = false;
   
   int total_pending = 0;
   
   for(int i = 0; i < OrdersTotal(); i++) {
      ulong ticket = OrderGetTicket(i);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if( magic == pMagic && IsPending(ticket))
      {
         total_pending++;
         ArrayResize(tickets, total_pending);
         tickets[total_pending - 1] = ticket;
         orderFound = true;
      }
   }
   
   return(orderFound);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPending::CancelAllByMagic(ulong pMagic)
{
   bool ordersCanceled = true;
   ulong tickets[];
   
   GetAllByMagic(pMagic, tickets);
   
   for(int i = 0; i < ArraySize(tickets); i++)
   {
      ordersCanceled = DeleteOrder(tickets[i], pMagic);
      if(!ordersCanceled) break;
   }
   
   
   return(ordersCanceled);
}
//+------------------------------------------------------------------+
//| IsPending - Check if order type is pending order                 |
//+------------------------------------------------------------------+
bool CMyPending::IsPending(ulong pTicket)
{
   bool orderIsPending = false;
   
   long orderType = OrderGetInteger(ORDER_TYPE);
   
   if(orderType == ORDER_TYPE_BUY_LIMIT ||
   orderType == ORDER_TYPE_SELL_LIMIT ||
   orderType == ORDER_TYPE_BUY_STOP ||
   orderType == ORDER_TYPE_SELL_STOP ||
   orderType == ORDER_TYPE_BUY_STOP_LIMIT ||
   orderType == ORDER_TYPE_SELL_STOP_LIMIT)
   {
      orderIsPending = true;
   }
   
   return(orderIsPending);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPending::DeleteOrder(ulong pTicket, ulong pMagic)
{
   MqlTradeRequest   request;
   MqlTradeResult    result;
   ZeroMemory(request);
   ZeroMemory(result);   

   request.action    =TRADE_ACTION_REMOVE;
   request.magic     =pMagic;
   request.order     =pTicket;

   return(OrderSend(request, result));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::BuyLimit(string pSymbol) 
{ 
  OrderCount(pSymbol); 
  return(BuyLimitCount); 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::SellLimit(string pSymbol) 
{ 
  OrderCount(pSymbol); 
  return(SellLimitCount); 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::BuyStop(string pSymbol) 
{ 
  OrderCount(pSymbol); 
  return(BuyStopCount); 
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::SellStop(string pSymbol) 
{ 
  OrderCount(pSymbol); 
  return(SellStopCount); 
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::BuyStopLimit(string pSymbol) 
{ 
  OrderCount(pSymbol); 
  return(BuyStopLimitCount); 
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::SellStopLimit(string pSymbol) 
{ 
  OrderCount(pSymbol); 
  return(SellStopLimitCount); 
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMyPending::TotalPending(string pSymbol)
{
	OrderCount(pSymbol);
	return(TotalPendingCount);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPending::GetTickets(string pSymbol,ulong &pTickets[])
{
  OrderCount(pSymbol);
  ArrayCopy(pTickets,PendingTickets);
  return;
}

//------------------------------------
//Misc Functions
//------------------------------------

//OrderType
long OrderType(ulong pTicket)
{
  bool select = OrderSelect(pTicket);
  if(select == true) return(OrderGetInteger(ORDER_TYPE));
  else return(WRONG_VALUE);
}

//OrderVolume
double OrderVolume(ulong pTicket)
{
  bool select = OrderSelect(pTicket);
  if(select == true) return(OrderGetDouble(ORDER_VOLUME_CURRENT));
  else return(WRONG_VALUE);
}

//OrderComment
string OrderComment(ulong pTicket)
{
  bool select = OrderSelect(pTicket);
  if(select == true) return(OrderGetString(ORDER_COMMENT));
  else return(NULL);
}