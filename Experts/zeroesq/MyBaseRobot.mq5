//+------------------------------------------------------------------+
//|                                                  MyBaseRobot.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <Gabriel\MyDashboard.mqh>
#include <Gabriel\Mykeypad.mqh>
#include <Gabriel\MyTradeNew.mqh>
#include <Gabriel\MyPositionInfo.mqh>
#include <Gabriel\MyPriceBars.mqh>
#include <Gabriel\MyThresholds.mqh>
#include <Gabriel\MyBrainMR.mqh>

input ulong    inpMagic;
input ulong    inpDeviation=4;
input int      inpTradeVolume=1;
input double   inpMaxLoss=0;
input double   inpMaxProfit=0;
input uint     inpFirstTradableBar=0;
input uint     inpLastTradableBar=0;
input uint     inpHourFrom=0;
input uint     inpMinFrom=0;
input uint     inpHourTo=0;
input uint     inpMinTo=0;
input uint     inpForceCloseHour=17;
input uint     inpForceCloseMin=30;

//CMyKeypad            keypad;
CMyDashboard         dashboard;
CMyPositionInfo      position;
CMyTrade             trade;
CMyBars              pricebar;
CMyThresholds        thresholds;
CMyBrain             brain;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(86400);
   
   trade.Init(inpMagic,inpDeviation,ORDER_FILLING_IOC);
   
   dashboard.Init();
   
   //keypad.Init();
   
   thresholds.SetMaxLossProfit(inpMaxLoss,inpMaxProfit);
   thresholds.SetBarsRange(inpFirstTradableBar,inpLastTradableBar);
   thresholds.SetTradingHours(inpHourFrom,inpMinFrom,inpHourTo,inpMinTo);
   thresholds.SetForceCloseTime(inpForceCloseHour,inpForceCloseMin);
   
   brain.Init(_Symbol,_Period,5,2,PRICE_CLOSE);
   
   ChartRedraw();
   
   MathSrand(GetTickCount());
   
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//      pricebar.Update(_Symbol,PERIOD_CURRENT);
//      
//      if(pricebar.IsNewBar(_Symbol,PERIOD_CURRENT))
//      {
//         //Update time-stop
//      }

      if(position.SelectPositionByMagic(_Symbol,inpMagic))
      {
         position.CalcEAOpenProfit(_Symbol,inpMagic);
         
         dashboard.UpdateOpenedAmount(position.GetEAOpenProfit());
         
         double profit=position.GetEATotalProfit();
         
         if(thresholds.CheckToClosePosition(profit)) 
            trade.Close(_Symbol);
            
         //Close partial
         //Modify SL/TP            

      }
      else
      {         
         dashboard.UpdateOpenedAmount(0);
         
         int barNumber=pricebar.GetDayBarCount(_Symbol,PERIOD_CURRENT);
         
         if(!thresholds.CheckToOpenPosition(barNumber))
            return;
         
         
         int action = brain.Run();
         
         if(action==BRAIN_BUY)
            {
             trade.BuyMarket(_Symbol,inpTradeVolume);
            }
         
//         double lAsk=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
//         double lBid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
//         
//         double lRandom=MathRand()%2;
//         double lSLTP=40;         
//         
//         if(lRandom==0) trade.BuyMarket(_Symbol,inpTradeVolume,lAsk-lSLTP,lAsk+lSLTP);
//         if(lRandom==1) trade.SellMarket(_Symbol,inpTradeVolume,lBid+lSLTP,lBid-lSLTP);
         
         //if(lRandom==0) trade.BuyMarket(_Symbol,inpTradeVolume);
         //if(lRandom==1) trade.SellMarket(_Symbol,inpTradeVolume);
      }
  
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
      thresholds.Reset();
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD)
      
      position.CalcEADayProfit(_Symbol,inpMagic);
      
      dashboard.UpdateClosedAmount(position.GetEADayProfit());
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+