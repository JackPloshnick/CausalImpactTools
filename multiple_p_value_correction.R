install.packages("CausalImpact")
library(CausalImpact)

library(devtools)
devtools::install_github("JackPloshnick/CausalImpactTools")
library(CausalImpactTools)


# Simulate timeseries data
set.seed(42)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
x2 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y1 <- 1.2 * x1 + rnorm(100)
y2 <- 1.5 * x1 + rnorm(100)


data <- cbind(y1, y2, x1, x2)
dependent_variables <- c("y1", "y2")



multiple_p_value_correction <- function(data = NULL, pre.period = NULL,
                          post.period = NULL, model.args = NULL,
                          bsts.model = NULL, post.period.response = NULL,
                          alpha = 0.05, per_period_lifts = NULL, dependent_variables = NULL) {

  p_values <- list()
  for(var in seq_along(dependent_variables)){
    
    #create dataframe where only one dependent variable is present
    dep_col <- data[, dependent_variables[var], drop = FALSE]
    other_cols <- data[, !colnames(data) %in% dependent_variables, drop = FALSE]
    training_df <- cbind(dep_col, other_cols)
    
    #train model and get p-value
    impact <- impact <- CausalImpact(data = training_df, pre.period,
                                     post.period, model.args,
                                     bsts.model, post.period.response,
                                     alpha = alpha)
    
    p_values<- append(p_values,impact$summary$p[1])
  
  }
  #bonferroni correction
  p_corrected <- p.adjust(p_values, method = "bonferroni")
  
  df_with_p_values <- data.frame(dependent_variables, unlist(p_values), p_corrected )
  names(df_with_p_values) <- c('dependent_variable', 'p_value', 'p_value_corrected')
  return(df_with_p_values)
}

multiple_p_value_correction(data, dependent_variables = dependent_variables,pre.period = c(1,70), post.period = c(71,100))

