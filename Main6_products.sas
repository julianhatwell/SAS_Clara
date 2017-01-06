* Master table for denormalised product data, including when ordered;
title; *clear any previous title;

* proc sql has been used to reflect the origin of this data in a relational database ;
proc sql;
	title 'Products Reporting Table';
	create table work.ProductsReportingTable AS
	SELECT oi.order AS OrderID, oi.year AS OrderYear, oi.month AS OrderMonth
	, p.id AS ProductId, p.name AS ProductName, p.cost AS ProductCost
	, p.price AS ProductPrice, p.margin AS ProductMargin, p.InventoryCost AS InventoryCost
	, ag.name AS AgeGroup, cg.name AS Category, og.name AS SupplierName
	, og.city AS SupplierCity, og.County AS SupplierCounty 
	FROM work.OrderItems oi
	INNER JOIN work.Product p
	ON oi.productid = p.id
	INNER JOIN work.Agegroup ag
	ON p.Agegroup = ag.id
	INNER JOIN work.Category cg
	ON p.Category = cg.id
	INNER JOIN work.Origin og
	ON p.origin = og.id;
quit;

* Products and profits summary;
proc means data=work.ProductsReportingTable nway nonobs noprint;
	title 'Products Ordered';
	var ProductPrice ProductCost InventoryCost;
	class ProductName;
	output out=work.ProfitSummary 
		sum=TotProdSales TotProdCosts TotInvCost;
run;
data work.ProfitSummaryEnhanced;
	set work.ProfitSummary;
	TotProfit = TotProdSales - TotProdCosts;
	format TotProfit NLMNLGBP10.2;
run;
proc sort data=work.ProfitSummaryEnhanced;
	by descending TotProfit;
run;
proc expand data=work.ProfitSummaryEnhanced out=work.ProfitSummaryEnhanced method=none;
	convert TotProfit = CumProfit / transout=(cusum);
	format TotProfit NLMNLGBP10.2;
run;

* sort and count by items sold;
proc sort data=work.ProfitSummaryEnhanced (keep=ProductName _FREQ_ rename=(_FREQ_ = NumSold)) out=work.ItemSoldSummary;
	by descending NumSold;
run;
proc expand data=work.ItemSoldSummary out=work.ItemSoldSummary method=none;
	convert NumSold = CumNumSold / transout=(cusum);
run;

data work.ProductsReportingTable;
	set work.ProductsReportingTable;
	Profit = ProductPrice - ProductCost;
	format Profit NLMNLGBP10.2;
run;
