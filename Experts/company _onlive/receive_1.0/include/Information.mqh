//+------------------------------------------------------------------+
//|                                                  Information.mqh |
//|                                                      David Yisun |
//|                                              david_yisun@163.com |
//+------------------------------------------------------------------+
#property copyright "David Yisun"
#property link      "david_yisun@163.com"
#property strict




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



#include "..\SignalReceive.mq4"
#include "trader.mqh"

int                            handle1=0;                     //句柄1:当前持仓
int                            handle2=0;                     //句柄2:历史持仓     
int                            order_num=0;                   //当前订单数
int                            order_history_num=0;           //历史订单数
//+------------------------------------------------------------------+
//| 读取主账户当前持仓情况                                           |
//+------------------------------------------------------------------+
void  reader_AccountNow(string filename)
  {
   handle1=FileOpen(filename,FILE_CSV|FILE_COMMON|FILE_READ,',');
   if(handle1>0)
     {
      string  r=FileReadString(handle1);
      if(StringFind(r,"#",0)==-1)
        {
         FileClose(handle1);
         return;
        }
      order_num=StrToInteger(StringSetChar(r,StringLen(r)-1,0)); //获取订单数     
      ArrayResize(information,order_num);
      for(int i=0;i<order_num;i++)
        {
         information[i].order_Type=StrToInteger(FileReadString(handle1));
         information[i].order_Symbol=FileReadString(handle1);
         information[i].order_OpenPrice=StrToDouble(FileReadString(handle1));

         information[i].order_TakeProfit=StrToDouble(FileReadString(handle1));
         double reader_tp=MathAbs(information[i].order_OpenPrice-information[i].order_TakeProfit)/SymbolInfoDouble(information[i].order_Symbol,SYMBOL_POINT);
         information[i].order_TPPoints=(reader_tp<0)?0:(reader_tp);

         information[i].order_StopLoss=StrToDouble(FileReadString(handle1));
         double reader_sl=MathAbs(information[i].order_OpenPrice-information[i].order_StopLoss)/SymbolInfoDouble(information[i].order_Symbol,SYMBOL_POINT);
         information[i].order_SLPoints=(reader_tp<0)?0:(reader_tp);

         information[i].order_Lots=StrToDouble(FileReadString(handle1));
         information[i].order_OpenTime=StrToTime(FileReadString(handle1));
         information[i].order_Ticket="Trend("+FileReadString(handle1)+")";

         string re1=FileReadString(handle1);
         string re2 = re1;
         string re3 = "from #";
         if(StringFind(re1,re3,0)==-1)
           {
            information[i].order_Comment="";
           }
         else
           {
            int re_num=StringReplace(re2,re3,"");
            information[i].order_Comment=re2;
           }
        }
      FileClose(handle1);
     }

  }
//+------------------------------------------------------------------+
//| 读取主账户历史持仓情况                                           |
//+------------------------------------------------------------------+
void  reader_AccountHistory(string filename)
  {

   handle2=FileOpen(filename,FILE_CSV|FILE_COMMON|FILE_READ,',');
   if(handle2>0)
     {
      string  r=FileReadString(handle2);
      if(StringFind(r,"#",0)==-1)
        {
         FileClose(handle1);
         return;
        }
      order_history_num=StrToInteger(StringSetChar(r,StringLen(r)-1,0)); //获取历史订单数   
      ArrayResize(info_his,order_history_num);
      for(int i=0;i<order_history_num;i++)
        {
         info_his[i].order_Ticket="Trend("+FileReadString(handle2)+")";
         info_his[i].order_Type=StrToInteger(FileReadString(handle2));
         info_his[i].order_Symbol=FileReadString(handle2);
         info_his[i].order_Lots=StrToDouble(FileReadString(handle2));
         string re1 = FileReadString(handle2);
         string re2 = re1;
         string re3 = "to #";
         if(StringFind(re1,re3,0)==-1)
           {
            info_his[i].order_Comment="";
           }
         else
           {
            int re_num=StringReplace(re2,re3,"");
            info_his[i].order_Ticket="Trend("+re2+")";
           }
        }
      FileClose(handle2);
     }

  }

//+------------------------------------------------------------------+
