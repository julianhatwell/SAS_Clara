proc print data=DomIntSummaryEnhanced (where = (OrderYear > 2010 AND OrderYear < 2014));
	var OrderYear TotalOfTotals TotalLY GrowthAmount vs_LY_Revenue YoY DomInt;
	format TotalOfTotals TotalLY GrowthAmount NLMNLGBP30.2;
run;

proc print data=work.ProductsReportingTable (drop=ProductId SupplierCity SupplierCounty obs=6);
run;

proc freq data=work.ProductsReportingTable;
tables Category * SupplierName / plots=all;
run;

proc print data=work.OrdersSummaryFullTrend (obs=10);
run;

