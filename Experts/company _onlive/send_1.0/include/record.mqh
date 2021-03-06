//+------------------------------------------------------------------+
//|                                                       record.mqh |
//|                                                      David Yisun |
//|                                              David_yisun@163.com |
//+------------------------------------------------------------------+
#property copyright "David Yisun"
#property link      "David_yisun@163.com"
#property strict

#include "..\SignalSend.mq4"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| 主账户当前持仓信息记录                                           |
//+------------------------------------------------------------------+
void Recorder_AccountNow(string filename)
  {
   handle1=FileOpen(filename,FILE_CSV|FILE_COMMON|FILE_WRITE,',');
   if(handle1>0)
     {
      FileWrite(handle1,IntegerToString(OrdersTotal())+"#");
      for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
            FileWrite(handle1,OrderType(),OrderSymbol(),OrderOpenPrice(),
                      OrderTakeProfit(),OrderStopLoss(),OrderLots(),OrderOpenTime(),OrderTicket(),OrderComment());
        }
      FileClose(handle1);     
     }

  }
//+------------------------------------------------------------------+
//| 主账户历史持仓信息记录                                           |
//+------------------------------------------------------------------+  
void Recorder_AccountHistory(string filename,int num)
  {
   handle2=FileOpen(filename,FILE_CSV|FILE_COMMON|FILE_WRITE,',');
   if(handle2>0)
     {          
      int n = MathMin(OrdersHistoryTotal(),num);
      FileWrite(handle2,IntegerToString(n-1)+"#");
      //Alert("here");
      for(int i=OrdersHistoryTotal()-1;i>OrdersHistoryTotal()-n;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)
            FileWrite(handle2,OrderTicket(),OrderType(),OrderSymbol(),OrderLots(),OrderComment());
        }
      FileClose(handle2);
     }
  }


//+------------------------------------------------------------------+
