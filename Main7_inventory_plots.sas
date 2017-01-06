* call the style sheet for the red & black points;
ods html style=Styles.mystyle1;

* inventory trend;
proc sgplot data=work.InventorySummaryEnhanced;
	title 'Inventory Requirments Trends';
	series x = TIME y = TotInvCost / transparency = 0.75;
	series x = TIME y = MovAveInvCost;
	series x = TIME y = MovMaxInvCost;
	xaxis label='Months since Jan 2007';
	yaxis label='Notional Inventory Cost: Total with Moving Ave and Max';
run; 

* reset the title and default style;
title;
ods html style=Styles.Default;
