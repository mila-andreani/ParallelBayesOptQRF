#' Additional functions
#'
#' @export
score_fun_opt<-function(score_fun, custom_fun, DF, predictions, p, Y_obs){

  if (score_fun=='check'){
    Score <- -((sum(check(DF$Y-predictions, tau = p), na.rm = T)/nrow(DF)))
  } else if (score_fun=='mae'){
    Score <- -sum(abs(Y_obs-predictions))/nrow(DF)
  } else if (score_fun=='mse'){
    Score <- -sum((Y_obs-predictions)^2)/nrow(DF)
  } else if (score_fun=='custom'){
    Score <- -sum((custom_fun(Y_obs, predictions))/nrow(DF))
  }

}
