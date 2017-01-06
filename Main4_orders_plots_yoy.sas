* call the style sheet for the red & black points;
ods html style=Styles.mystyle1;

* plots for yoy trends;
proc sgplot data=work.OrdersSummaryYear;
	title 'Standard Toys';
	title2 'Total Annual Revenue';
	series x = OrderYear y = TotalOfTotals;
	scatter x = OrderYear y = TotalOfTotals / group = vs_LY_Revenue;
	yaxis label='Total Revenue from Orders';
	refline 2011 / axis=x lineattrs=(pattern=LongDash) label = 'Unprecedented growth surge';
run; 
proc sgplot data=work.OrdersSummaryYear;
	title 'Standard Toys';
	title2 'Number of Orders each year';
	series x = OrderYear y = _FREQ_;
	scatter x = OrderYear y = _FREQ_ / group = vs_LY_Revenue;
	yaxis label='Number of Orders';
run; 
proc sgplot data=work.OrdersSummaryYear;
	title 'Standard Toys';
	title2 'Annual Revenue Year over Year';
	series x = OrderYear y = YoY;
	scatter x = OrderYear y = YoY / group = vs_LY_Revenue;
	yaxis label='Year Over Year';
	refline 2013 / axis=x lineattrs=(pattern=LongDash) label = 'Beginning of stable growth';
run; 

* call the style sheet for the blue lines;
ods html style=Styles.mystyle2;

* plots for summary stats order totals;
proc sgplot data=work.OrdersSummaryYear;
	title 'Standard Toys';
	title2 'Order Total Summary Stats Yearly Trend';
	series x = OrderYear y = AvgOrderTotal;
	series x = OrderYear y = MedOrderTotal;
	series x = OrderYear y = ModOrderTotal;
	yaxis label='Mean, Median and Mode Order Totals';
run; 

proc sgplot data=work.OrdersSummaryYear;
	title 'Standard Toys';
	title2 'Order Total Summary Stats Yearly Trend';
	series x = OrderYear y = AvgLogOrderTotal;
	series x = OrderYear y = MedLogOrderTotal;
	series x = OrderYear y = ModLogOrderTotal;
	refline 2011 / axis=x lineattrs=(pattern=LongDash) label = 'Modest uplift on median/mean';
	yaxis grid offsetmin=0.05 offsetmax=0.1
         values=(3.0 3.4 4.2 4.5 5.0 5.5)
         valuesdisplay = (" " "GBP30" "GBP60" "GBP90" "GBP150" "GBP250")
	label='exp (Mean, Median and Mode log(Order Totals))';
run; 

* call the style sheet for the histogram with norm and kern;
ods html style=Styles.mystyle1;

* histograms of order totals with density functions;
proc sgplot data=work.OrdersReportingTable;
	title 'Standard Toys';
	title2 'Distribution of order totals - All years';
	histogram ordertotal;
	density ordertotal;
	density ordertotal / type=kernel;
run;

proc sgplot data=work.OrdersReportingTable;
	title 'Standard Toys';
	title2 'Distribution of log(order totals) - All years';
	histogram logordertotal;
	density logordertotal;
	density logordertotal / type=kernel;
run;

* reset the title and default style;
title;
ods html style=Styles.Default;
