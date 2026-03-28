#' Summarize a gam2formula object.
#'
#' The default summary method for an object of class \code{gam2formula}.
#'
#' @param object An object of class \code{gam2formula} as returned by 
#' \code{\link[=gam2formula]{gam2formula()}}.
#' @param ... Other arguments.
#'
#' @return The input object, invisibly.
#'
#' @seealso Use the function  \code{\link[=print.gam2formula]{print()}} to print 
#' the derived formula of a smooth and the function 
#' \code{\link[=predict.gam2formula]{predict()}} to predict from the derived 
#' formula of a smooth.
#'
#' @examples
#' # generate data and fit gam with mgcv
#' library(mgcv)
#' set.seed(2)
#' dat <- gamSim(1, n = 200, dist = "normal", scale = 2, verbose = FALSE)
#' mod <- gam(y ~ s(x0, bs = "cr") + s(x1, bs = "bs", m = c(4, 2)) +
#' s(x2, bs = "ps") + s(x3), data = dat)
#' mod_formulas <- gam2formula(mod)
#' summary(mod_formulas)
#'
#' @export
summary.gam2formula <- function(object, ...) {

  cat("gam2formula object with", nrow(object), "derived formulas for:",
      paste(object$term, collapse = ", "), "\n")
  cat("Original call:\n", paste(deparse(attr(object, "call"), width.cutoff = 80L), collapse = "\n"), "\n\n")

  cat("Extracted smooth terms:\n")
  print(as.data.frame(object[, c("term", "type")]), row.names = FALSE, right = FALSE)

  invisible(object)
}
