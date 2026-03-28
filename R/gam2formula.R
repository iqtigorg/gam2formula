#' Derive formulas for all B-spline, P-spline and cubic regression spline smooths of a
#' generalized additive model fitted with \code{mgcv}.
#'
#' @param mod A fitted model object of class \code{gam} or \code{bam} with at least 
#' one smooth of type \code{"bs"} (B-spline), \code{"ps"} (P-spline) or 
#' \code{"cr"} (cubic regression spline).
#'
#' @details
#' This function derives formulas for all B-spline, P-spline and cubic regression
#' spline smooths of a generalized additive model fitted with \code{\link[mgcv:gam]{gam()}} 
#' or \code{\link[mgcv:bam]{bam()}}. To this end, the function uses a simple basis 
#' representation for each supported smooth and computes the basis coefficients 
#' using ordinary least squares. Predictions from the derived formulas are 
#' typically in perfect agreement with predictions 
#' from \code{\link[mgcv:predict.gam]{predict.gam()}} up to numerical error 
#' of negligible magnitude. The function works for any type of 
#' response including binary, continuous, count or time-to-event responses.
#'
#' @return An object of class \code{gam2formula}. This is a nested tibble with one 
#' row per supported smooth in the model object. The derived formulas are stored in
#' the column \code{coeftab}.
#'
#' @seealso Use the function \code{\link[=summary.gam2formula]{summary()}} 
#' for an overview, the function \code{\link[=print.gam2formula]{print()}} to print 
#' the derived formula of a smooth, and the function 
#' \code{\link[=predict.gam2formula]{predict()}} to predict from the derived 
#' formula of a smooth.
#'
#' @section Warnings: There is no
#' support for thin plate regression splines of class \code{"tp"} 
#' (the default in \code{mgcv}), as these do not have a simple basis representation. 
#' In addition, there is currently no support for smooths that contain 
#' a \code{by = } statement, multivariate smooths of 
#' classes \code{"te"} or \code{"ti"} or fits from
#' \code{\link[mgcv:bam]{bam()}} with option \code{discrete = TRUE}.
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
#' # get an overview of all derived formulas
#' summary(mod_formulas)
#'
#' # print derived formula for s(x0)
#' print(mod_formulas, term = "x0")
#'
#' # print derived formula in LaTeX format
#' print(mod_formulas, term = "x0", format = "latex")
#'
#' # predict from the derived formula of s(x0) at original data points
#' predict(mod_formulas, term = "x0", newdata = dat)
#'
#' # predict from the derived formula at new data points
#' predict(mod_formulas, term = "x0", 
#' newdata = data.frame(x0 = seq(min(dat$x0), max(dat$x0), len = 100)))
#'
#' @import mgcv
#' @importFrom stats lm coef model.frame
#' @importFrom tibble tibble as_tibble
#' @importFrom purrr map map2 map_vec map_chr list_rbind reduce pluck
#'
#' @export
gam2formula <- function(mod){

  # object structure verification
  stopifnot(!is.null(mod))
  stopifnot("gam" %in% class(mod))

  # extract list of all smooth terms
  list_smooths <- mod$smooth
  if(length(list_smooths) == 0) stop("No smooth terms found.")

  # check for discrete
  if(isTRUE(mod$dinfo$para.discrete)) stop("Fit from `mgcv::bam` with `discrete = TRUE` not supported.")

  # filter for supported smooth types
  supported_types <- c("Bspline.smooth", "pspline.smooth", "cr.smooth")
  used_types <- map_vec(list_smooths, ~class(.x)[1])
  supported <- used_types %in% supported_types

  # filter for those which have no 'by ='
  has_by <- map_vec(list_smooths, ~.x$by) != "NA"
  if(any(has_by)) warning("Smooth terms containing 'by =' statements have been excluded.")
  supported <- supported & !has_by

  # check if there are smooth terms left
  if(sum(supported)==0) stop(paste0(
    "No supported smooth terms found. ",
    "Supported types: B-spline ('bs'), P-spline ('ps') and cubic regression spline ('cr'). ",
    "They must be specified without a 'by =' statement.")
  )

  result <- list_rbind(map2(list_smooths[supported], used_types[supported], function(smooth, type) {
    switch(
      type,
      "Bspline.smooth" = smooth2formula_bs(
        smooth = smooth,
        mod = mod
      ),
      "pspline.smooth" = smooth2formula_ps(
        smooth = smooth,
        mod = mod
      ),
      "cr.smooth" = smooth2formula_cr(
        smooth = smooth,
        mod = mod
      )
    )
  }))

  class(result) <- c("gam2formula", class(result))

  # store original call
  attr(result, "call") <- mod$call

  return(result)
}

