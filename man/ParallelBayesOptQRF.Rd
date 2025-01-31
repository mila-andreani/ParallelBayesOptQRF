% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ParallelBayesOptQRF.R
\name{ParallelBayesOptQRF}
\alias{ParallelBayesOptQRF}
\title{Parallel Bayesian Optimization for non-crossing quantiles.
Allows to optimize Quantile Regression Forests via Bayesian Optimization. It is an adaptation to Quantile Regression Forests of the well-known package ParBayesianOptimization.}
\usage{
ParallelBayesOptQRF(
  model = NULL,
  DF,
  bounds,
  bayesopt_ctrl,
  p = 0.5,
  weights = NULL,
  seed = NULL,
  parallel = FALSE,
  score_fun = NULL,
  custom_fun = NULL,
  Y_obs = NULL,
  fit_opt_model = c("Yes", "No"),
  oos = c("No", "Yes"),
  new_data = NULL,
  honesty = TRUE,
  honesty_fraction = 0.3,
  samptype = c("swr", "swor"),
  splitrule = NULL,
  method = c("local", "forest", "gk"),
  importance = NULL
)
}
\arguments{
\item{model}{Quantile Regression Forest model to be fitted. It allows the use of the model 'ranger' from the ranger package, 'grf' from the Generalized Random Forest package and 'src' from the randomForestSRC package.}

\item{DF}{The dataset to be used containing as first column the outcome variable. Should be Data.Frame or an object coercible to Data.Frame.}

\item{bounds}{Bounds for the Bayesian optimization (n_trees, min_node_size, mtry_opt, sample_fraction).}

\item{bayesopt_ctrl}{Options for the Bayesian Optimization algorithm.}

\item{p}{vector of quantiles of length n}

\item{weights}{vector of weights of length n used to compute the weighted average across quantiles of the Score function in the Bayesian Optimization algorithm. The values must add to 1. For simple mean, simply put 1/n as weight for each quantile.}

\item{seed}{For reproducible results.}

\item{parallel}{Allows for parallel computation. Default is FALSE.}

\item{score_fun}{Score function in the Bayesian algorithm. It allows for 'check' (quantile loss function) from Koenker and Bassett (1982), 'mse' for Mean Squared Error, 'mae' for Mean Absolute Error, 'custom' for a custom loss function to be defined by the user.}

\item{custom_fun}{FUN custom score function.}

\item{Y_obs}{True values to be used in the custom_fun if score_fun = 'custom'. Could be a vector of simulated quantiles or observed values.}

\item{fit_opt_model}{After the optimization, allows to fit the selected model with the optimized parameters. Default is 'Yes'.}

\item{oos}{Should the predictions from the optimized model be Out-of-Sample? Default is 'No'.}

\item{new_data}{New data to be used for Out-of-Sample predictions if oos = 'Yes'.}

\item{honesty}{Additional parameter for 'grf' if model = 'grf'. Default is TRUE.}

\item{honesty_fraction}{Additional parameter for 'grf' if honesty = TRUE. Default is 0.3.}

\item{samptype}{Additional parameter to set the observation sampling type. Default is 'swr', that is sample with replacement. Other options are 'swor' that is sample without replacement.}

\item{splitrule}{Additional parameter to set the splitting rule settings. For 'src' model default is 'quantile.regr', otherwise it can be set to "la.quantile.regr" allowing to use local adaptive quantile regression splitting instead of CART splitting rules, which can be set using splitrule='mse'.
For the 'ranger' model it can be chosen among "variance", "extratrees", "max-stat", "beta". In this case default is "variance".}

\item{method}{Additional parameter for 'src' allowing to set the method used to compute quantile estimations. Default is 'local'. Other settings are 'forest', which is similar to Meinhausen (2006), 'gk' Greenwald-Khanna algorithm suitable for big data and 'local' using the local adjusted cdf approach.}

\item{importance}{Additional parameter to set the variable importance measure. For 'ranger' models is 'permutation, for 'src' model can be chosen among "anti", "permute", "random" (default is "anti") and for 'grf' it is pre-determined by the grf package.}
}
\value{
A list comprising:
\item{opt_res }{Optimized values from the Bayesian Optimization algorithm along with other info on the convergence}
\item{predictions }{Predictions from the fitted optimized model}
\item{optimized_model}{A 'grf', 'ranfomForestSRC' or 'ranger' object representing the fitted Quantile Regression Forest with the optimized values. The obtained object retains the same attributes of the chosen model, so that all the functions from the 'ranger', 'grf' and 'randomForestSRC' packages can be applied on this object.}
}
\description{
Parallel Bayesian Optimization for non-crossing quantiles.
Allows to optimize Quantile Regression Forests via Bayesian Optimization. It is an adaptation to Quantile Regression Forests of the well-known package ParBayesianOptimization.
}
\details{
For further information on the use of the Bayesian Optimization fine tuning parameters, see ParBayesianOptimization. For other information on the Quantile Regression Forests models see the ranger, randomForesSRC and grf packages documentation.
}
\examples{
bounds = list(mtry_opt=c(1L,8L),
min_node_size = c(100L,120L),
num_trees = c(100L,300L),
sample_fraction=c(0.7, 0.9))

bayesopt_ctrl=list(init_points = 5,
                  n_iter = 10,
                  acq = "ucb",
                  kappa = 2.576,
                 eps = 0.0,
                 optkernel = list(type = "matern", nu = 5/2),
                 iters.n = 4,
                 iters.k = 4)


## Optimization of a 'ranger' quantile regression forest with the Boston Housing dataset


data(Boston, package = "MASS") ###Load the data




model <- 'ranger' ###Select the model

QRF_optimized <- ParallelBayesOptQRF(model, Boston, bounds,
bayesopt_ctrl, p=0.1, seed=123) ###Optimized model

opt_params(QRF_optimized)
var_imp(QRF_optimized)
}
