* loads data created in JMP (and exported as SAS data sets) into work library; 

libname clara "C:\Users\Julian\OneDrive\Documents\BCU\Business Intelligence\Clara Toys Assignment";

* data created in JMP;
data work.Origin;
	set clara.Origin;
	drop address email tel;
data work.Product;
	set clara.Product;
	InventoryCost = .;
	IF (origin EQ 1) THEN InventoryCost = size;
	IF (origin NE 1) THEN InventoryCost = size * 2;
	drop size;
data work.Handmade;
	set clara.Handmade;
data work.HandmadeOrders;
	set clara.HandmadeOrders;
data work.Maker;
	set clara.Maker;

run;

libname clara clear;
