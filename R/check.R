#' Quantile Regression loss as in Koenker and Bassett (1982)
#'@param tau Quantile probability level
#'@param x Observation
#' @export


check <- function(x,tau){
  x*(tau - (x<0))
}



