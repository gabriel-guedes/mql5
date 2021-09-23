//+------------------------------------------------------------------+
//|                                                      History.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

class History {
   private:
      ulong m_deal_times[];
      double m_deal_profits[];
      void update_deals(ulong magic);      
   public:
      void History(void);
      void update_deals_of_the_day(ulong magic);
      ulong get_last_deal_time(void);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void History::History(void)
{

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void History::update_deals(ulong magic) {
   int total_deals = HistoryDealsTotal();
   
   int counter = 0;
   for(int i = 0; i < total_deals; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == magic) {
         ArrayResize(m_deal_times, counter+1);
         ArrayResize(m_deal_profits, counter+1);
         m_deal_times[counter] = HistoryDealGetInteger(ticket, DEAL_TIME);
         m_deal_profits[counter] = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         counter++;
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong History::get_last_deal_time(void) {
   int total_deals = ArraySize(m_deal_times);
   
   if(total_deals > 0)
      return(m_deal_times[total_deals - 1]);
   else
      return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void History::update_deals_of_the_day(ulong magic) {
   MqlDateTime now, day_begin, day_end;
   TimeToStruct(TimeCurrent(), now);
   
   day_begin = now;
   day_begin.hour = 0;
   day_begin.min = 0;
   day_begin.sec = 0;
   
   day_end = now;
   day_end.hour = 23;
   day_end.min = 59;
   day_end.sec = 59;
   
   HistorySelect(StructToTime(day_begin), StructToTime(day_end));
   
   update_deals(magic);
}