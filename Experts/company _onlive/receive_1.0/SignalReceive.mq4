//+------------------------------------------------------------------+
//|                                                SignalReceive.mq4 |
//|                                                      David Yisun |
//|                                              david_yisun@163.com |
//+------------------------------------------------------------------+
#property copyright "David Yisun"
#property link      "david_yisun@163.com"
#property version   "1.00"
#property strict
#property description "跟单系统接受端原始版本"

//---ea编号
input  int                         MAGICNUM=407610636;
//---连接外部库
//---连接内部库
#include "Include/Information.mqh"
#include "Include/trader.mqh"
#include "Include/Windows.mqh"
//---调试参数
int li=1;
int step = 0;
bool test=false;
//---接受信号参数
input string                       account_name="";                  //追踪账户
string                             FileName_AccountNow;              //当前持仓
string                             FileName_AccountHistory;          //历史持仓 
int Slippage=100;
input bool                         FollowExcute=true;                //是否执行跟单
//---本地参数
input double                       LotsRatio=1;                      //投资比例
input bool                         Reverse=false;                    //是否反向下单   

input int                          PriceDeviation = 5;               //价格偏差(点)
input int                          TimeDeviation = 10;               //时间偏差(秒)

input bool                         IsTrack_TP_and_SL=true;           //是否追踪止盈

input bool                         IsLimit_Sym = false;              //是否限制品种
input string                       Limit_Sym1 = "";                  //需要限制的品种1 
input string                       Limit_Sym2 = "";                  //需要限制的品种2

input bool                         IsLimit_TypeLim = false;          //是否限制正向挂单limit
input bool                         IsLimit_TypeStop = false;         //是否限制反向挂单stop

input bool                         IsTrack_Close=true;               //是否跟踪平仓

input bool                         IsForceOpen=false;                //是否强制跟单
input bool                         IsPrintError=true;                //是否打印报错信息                             
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ReadNow
  {
   ENUM_ORDER_TYPE   order_Type;        //订单类型
   string            order_Symbol;      //品种
   double            order_OpenPrice;   //开仓价格
   double            order_TakeProfit;  //止盈
   double            order_TPPoints;    //止盈点数  
   double            order_StopLoss;    //止损
   double            order_SLPoints;    //止损点数
   datetime          order_OpenTime;    //开仓时间
   double            order_Lots;        //下单量
   string            order_Ticket;      //订单编号
   string            order_Comment;     //订单注释
  };
ReadNow                               information[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ReadHistory
  {
   ENUM_ORDER_TYPE   order_Type;        //订单类型
   string            order_Symbol;      //品种
   double            order_Lots;        //下单量
   string            order_Ticket;      //订单编号
   string            order_Comment;     //订单注释
  };
ReadHistory                            info_his[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Follow
  {
   ENUM_ORDER_TYPE   order_Type;        //订单类型
   string            order_Symbol;      //品种
   double            order_OpenPrice;   //开仓价格
   double            order_TakeProfit;  //止盈
   double            order_TPPoints;    //止盈点数  
   double            order_StopLoss;    //止损
   double            order_SLPoints;    //止损点数
   datetime          order_OpenTime;    //开仓时间
   double            order_Lots;        //下单量
   string            order_Ticket;      //订单编号
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(100);
   handle1=0;
   handle2=0;
   order_num=0;
   order_history_num=0;

//---
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(step>li) return;
   if(!FollowExcute) return;
//---设置跟单账号
   FileName_AccountNow=account_name+"AccountNow.csv";
   FileName_AccountHistory=account_name+"AccountHistory.csv";
//---读取跟单信息
   reader_AccountNow(FileName_AccountNow);
   reader_AccountHistory(FileName_AccountHistory);
//Alert(info_his[9].order_Comment);
//Alert(information[0].order_OpenPrice);
//Alert(EnumToString(information[0].order_Type));
//int test=0;
//Alert("tp:",information[test].order_TPPoints);
//Alert("sl:",information[test].order_SLPoints);
//datetime m = information[test].order_OpenTime;
//Alert(m<(TimeCurrent()-10000000));


//---获取当前账户订单情况
   int  num=OrdersTotal();

//---循环一:检测主账户是否在跟单账户中存在，开仓和改单
   for(int i=0;i<order_num;i++)
     {
      bool exit= false;
      for(int j=0;j<num;j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) continue;
         if(OrderMagicNumber()==MAGICNUM)
           {
            if(OrderComment()==information[i].order_Ticket)
              {

               exit=true;
               Follow  follow; //申请当前跟单信息结构体
               //---获取订单类型
               follow.order_Type=information[i].order_Type;

               //---检查止盈止损                          
               if(IsTrack_TP_and_SL==true)
                 {
                  Rev_TpAndSl(
                              information[i].order_TakeProfit,
                              information[i].order_StopLoss,
                              follow.order_TakeProfit,
                              follow.order_StopLoss,
                              Reverse
                              );
                 }
               else
                 {
                  follow.order_TakeProfit=OrderTakeProfit();
                  follow.order_StopLoss=OrderStopLoss();
                 }
               //---获取开仓价
               if(information[i].order_Type<=1) //如果是已成单
                 {
                  follow.order_OpenPrice=OrderOpenPrice();
                 }                                                                       //如果是挂单
               else follow.order_OpenPrice=information[i].order_OpenPrice;

               //---检查是否修改订单
               Check_Modify(
                            follow.order_Type,
                            follow.order_OpenPrice,
                            follow.order_TakeProfit,
                            follow.order_StopLoss
                            );
              }
           }
        }
      if(exit==false) //如果该单在当前账户中不存在
        {
         if(!IsForceOpen) //判断是否强制跟单      
           {
            //---严格检查该单的条件
            if(!Check_Time(information[i].order_OpenTime,TimeDeviation) && information[i].order_Comment=="") continue;   //检查时间有效性
            if(!Check_OrderType(information[i].order_Type,IsLimit_TypeLim,IsLimit_TypeStop)) continue;  //检查有效下单类型
            if(!Check_Price(information[i].order_Type,information[i].order_Symbol,information[i].order_OpenPrice,PriceDeviation) && information[i].order_Comment=="") continue;  //检查价格偏离程度            
            if(!Check_Symbol(information[i].order_Symbol)) continue;    //检查有效下单品种
            if(Check_Opened(information[i].order_Ticket)) continue;     //检查是否开过仓
           }
         //---记录开单信息
         Follow   follow;
         //---确定手数
         follow.order_Lots=information[i].order_Lots*LotsRatio;
         //---记录跟单
         follow.order_Ticket=information[i].order_Ticket;
         //---确定下单品种、方向
         Rev_OrderType(information[i].order_Symbol,
                       information[i].order_Type,
                       information[i].order_OpenPrice,
                       follow.order_Symbol,
                       follow.order_Type,
                       follow.order_OpenPrice,
                       Reverse);

         //---确定止盈止损                          
         if(IsTrack_TP_and_SL==true)
           {
            Rev_TpAndSl(
                        information[i].order_TakeProfit,
                        information[i].order_StopLoss,
                        follow.order_TakeProfit,
                        follow.order_StopLoss,
                        Reverse
                        );
           }
         else
           {
            follow.order_TakeProfit=0;
            follow.order_StopLoss=0;
           }
         //---下单
         int res=-1;
         //Alert(follow.order_Type);  
/*          
           res = OrderSend(follow.order_Symbol,
                           follow.order_Type,
                           follow.order_Lots,
                           MarketInfo(follow.order_Symbol,MODE_BID),
                           300,
                           follow.order_StopLoss,
                           follow.order_TakeProfit,
                           follow.order_Ticket,
                           MAGICNUM,0,clrGreen);*/
         //Alert(follow.order_OpenPrice);
         res=SendOrder(follow.order_Symbol,
                       follow.order_Type,
                       follow.order_Lots,
                       follow.order_OpenPrice,
                       PriceDeviation,
                       follow.order_StopLoss,
                       follow.order_TakeProfit,
                       follow.order_Ticket,
                       MAGICNUM);

         if(res<0) Print("Fail send order!");
        }
     }

/*
         double ASK=MarketInfo(follow.order_Symbol,MODE_ASK);
         double BID=MarketInfo(follow.order_Symbol,MODE_BID);
         if(Reverse)
           {
            if(information[i].order_Type==OP_BUY)
              {
               OrderSend(information[i].order_Symbol,OP_SELL,LotsRatio*information[i].order_Lots,
                         BID,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
              }
            if(information[i].order_Type==OP_SELL)
               OrderSend(information[i].order_Symbol,OP_BUY,LotsRatio*information[i].order_Lots,
                         ASK,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
            if(information[i].order_Type==OP_BUYLIMIT)
               OrderSend(information[i].order_Symbol,OP_SELLLIMIT,LotsRatio*information[i].order_Lots,
                         BID,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
            if(information[i].order_Type==OP_SELLLIMIT)
               OrderSend(information[i].order_Symbol,OP_BUYLIMIT,LotsRatio*information[i].order_Lots,
                         ASK,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
            if(information[i].order_Type==OP_BUYSTOP)
               OrderSend(information[i].order_Symbol,OP_SELLSTOP,LotsRatio*information[i].order_Lots,
                         BID,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
            if(information[i].order_Type==OP_SELLSTOP)
               OrderSend(information[i].order_Symbol,OP_BUYSTOP,LotsRatio*information[i].order_Lots,
                         ASK,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
           }
         else
           {

            if(information[i].order_Type==OP_BUY || information[i].order_Type==OP_BUYLIMIT || information[i].order_Type==OP_BUYSTOP)
              {
               OrderSend(information[i].order_Symbol,information[i].order_Type,LotsRatio*information[i].order_Lots,
                         ASK,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
              }
            else
              {
               OrderSend(information[i].order_Symbol,information[i].order_Type,LotsRatio*information[i].order_Lots,
                         BID,Slippage,information[i].order_StopLoss,
                         information[i].order_TakeProfit,information[i].order_Ticket,
                         MAGICNUM,0,clrGreen);
              }

           }
         */

//---循环二:检测主账户中不存在，跟单账户中存在的单子，平仓
   if(IsTrack_Close==false) return;    //检查是否跟踪平仓
   for(int j=0;j<num;j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) return;
      if(OrderMagicNumber()==MAGICNUM)
        {
         bool exit=false;
         string comment=OrderComment();
         for(int i=0;i<order_history_num;i++)
           {
            if(comment==info_his[i].order_Ticket) exit=true;
           }
         if(exit==true)
           {
            double ASK=MarketInfo(OrderSymbol(),MODE_ASK);
            double BID=MarketInfo(OrderSymbol(),MODE_BID);
            if(OrderType()==OP_BUY)
              {
               if(OrderClose(OrderTicket(),OrderLots(),BID,Slippage,clrWhite)==false)
                  Print("close fail");
              };
            if(OrderType()==OP_SELL)
              {
               if(OrderClose(OrderTicket(),OrderLots(),ASK,Slippage,clrWhite)==false)
                  Print("close fail");
              };
            if(OrderType()>1)
              {
               if(OrderDelete(OrderTicket())==false)
                  Print("delete fail");
              };
           }
        }
     }

   if(test) step++;

  }
//+------------------------------------------------------------------+
