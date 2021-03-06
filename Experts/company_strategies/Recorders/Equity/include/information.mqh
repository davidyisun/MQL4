//+------------------------------------------------------------------+
//|                                                  information.mqh |
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
bool RecorderForEquity(string x,int magicnum,bool only_tradeorder=true)
  {
   bool res=true;
   string name=x+"Equity.csv";  //文件名
//---文件是否存在---
   bool FileExit=false;
   if(FileIsExist(name)) FileExit=true;
//---操作文件---
   int handle=FileOpen(name,FILE_READ|FILE_CSV|FILE_WRITE|FILE_COMMON,',');
   if(handle!=INVALID_HANDLE)
     {
      if(FileExit==false)
         FileWrite(handle,
                   "当前时间(服务器)",
                   "本地时间",
                   "账号",
                   "订单号",
                   "品种",
                   "订单类型",
                   "开仓时间",
                   "持仓时间(min)",
                   "开仓价格",
                   "本单盈亏",
                   "当前ASK",
                   "当前BId",
                   "当前点差",
                   "价差(point)",
                   "MagicNum",
                   "账户余额",
                   "账户净值",
                   "已用保证金",
                   "可用保证金",
                   "预付款比例",
                   "杠杆水平",
                   "账户总获利",
                   "交易商名称",
                   "服务器名称"
                   );
      FileSeek(handle,0,SEEK_END);
      int order_num=OrdersTotal();
      int recorder_count=0; //计数器

      if(order_num>0)
        {
         for(int i=0;i<order_num;i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
              {
               Print("OrderSelect Failed");
               continue;
              }
            else
              {
               //---获取订单类型-and-计算价差--

               double pricechange;  //价差
               string type="";      //类型
               switch(OrderType())
                 {
                  case OP_BUY :
                    {
                     type="BUY";
                     double p=MarketInfo(OrderSymbol(),MODE_BID);
                     double point=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                     pricechange =(p-OrderOpenPrice())/point;
                    }
                  break;
                  case OP_SELL :
                    {
                     type="SELL";
                     double p=MarketInfo(OrderSymbol(),MODE_ASK);
                     double point=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                     pricechange =(p-OrderOpenPrice())/point;
                    }
                  break;
                  case OP_BUYLIMIT :
                    {
                     type="BUYLIMIT";
                     pricechange=0;
                    }
                  break;
                  case OP_BUYSTOP :
                    {
                     type="BUYSTOP";
                     pricechange=0;
                    }
                  break;
                  case OP_SELLLIMIT :
                    {
                     type="SELLLIMIT";
                     pricechange=0;
                    }
                  break;
                  default:
                    {
                     type="SELLSTOP";
                     pricechange=0;
                    }
                  break;
                 }
               //---判断是否记录挂单---
               if(only_tradeorder && (OrderType()>1)) continue;

               //---计算当前持仓时间---
               double holdtime=SecondsConvert(TimeCurrent()-OrderOpenTime(),0);

               //---写入信息---
               FileWrite(handle,
                         TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                         TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),
                         AccountInfoInteger(ACCOUNT_LOGIN),
                         OrderTicket(),
                         OrderSymbol(),
                         type,
                         OrderOpenTime(),
                         holdtime,
                         OrderOpenPrice(),
                         OrderProfit(),
                         MarketInfo(OrderSymbol(),MODE_ASK),
                         MarketInfo(OrderSymbol(),MODE_BID),
                         MarketInfo(OrderSymbol(),MODE_SPREAD),
                         pricechange,
                         magicnum,
                         AccountInfoDouble(ACCOUNT_BALANCE),
                         AccountInfoDouble(ACCOUNT_EQUITY),
                         AccountInfoDouble(ACCOUNT_MARGIN),
                         AccountInfoDouble(ACCOUNT_MARGIN_FREE),
                         AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),
                         AccountInfoInteger(ACCOUNT_LEVERAGE),
                         AccountInfoDouble(ACCOUNT_PROFIT),
                         AccountInfoString(ACCOUNT_COMPANY),
                         AccountInfoString(ACCOUNT_SERVER)
                         );
               recorder_count++;
              }
            }
           }
         if(recorder_count==0)
            {
            FileWrite(handle,
                      TimeCurrent(),
                      TimeLocal(),
                      AccountInfoInteger(ACCOUNT_LOGIN),
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      magicnum,
                      AccountInfoDouble(ACCOUNT_BALANCE),
                      AccountInfoDouble(ACCOUNT_EQUITY),
                      AccountInfoDouble(ACCOUNT_MARGIN),
                      AccountInfoDouble(ACCOUNT_MARGIN_FREE),
                      AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),
                      AccountInfoInteger(ACCOUNT_LEVERAGE),
                      AccountInfoDouble(ACCOUNT_PROFIT),
                      AccountInfoString(ACCOUNT_COMPANY),
                      AccountInfoString(ACCOUNT_SERVER)
                      );
              }
         FileClose(handle);
         return(res);
     }
   else
     {
      res=false;
      Print("Open The File Failed");
      return(res);
     }

   return(res);
  }
//+------------------------------------------------------------------+

//---公共函数---
//+------------------------------------------------------------------+
//|公1:时间转换                                                      |
//|说明:将秒数化为分钟或者小时，或者天数,分别为mode= 0,1,2默认为0    |
//+------------------------------------------------------------------+
double SecondsConvert(long seconds,int mode=0)
  {
   double res=0.0;
   switch(mode)
     {
      case 0 :
         res=double(seconds)/60.00000000;
         break;
      case 1:
         res=double(seconds)/(60.00000000*60.00000000);
         break;
      default:
         res=double(seconds)/(60.00000000*60.00000000*24.00000000);
         break;
     }
   return res;
  }
//+------------------------------------------------------------------+
