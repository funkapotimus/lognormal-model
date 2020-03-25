library(shiny)
library(plotly)
options(shiny.trace=TRUE)
options(shiny.fullstacktrace=TRUE)
# Define UI for OLS demo application
shinyUI(fluidPage(
  includeCSS("style.css"),
  #  Application title
  headerPanel("Sharadar Equity Prices or: How I learned how to love the lognormal model"),
  sidebarPanel(
  
  withMathJax(),
  helpText("This interactive app takes advantage of the Quandl API feed for Sharadar Equity Prices and returns a candlestick shaped graph for the selected data set. 
			This app also applies the lognormal distribution to the selected data set to model the stock price movement using the dates from 2018-09-04 to 2018-12-31 (T = 82).
			The range can be easily extended to allow real time data though this data is not accessible without purchasing a subscription to the Quandl API feed
			and is therefore not a part of this project. The purpose of this project is to gauge the accuracy of the lognormal model with a nondividend paying stock (not 
			all the stocks shown here have a \\(\\delta\\) = 0 but \\(\\delta\\) is close enough to zero and for the purposes of this project well assume so)
			The stocks in this data set are displayed below:"),
	

	 selectInput("type", "Select a stock:",
                 list(
						"Apple"="AAPL",	
						"American Express"="AXP",
						"Boeing"="BA",
						"Caterpillar Inc."="CAT",
						"Cisco Systems"="CSCO",
						"Chevron Corporation"="CVX",
						"DuPont"="DD",
						"The Walt Disney Company"="DIS",
						"General Electric"="GE",
						"Goldman Sachs"="GS",
						"The Home Depot"="HD",
						"IBM"="IBM",
						"Intel"="INTC",
						"Johnson & Johnson"="JNJ",
						"JPMorgan Chase"="JPM",
						"The Coca-Cola Company"="KO",
						"McDonald's"="MCD",
						"3M"="MMM",
						"Merck & Co."="MRK",
						"Microsoft"="MSFT",
						"Nike"="NKE",
						"Pfizer"="PFE",
						"Procter & Gamble" = "PG",
						"The Travelers Companies" = "TRV",
						"Tesla" = "TSLA",
						"UnitedHealth Group" = "UNH",
						"United Technologies" = "UTX",
						"Visa" = "V",
						"Verizon" = "VZ",
						"Walmart" = "WMT",
						"Exxon"	= "XOM"			  
					  )),

					  
	# verbatimTextOutput("describeticker"),	
	withMathJax(),
	helpText('We must first determine the parameters of the lognormal distribution. Using the stock prices {\\(S_{0}\\),\\(S_{1}\\),...,\\(S_{n}\\)}
				we calculate \\(X_i\\): $$X_i= \\ln \\left(\\frac{S_{i}}{S_{i-1}}\\right)$$'),
	helpText('Solving for \\(m\\): $$m = \\sum_{i=1}^n \\frac{X_i}{n}$$'),
	helpText('Solving for \\(v^2\\): $$v^2 = \\sum_{i=1}^n \\frac{(X_i-m)^2}{n-1}$$'),
	helpText('$$v^2 = \\sigma^2h$$'),
	helpText('Then \\(\\alpha\\): $$m=(\\alpha-\\delta-\\frac{1}{2}\\sigma^2)h$$'),
	helpText('Since \\(\\delta\\)=0: $$m=(\\alpha-\\frac{1}{2}\\sigma^2)h$$'),
	helpText('Solving for \\(\\alpha\\): $$\\alpha=\\frac{m}{h} + \\frac{1}{2}\\sigma^2$$'),
	
	helpText('The expectation of the stock price at time \\(T\\): $$E(S_T)= S_0e^{\\alpha T} $$'),
	
	
	HTML("<div style='color:red;'><strong>
	known bugs<br/>
	here i am not sure how to carry out the computation. Using h = 81 we obtain alpha equal the first value on the right. 
	This represents the daily volatility. However this does not seem correct. Here i believe we should use h = 1/252 
	the interval length being 1 day out 252 possible trading days which corresponds to annualized volatility. </strong>
	</div>"),
	
	helpText('Solving for \\(\\alpha\\): $$\\alpha=\\frac{m}{h} + \\frac{1}{2}\\sum_{i=1}^n \\frac{(X_i-m)^2}{n-1}\\frac{1}{h}$$'),

	HTML("<div style='color:red;'><strong>
	future updates<br/>
	• perhaps including the open stock price with the close stock price might increase the accuaracy of the model because twice the data<br/>
	• i kind of want to ad a checkbox that adjuts the value of h or perhaps even just adjust the value of alpha direclty <br/>
	• the black scholes model, mainly p(st > k) N(d1)
	
	</strong>
	</div>")
	
	
		),
	
  
  # Show the main display
  mainPanel(   
	#textOutput("describedata")
	plotlyOutput("fincandle"),
	verbatimTextOutput("describedata"),
	
	# helpText("The mean of the data set:"),	
	verbatimTextOutput("divisionmean"),
	verbatimTextOutput("divisionmeanannualized"),
	# helpText("The variance of the data set:"),
	# verbatimTextOutput("divisionvar"),
	plotOutput("endofdaygraph")
	
  )
))