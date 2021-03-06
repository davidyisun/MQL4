//+------------------------------------------------------------------+
//|                                                     template.mq4 |
//|                                                      David Yisun |
//|                                              david_yisun@163.com |
//+------------------------------------------------------------------+
#property copyright "David Yisun"
#property link      "david_yisun@163.com"
#property version   "1.00"
#property strict

#include "include\information.mqh"


int MagicNum=407610636;

input int t=1;//每t秒记录一次

//---调试参数
int limit = 1;
int step = 0;
bool test = false;

//---账户信息结构体
datetime CurrentTime;                                       //服务器时间
datetime LocalTime;                                         //本地时间
struct AccountInformation
  {
   //---string---
   string                              name;                //账户名称
   string                              server;              //服务器名称        
   string                              currency;            //货币类型
   string                              company;             //交易商名称
   //---integer---
   int                                 login;               //账户编号
   ENUM_ACCOUNT_TRADE_MODE             trade_mode;          //账户交易方式：模拟号还是实盘号
   int                                 leverage;            //账户杠杆
   int                                 limit_orders;        //最大限价单下单量
   bool                                trade_allowed;       //账户是否允许交易
   bool                                trade_expert;        //账户是否允许EA交易
   //---double---
   double                              balance;             //当前余额(不算持仓的盈亏)
   double                              profit;              //当前账户收益
   double                              equity;              //当前账户净值
   double                              margin;              //已用保证金
   double                              margin_free;         //可用保证金
   double                              margin_level;        //预付款比例(净值/已用保证金) 
   double                              margin_so_call;      //建仓的最低要求的预付款比例
   double                              margin_so_so;        //爆仓的预付款比例   
  };
AccountInformation     y;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//--- create timer
   EventSetTimer(t);
   //Alert(LocalTime);
   //---string---
   y.company = AccountInfoString(ACCOUNT_COMPANY);
   y.currency = AccountInfoString(ACCOUNT_CURRENCY);
   y.name = AccountInfoString(ACCOUNT_NAME);
   y.server = AccountInfoString(ACCOUNT_SERVER);
   //---integer---
   y.login = AccountInfoInteger(ACCOUNT_LOGIN);
   y.trade_mode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
   y.leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   y.limit_orders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   y.trade_allowed = AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   y.trade_expert = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   //---double---
   y.balance = AccountInfoDouble(ACCOUNT_BALANCE);
   y.profit = AccountInfoDouble(ACCOUNT_PROFIT);
   y.equity = AccountInfoDouble(ACCOUNT_EQUITY);
   y.margin = AccountInfoDouble(ACCOUNT_MARGIN);
   y.margin_free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   y.margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   y.margin_so_call = AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
   y.margin_so_so = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
  

      
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
//---
  if(step>limit) return;
  CurrentTime = TimeCurrent();
  LocalTime = TimeLocal();
  bool m=RecorderForEquity(y.login,MagicNum);
  if(test) step++;
  
  }
//+------------------------------------------------------------------+
