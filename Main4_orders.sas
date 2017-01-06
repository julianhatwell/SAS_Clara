* data from combining and summarising data sets that are already loaded;

title; * clear from any previous runs;

* master table for denormalised Orders data ;
* proc sql has been used to reflect the origin of this data in a relational database ;
proc sql;
	create table work.OrdersReportingTable AS
	SELECT o.id AS OrderId, o.year AS OrderYear, o.month AS OrderMonth
	, o.total AS OrderTotal, log(o.total) AS LogOrderTotal, c.id AS CustomerId
	, c.country AS CustomerCountry, os.name AS OrderSource
	FROM work.Orders o
	INNER JOIN work.Customers c
	ON o.cust = c.id
	INNER JOIN work.OrderSource os
	ON o.source = os.id;
quit;

proc print data=work.OrdersReportingTable (obs=6);
format OrderTotal NLMNLGBP30.2;
title 'Orders Reporting Table';
run;

* Order totals and summaries year on year;
proc means data=work.OrdersReportingTable nway nonobs noprint;
	var OrderTotal LogOrderTotal;
	class OrderYear;
	output out=work.OrdersSummaryYear 
		mean=AvgOrderTotal AvgLogOrderTotal
		median=MedOrderTotal MedLogOrderTotal
		mode=ModOrderTotal ModLogOrderTotal
		min=MinOrderTotal MinLogOrderTotal
		max=MaxOrderTotal MaxLogOrderTotal
		sum=TotalOfTotals;
run;
* calculate YoY if revenue growth is greater or less than last year;
data work.OrdersSummaryYear;
	set work.OrdersSummaryYear;
	TotalLY = lag(TotalofTotals);
	GrowthAmount = TotalOfTotals - TotalLY;
	if GrowthAmount > 0 then vs_LY_Revenue = "Increase";
	if GrowthAmount <= 0 then vs_LY_Revenue = "Decrease";
	YoY = (TotalOfTotals / TotalLY) - 1;
	format YoY PERCENT. 
			AvgOrderTotal MedOrderTotal
			ModOrderTotal MinOrderTotal 
			MaxOrderTotal TotalOFTotals
			TotalLY GrowthAmount NLMNLGBP30.2;
run;

* Seasonal Trends month on month;
proc means data=work.OrdersReportingTable nway nonobs noprint;
	var OrderTotal;
	class OrderMonth;
	output out=work.OrdersSummaryMonth 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;

* Full Time Series Trend;
proc means data=work.OrdersReportingTable nway nonobs noprint;
	var OrderTotal;
	class OrderYear OrderMonth;
	output out=work.OrdersSummaryFullTrend 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;

title; *clear title;
