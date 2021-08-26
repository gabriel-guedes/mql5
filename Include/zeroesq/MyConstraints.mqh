//+------------------------------------------------------------------+
//|                                                MyConstraints.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

class MyConstraints
{
   private:
      int m_hour_start;
      int m_minute_start;
      int m_hour_stop;
      int m_minute_stop;
   public:
      void MyConstraints();
      void SetDayTradeTime(int hour_start = 0, int minute_start = 0, int hour_stop = 0, int minute_stop = 0);
      bool DayTradeTimeCheck(datetime current_time);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyConstraints::MyConstraints(void)
{
   m_hour_start = 0;
   m_minute_start = 0;
   m_hour_stop = 0;
   m_minute_stop = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyConstraints::SetDayTradeTime(int hour_start = 0, int minute_start = 0, int hour_stop = 0, int minute_stop = 0)
{
   m_hour_start = hour_start;
   m_minute_start = minute_start;
   m_hour_stop = hour_stop;
   m_minute_stop = minute_stop;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyConstraints::DayTradeTimeCheck(datetime current_time)
{
   
   MqlDateTime day;
   TimeToStruct(current_time, day);
   
   if(m_hour_start != 0) {
      if(day.hour < m_hour_start) return(false);
      else if(day.hour == m_hour_start && day.min < m_minute_start) return(false);
   }
   
   if(m_hour_stop != 0) {
      if(day.hour > m_hour_stop) return(false);
      else if(day.hour == m_hour_stop && day.min >= m_minute_stop) return(false);
   }
   
   
   return(true);
}