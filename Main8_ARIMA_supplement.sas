title;
* call the style sheet for the red & black points;
ods html style=Styles.mystyle1;

data work.FullTrendForForecasting (drop=OrderMonth OrderYear TotalOfTotals);
	set work.OrdersSummaryFullTrend (keep=OrderMonth OrderYear TotalOfTotals);
	timeline = mdy(OrderMonth, 1, OrderYear);
	logOrderTotals = log(TotalOfTotals);
run;
proc print data=work.FullTrendForForecasting (obs=10);
run;

proc sgplot data=work.FullTrendForForecasting;
	series x=timeline y=logOrderTotals;
run;
proc sgplot data=work.OrdersSummaryMonth;
	series x=OrderMonth y=TotalOfTotals;
run;

proc arima data=work.FullTrendForForecasting;
	identify var=logOrderTotals(1,12) nlag=12;
run;
	estimate q=(1)(12) noconstant method=uls;
run;
	forecast out=b lead=24 id=timeline interval=month noprint;
quit;
data work.FullTrendForecast;
	set b;
	TotalOfTotals = exp(logOrderTotals);
	forecast = exp(forecast);
	if timeline GE MDY(1, 1, 2017) then	do;
			l95      = exp(l95);
			u95      = exp(u95);
		end;
	else do;
			l95      = .;
			u95      = .;
		end;
	format timeline YYMMN.;
run;
proc print data=work.FullTrendForecast (firstobs=100 obs=110);
run;

proc sgplot data=work.FullTrendForecast;
	band x=timeline upper=l95 lower=u95 / fillattrs=(color=cxFFCCFF);
	series x=timeline y=TotalOfTotals / lineattrs=(color=cx9900FF);
	scatter x=timeline y=TotalOfTotals / markerattrs=(symbol='circlefilled' color=cx9900FF);
	series x=timeline y=forecast / lineattrs=(pattern=ShortDash color=cxFF4444);
run;

* reset the title and default style;
title;
ods html style=Styles.Default;
