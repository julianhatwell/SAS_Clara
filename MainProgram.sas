
* enhance customers with first and latest order dates;
proc sort data=work.orders;
	by cust;
run;
data work.customersenhanced (drop=year month purchdate);
	merge work.customers (in=c rename=(id=cust))
		work.orders (in=o drop=id total source);
	by cust;
	PurchDate = mdy(month, 1, year);
	* initialise;
	if first.cust then do;
		FirstPurch = PurchDate;
		FirstPurchYear = year(FirstPurch);
		LastPurch = .;
	end;
	* accumulate;
		* do nothing here;
	* complete;
	if last.cust then do;
		LastPurch = PurchDate;
		LastPurchYear = year(LastPurch);
		output;
	end;
	retain FirstPurch FirstPurchYear LastPurch LastPurchYear Frequency;
	format FirstPurch LastPurch DATE9.;
run;
* clean up;
proc sort data=work.orders;
	by id;
run;
data work.customersenhanced;
	set work.customersenhanced;
	Recency = 2016 - LastPurchYear;
run;
* get order totals per customer;
proc means data=work.orders nway nonobs noprint;
	class cust;
	var total;
	output out=work.customersvalue
			mean = AvgOrder
			sum = Value;
run;
data work.customersenhanced;
	merge work.customersenhanced (in=ce)
		work.customersvalue (in=cv drop=_TYPE_ rename=(_FREQ_=Frequency));
		by cust;
run;

proc freq data=customersenhanced noprint;
	*tables Frequency*FirstPurchYear / norow nocol out=work.customerscounts;
	tables FirstPurchYear / outcum norow nocol out=work.customerscounts;
run;


* mailing list;
data mailinglistenhanced;
	merge work.mailinglist (in = ml)
			work.customersenhanced (in = cu keep = email FirstPurch LastPurch);
	format dateSubscribed DATE9.;
	if (intck('MONTH', dateSubscribed, LastPurch) ge 1) and (intck('MONTH', dateSubscribed, LastPurch) le 12) then converted = 12;
	if (intck('MONTH', dateSubscribed, LastPurch) ge 1) and (intck('MONTH', dateSubscribed, LastPurch) le 9) then converted = 9;
	if (intck('MONTH', dateSubscribed, LastPurch) ge 1) and (intck('MONTH', dateSubscribed, LastPurch) le 6) then converted = 6;
	if (intck('MONTH', dateSubscribed, LastPurch) ge 1) and (intck('MONTH', dateSubscribed, LastPurch) le 3) then converted = 3;
run;

proc sql;
	title 'Handmade Product Orders Table';
	create table work.HandmadeOrdersTable AS
	SELECT hmo.year AS OrderYear, hmo.month AS OrderMonth, hmo.qty AS OrderQuantity
	, hmo.lineprice AS OrderTotal, hmo.customerId AS Customer
	, hm.name AS ProductName, hm.purchqty AS OriginalStockQty, hm.purchdate AS OriginalPurchDate
	, m.name AS MakerName, m.town AS MakerCity, m.County AS MakerCounty
	FROM
	work.HandmadeOrders hmo
	RIGHT OUTER JOIN work.Handmade hm
	ON hmo.specialProductId = hm.id
	INNER JOIN work.Maker m
	ON hm.seller = m.id;
quit;

data work.ProfitSummaryEnhanced;
	set work.ProfitSummary;
	TotProfit = TotProdSales - TotProdCosts;
	UnitInvCost = TotInvCost / _FREQ_;
	AdjTotProfit1 = TotProfit - TotInvCost;
	AdjTotProfit2 = TotProfit / UnitInvCost;
	AdjProfit = (AdjTotProfit1 + AdjTotProfit2)/2;
	format TotProfit NLMNLGBP10.2;
run;


* Products ordered totals and summaries year on year;
proc means data=work.ProductsReportingTable nway nonobs noprint;
	title 'Products Ordered By Year';
	var ProductPrice ProductCost InventoryCost;
	class OrderYear ProductName;
	output out=work.ProductSummary 
		sum=TotProdSales TotProdCosts TotInvCost;
run;
data work.ProductSummaryEnhanced;
	set work.ProductSummary;
	TotProfit = TotProdSales - TotProdCosts;
	UnitInvCost = TotInvCost / _FREQ_;
	AdjTotProfit1 = TotProfit - TotInvCost;
	AdjTotProfit2 = TotProfit / UnitInvCost;
	format TotProfit AdjTotProfit1 AdjTotProfit2 NLMNLGBP10.2;
run;

* Product Lines (Age Group) ;
proc means data=work.ProductsReportingTable nway nonobs noprint;
	title 'Products Lines Ordered By Year';
	var ProductPrice ProductCost;
	class OrderYear AgeGroup;
	output out=work.AgeGroupSummary 
		sum=TotProdSales TotProdCosts;
run;
data work.AgeGroupSummaryEnhanced;
	set work.AgeGroupSummary;
	TotProfit = TotProdSales - TotProdCosts;
	format TotProfit NLMNLGBP10.2;
run;

* Product Categories ;
proc means data=work.ProductsReportingTable nway nonobs noprint;
	title 'Products Categories Ordered By Year';
	var ProductPrice ProductCost;
	class OrderYear Category;
	output out=work.CategorySummary 
		sum=TotProdSales TotProdCosts;
run;
data work.CategorySummaryEnhanced;
	set work.CategorySummary;
	TotProfit = TotProdSales - TotProdCosts;
	format TotProfit NLMNLGBP10.2;
run;

* Product Suppliers ;
proc means data=work.ProductsReportingTable nway nonobs noprint;
	title 'Products (Suppliers) Ordered By Year';
	var ProductPrice ProductCost;
	class OrderYear SupplierName;
	output out=work.SupplierSummary 
		sum=TotProdSales TotProdCosts;
run;
data work.SupplierSummaryEnhanced;
	set work.SupplierSummary;
	TotProfit = TotProdSales - TotProdCosts;
	format TotProfit NLMNLGBP10.2;
run;
