packages <- c("XML", "tidyr", "dplyr", "vcdExtra")

for (p in packages) {
  if (!(require(p, character.only = TRUE))) {
    install.packages(p, dep=TRUE)
    require(p, character.only = TRUE)
  }
}

# set up of country list using web scraping
ctryCon <- url("https://www.countries-ofthe-world.com/countries-of-europe.html")
countryPage <- readLines(ctryCon)
countryTable <- readHTMLList(countryPage)
countriesOfEurope <- c(countryTable[[2]], countryTable[[3]], countryTable[[4]])
countriesOfEurope <- countriesOfEurope[sapply(countriesOfEurope, nchar) > 1]
countriesOfEurope[countriesOfEurope == "United Kingdom (UK)"] <- "United Kingdom" # inconsitent source

# currency lists
currCon = url("https://www.countries-ofthe-world.com/world-currencies.html")
currencyPage <- readLines(currCon)
currencyTable <- readHTMLTable(currencyPage)
currencyTable <- currencyTable[[1]]
currenciesOfEurope <- currencyTable$Currency[match(countriesOfEurope, as.character(currencyTable$`Country or territory`))]
currencyCodesOfEurope <- currencyTable$`ISO-4217`[match(countriesOfEurope, as.character(currencyTable$`Country or territory`))]
countriesOfEurope[countriesOfEurope == "United Kingdom (UK)"] <- "United Kingdom" # inconsitent source

# exchange rates
frxCon <- url("http://www.xe.com/currencytables/?from=USD")
frxPage <-  readLines(frxCon)
frxTable <- readHTMLTable(frxPage)
frxTable <- frxTable[[1]]
names(frxTable)[1] <- "currCode" # tidy a nasty HTML artefact
toDollarRate <- frxTable$`Units per USD`[match(currencyCodesOfEurope, frxTable$currCode)]
fromDollarRate <- frxTable$`USD per Unit`[match(currencyCodesOfEurope, frxTable$currCode)]

countriesOfEuropeData <- data.frame(countryName = countriesOfEurope
                                    , currencyName = currenciesOfEurope
                                    , currencyCode = currencyCodesOfEurope
                                    , toDollarRate, fromDollarRate)

# set up of everything else
set.seed(2007)
sales.years <- 2007:2016
n.years <- length(sales.years)
n.months <- 12
n.periods <- n.years * n.months

yoy.growth <- 0.05 + rnorm(length(sales.years))/40 + c(-0.01, -0.005
                                                       , 0, 0
                                                       , 0, 0.01
                                                       , 0.02, 0.02
                                                       , 0.03, 0.035)

target.orders.2016 <- 1140
target.revenue.2016 <- 310000

yoy.revenue <-  
  round(target.revenue.2016 * rev(
    cumprod(1/(1 + yoy.growth))))

yoy.orders <-
  round(target.orders.2016 * rev(
    cumprod(1/(1 + yoy.growth))))

sales.months <- 1:12
monthly.trend <- c(1, 1.05, 2, 1.4, 1.1, 1.1, 2, 1.4, 1, 1, 1.4, 2.25)
monthly.trend <- monthly.trend / sum(monthly.trend)


sales.grid <- expand.grid(sales.months, sales.years)

all.monthly.sales <- round(
  rep(yoy.revenue, each = n.months) * 
  (
    rep(monthly.trend, n.years) * 
    rnorm(n.periods, mean = 1, sd = 0.2)
  )
)

all.monthly.orders <- round(
  rep(yoy.orders, each = n.months) * 
    (
      rep(monthly.trend, n.years) * 
        rnorm(n.periods, mean = 1, sd = 0.1)
    )
)

sales.grid <- cbind(sales.grid, all.monthly.orders, all.monthly.sales)
names(sales.grid) <- c("month", "year", "orders", "sales")

product.table <- read.csv("C:\\Users\\Julian\\OneDrive\\Documents\\BCU\\Business Intelligence\\Clara Toys Assignment\\Product.csv")

product.table$cost <- as.numeric(separate(
  data = product.table
  , col = cost
  , into = c("pound", "cost")
  , sep = 2)$cost)

product.table$price <- as.numeric(separate(
  data = product.table
  , col = price
  , into = c("pound", "price")
  , sep = 2)$price)

product.table$margin <- as.numeric(separate(
  data = product.table
  , col = margin
  , into = c("margin", "pc")
  , sep = -2)$margin)

names(product.table)[1] <- "id"

product.weights <- c(2, 3, 1, 5, 1
                     , 2, 2, 5, 6, 4
                     , 7, 6, 5, 4, 1
                     , 4, 4, 3, 1, 2)
product.weights <- product.weights / sum(product.weights)

orders <- expand.dft(sales.grid[, 1:3], freq = "orders")
orders$order <- as.numeric(row.names(orders))
prod <- product.table[sample(product.table$id
                             , size = nrow(orders)
                             , prob = product.weights
                             , replace = TRUE), c("id", "price")]

orders <- data.frame(orders, prod)

sales.generator <- tapply(orders$price
       , list(orders$year
              , orders$month)
              , sum)

sales.history <- matrix(sales.grid$sales, nrow = 10, ncol = 12, byrow = TRUE)

while(any(sales.history > sales.generator)) {
  incomplete.sales <- which(t(sales.history > sales.generator))
  prod <- product.table[sample(product.table$id
                               , size = length(incomplete.sales)
                               , prob = product.weights
                               , replace = TRUE), c("id", "price")]
  
  add.to.orders <- sapply(incomplete.sales, function(x) {
    yr <- sales.grid[x, "year"]
    mn <- sales.grid[x, "month"]
    odr <- sample(orders[orders$year == yr &
                           orders$month == mn, "order"]
                  , size = 1)
    c(month = mn
               , year = yr
               , order = odr)
  })
  
  add.to.orders <- t(add.to.orders)
  add.to.orders <- data.frame(add.to.orders, prod)
  orders <- rbind(orders, add.to.orders)
  
  sales.generator <- tapply(orders$price
                            , list(orders$year
                                   , orders$month)
                            , sum)
}

for (i in 1:n.years) {
  for( j in 1:n.months) {
    n.orders <- sales.grid[sales.grid$year == sales.years[i] &
                             sales.grid$month == j, "orders"]
    if (i == 1 & j == 1) {
      cust <- 1:n.orders
      orders.count <- n.orders
    } else {
      repeat.cust <- sample(cust
                            , size = length(cust) * runif(1, max = 0.0033))
      repeat.cust <- sapply(repeat.cust
                            , function(x) {
                              if(length(which(cust == x)) > 2) {
                                if(rbinom(1, size = 1, p = 0.35) == 1) {
                                  x
                                } else { NA }
                              } else { x }
                            })
      if (length(repeat.cust) == 0) { repeat.cust <- numeric(0) }
      repeat.cust <- repeat.cust[!(is.na(repeat.cust))]
      this.month.cust <- c(repeat.cust, max(cust) + 1:(n.orders - length(repeat.cust)))
      cust <- c(cust, this.month.cust)
      orders.count <- orders.count + n.orders
    }
  }
}

source <- sapply(1:n.periods, function(x) {
  
  weights <- c(max(1:n.periods) - x
               , quantile(1:n.periods, (n.periods - x)/n.periods) + x/5
               , max(1:n.periods) + x)
  weights <- weights / sum(weights)
  src <- sample(3
                 , size = sales.grid$orders[x]
                 , prob = weights
                 , replace = TRUE)
  src
})

order.items <- orders
orders <- unique(order.items[, c("order", "year", "month")])
row.names(orders) <- as.character(seq_along(orders$order))
orders <- rename(orders, id = order)
orders$total <- as.vector(tapply(order.items$price, order.items$order, sum))
orders$cust <- cust[orders$id]
orders$source <- unlist(source)

order.items <- rename(order.items, productid = id)

customers <- list()
customers$id <- sort(unique(cust))
customers$firstOrderYear <- sapply(customers$id
              , function(x) {
              first((orders[orders$cust == x
                            , "year"]))
                })
customers$firstOrderMonth <- sapply(customers$id
                                   , function(x) {
                                     first((orders[orders$cust == x
                                                   , "month"]))
                                   })
n.custPerYear <- tapply(customers$id, customers$firstOrderYear, length)
otherCountryProb <- seq(0.95, 0.8, length.out = n.years)

country <- unlist(sapply(1:n.years, function(x) {
  
  ctry <- ifelse(rbinom(n.custPerYear[x], size = 1, prob = otherCountryProb[x]) == 1
                 , "United Kingdom", "Other")
  ctry
  }))

n.otherCountry <- length(country[country == "Other"])
countryProbs <- rep(1, length(countriesOfEuropeData$countryName))
specialCountries <- sum(seq_along(countryProbs) %% 8 == 0)
countryProbs[seq_along(countryProbs) %% 8 == 0] <- sample(2000, size = specialCountries)
countryProbs <- countryProbs / sum(countryProbs)
country[country == "Other"] <- sample(as.vector(countriesOfEuropeData$countryName)
                                      , size = n.otherCountry
                                      , prob = countryProbs
                                      , replace = TRUE)
customers$name <- paste0("cust", customers$id)
customers$address <- "XXX XXXXX XXXX XXX"
customers$country <- country
customers$email <- paste0("customer", customers$id, "@hotmail.com")
customers$tel <- "555-5555"

customers <- as.data.frame(customers)

custMailing <- sample(nrow(customers)
                     , size = nrow(customers) * 0.66)
mailinglist <- list()
mailinglist$email <- c(paste0("cust", customers$id[custMailing], "@hotmail.com")
                 , paste0("recipient", (1:12000), "@hotmail.com"))
yearSubscribed <- sample(sales.years
                          , length(custMailing) + 12000
                          , replace = TRUE
                          , prob = (1:10/sum(1:10)))
monthSubscribed <- sample(1:12
                          , length(custMailing) + 12000
                          , replace = TRUE
                          , prob = monthly.trend)
mailinglist$dateSubscribed <- paste("01"
                                    , ifelse(monthSubscribed < 10
                                             , paste0("0", monthSubscribed)
                                             , monthSubscribed)
                                    , yearSubscribed, sep = "/")
mailinglist <- as.data.frame(mailinglist)

write.table(orders
          , sep=","
          , quote = FALSE
          , file = "C:\\Users\\Julian\\OneDrive\\Documents\\BCU\\Business Intelligence\\Clara Toys Assignment\\Orders.csv"
          , row.names = FALSE
          , col.names = FALSE)

write.table(order.items
          , sep=","
          , quote = FALSE
          , file = "C:\\Users\\Julian\\OneDrive\\Documents\\BCU\\Business Intelligence\\Clara Toys Assignment\\OrderItems.csv"
          , row.names = FALSE
          , col.names = FALSE)

write.table(customers
          , sep=","          
          , quote = FALSE
          , file = "C:\\Users\\Julian\\OneDrive\\Documents\\BCU\\Business Intelligence\\Clara Toys Assignment\\Customers.csv"
          , row.names = FALSE
          , col.names = FALSE)

write.table(mailinglist
            , sep=","          
            , quote = FALSE
            , file = "C:\\Users\\Julian\\OneDrive\\Documents\\BCU\\Business Intelligence\\Clara Toys Assignment\\Mailinglist.csv"
            , row.names = FALSE
            , col.names = FALSE)
