* customers;
title; * clear any previous title;

* formatting for the proc means print out;
proc template;
	edit base.summary;
		edit mean;
			format=NLMNLGBP30.2;
		end;
		edit median;
			format=NLMNLGBP30.2;
		end;
		edit mode;
			format=NLMNLGBP30.2;
		end;
		edit sum;
 			format=NLMNLGBP30.2;
		end;
		edit min;
 			format=NLMNLGBP30.2;
		end;
		edit max;
 			format=NLMNLGBP30.2;
 		end;
	end;
run;

* print the mean and sum by country ;
proc means data=work.OrdersReportingTable nway nonobs n mean sum;
	title 'Customer Orders Totals By Country';
	var OrderTotal;
	class CustomerCountry;
run;

* print the mean and sum by country and year and output a new dataset;
proc means data=work.OrdersReportingTable nway nonobs noprint;
	var OrderTotal;
	class OrderYear CustomerCountry;
	output out=work.CustomerSummary 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;

* process just the domestic (UK) customers ;
data work.DomesticCustomers;
	set work.OrdersReportingTable (where=(CustomerCountry EQ 'United Kingdom'));
run;
* data on domestic trends by channel;
proc means data=work.DomesticCustomers nway nonobs noprint;
	var OrderTotal;
	class OrderYear OrderSource;
	output out=work.SourceSummary 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;
data work.SourceSummary;
	set work.SourceSummary;
	format AvgOrderTotal MedOrderTotal
			ModOrderTotal MinOrderTotal 
			MaxOrderTotal TotalOFTotals
			TotalLY GrowthAmount NLMNLGBP30.2;
run;
* data on domestic customers;
proc means data=work.DomesticCustomers nway nonobs noprint;
	var OrderTotal;
	class OrderYear;
	output out=work.DomesticSummary 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;
data work.DomesticSummaryEnhanced;
	set work.DomesticSummary;
	length DomInt $ 13;
	DomInt = 'Domestic';
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

* process just the international customers ;
data work.InternationalCustomers;
	set work.OrdersReportingTable (where=(CustomerCountry NE 'United Kingdom'));
run;
proc means data=work.InternationalCustomers nway nonobs noprint;
	var OrderTotal;
	class OrderYear;
	output out=work.InternationalSummary 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;
data work.InternationalSummaryEnhanced;
	set work.InternationalSummary;
	length DomInt $ 13;
	DomInt = 'International';
	TotalLY = lag(TotalofTotals);
	GrowthAmount = TotalOfTotals - TotalLY;
	if GrowthAmount > 0 then vs_LY_Revenue = "Increase";
	if GrowthAmount <= 0 then vs_LY_Revenue = "Decrease";
	YoY = (TotalOfTotals / TotalLY) - 1;
	format YoY PERCENT.;
run;
data work.DomIntSummaryEnhanced;
	set DomesticSummaryEnhanced InternationalSummaryEnhanced;
run;

* data on trends by country;
proc means data=work.InternationalCustomers nway nonobs noprint;
	var OrderTotal;
	class OrderYear CustomerCountry;
	output out=work.InternationalByCountry 
		mean=AvgOrderTotal
		median=MedOrderTotal
		mode=ModOrderTotal
		min=MinOrderTotal
		max=MaxOrderTotal
		sum=TotalOfTotals;
run;
* let's ditch the countries with just a handful of orders;
* useful to report on trends for the top performing non-UK countries;
proc sort data = work.InternationalByCountry;
by CustomerCountry;
run;
* this narrow dataset just sums up the number of orders in each country;
proc means data=work.InternationalByCountry nway nonobs noprint;
	var _FREQ_;
	class CustomerCountry;
	output out=work.InternationalOrders
		sum=TotalOrders;
run;
* merge it back to the main table and only keep rows that have > 10 orders; 
data work.InternationalByCountry;
	merge work.InternationalByCountry (in = cty)
		work.InternationalOrders (in = ord
								where = (TotalOrders GT 10));
	by CustomerCountry ;
	if cty AND ord;
run;

* combine with Domestic orders and only use the first and latest years - for the pie chart;
data work.DomIntTotalsYears;
	set work.DomesticSummary;
	length DomInt $ 13;
	DomInt = 'Domestic';
	format TotalOfTotals NLMNLGBP30.2;
run;
proc append base=work.DomIntTotalsYears data=InternationalSummary;
run;
data work.DomIntTotalsYears;
	set work.DomIntTotalsYears (where=(OrderYear in (2007 2016)));
	if DomInt NE 'Domestic' then DomInt = 'International';
run;
