# CausalImpactTools

## Lift estimates for CausalImpact Tests
How much incremental lift will a `CausalImpact` test need to drive for it to be considered
statistically significant? The `find_min_lift` function will simulate a range of lifts
on timeseries data, and then execute a `CausalImpact` analysis. The function outputs 
a dataframe which can be used to approximate the needed lift for a `CausalImpact` test.

This function simulates a lift by adding the following to the post period dependent variable:
```r
+ rnorm(<post.period.length>, sd = <pre.period.standard.error>, mean = <simulated.lift> )
```

If you expect the variance of your dependent variable to be signifigantly different when the test is 
run vs in simulated data, this function may not be appropriate. 

### Example

```r
install.packages("CausalImpact")
library(CausalImpact)

library(devtools)
devtools::install_github("JackPloshnick/CausalImpactTools")
library(CausalImpactTools)


# Simulate timeseries data
set.seed(42)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
data <- cbind(y, x1)

# simulate per-period lifts
needed_lifts <- find_min_lift(data, per_period_lifts = c(0.01,1,2), 
  number_of_simulations = 5, pre.period = c(1,70), post.period = c(71,100))
needed_lifts 
```
