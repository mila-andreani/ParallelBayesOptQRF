#' Function to check user inputs in functions. It is strongly recommended to run this before the optimizer.
#' @param All All parameters of the optimizer
#' @export
#'
check_inputs <- function(model=NULL,
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
                         samptype = NULL,
                         splitrule = NULL,
                         method = NULL, importance=NULL){



  model <- match.arg(model, c('ranger', 'grf', 'src'))

  stopifnot(is.matrix(DF) | is.data.frame(DF))

  l=length(p)
  n=nrow(DF)

  if (is.null(weights)){

    weights=rep(1/n, l)
  }

  if (length(p)>=2){


    len=length(weights)==length(p)
    stopifnot("'weights' must have the same length of p " = isTRUE(len))
    add_to1=sum(weights)==1
    stopifnot("'weights' must add to 1 " = isTRUE(add_to1))

  }else if (length(p)==1){

    weights=1

  } else {

    print('Select a quantile probability level')

  }

  score_fun=match.arg(score_fun)

  if (length(Y_obs)>0){

    len=length(Y_obs)==nrow(DF)
    stopifnot("'Y_obs' must have the same num of observations of DF " = isTRUE(len))
  }

  fit_opt_model=match.arg(fit_opt_model)

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

  inputs=as.matrix(c(model=model,
                 p = p, weights=weights,
                 seed = NULL,
                 DF='OK',
                 Y_obs='OK',
                 new_data='OK',
                 parallel = FALSE,
                 score_fun = score_fun,
                 custom_fun = custom_fun,
                 fit_opt_model = fit_opt_model,
                 oos = oos,
                 honesty = honesty,
                 honesty_fraction = honesty_fraction,
                 samptype = samptype,
                 splitrule = splitrule,
                 method = method, importance=importance),18,18)
  colnames(inputs)='Settings'

  cat('You\'re good to go! ;) Here\'s the list of the input arguments:\n')
  print(inputs)

  return(inputs=inputs)

}

