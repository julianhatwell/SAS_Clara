proc means data=work.ProductsReportingTable nway nonobs noprint;
	title 'Inventory By Year and Month';
	var InventoryCost;
	class OrderYear OrderMonth;
	output out=work.InventorySummary 
		sum=TotInvCost;
run;
proc expand data = work.InventorySummary out = work.InventorySummaryEnhanced;
	convert TotInvCost = MovAveInvCost / METHOD = none TRANSFORMOUT = (cmovave (1 2 3 4 5 6 7 8 9));
	convert TotInvCost = MovMaxInvCost / METHOD = none TRANSFORMOUT = (cmovmax 18);
run;
