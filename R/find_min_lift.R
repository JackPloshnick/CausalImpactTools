#' Find the minimum lift needed for a CausalImpact Test
#'
#' This function simulates different lift values to determine the smallest lift detectable
#' by the `CausalImpact` package. It loops through the provided lift values and calculates
#' the p-value for each simulated lift.
#'
#' @param data A data frame or matrix used for the `CausalImpact` analysis.
#' @param pre.period A numeric vector specifying the start and end indices of the pre-intervention period.
#' @param post.period A numeric vector specifying the start and end indices of the post-intervention period.
#' @param model.args Arguments for the Bayesian Structural Time Series model passed to `CausalImpact`.
#' @param bsts.model A pre-constructed `bsts` model (optional). Defaults to `NULL`.
#' @param post.period.response Response data for the post-period (optional). Defaults to `NULL`.
#' @param alpha Significance level for the analysis. Defaults to `0.05`.
#' @param per_period_lifts A numeric vector of lift values per period.
#' @return A data frame with two columns:
#'   \itemize{
#'     \item \code{lift}: The simulated lift values.
#'     \item \code{p_value}: The corresponding p-values from the `CausalImpact` analysis.
#'   }
#' @examples
#' # Example usage:
#' library(CausalImpact)
#'
#' x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
#' y <- 1.2 * x1 + rnorm(100)
#' data <- cbind(y, x1)
#' df <- find_min_lift(data, per_period_lifts = c(0.01,1,2), pre.period = c(1,70), post.period = c(71,100))
#' print(df)
#' @export
find_min_lift <- function(data = NULL, pre.period = NULL,
                          post.period = NULL, model.args = NULL,
                          bsts.model = NULL, post.period.response = NULL,
                          alpha = 0.05, per_period_lifts = NULL) {

  #prepare for the loop
  results <- list()
  pre.period.sd <- sd(data[,1][pre.period[1]:pre.period[2]])
  counter <- 0

  #loop through each lift value
  for(lift in per_period_lifts){
    loop_data <- data

    # simulate a lift
    loop_data[,1][post.period[1]:post.period[2]] <- loop_data[post.period[1]:post.period[2]] + lift  #+ rnorm(length(loop_data[post.period[1]:post.period[2]]), sd = pre.period.sd, mean = lift )


    impact <- CausalImpact(data = loop_data, pre.period,
                           post.period, model.args,
                           bsts.model, post.period.response,
                           alpha = alpha)

    counter <- counter + 1
    results[[counter]] <- data.frame(lift = lift, p_value = impact$summary$p[1])

  }
  df <- do.call(rbind, results)
  return(df)
}
