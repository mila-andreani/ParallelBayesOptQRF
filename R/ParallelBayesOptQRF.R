#' Parallel Bayesian Optimization for non-crossing quantiles.
#' Allows to optimize Quantile Regression Forests via Bayesian Optimization. It is an adaptation to Quantile Regression Forests of the well-known package ParBayesianOptimization.
#'
#' @param model Quantile Regression Forest model to be fitted. It allows the use of the model 'ranger' from the ranger package, 'grf' from the Generalized Random Forest package and 'src' from the randomForestSRC package.
#' @param DF The dataset to be used containing as first column the outcome variable. Should be Data.Frame or an object coercible to Data.Frame.
#' @param bounds Bounds for the Bayesian optimization (n_trees, min_node_size, mtry_opt, sample_fraction).
#' @param bayesopt_ctrl Options for the Bayesian Optimization algorithm.
#' @param p vector of quantiles of length n
#' @param weights vector of weights of length n used to compute the weighted average across quantiles of the Score function in the Bayesian Optimization algorithm. The values must add to 1. For simple mean, simply put 1/n as weight for each quantile.
#' @param seed For reproducible results.
#' @param parallel Allows for parallel computation. Default is FALSE.
#' @param score_fun Score function in the Bayesian algorithm. It allows for 'check' (quantile loss function) from Koenker and Bassett (1982), 'mse' for Mean Squared Error, 'mae' for Mean Absolute Error, 'custom' for a custom loss function to be defined by the user.
#' @param custom_fun FUN custom score function.
#' @param Y_obs True values to be used in the custom_fun if score_fun = 'custom'. Could be a vector of simulated quantiles or observed values.
#' @param fit_opt_model After the optimization, allows to fit the selected model with the optimized parameters. Default is 'Yes'.
#' @param oos Should the predictions from the optimized model be Out-of-Sample? Default is 'No'.
#' @param new_data New data to be used for Out-of-Sample predictions if oos = 'Yes'.
#' @param honesty Additional parameter for 'grf' if model = 'grf'. Default is TRUE.
#' @param honesty_fraction Additional parameter for 'grf' if honesty = TRUE. Default is 0.3.
#' @param method Additional parameter for 'src' allowing to set the method used to compute quantile estimations. Default is 'local'. Other settings are 'forest', which is similar to Meinhausen (2006), 'gk' Greenwald-Khanna algorithm suitable for big data and 'local' using the local adjusted cdf approach.
#' @param samptype Additional parameter to set the observation sampling type. Default is 'swr', that is sample with replacement. Other options are 'swor' that is sample without replacement.
#' @param splitrule Additional parameter to set the splitting rule settings. For 'src' model default is 'quantile.regr', otherwise it can be set to "la.quantile.regr" allowing to use local adaptive quantile regression splitting instead of CART splitting rules, which can be set using splitrule='mse'.
#' For the 'ranger' model it can be chosen among "variance", "extratrees", "max-stat", "beta". In this case default is "variance".
#' @param importance Additional parameter to set the variable importance measure. For 'ranger' models is 'permutation, for 'src' model can be chosen among "anti", "permute", "random" (default is "anti") and for 'grf' it is pre-determined by the grf package.
#' @details For further information on the use of the Bayesian Optimization fine tuning parameters, see ParBayesianOptimization. For other information on the Quantile Regression Forests models see the ranger, randomForesSRC and grf packages documentation.
#' @return A list comprising:
#' \item{opt_res }{Optimized values from the Bayesian Optimization algorithm along with other info on the convergence}
#' \item{predictions }{Predictions from the fitted optimized model}
#' \item{optimized_model}{A 'grf', 'ranfomForestSRC' or 'ranger' object representing the fitted Quantile Regression Forest with the optimized values. The obtained object retains the same attributes of the chosen model, so that all the functions from the 'ranger', 'grf' and 'randomForestSRC' packages can be applied on this object.}
#' @examples
#' bounds = list(mtry_opt=c(1L,8L),
#'min_node_size = c(100L,120L),
#'num_trees = c(100L,300L),
#'sample_fraction=c(0.7, 0.9))
#'
#'bayesopt_ctrl=list(init_points = 5,
#'                   n_iter = 10,
#'                   acq = "ucb",
#'                   kappa = 2.576,
#'                  eps = 0.0,
#'                  optkernel = list(type = "matern", nu = 5/2),
#'                  iters.n = 4,
#'                  iters.k = 4)
#'
#'
#' ## Optimization of a 'ranger' quantile regression forest with the Boston Housing dataset
#'
#'
#'data(Boston, package = "MASS") ###Load the data
#'
#'
#'
#'
#'model <- 'ranger' ###Select the model
#'
#'QRF_optimized <- ParallelBayesOptQRF(model, Boston, bounds,
#'bayesopt_ctrl, p=0.1, seed=123) ###Optimized model
#'
#'opt_params(QRF_optimized)
#'var_imp(QRF_optimized)
#' @export

ParallelBayesOptQRF <- function (model=NULL,
                              DF,
                              bounds,
                              bayesopt_ctrl,
                              p = 0.5, weights=NULL,
                              seed = NULL,
                              parallel = FALSE,
                              score_fun = NULL,
                              custom_fun = NULL,
                              Y_obs = NULL,
                              fit_opt_model = c("Yes", "No"),
                              oos = c("No", "Yes"),
                              new_data=NULL,
                              honesty = TRUE,
                              honesty_fraction = 0.3,
                              samptype = c( 'swr', 'swor'),
                              splitrule = NULL,
                              method = c( "local", "forest", "gk"), importance=NULL){
  ########PRELIMINARS
  l=length(p)
  n=nrow(DF)

  if (is.null(weights)){

    weights=rep(1/n, l)
  }

  model <- match.arg(model, c('ranger', 'grf', 'src'))

  fit_opt_model=match.arg(fit_opt_model)

  score_fun=match.arg(score_fun, c('check', 'mae', 'mse', 'custom_fun'))

  if (is.null(custom_fun==FALSE)){

    fun=is.function(custom_fun)
    stopifnot("custom_fun must be a FUN" = isTRUE(fun))

  }


  oos=match.arg(oos)

  if (length(dim((new_data)))>2){
    stopifnot(is.matrix(new_data) | is.data.frame(new_data))
    n_col=ncol(new_data)==ncol(DF[,-1])
    stopifnot("new_data must have the same num of covariates of the training set" = isTRUE(n_col))
    names_cov=colnames(new_data)==colnames(DF[,-1])
    stopifnot("new_data must have the same covariates names of the training set" = isTRUE(names_cov))
  }

  samptype=match.arg(samptype)

  if (model=='ranger'){
    samptype=match.arg(samptype, c('swr','swor'))

    if (samptype=='swr'){
      replace=TRUE
    }else {
      replace=FALSE
    }

  }

  if (model=='ranger'){
    splitrule_ranger=c("variance", "extratrees", "max-stat", "beta")
    splitrule=match.arg(splitrule, splitrule_ranger)


    importance_ranger=c("permutation")
    importance=match.arg(importance, importance_ranger)


  } else if (model=='src'){
    splitrule_src=c("quantile.regr", "mse", "la.quantile.regr")
    splitrule=match.arg(splitrule, splitrule_src)

    method=match.arg(method, c("local", "forest", "gk"))

    importance_src=c("anti", "permute", "random")
    importance=match.arg(importance, importance_src)

    samptype_src=c("swr", "swor")
    samptype=match.arg(samptype, samptype_src)

  }
  ################



  DF=as.data.frame(DF)
  colnames(DF)[1]='Y'
  #changes the first column name in the DF into 'Y'

  #Takes the values defined in 'bounds'
  mtry_opt=bounds$mtry_opt
  min_node_size=bounds$min_node_size
  num_trees=bounds$num_trees
  sample_fraction=bounds$sample_fraction

  seed=seed
  p=p
  DF=DF
  Y_obs=Y_obs
  custom_fun=custom_fun
  honesty=honesty
  honesty_fraction=honesty_fraction
  weights=weights
  #1) Define the model to be optimized


  QRF <- function(mtry_opt, min_node_size, num_trees, sample_fraction) {

    if (model=='ranger'){

      model <- ranger(Y ~ ., data = as.data.frame(DF), mtry = round(mtry_opt),
                      min.node.size=round(min_node_size), sample.fraction=round(sample_fraction), num.trees=round(num_trees),
                      replace=replace, quantreg = TRUE, seed = 123, importance=importance, keep.inbag=TRUE)

      predictions <- predict(model, data=NULL, type='quantiles', quantiles=p, seed=123)$predictions
      #in sample predictions

      Score <- score_noncrossing(weights, score_fun, custom_fun, DF, predictions, p, Y_obs)

    } else if (model=='grf') {

      p=p
      X=DF[,-1]
      Y=DF$Y
      model <- quantile_forest(X, Y, quantiles = p, num.trees = round(num_trees),
                               mtry = round(mtry_opt),
                               min.node.size=round(min_node_size), compute.oob.predictions=TRUE,
                               sample.fraction=sample_fraction, honesty=honesty, honesty.fraction = honesty_fraction)
      predictions <- predict(model, new_data=NULL)

      Score <- score_noncrossing(weights, score_fun, custom_fun, DF, predictions, p, Y_obs)

    } else if (model=='src'){

      model <-  quantreg(Y ~ ., data = as.data.frame(DF), mtry = round(mtry_opt),
                         ntree=round(num_trees),
                         nodesize=round(min_node_size), samptype=samptype,
                         splitrule = splitrule, method = method, prob=p,seed=123, importance=importance)

      predictions = model[["quantreg"]][["quantiles"]]

      Score <- score_noncrossing(weights, score_fun, custom_fun, DF, predictions, p, Y_obs)

    }

    list(Score=Score)
  }



  cat('Starting optimization...', sep="\n")

  #2) Actual Optimization (Allows for parallel computation if 'parallel' has been set to TRUE. Default is FALSE)
  opt_res <- bayesOpt(QRF,
                      bounds = bounds,
                      iters.n = bayesopt_ctrl$iters.n,
                      iters.k = bayesopt_ctrl$iters.k,
                      initPoints = bayesopt_ctrl$init_points,
                      parallel=parallel,
                      otherHalting = list(timeLimit = Inf, minUtility = 0),
                      acq = bayesopt_ctrl$acq,
                      kappa=bayesopt_ctrl$kappa,
                      eps=bayesopt_ctrl$eps,
                      errorHandling=3,
                      plotProgress=TRUE,
                      verbose = 2)

  #3) Fits RF with best parameters and returns the fitted values

  if(fit_opt_model=='Yes'){

    cat('End optimization. Fitting the optimized model...', sep="\n")


    if (model=='ranger'){

      q.forest <- ranger(Y ~ ., data = as.data.frame(DF), num.trees = getBestPars(opt_res)$num_trees ,
                         mtry = getBestPars(opt_res)$mtry_opt,
                         min.node.size=getBestPars(opt_res)$min_node_size, sample.fraction =getBestPars(opt_res)$sample_fraction, quantreg=TRUE,
                         keep.inbag=TRUE, importance=importance, replace=replace,seed=123)
      if (oos=='No'){

        predictions <- predict(q.forest, data=NULL, type='quantiles', quantiles=p)$predictions

      } else if (oos=='Yes') {

        predictions <- predict(q.forest, data=new_data, type='quantiles', quantiles=p)$predictions

      }

    } else if (model=='grf'){
      X=DF[,-1]
      Y=DF[,1]
      q.forest <- quantile_forest(X, Y, quantiles = p, num.trees = getBestPars(opt_res)$num_trees,
                                  mtry = getBestPars(opt_res)$mtry_opt,
                                  min.node.size=getBestPars(opt_res)$min_node_size,
                                  sample.fraction = getBestPars(opt_res)$sample_fraction, honesty=honesty,
                                  honesty.fraction = honesty_fraction)

      if (oos=='No'){

        predictions <- predict(q.forest, new_data=NULL)

      } else if (oos=='Yes') {

        predictions <- predict(q.forest, new_data=new_data)

      }

    } else if (model=='src'){

      q.forest <-  quantreg(Y ~ ., data = as.data.frame(DF), mtry = getBestPars(opt_res)$mtry_opt,
                            ntree=getBestPars(opt_res)$num_trees,
                            nodesize=getBestPars(opt_res)$min_node_size, samptype=samptype,
                            splitrule = splitrule, method = method, prob=p,seed=123, importance=importance)

      if (oos=='No'){

        predictions <- t(q.forest[["quantreg"]][["quantiles"]])

      } else if (oos=='Yes') {

        predictions <- quantreg(object=q.forest, new_data=as.data.frame(new_data))

      }

    }

    cat('End fitting', sep="\n")

    #4) List of Results
    colnames(predictions)=p
    return(list(opt_res=opt_res, predictions=predictions, optimized_model=q.forest, model=model, cov_names=colnames(DF[,-1])))

  }else{

    return(opt_res=opt_res)

    cat('End Optimization', sep="\n")

  }

}
