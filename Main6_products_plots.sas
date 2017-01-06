* call the style sheet for the red & black points;
ods html style=Styles.mystyle1;

* plots for product trends;
* pareto style profitability chart; 
proc sgplot data=work.ProfitSummaryEnhanced;
	title 'Total Profit per Product';
	series x = ProductName y = CumProfit;
	refline 450000;
	refline 'Ultra Deluxe Crayon Set' / axis = x;
	scatter x = ProductName y = TotProfit / 
		markerattrs=(symbol=squarefilled size=10px);
run;
* pareto style items sold chart; 
proc sgplot data=work.ItemSoldSummary;
	title 'Total Number Sold per Product';
	series x = ProductName y = CumNumSold;
	refline 36000;
	refline 'Dried Pea Wooden Rattle' / axis = x;
	scatter x = ProductName y = NumSold / 
		markerattrs=(symbol=squarefilled size=10px);
run;

* various pies for share of profits;
proc gchart data=work.ProductsReportingTable;
	title 'AgeGroup Share of Profit';
	pie AgeGroup / sumvar = Profit
				percent=outside;
run;
proc gchart data=work.ProductsReportingTable;
	title 'Category Share of Profit';
	pie Category / sumvar = Profit
				percent=outside;
run;
proc gchart data=work.ProductsReportingTable;
	title 'Supplier Share of Profit';
	pie SupplierName / sumvar = Profit
				percent=outside;
run;
* mosaic frequency plot of units sold;
proc format;
	value $category 'Baby_Teethers' = 'Baby Teethers'
					'Reach_&_Grab' = 'Reach & Grab'
					'Play_Environment' = 'Play Environment'
					'Early_Learning' = 'Early Learning';
run;
proc freq data=work.ProductsReportingTable;
tables Category * SupplierName / nofreq norow nocol chisq plots=all;
format Category $category.;
run;


* reset the title and default style;
title; 
ods html style=Styles.Default;
