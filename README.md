# ParallelBayesOptQRF
ParallelBayesOptQRF is an R package that allows to optimize Quantile Regression Forests models via parallel Bayesian Optimization. It is built upon the R packages parBayesianOptimization, ranger, grf and randomForestSRC.

## Functionality

BayesOptQRF provides a user-friendly interface for performing parallel Bayesian optimization of Quantile Regression Forests in R. Users can specify the type of Quantile Regression Forest to be fitted, the score function, define the search space, and set optimization parameters such as the number of iterations and the acquisition function to use. 

Additional functions in the package allow to extract the optimized set of parameters, the estimated predictions and the variable importance from the optimized model.

## Bayesian Optimization

Bayesian optimization is a powerful optimization technique that is particularly useful for optimizing black-box functions where the objective function is expensive to evaluate and may be noisy or uncertain. It works by building a probabilistic model of the objective function and using this model to guide the search for the optimal solution. By iteratively selecting the next point to evaluate based on a balance of exploration and exploitation, Bayesian optimization can efficiently find the global optimum with a minimal number of evaluations.

## Quantile Regression Forests

Quantile Regression Forests are a flexible and robust method for estimating conditional quantiles of a response variable. They extend traditional regression forests by allowing the estimation of multiple quantiles simultaneously, making them well-suited for capturing heterogeneity in the data and providing a more comprehensive understanding of the relationship between predictors and the response variable.



