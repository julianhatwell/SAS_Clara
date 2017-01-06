* Create standard colour templates for a professional look;

proc template;
   define style styles.myStyle1;
   parent=styles.statistical;
      style graphdata1 /
          markersymbol='circlefilled'
          contrastcolor=red;
      style graphdata2 /
          markersymbol='circlefilled'
          contrastcolor=black;
   end;
run;

* Create standard colour templates for a professional look;

proc template;
	define style styles.myStyle2;
	parent=styles.statistical;
		style graphdata1 /
			linestyle=1
			contrastcolor=cx1B20FF;
      	style graphdata2 /
			linestyle=1
			contrastcolor=cx4B72FF;
		style graphdata3 /
			linestyle=1
			contrastcolor=cx7FA5F6;
	end;
run;

* Create standard colour templates for a professional look;

proc template;
	define style styles.myStyle3;
	parent=styles.statistical;
		style graphdata1 /
			markersymbol='circlefilled'
			color=cx1B20FF
			contrastcolor=cx1B20FF;
		style graphdata2 /
			markersymbol='circlefilled'
			color=cxBBAA33
			contrastcolor=cxBBAA33;
	end;
run;
