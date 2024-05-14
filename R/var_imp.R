#' Extracts and Plot variable Importance computed with default settings of QRF models.
#' @param object an optimized QRF model with ParallelBayesOptQRF or NonCrossingBayesOpt
#' @return List of 'varimp_df' ordered data frame of variable importance and ggplot object 'plot_varimp'.
#' @details
#' For non-crossing quantiles there is just one vector of values.
#' To obtain a variable importance vector for each quantile level, you should optimize each QRF separately with ParallelBayesOptQRF or NonCrossingBayesOpt.
#'
#' @export

var_imp <- function(object){

  model=object$model
  qrf=object$optimized_model

  if (model=='ranger'){

    Importance=qrf$variable.importance

    }else if (model=='grf'){

      Importance=variable_importance(qrf)

      }else if (model=='src'){

        Importance=vimp(qrf)$importance

      }
  #Variable names
  Variable=object$cov_names

  #Create ordered  df of variable importance values
  varimp_df=data.frame(Variable, Importance)
  rownames(varimp_df)=NULL
  varimp_df=varimp_df[order(varimp_df$Importance,decreasing=FALSE),]

  #Transform variable names into ordered factors sot hat ggplot plots values in descending order and not alphabetical order
  varimp_df$Variable = factor(varimp_df$Variable,
                              levels=varimp_df[order(varimp_df$Importance), "Variable"])

  #ggplot creation
  plot<-ggplot(data=varimp_df, aes(y=Importance, x=Variable)) +
    geom_bar(stat="identity")+ coord_flip()

  return(list(varimp_df=varimp_df, plot_varimp=plot))

}




