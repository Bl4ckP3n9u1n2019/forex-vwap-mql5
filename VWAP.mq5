//+------------------------------------------------------------------+
//|                                                         VWAP.mq5 |
//|                                                    UndauntedFish |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "UndauntedFish"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window


// Array of historic VWAP values
double vwap[];

//Cumulative Volume and PV for the day -- resets every night at 21:00 (except on days where the market is closed)
double cumuVol, cumuPV;

int OnInit()
{
   // Sort the elements of the array so that the first element is always the most recent value (LIFO)
   ArraySetAsSeries(vwap, true);
   
   return(INIT_SUCCEEDED);
}

void updateVwapIndicator(long volume, double high, double low, double close, datetime currentTime)
{
   /*
   if (currentTime == "21:00")
   {
      recalculation at current bar, wipe old cumuVol and cumuPV and continue with calculation
   }
   */
   
   // Computes the current cumulative PV
   double currentPV = computePV(volume, high, low, close);
   addToCumuPV(currentPV);
   
   // Computes the current cumulative Volume
   addToCumuVol(volume);
   
   // Computes the current vwap
   double currentVwap = calculateVWAP();
   
   // Adds the current vwap to the array of historic vwaps to be displayed on the main chart
   addDouble(currentVwap, &vwap);
}

// Computes the price-volume for any time period.
private double computePV(long volume, double high, double low, double close)
{
   double avgPrice = (high + low + close) / 3.0;
   double pv = avgPrice * volume;
   
   return pv;
}

// Adds the current PV to the cumulative PV
private addToCumuPV(double myPV)
{
   cumuPV = cumuPV + myPV;
}

// Adds the current Volume to the cumulative Volume
private addToCumuVol(double myVol)
{
   cumuVol = cumuVol + myVol;
}

// Calculates the current Vwap based on the cumulative PV and cumulative Volume
private double calculateVWAP()
{
   return NormalizeDouble(cumuPV / cumuVol, 5);
}


// Inserts current Vwap to the array of historic vwap values.
private addToVwap(double myVwap)
{
   if (ArraySize(vwap) == 0)
   {
      vwap[0] = myVwap;
   }
   else
   {
      addDouble(myVwap, &vwap);
   }
}



/* Helper Functions */

// Adds the double to the first element of the array
private addDouble(double value, double &array[])
{
   double tempArray[];
   ArrayResize(tempArray, ArraySize(array) + 1);
   
   // Copies all values from the tempArray to the &array, starting from array[1], leaving array[0] empty
   ArrayCopy(array, &tempArray, 1, 0, WHOLE_ARRAY);
   
   // Puts the input value in array[0]
   array[0] = value; // THIS IS GIVING PROBLEM??? WHAAA
   
   ArrayFree(tempArray);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function: Runs every tick             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{  
   updateVWAPIndicator(volume[0], high[0], low[0], close[0], time[0]);
   
   //return value of prev_calculated for next call
   return(rates_total);
}
