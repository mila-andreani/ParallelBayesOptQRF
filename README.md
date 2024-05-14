# ParallelBayesOptQRF
ParallelBayesOptQRF is an R package that allows to optimize Quantile Regression Forests models via parallel Bayesian Optimization. This package allows also to compute multiple non-crossing quantiles and it is built upon the R packages parBayesianOptimization, ranger, grf and randomForestSRC.

It is possibile to specify the type of Quantile Regression Forest to be fitted, the score function, define the search space, and set optimization parameters such as the number of iterations and the acquisition function to use. 

Additional functions in the package allow to extract the optimized set of parameters, the estimated predictions and the variable importance from the optimized model.

# Installation

The most recent version of the package can be downloaded from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("mila-andreani/ParallelBayesOptQRF")
```

# Easy Example: Boston Housing Dataset

## 1) Load the library and the Dataset

``` r
library(ParallelBayesOptQRF)
data(Boston, package='MASS')
```

## 2) Register Clusters for Parallel Computation

``` r
 n.cores <- 2
    my.cluster <- parallel::makeCluster(
      n.cores, 
      type = 'FORK'
    )
    cl<-makeCluster(n.cores, outfile="Log.txt")
    doParallel::registerDoParallel(cl = cl)
```

## 2) Set the boundaries for the Bayesian Optimization

The boundaries lists follow the input of the ParBayesianOptimization package.

``` r
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
``` 
## 3) Check the inputs with the check_inputs() function

The check_inputs() function provides a fast and easy way to check the input parameters (including dataset used for training and testing the model) before running a demanding optimization. If correct, the function returns the chosen inputs along with the default values of arguments that have not been specified.

``` r
inputs=check_inputs('ranger', Boston, fit_opt_model = "Yes", oos='"No")

#>You're good to go! ;) Here's the list of the input arguments:
#>                 Settings     
#>model            "ranger"     
#>p                "0.5"        
#>weights          "1"          
#>DF               "OK"         
#>Y_obs            "OK"         
#>new_data         "OK"         
#>parallel         "FALSE"      
#>fit_opt_model    "Yes"        
#>oos              "No"         
#>honesty          "TRUE"       
#>honesty_fraction "0.3"        
#>samptype         "swr"        
#>splitrule        "variance"   
#>importance       "permutation"
``` 


``` r
## Bayesian Optimization

Bayesian optimization is a powerful optimization technique that is particularly useful for optimizing black-box functions where the objective function is expensive to evaluate and may be noisy or uncertain. It works by building a probabilistic model of the objective function and using this model to guide the search for the optimal solution. By iteratively selecting the next point to evaluate based on a balance of exploration and exploitation, Bayesian optimization can efficiently find the global optimum with a minimal number of evaluations.

## Quantile Regression Forests

Quantile Regression Forests are a flexible and robust method for estimating conditional quantiles of a response variable. They extend traditional regression forests by allowing the estimation of multiple quantiles simultaneously, making them well-suited for capturing heterogeneity in the data and providing a more comprehensive understanding of the relationship between predictors and the response variable.




