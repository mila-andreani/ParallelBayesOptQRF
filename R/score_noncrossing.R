#' Additional functions
#'
#' @export
score_noncrossing <- function(weights, score_fun, custom_fun, DF, predictions, p, Y_obs) {

  l=length(p)
  Score_vec=c()
  for (c in 1:l){
    w=weights[c]
    if (score_fun=='check'){
      s <- -((sum(check(DF$Y-predictions[,c], tau = p[c]), na.rm = T)/nrow(DF)))
    } else if (score_fun=='mae'){
      s <- -sum(abs(Y_obs[,c]-predictions[,c]))/nrow(DF)
    } else if (score_fun=='mse'){
      s <- -sum((Y_obs[,c]-predictions[,c])^2)/nrow(DF)
    } else if (score_fun=='custom'){
      s <- -sum((custom_fun(Y_obs[,c],predictions[,c]))/nrow(DF))
    }
    Score_vec=c(Score_vec, s*w)
  }

  Score_noncrossing <- sum(Score_vec)

}
