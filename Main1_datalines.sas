* sets up basic categories and keywords for the de-normalised data;

libname clara "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment";

* data created directly - categories and key words;
data work.Agegroup;
	input id name $;
	datalines;
1 Babies
2 Toddlers
3 Kiddies
;
data work.Category;
	length name $ 20;
	input id name $;
	datalines;
1	Baby_Teethers
2	Reach_&_Grab
3	Early_Learning
4	Activity
5	Play_Environment
6	Companion
;
data work.OrderSource;
	length name $ 10;
	input id name $;
	datalines;
1	mail_order
2	telephone
3	internet
;
run;

libname clara clear;
