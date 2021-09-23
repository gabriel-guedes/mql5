//+------------------------------------------------------------------+
//|                                                     Position.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

class Position {
   private:
      ulong m_magic, m_ticket, m_bars_duration;
      datetime m_time;
      ENUM_POSITION_TYPE m_type;
      double m_volume, m_entry_price, m_stop_loss, m_take_profit, m_open_profit, m_max_profit;
      void reset(void);
 
   public:
      void Position(ulong magic);
      void update(void);
      void update_profit(void);
      bool is_flat(void);
      double get_open_profit(void);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Position::Position(ulong magic) {
   m_magic = magic;
   reset();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Position::reset(void) {
      m_type = WRONG_VALUE;
      m_ticket = WRONG_VALUE;
      m_bars_duration = 0;
      m_time = 0;
      m_volume = 0.00;
      m_entry_price = 0.00;
      m_stop_loss = 0.00;
      m_take_profit = 0.00;
      m_open_profit = 0.00;
      m_max_profit = 0.00;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Position::update(void) {
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      long type = PositionGetInteger(POSITION_TYPE);
      if(magic ==  m_magic && symbol == _Symbol) {
         m_type = ENUM_POSITION_TYPE(type);
         m_ticket = PositionGetTicket(i);
         m_volume = PositionGetDouble(POSITION_VOLUME);
         m_time = int(PositionGetInteger(POSITION_TIME));
         m_entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
         return;
       }
    }
    
    reset();   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Position::is_flat(void) {
   return(m_type != POSITION_TYPE_BUY && m_type != POSITION_TYPE_SELL);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Position::update_profit(void) {
   if(!PositionSelectByTicket(m_ticket)) return;
   
   m_open_profit = PositionGetDouble(POSITION_PROFIT);
   if(m_open_profit > m_max_profit) m_max_profit = m_open_profit;
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Position::get_open_profit(void) {
   return(m_open_profit);
}
