#' Predict from the derived formula of a smooth.
#'
#' The default prediction method for an object of class \code{gam2formula}.
#'
#' @param object An object of class \code{gam2formula} as returned by 
#' \code{\link[=gam2formula]{gam2formula()}}.
#'
#' @param term A string with the name of the predictor for which predictions shall
#' be made (must be included in \code{x} and can only be of length one).
#'
#' @param newdata A \code{data.frame} which contains new values of the predictor for
#' which predictions shall be made. Must contain at least a column with the name
#' that matches \code{term}.
#'
#' @param ... Other arguments.
#'
#' @details
#' This function computes point predictions from a derived formula of a smooth.
#' The predictions are centered as in \code{mgcv}'s internal functions and apply only
#' to the smooth term. That is, they represent the partial effect of the
#' model component specified by \code{term} (for example, they exclude contributions
#' from the global intercept). Predictions are on the link scale.
#'
#' @return A numeric vector with point predictions.
#'
#' @seealso Use the function \code{\link[=summary.gam2formula]{summary()}} 
#' for an overview and the function \code{\link[=print.gam2formula]{print()}} to print 
#' the derived formula of a smooth.
#'
#' @examples
#' # generate data and fit gam with mgcv
#' library(mgcv)
#' set.seed(2)
#' dat <- gamSim(1, n = 200, dist = "normal", scale = 2, verbose = FALSE)
#' mod <- gam(y ~ s(x0, bs = "cr") + s(x1, bs = "bs", m = c(4, 2)) +
#' s(x2, bs = "ps") + s(x3), data = dat)
#'
#' # derive closed formulas for all supported smooths using gam2formula
#' mod_formulas <- gam2formula(mod)
#'
#' # predict from the derived formula of s(x0) at original data points
#' predict(mod_formulas, term = "x0", newdata = dat)
#'
#' # predict from the derived formula at new data points
#' predict(mod_formulas, term = "x0", 
#' newdata = data.frame(x0 = seq(min(dat$x0), max(dat$x0), len = 100)))
#'
#' @export
predict.gam2formula <- function(object, term, newdata, ...){

  # object structure verification
  stopifnot("gam2formula" %in% class(object))

  # input checks for term
  stopifnot(length(term) == 1 & is.character(term))
  stopifnot(term %in% object$term)
  stopifnot(term %in% names(newdata))

  # extract the required coeftab
  coeftab <- object$coeftab[[term]]

  # input checks for coeftab
  stopifnot(nrow(coeftab) > 0)
  stopifnot(all(c("term", "range", "bfun", "coef") %in% names(coeftab)))

  # evaluate the j'th basis function at the corresponding vector of observations
  # in order to obtain the design matrix
  Z <- reduce(map(1:nrow(coeftab), function(j){
    Z_j <- with(newdata, eval(parse(text = coeftab$bfun[j])))
    with(newdata, Z_j * eval(parse(text = coeftab$range[j])))
  }), ~cbind(.x, .y, deparse.level = 0))

  # compute vector of point predictions via multiplication with coefficients
  y <- as.vector(Z %*% coeftab$coef)

  return(y)
}


