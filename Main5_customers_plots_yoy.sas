* call the style sheet for the red & black points;
ods html style=Styles.mystyle3;

* plots for customer trends;
proc sgplot data=work.DomIntSummaryEnhanced;
   vbar OrderYear / response=TotalOfTotals group=DomInt groupdisplay=cluster;
   xaxis display=(nolabel novalues noticks);
   yaxis label='Total Revenue from Orders';
   keylegend / location=inside position=topleft across=1;
run;
proc sgplot data=work.DomIntSummaryEnhanced;
	title 'Growth Trend in Domestic vs International Sales over 10 years';
	series x = OrderYear y = YoY / group = DomInt;
	refline 0.1 / axis=y lineattrs=(pattern=LongDash) label = '10%';
	refline 0.2 / axis=y lineattrs=(pattern=LongDash) label = '20%';
run;

proc sgplot data=work.SourceSummary;
	title 'Trend in Sales Channel Revenue (Domestic Customers) over 10 years';
	series x = OrderYear y = TotalOfTotals / group = OrderSource;
run;
proc gchart data=work.DomIntTotalsYears;
	title 'Domestic and International Share of Revenue';
	pie Domint / sumvar = TotalOfTotals
				group = OrderYear
				across = 2
				percent=outside;
run;
quit;
* reset the title and default style;
title; 
ods html style=Styles.Default;
