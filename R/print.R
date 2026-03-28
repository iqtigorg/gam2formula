#' Print the derived formula of a smooth.
#'
#' The default printing method for an object of class \code{gam2formula}.
#'
#' @param x An object of class \code{gam2formula} as returned by 
#' \code{\link[=gam2formula]{gam2formula()}}.
#'
#' @param term Can either be \code{NULL} (default) or a string with the name of 
#' the predictor for which to print
#' the formula (must be included in \code{x} and can only be of length one).
#'
#' @param format Can either be \code{NULL} (default) or \code{"latex"}.
#'
#' @param ... Other arguments.
#'
#' @details When \code{term = NULL}, an overview is printed via
#'  \code{\link[=summary.gam2formula]{summary()}}.
#' When \code{term} is given with \code{format = NULL}, the coefficient 
#' table is returned as a tibble.
#' When \code{format = "latex"}, LaTeX code is printed.
#'
#' @seealso Use the function \code{\link[=summary.gam2formula]{summary()}} 
#' for an overview and the function  \code{\link[=predict.gam2formula]{predict()}} 
#' to predict from the derived formula of a smooth.
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
#' # print derived formula for s(x0)
#' print(mod_formulas, term = "x0")
#'
#' # print derived formula in LaTeX format
#' print(mod_formulas, term = "x0", format = "latex")
#'
#' @export
print.gam2formula <- function(x, term = NULL, format = NULL, ...) {

  # object structure verification
  stopifnot("gam2formula" %in% class(x))

  # input checks for term
  stopifnot(is.null(term) || length(term) == 1 & is.character(term) & term %in% x$term)

  # input checks for format
  stopifnot(is.null(format) || format == "latex")

  if (!is.null(format) && is.null(term)) {
    stop("No term was specified for printing in the requested format.")
  }

  # default: print overview
  if (is.null(term)) {
    return(summary(x))
  }

  if (!is.null(term)) {
    if (is.null(format)) {
      return(x$coeftab[[term]])
    }
    if (!is.null(format) && format == "latex") {
      return(cat(write_latex(x, term)))
    }
  }
}
