* loads data created in R simulation (and exported as csv) into work library;

libname clara "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment";

* data created in R simulations as .csv files;
data work.Customers;
	length name $ 8 address $ 18 country $ 23 email $ 30 tel $ 8;
	infile "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment\Customers.csv" dlm=",";
	input id firstOrderYear firstOrderMonth name $ address $ country $ email $ tel $;
	drop firstOrderYear firstOrderMonth address tel;
data work.OrderItems;
	infile "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment\OrderItems.csv" dlm=",";
	input month year order productid price;
data work.Orders;
	infile "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment\Orders.csv" dlm=",";
	input id year month total cust source;
data work.Mailinglist;
	informat dateSubscribed DDMMYY10.;
	length email $ 30;
	infile "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment\MailingList.csv" dlm=",";
	input email $ dateSubscribed;
	format dateSubscribed DDMMYY10.;
run;

libname clara clear;
