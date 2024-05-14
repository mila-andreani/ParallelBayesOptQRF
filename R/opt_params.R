#' Extracts Optimized Parameters
#'@param object optimized_model obtained after the Bayesian Optimization
#' @export
opt_params <- function (object){

  #Get optimized parameters
  mtry=getBestPars(object$opt_res)$mtry_opt
  min.node.size=getBestPars(object$opt_res)$min_node_size
  n.trees=getBestPars(object$opt_res)$num_trees
  sample.fraction=getBestPars(object$opt_res)$sample_fraction

  #create optimized parameters df
  opt_params=data.frame(rbind(mtry, min.node.size, n.trees, round(sample.fraction,2)), row.names = c('M try', 'Min Node Size', '# Trees', 'Sample Fraction'))
  colnames(opt_params)=NULL


  cat('\nOptimal Parameters found via Bayesian Optimization:\n')

  return(list(opt_params, mtry=mtry, min.node.size=min.node.size, n.trees=n.trees, sample.fraction=sample.fraction))

}

