options(repos=structure(c(CRAN="http://cran.rstudio.com")))
options(shiny.trace=TRUE)
library(Quandl)
library(plotly)
library(dplyr)

if (!("shiny" %in% names(installed.packages()[,"Package"]))) {install.packages("shiny")}
suppressMessages(library(shiny, quietly = TRUE))

if (!("openintro" %in% names(installed.packages()[,"Package"]))) {install.packages("openintro")}
suppressMessages(library(openintro, quietly = TRUE))

if (!("plotrix" %in% names(installed.packages()[,"Package"]))) {install.packages("plotrix")}
suppressMessages(library(plotrix, quietly = TRUE))



Quandl.api_key("YOUR_KEY_HERE")
findata <- Quandl.datatable("SHARADAR/SEP")
fintickerdata <- subset(findata, select = c("ticker"))
finuniquetickerdata <- unique(fintickerdata)
rownames(finuniquetickerdata) <- 1:nrow(finuniquetickerdata)

shinyServer(function(input, output) {
  
	#data handler based on user input$type
	myshittydata <- reactive({
		 a <- subset(findata, ticker == input$type, select = c("ticker", "date" , "open", "high", "low", "close", "volume", "dividends"))
		 a <- droplevels(a)
		 return(a)

	})
	 
	myshittydivision <- reactive({
		b <- subset(findata, ticker == input$type, select = c("ticker", "date" , "open", "high", "low", "close", "volume", "dividends"))
		b <- droplevels(b)
		prices <- subset(b, select=c("close"))
		prices_offset <- subset(b[-1,], select=c("close"))
		prices_v2 <- subset(b[-82,], select=c("close"))
		division <- log(prices_offset/prices_v2)
		return(division)
	 })
		 
	myshittyprediction <- reactive({
		dateandclose <- subset(findata, ticker == input$type, select = c("date" , "close"))
		rownames(dateandclose) <- 1:nrow(dateandclose)
		dateandclose <- arrange(dateandclose, -row_number())
		
		# here i need the value of the stock price at the end of the first day
		# i also need the value of my shittydivision
		mean <- sapply(myshittydivision(), mean,  na.rm=TRUE)			
		ximinusxbar <- (myshittydivision()-mean)^2
		sumofximinusxbar <- colSums(ximinusxbar)		
		varianceofdivision <- sumofximinusxbar/80		
		sigma <- mean/81+.5*(varianceofdivision)		
		functionvalues <- dateandclose[1,'close']*exp(sigma*as.numeric(rownames(dateandclose)))
		predictedandobservedvalues <- cbind(dateandclose,functionvalues)
		return(predictedandobservedvalues)
		# functionvaluesannualized <- dateandclose[1,'close']*exp(-0.1965505 *as.numeric(rownames(dateandclose))/252)
		# predictedandobservedvalues2 <- cbind(dateandclose,functionvaluesannualized)
	 })
	 
	 
	 myshittypredictionannualized <- reactive({
		dateandclose <- subset(findata, ticker == input$type, select = c("date" , "close"))
		rownames(dateandclose) <- 1:nrow(dateandclose)
		dateandclose <- arrange(dateandclose, -row_number())
		
		# here i need the value of the stock price at the end of the first day
		# i also need the value of my shittydivision
		mean <- sapply(myshittydivision(), mean,  na.rm=TRUE)			
		ximinusxbar <- (myshittydivision()-mean)^2
		sumofximinusxbar <- colSums(ximinusxbar)		
		varianceofdivision <- sumofximinusxbar/80		
		sigma <- (mean+.5*(varianceofdivision))*(252)		
		functionvalues <- dateandclose[1,'close']*exp(sigma*as.numeric(rownames(dateandclose))/252)
		predictedandobservedvalues <- cbind(dateandclose,functionvalues)
		return(predictedandobservedvalues)
		# functionvaluesannualized <- dateandclose[1,'close']*exp(-0.1965505 *as.numeric(rownames(dateandclose))/252)
		# predictedandobservedvalues2 <- cbind(dateandclose,functionvaluesannualized)
	 })

  
  output$describedata <- renderPrint({	  
		summary(myshittydata())
	 })
	 
	output$describeticker <- renderPrint({	  
		finuniquetickerdata
	 })
	
	
	output$logdivision <- renderPrint({	  
		division
	 })
	 
	 output$describedivision<- renderPrint({	  
		summary(division)
	 })
	 
	 
	 #here we need to calculate (1/N-1)SUM(1 to n)(xi-xbar)^2
	  output$divisionmean<- renderPrint({	  
		mean <- sapply(myshittydivision(), mean,  na.rm=TRUE)	
		#here we need to calculate (1/N-1)SUM(1 to n)(xi-xbar)^2
		# here i believe we should use 80. we started with 82 observations lost one to offset. so we end with 81 and n-1 is 80
		ximinusxbar <- (myshittydivision()-mean)^2
		sumofximinusxbar <- colSums(ximinusxbar)		
		varianceofdivision <- sumofximinusxbar/80		
		sigma <- mean/81+.5*(varianceofdivision)
		sigma
		# ximinusxbar <- (division-mean)^2
		# sumofximinusxbar <- colSums(ximinusxbar)		
		# varianceofdivision <- sumofximinusxbar/80
		# annualizedvariance <- varianceofdivision*252
		# sigma <- mean*252+.5*(annualizedvariance)
		# sigma
		
	 })
	 
	 output$divisionmeanannualized<- renderPrint({	  	
		# here i believe we should use 80. we started with 82 observations lost one to offset. so we end with 81 and n-1 is 80
		# ximinusxbar <- (division-mean)^2
		# sumofximinusxbar <- colSums(ximinusxbar)		
		# varianceofdivision <- sumofximinusxbar/80		
		# sigma <- mean/81+.5*(varianceofdivision)
		# sigma
		mean <- sapply(myshittydivision(), mean,  na.rm=TRUE)	
		ximinusxbar <- (myshittydivision()-mean)^2
		sumofximinusxbar <- colSums(ximinusxbar)		
		varianceofdivision <- sumofximinusxbar/80
		annualizedvariance <- varianceofdivision*252
		sigma <- mean*252+.5*(annualizedvariance)
		sigma
		
	 })
	
	 output$divisionvar<- renderPrint({	  
		variance <-sapply(division, var,  na.rm=TRUE)
		logvariance <- variance/81
		logvariance
	 })
	
	
	output$fincandle <- renderPlotly({
	
		i <- list(line = list(color = '#003f5c'))
		d <- list(line = list(color = '#bc5090'))
		p <- plot_ly(x = myshittydata()$date, type="candlestick",
          open = myshittydata()$open, close = myshittydata()$close,
          high = myshittydata()$high, low = myshittydata()$low,
          increasing = i, decreasing = d)	 %>%
			layout(
				title = input$type
				
				)
		
	
	})
	
	
	output$endofdaygraph<- renderPlot({	  
	
		# ggplot(data = finpartialdata, mapping = aes(x = date, y = close)) + geom_point() + geom_line() 
		ggplot() + 
		  geom_line(data = myshittyprediction(), aes(x = date, y = close), color = "#003f5c") + geom_point(data= myshittyprediction(), aes(x=date, y=close)) +
		  geom_line(data =  myshittyprediction(), aes(x = date, y = functionvalues), color = "#bc5090") + geom_point(data= myshittyprediction(), aes(x=date, y=functionvalues)) +
		  geom_line(data =  myshittypredictionannualized(), aes(x = date, y = functionvalues), color = "#bc5090") + geom_point(data= myshittypredictionannualized(), aes(x=date, y=functionvalues)) +
		  xlab('Date') +
		  ylab('Close')
	  
		
	  
	 })
  
   
 
})
