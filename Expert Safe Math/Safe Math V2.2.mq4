//+------------------------------------------------------------------+
//|                                                    Safe Math.mq4 |
//|                                          Copyright 2022, aka4855 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#property copyright     "Safe Math 2022"
#property version       "V2.2"
#property description   "Safe Math v2.2"
//+------------------------------------------------------------------+

#define  Shift             1


int arrLevel[2] = {1000,400,400,400};
int ind;

string EA_will_Expired_at              = "2023.8.28"; //year.month.day Expiration

bool firesell = false;
bool firebuy = false;

string EA_Comment = "Safe Math v2.2";

extern string   t1                       = "Magic Number";
input int     MagicBuy                 = 11;
input int     MagicSell                = 22;

string f6                         = "------- Trend MA -------";
ENUM_TIMEFRAMES Trend_MA_TimeFrame = PERIOD_H1;
int             Trend_MA           = 30;
ENUM_MA_METHOD  Trend_MA_Method    = MODE_EMA;
ENUM_APPLIED_PRICE Trend_MA_Price  = PRICE_CLOSE;

string f7                       = "------- Signal MA -------";
int                MA_Period     = 30;
ENUM_MA_METHOD     MA_Method     = MODE_LWMA;
ENUM_APPLIED_PRICE MA_Price      = PRICE_CLOSE;

string f8                       = "------- RSI Cross -------";
int                Fast_RSI      = 15;
int                Slow_RSI      = 25;
ENUM_APPLIED_PRICE RSI_Price     = PRICE_CLOSE;

string f9                       = "------- Parabolic SAR -------";
double  Step                     = 0.01;
double  Max                      = 0.2;

extern string ti2                       = ">>> Setting Hour <<<";
input int     StartHour               = 00;
input int     StartMinute             = 00;
input int     FinishHour              = 24;
input int     FinishMinute            = 0;

string title4                       = "------- Stop Losss Equity -------";
int  StopLossEquity               = 70;
bool  StopEa                      = false;

double  Lots                     = 7;
double  Risk                     = 2;
bool    MM                       = False;
double  Lot_Digits               = 2;

string t4                       = "------- Risk Management -------";
double  Multiplier               = 1.5;
double  GetProfit            = 100;
double  Max_GetProfit    = 100;
double  Maximal_Loss             = 0;
double Maximal_Lots             = 1.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeNS
  {
   INVEST=0,   // Investing.com
   DAILYFX=1,  // Dailyfx.com
  };
//--- input parameters
TypeNS SourceNews=INVEST;
bool     LowNews             = false;
int      LowIndentBefore     = 15;
int      LowIndentAfter      = 15;
bool     MiddleNews           = false;
int      MiddleIndentBefore   = 30;
int      MiddleIndentAfter    = 30;
bool     HighNews            = true;
int      HighIndentBefore    = 60;
int      HighIndentAfter     = 60;
bool     NFPNews             = true;
int      NFPIndentBefore     = 180;
int      NFPIndentAfter      = 180;

bool    DrawNewsLines        = true;
color   LowColor             = clrYellow;
color   MiddleColor           = clrOrange;
color   HighColor            = clrRed;
int     LineWidth            = 2;
ENUM_LINE_STYLE LineStyle    = STYLE_SOLID;
bool    OnlySymbolNews       = true;
int  GMTplus=0;     // Your Time Zone, GMT (for news)

int NomNews=0,Now=0,MinBefore=0,MinAfter=0;
string NewsArr[4][1000];
datetime LastUpd;
string ValStr;
int   Upd            = 86400;      // Period news updates in seconds
bool  Next           = false;      // Draw only the future of news line
bool  Signal         = false;      // Signals on the upcoming news
datetime TimeNews[300];
string Valuta[300],News[300],Vazn[300];





//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {

   int  ticketBuyOrder       =  GetTicketOfLargestBuyOrder();
   int  ticketSellOrder      =  GetTicketOfLargestSellOrder();
   bool isNewBar             =  IsNewBar();
   int  index;


   if(isNewBar==true)
     {

      // Bars
      double CLOSE  = iClose(Symbol(), 0, Shift);
      double CLOSE1 = iClose(Symbol(), 0, Shift+1);
      double HIGH   = iHigh(Symbol(), 0, Shift);
      double LOW    = iLow(Symbol(), 0, Shift);
      HideTestIndicators(true);
      double dRSIFast  = iRSI(Symbol(), 0, Fast_RSI, RSI_Price, 0);
      double dRSIFast1 = iRSI(Symbol(), 0, Fast_RSI, RSI_Price, 3);
      double dRSISlow  = iRSI(Symbol(), 0, Slow_RSI, RSI_Price, 0);
      double dTrendMA1 = iMA(Symbol(), Trend_MA_TimeFrame, Trend_MA, 0, Trend_MA_Method, Trend_MA_Price, 1);
      double MA        = iMA(Symbol(),0,MA_Period,0,MA_Method,MA_Price,0);
      double trade_sar = iSAR(Symbol(), 0, Step, Max, Shift);
      HideTestIndicators(false);

      if(OrdersTotal() < 1)
        {

         if(dRSIFast<dRSIFast1 && dRSIFast<dRSISlow && trade_sar > CLOSE1 && MA>CLOSE1)
           {
            firesell = true;
            firebuy = false;
           }

         if(dRSIFast>dRSIFast1 && dRSIFast>dRSISlow && trade_sar < CLOSE1 && MA<CLOSE1)
           {
            firesell = false;
            firebuy = true;
           }

        }
     }


   if(OrdersTotal() < 2)
     {

      if(isNewBar == true && CheckTradingTime() && ticketBuyOrder==0 && firebuy==true)
        {
         index = OrderSend(Symbol(),OP_BUY, GetLotSize(), Ask, 3, 0, 0, EA_Comment, MagicBuy, 0, Green);
        }


      if(isNewBar==true && CheckTradingTime() == true && ticketSellOrder == 0 && firesell == true)
        {
         index = OrderSend(Symbol(), OP_SELL, GetLotSize(), Bid, 3, 0, 0, EA_Comment, MagicSell, 0, Yellow);
        }

     }
   else
     {

      if((isNewBar == true && ticketBuyOrder != 0 && GetSellOrderCount() < 2))
        {
         if(OrderSelect(ticketBuyOrder, SELECT_BY_TICKET))
           {

            double orderLots  = OrderLots();
            double orderPrice = OrderOpenPrice();


            if(Ask <= NormalizeDouble(orderPrice - arrLevel[ind] * Point,Digits))
              {

               index = OrderSend(Symbol(), OP_BUY, NormalizeDouble(orderLots * Multiplier, 2), Ask, 3, 0, 0, EA_Comment, MagicBuy, 0,Blue);
               if(ind < 3)
                 {
                  ind+=1;
                  Print("gfg "+ind);
                 }
              }

           }
        }



      if((isNewBar==true && ticketSellOrder !=0 && GetBuyOrderCount() < 2))
        {
         if(OrderSelect(ticketSellOrder, SELECT_BY_TICKET))
           {

            double orderLots  = OrderLots();
            double orderPrice = OrderOpenPrice();

            if(Bid >= NormalizeDouble(orderPrice + arrLevel[ind] * Point,Digits))
              {
               index = OrderSend(Symbol(), OP_SELL, NormalizeDouble(orderLots * Multiplier, 2), Bid, 3, 0, 0, EA_Comment, MagicSell, 0, Blue);
               if(ind < 3)
                 {
                  ind+=1;
                  Print("fff "+ind);
                 }
              }



           }
        }

     }






  }


//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

     if(IsTesting())
       {
        return;
       }

//---
   string expire_date = EA_will_Expired_at; //<-- hard coded datetime
   datetime e_d = StrToTime(expire_date);
   if(CurTime() <= e_d)
     {

     }
   else
     {
      Print("...............................Stop trades expire_date...");
      Alert("Expert is Expired, connect with us telegram: @ ");
      return;
     }

   if(!IsDemo())
     {
      MessageBox("This only works on demo account please connect with us telegram: @"," Error ",MB_ICONINFORMATION);
      return;
     }
   /* if (AccountNumber() != "250574457") //250692889      250574457
    {
       return;
    }
    */

   /*   int spread = MarketInfo(Symbol(),MODE_SPREAD);

      if(spread > MaxSpread)
        {
         StopEa = true;
         CloseAllOrders();
         return;
        }
        */

   LABEL("l","EA Math v2.2","Tahoma",12,Red,2,7,7);
   LABEL("2","Version Demo","Tahoma",12,White,2,120,7);
   LABEL("3","connect with us telegram: @ ","Tahoma",12,White,3,7,30);
   LABEL("4","channel telegram: @ ","Tahoma",12,White,3,7,7);


   if(PercentEquityCurrent() >= StopLossEquity)
     {
      CloseAllOrders();
      StopEa = True;
      Print("...................Stop trades StopLossEquity...");
      return;
     }



   string TextDisplay="";

   /*  Check News   */
   bool trade=true;

   int NewsPWR=0;
   datetime nextSigTime=0;
   if(LowNews || MiddleNews || HighNews || NFPNews)
     {
      if(SourceNews==0)
        {
         // Investing
         if(CheckInvestingNews(NewsPWR,nextSigTime))
           {
            trade=false;   // news time
           }
        }
      if(SourceNews==1)
        {
         //DailyFX
         if(CheckDailyFXNews(NewsPWR,nextSigTime))
           {
            trade=false;   // news time
           }
        }


     }
   if(trade)
     {
      // No News, Trade enabled

      if(ObjectFind(0,"NS_Label")!=-1)
        {
         ObjectDelete(0,"NS_Label");
        }

     }
   else  // waiting news , check news power
     {
      color clrT=LowColor;
      if(NewsPWR>3)
        {

         clrT = HighColor;
        }
      else
        {
         if(NewsPWR>2)
           {

            clrT = HighColor;
           }
         else
           {
            if(NewsPWR>1)
              {

               clrT = MiddleColor;
              }
            else
              {

               clrT = LowColor;
              }
           }
        }
      // Make Text Label
      if(nextSigTime>0)
        {

        }
      if(ObjectFind(0,"NS_Label")==-1)
        {

        }
      if(ObjectGetInteger(0,"NS_Label",OBJPROP_COLOR)!=clrT)
        {


        }
     }


   /*  End Check News   */
   if(IsTradeAllowed() && trade)
     {
      if(StopEa == false)
        {
         // No news and Trade Allowed
         CheckForOpen();
         CloseProfit();
        }

     }

   if(OrdersTotal() > 0 && StopEa == false && trade == false)
     {
      CloseProfit();
     }



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LABEL(string sName,string sText,string sFont,int iFontSize,color cFontColor,int iCorner,int iX,int iY)
  {
   if(ObjectFind(sName)==-1)
     {
      ObjectCreate(sName,OBJ_LABEL,0,0,0);
     }
   else
     {
      if(!IsTesting())
        {
         ObjectDelete(sName);
         ObjectCreate(sName,OBJ_LABEL,0,0,0);
        }
     }
   ObjectSetText(sName,sText,iFontSize,sFont,cFontColor);
   ObjectSet(sName,OBJPROP_CORNER,iCorner);
   ObjectSet(sName,OBJPROP_XDISTANCE,iX);
   ObjectSet(sName,OBJPROP_YDISTANCE,iY);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int PercentEquityCurrent()

  {
   int pec;
   if(AccountEquity() < AccountBalance())
     {
      pec = AccountBalance() - AccountEquity();
      pec = pec * 100;
      pec = pec / AccountBalance();
     }
   return pec;
  }



void CloseProfit()

  {

   double profitBuyOrders=0;
   for(int k=OrdersTotal()-1; k >=0; k--)
     {
      if(OrderSelect(k,SELECT_BY_POS))
        {
         if(Symbol()==OrderSymbol() && OrderType()==OP_BUY && OrderMagicNumber() == MagicBuy)
           {
            profitBuyOrders = profitBuyOrders + OrderProfit() + OrderSwap() + OrderCommission();
           }
        }
     }




   double profitSellOrders=0;
   for(int j=OrdersTotal()-1; j>=0; j--)
     {
      if(OrderSelect(j,SELECT_BY_POS))
        {
         if(Symbol() == OrderSymbol() && OrderType()==OP_SELL && OrderMagicNumber() == MagicSell)
           {
            profitSellOrders = profitSellOrders + OrderProfit() + OrderSwap() + OrderCommission();
           }
        }
     }



   if(Max_GetProfit> 0  && profitBuyOrders + profitSellOrders >= Max_GetProfit)
     {
      CloseAllSellOrders();
      CloseAllBuyOrders();
      firebuy=false;
      firesell=false;
     }

   double totalglobalprofit = TotalProfit();
   if((GetProfit > 0 && totalglobalprofit >= GetProfit) || (Maximal_Loss < 0 && totalglobalprofit <= Maximal_Loss))
     {
      CloseAllOrders();
      firebuy  = false;
      firesell = false;
     }
// ind = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTicketOfLargestBuyOrder()
  {
   double maxLots=0;
   int    orderTicketNr=0;

   for(int i=0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderType()==OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber()==MagicBuy)
           {

            double orderLots = OrderLots();
            if(orderLots >= maxLots)
              {
               maxLots       = orderLots;
               orderTicketNr = OrderTicket();
              }
           }
        }
     }
   return orderTicketNr;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTicketOfLargestSellOrder()
  {
   double maxLots=0;
   int orderTicketNr=0;

   for(int l=0; l<=OrdersTotal(); l++)
     {
      if(OrderSelect(l,SELECT_BY_POS))
        {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicSell)
           {
            double orderLots = OrderLots();
            if(orderLots >= maxLots)
              {
               maxLots = orderLots;
               orderTicketNr = OrderTicket();
              }
           }
        }
     }
   return orderTicketNr;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime time = Time[0];
   if(Time[0] > time)
     {
      time = Time[0]; //newbar, update time
      return (true);
     }
   return(false);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLotSize()
  {
   double minlot    = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot    = MarketInfo(Symbol(), MODE_MAXLOT);
   double leverage  = AccountLeverage();
   double lotsize   = MarketInfo(Symbol(), MODE_LOTSIZE);
   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double MinLots = 0.01;
   double lots = Lots;

   if(MM)
     {
      lots = NormalizeDouble(AccountFreeMargin() * Risk/100 / 1000.0, Lot_Digits);
      if(lots < minlot)
         lots = minlot;
      if(lots > Maximal_Lots)
         lots = Maximal_Lots;
      if(AccountFreeMargin() < Ask * lots * lotsize / leverage)
        {
         Print("Invalid Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
         Comment("Invalid Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
        }
     }
   else
      lots=NormalizeDouble(Lots, Digits);
   return(lots);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckTradingTime()
  {
   int min  = TimeMinute(TimeCurrent());
   int hour = TimeHour(TimeCurrent());

// check if we can trade from 00:00 - 24:00
   if(StartHour == 0 && FinishHour == 24)
     {
      if(StartMinute==0 && FinishMinute==0)
        {
         // yes then return true
         return true;
        }
     }

   if(StartHour > FinishHour)
     {
      return(true);
     }

// suppose we're allowed to trade from 14:15 - 19:30

// 1) check if hour is < 14 or hour > 19
   if(hour < StartHour || hour > FinishHour)
     {
      // if so then we are not allowed to trade
      return false;
     }

// if hour is 14, then check if minute < 15
   if(hour == StartHour && min < StartMinute)
     {
      // if so then we are not allowed to trade
      return false;
     }

// if hour is 19, then check  minute > 30
   if(hour == FinishHour && min > FinishMinute)
     {
      // if so then we are not allowed to trade
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllOrders()
  {
   CloseAllBuyOrders();
   CloseAllSellOrders();
//ind = 0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllSellOrders()
  {
   for(int h=OrdersTotal(); h>=0; h--)
     {
      if(OrderSelect(h,SELECT_BY_POS))
        {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicSell)
           {
            RefreshRates();
            bool success =OrderClose(OrderTicket(), OrderLots(), Ask, 0, Yellow);
           }
        }
     }
   ind = 0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllBuyOrders()
  {
   for(int m=OrdersTotal(); m>=0; m--)
     {
      if(OrderSelect(m, SELECT_BY_POS))
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicBuy)
           {
            RefreshRates();
            bool success = OrderClose(OrderTicket(), OrderLots(), Bid, 0, Green);
           }
        }
     }
   ind = 0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalProfit()
  {
   double totalProfit = 0;
   for(int j=OrdersTotal(); j >= 0; j--)
     {
      if(OrderSelect(j,SELECT_BY_POS))
        {
         if(OrderSymbol() == Symbol())
           {
            if(OrderMagicNumber() == MagicSell || OrderMagicNumber() == MagicBuy)
              {
               RefreshRates();

               totalProfit = totalProfit + OrderProfit() + OrderSwap() + OrderCommission();
              }
           }
        }
     }
   return totalProfit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetBuyOrderCount()
  {
   int count=0;

// find all open orders of today
   for(int k = OrdersTotal(); k >=0 ; k--)
     {
      if(OrderSelect(k, SELECT_BY_POS))
        {
         if(OrderType()==OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicBuy)
           {
            count=count+1;
           }
        }
     }
   return count;
  }


//+------------------------------------------------------------------+
int GetSellOrderCount()
  {
   int count=0;

// find all open orders of today
   for(int k = OrdersTotal(); k >=0 ; k--)
     {
      if(OrderSelect(k, SELECT_BY_POS))
        {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicSell)
           {
            count=count+1;
           }
        }
     }
   return count;
  }
//+------------------------------------------------------------------+



//////////////////////////////////////////////////////////////////////////////////
string ReadCBOE()
  {

   string cookie=NULL,headers;
   char post[],result[];
   string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"):
   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//---
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//--- error checking
   if(res==-1)
     {
      Print("WebRequest error, err.code  =",GetLastError());
      MessageBox("add address 'http://ec.forexprostools.com/' in Tools Option Expert Advisors "," Error ",MB_ICONINFORMATION);
      //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
     }
   else
     {
      //--- successful download
      //PrintFormat("File successfully downloaded, the file size in bytes  =%d.",ArraySize(result));
      //--- save the data in the file
      int filehandle=FileOpen("news-log.html",FILE_WRITE|FILE_BIN);
      //--- проверка ошибки
      if(filehandle!=INVALID_HANDLE)
        {
         //---save the contents of the array result [] in file
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- close file
         FileClose(filehandle);

         int filehandle2=FileOpen("news-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
        }
      else
        {
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }

   return(TXT);
  }
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   return((datetime)(StringToTime(time) + GMTplus*3600));
  }
//////////////////////////////////////////////////////////////////////////////////
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);

   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)
         break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);

      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)
         break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][NomNews])<0)
         continue;

      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)
         break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !HighNews)
         continue;
      if(StringFind(NewsArr[2][NomNews],"Moderate")>=0 && !MiddleNews)
         continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !LowNews)
         continue;

      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)
         break;
      if(sh1<0 || sh1>sh2)
         NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else
         NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);

      NomNews++;
      if(NomNews==300)
         break;
     }
  }
//+------------------------------------------------------------------+
int del(string name) // Спец. ф-ия deinit()
  {
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Obj_Name=ObjectName(n);
      if(StringFind(Obj_Name,name,0)!=-1)
        {
         ObjectDelete(Obj_Name);
        }
     }
   return 0;                                      // Выход из deinit()
  }
//+------------------------------------------------------------------+
bool CheckInvestingNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false;
   pwr=0;
   int maxPower=0;
   if(LowNews || MiddleNews || HighNews || NFPNews)
     {
      if(TimeCurrent()-LastUpd>=Upd)
        {
         Print("Investing.com News Loading...");
         UpdateNews();
         LastUpd=TimeCurrent();
         Comment("");
        }
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0; i<NomNews; i++)
           {
            string Name=StringSubstr("NS_"+TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")
               if(ObjectFind(Name)==0)
                  continue;
            if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][i])<0)
               continue;
            if(TimeNewsFunck(i)<TimeCurrent() && Next)
               continue;

            color clrf=clrNONE;
            if(HighNews && StringFind(NewsArr[2][i],"High")>=0)
               clrf=HighColor;
            if(MiddleNews && StringFind(NewsArr[2][i],"Moderate")>=0)
               clrf=MiddleColor;
            if(LowNews && StringFind(NewsArr[2][i],"Low")>=0)
               clrf=LowColor;

            if(clrf==clrNONE)
               continue;

            if(NewsArr[3][i]!="")
              {
               ObjectCreate(0,Name,OBJ_VLINE,0,TimeNewsFunck(i),0);
               ObjectSet(Name,OBJPROP_COLOR,clrf);
               ObjectSet(Name,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Name,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int ii;
      CheckNews=false;
      for(ii=0; ii<NomNews; ii++)
        {
         int power=0;
         if(HighNews && StringFind(NewsArr[2][ii],"High")>=0)
           {
            power=3;
            MinBefore=HighIndentBefore;
            MinAfter=HighIndentAfter;
           }
         if(MiddleNews && StringFind(NewsArr[2][ii],"Moderate")>=0)
           {
            power=2;
            MinBefore=MiddleIndentBefore;
            MinAfter=MiddleIndentAfter;
           }
         if(LowNews && StringFind(NewsArr[2][ii],"Low")>=0)
           {
            power=1;
            MinBefore=LowIndentBefore;
            MinAfter=LowIndentAfter;
           }
         if(NFPNews && StringFind(NewsArr[3][ii],"Nonfarm Payrolls")>=0)
           {
            power=4;
            MinBefore=NFPIndentBefore;
            MinAfter=NFPIndentAfter;
           }
         if(power==0)
            continue;

         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(ii) && TimeCurrent()-MinAfter*60<TimeNewsFunck(ii) && (!OnlySymbolNews || (OnlySymbolNews && StringFind(ValStr,NewsArr[1][ii])>=0)))
           {
            if(power>maxPower)
              {
               maxPower=power;
               mintime=TimeNewsFunck(ii);
              }
           }
         else
           {
            CheckNews=false;
           }
        }
      if(maxPower>0)
        {
         CheckNews=true;
        }
     }
   pwr=maxPower;
   return(CheckNews);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const string text="Label",const color clr=clrRed)
  {
   long x_distance;
   long y_distance;
   long chart_ID=0;
   string name="NS_Label";
   int sub_window=0;
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER;
   string font="Arial";
   int font_size=8;
   double angle=0.0;
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER;
   bool back=false;
   bool selection=false;
   bool hidden=true;
   long z_order=0;
//--- определим размеры окна
   ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
   ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,(int)(x_distance/27));
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,(int)(y_distance/15));
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateDFX()
  {
   string DF="";
   string MF="";
   int DeltaGMT=GMTplus; // 0 -(TimeGMTOffset()/60/60)-DeltaTime;
   int ChasPoyasServera=DeltaGMT;
   datetime NowTimeD1=Time[0];
   datetime LastSunday=NowTimeD1-TimeDayOfWeek(NowTimeD1)*86399;
   int DayFile=TimeDay(LastSunday);
   if(DayFile<10)
      DF="0"+(string)DayFile;
   else
      DF=(string)DayFile;
   int MonthFile=TimeMonth(LastSunday);
   if(MonthFile<10)
      MF="0"+(string)MonthFile;
   else
      MF=(string)MonthFile;
   int YearFile=TimeYear(LastSunday);
   string DateFile=MF+"-"+DF+"-"+(string)YearFile;
   string FileName= DateFile+"_dfx.csv";
   int handle;

   if(!FileIsExist(FileName))
     {
      string url="http://www.dailyfx.com/files/Calendar-"+DateFile+".csv";
      string cookie=NULL,headers;
      char post[],result[];
      string TXT="";
      int res;
      string text="";
      ResetLastError();
      int timeout=5000;
      res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
      if(res==-1)
        {
         Print("WebRequest error, err.code  =",GetLastError());
         MessageBox("add address 'http://ec.forexprostools.com/' in Tools Option Expert Advisors"," Error ",MB_ICONINFORMATION);
        }
      else
        {
         int filehandle=FileOpen(FileName,FILE_WRITE|FILE_BIN);
         if(filehandle!=INVALID_HANDLE)
           {
            FileWriteArray(filehandle,result,0,ArraySize(result));
            FileClose(filehandle);
           }
         else
           {
            Print("Error in FileOpen. Error code =",GetLastError());
           }
        }
     }
   handle=FileOpen(FileName,FILE_READ|FILE_CSV);
   string data,time,month,valuta;
   int startStr=0;
   if(handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         int str_size=FileReadInteger(handle,INT_VALUE);
         string str=FileReadString(handle,str_size);
         string value[10];
         int k=StringSplit(str,StringGetCharacter(",",0),value);
         data = value[0];
         time = value[1];
         if(time=="")
           {
            continue;
           }
         month=StringSubstr(data,4,3);
         if(month=="Jan")
            month="01";
         if(month=="Feb")
            month="02";
         if(month=="Mar")
            month="03";
         if(month=="Apr")
            month="04";
         if(month=="May")
            month="05";
         if(month=="Jun")
            month="06";
         if(month=="Jul")
            month="07";
         if(month=="Aug")
            month="08";
         if(month=="Sep")
            month="09";
         if(month=="Oct")
            month="10";
         if(month=="Nov")
            month="11";
         if(month=="Dec")
            month="12";
         TimeNews[startStr]=StrToTime((string)YearFile+"."+month+"."+StringSubstr(data,8,2)+" "+time)+ChasPoyasServera*3600;
         valuta=value[3];
         if(valuta=="eur" ||valuta=="EUR")
            Valuta[startStr]="EUR";
         if(valuta=="usd" ||valuta=="USD")
            Valuta[startStr]="USD";
         if(valuta=="jpy" ||valuta=="JPY")
            Valuta[startStr]="JPY";
         if(valuta=="gbp" ||valuta=="GBP")
            Valuta[startStr]="GBP";
         if(valuta=="chf" ||valuta=="CHF")
            Valuta[startStr]="CHF";
         if(valuta=="cad" ||valuta=="CAD")
            Valuta[startStr]="CAD";
         if(valuta=="aud" ||valuta=="AUD")
            Valuta[startStr]="AUD";
         if(valuta=="nzd" ||valuta=="NZD")
            Valuta[startStr]="NZD";
         News[startStr]=value[4];
         News[startStr]=StringSubstr(News[startStr],0,60);
         Vazn[startStr]=value[5];
         if(Vazn[startStr]!="High" && Vazn[startStr]!="HIGH" && Vazn[startStr]!="Medium" && Vazn[startStr]!="MEDIUM" && Vazn[startStr]!="MED" && Vazn[startStr]!="Low" && Vazn[startStr]!="LOW")
            Vazn[startStr]=FileReadString(handle);
         startStr++;
        }
     }
   else
     {
      PrintFormat("Error in FileOpen = %s. Error code= %d",FileName,GetLastError());
     }
   NomNews=startStr-1;
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckDailyFXNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false;
   pwr=0;
   int maxPower=0;
   color clrf=clrNONE;
   mintime=0;
   if(LowNews || MiddleNews || HighNews || NFPNews)
     {
      if(Time[0]-LastUpd>=Upd)
        {
         Print("News DailyFX Loading...");
         UpdateDFX();
         LastUpd=Time[0];
        }
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0; i<NomNews; i++)
           {
            string Lname=StringSubstr("NS_"+TimeToStr(TimeNews[i],TIME_MINUTES)+"_"+News[i],0,63);
            if(News[i]!="")
               if(ObjectFind(0,Lname)==0)
                 {
                  continue;
                 }
            if(TimeNews[i]<TimeCurrent() && Next)
              {
               continue;
              }
            if((Vazn[i]=="High" || Vazn[i]=="HIGH") && HighNews==false)
              {
               continue;
              }
            if((Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED") && MiddleNews==false)
              {
               continue;
              }
            if((Vazn[i]=="Low" || Vazn[i]=="LOW") && LowNews==false)
              {
               continue;
              }
            if(Vazn[i]=="High" || Vazn[i]=="HIGH")
              {
               clrf=HighColor;
              }
            if(Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED")
              {
               clrf=MiddleColor;
              }
            if(Vazn[i]=="Low" || Vazn[i]=="LOW")
              {
               clrf=LowColor;
              }
            if(News[i]!="" && ObjectFind(0,Lname)<0)
              {
               if(OnlySymbolNews && (Valuta[i]!=StringSubstr(_Symbol,0,3) && Valuta[i]!=StringSubstr(_Symbol,3,3)))
                 {
                  continue;
                 }
               ObjectCreate(0,Lname,OBJ_VLINE,0,TimeNews[i],0);
               ObjectSet(Lname,OBJPROP_COLOR,clrf);
               ObjectSet(Lname,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Lname,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Lname,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      for(int i=0; i<NomNews; i++)
        {
         int power=0;
         if(HighNews && (Vazn[i]=="High" || Vazn[i]=="HIGH"))
           {
            power=3;
            MinBefore=HighIndentBefore;
            MinAfter=HighIndentAfter;
           }
         if(MiddleNews && (Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED"))
           {
            power=2;
            MinBefore=MiddleIndentBefore;
            MinAfter=MiddleIndentAfter;
           }
         if(LowNews && (Vazn[i]=="Low" || Vazn[i]=="LOW"))
           {
            power=1;
            MinBefore=LowIndentBefore;
            MinAfter=LowIndentAfter;
           }
         if(NFPNews && StringFind(News[i],"Non-farm Payrolls")>=0)
           {
            power=4;
            MinBefore=NFPIndentBefore;
            MinAfter=NFPIndentAfter;
           }
         if(power==0)
            continue;

         if(TimeCurrent()+MinBefore*60>TimeNews[i] && TimeCurrent()-MinAfter*60<TimeNews[i] && (!OnlySymbolNews || (OnlySymbolNews && (StringSubstr(Symbol(),0,3)==Valuta[i] || StringSubstr(Symbol(),3,3)==Valuta[i]))))
           {
            if(power>maxPower)
              {
               maxPower=power;
               mintime=TimeNews[i];
              }
           }
         else
           {
            CheckNews=false;
           }
        }
      if(maxPower>0)
        {
         CheckNews=true;
        }
     }
   pwr=maxPower;
   return(CheckNews);
  }

//+------------------------------------------------------------------+
