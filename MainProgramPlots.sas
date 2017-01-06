
* customer;
proc sgplot data=work.customerscounts;
	title 'New Customers per Year';
	series x = FirstPurchYear y = cum_freq;
run;

proc sgplot data=work.customerscounts;
	title 'New Customers per Year';
	series x = FirstPurchYear y = count;
run;


* plots for mom trends;
proc sgplot data=work.OrdersSummaryMonth;
	title 'Monthly Standard Toys Number of Orders';
	series x = OrderMonth y = _FREQ_;
run; 
proc sgplot data=work.OrdersSummaryMonth;
	title 'Monthly Standard Toys Total Revenue';
	series x = OrderMonth y = TotalOfTotals;
run; 
proc sgplot data=work.OrdersSummaryMonth;
	title 'Standard Order Summary Stats';
	series x = OrderMonth y = AvgOrderTotal;
	series x = OrderMonth y = MedOrderTotal;
	series x = OrderMonth y = ModOrderTotal;
run; 



* tall data for inventory bar chart;
data work.ProductInventoryAnalysis;
	set work.ProfitSummaryEnhanced (keep = ProductName TotProfit rename=(TotProfit = Measure));
	MeasureName = 'TotProfit ';
run;
proc append base=work.ProductInventoryAnalysis data=work.ProfitSummaryEnhanced (keep = ProductName AdjProfit rename=(AdjProfit = Measure));
run;
data work.ProductInventoryAnalysis;
	set work.ProductInventoryAnalysis;
	if MeasureName = '' then MeasureName = 'AdjProfit';
run;
proc sgplot data=work.InternationalByCountry;
	title 'Growth Trend in International Sales Revenue over 10 years';
	series x = OrderYear y = TotalOfTotals / group = CustomerCountry;
run;
proc sgplot data=work.InternationalByCountry;
	title 'Average Order Total Trend in International Sales over 10 years';
	series x = OrderYear y = AvgOrderTotal / group = CustomerCountry;
run;

proc sgplot data=ProductSummaryEnhanced;
	title 'Overall profitability of Individual Products';
	vbox TotProfit / category=ProductName;
run; 
proc sgplot data=ProductSummaryEnhanced;
	title 'Popularity of Individual Products';
	vbox _FREQ_ / category=ProductName;
run; 
proc sgplot data=ProductSummaryEnhanced;
	title 'Adjusted profitability of Individual Products';
	vbox AdjTotProfit1 / category=ProductName;
run; 
* measure 2 penalises bulkier products more heavily and is a more useful differentiator;
proc sgplot data=ProductSummaryEnhanced;
	title 'Adjusted profitability of Individual Products';
	vbox AdjTotProfit2 / category=ProductName;	
run; 
proc sgplot data=ProductSummaryEnhanced;
	title 'Popularity of Individual Products';
	vbox AdjTotProfit2 / category=ProductName;
run; 

proc sgplot data=AgeGroupSummaryEnhanced;
	title 'Overall profitability of Products Lines (Age Groups)';
	vbox TotProfit / category=AgeGroup;
run; 
proc sgplot data=AgeGroupSummaryEnhanced;
	title 'Popularity of Products Lines (Age Groups)';
	vbox _FREQ_ / category=AgeGroup;
run; 

proc sgplot data=CategorySummaryEnhanced;
	title 'Overall profitability of Products Categories';
	vbox TotProfit / category=Category;
run; 
proc sgplot data=CategorySummaryEnhanced;
	title 'Popularity of Products Categories';
	vbox _FREQ_ / category=Category;
run; 

proc sgplot data=SupplierSummaryEnhanced;
	title 'Overall profitability of Products Suppliers';
	vbox TotProfit / category=SupplierName;
run; 
proc sgplot data=SupplierSummaryEnhanced;
	title 'Popularity of Products Suppliers';
	vbox _FREQ_ / category=SupplierName;
run; 
