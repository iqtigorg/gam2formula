#' Derive closed formula for a cubic regression spline smooth
#'
#' @param smooth A  \code{"cr"} (cubic regression spline) smooth.
#' @param mod The model object that the smooth forms part of.
#' @param ngrid The number of grid points on which to evaluate the smooth.
#'
#' @return A nested tibble with name of the term, type of the smooth (\code{"cr"}) and a closed formula representation of the smooth.
smooth2formula_cr <- function(smooth, mod, ngrid = 1e3){
  #### extract required quantities from the smooth ####
  # get term name
  term <- smooth$term
  # get spline coefficients (for QR-centered cardinal splines from mgcv)
  gamma <- coef(mod)[smooth$first.para:smooth$last.para]
  # get knots
  knots <- smooth$xp
  # get number of knots
  nk <- length(knots)
  # get interval boundaries
  a <- knots[1]
  b <- knots[nk]

  #### check if knots were set to default ####
  default_knots <- smooth.construct(s(x, bs = "cr", k = smooth$bs.dim),
                                    data = tibble(x = model.frame(mod)[[term]]),
                                    knots = NULL)$xp
  if(!isTRUE(all.equal(knots, default_knots, tolerance = 1e-6))){
    stop(paste0("It seems that default knot placement was not used for smooth term ",
                term, ".\n Manual knot placement currently not supported."
    ))}

  #### derive formula representation of the smooth ####
  # predict spline on fine, equidistant grid
  xnew <- seq(a, b, length.out = ngrid)
  newdata <- data.frame(xnew)
  names(newdata) <- term
  X <- PredictMat(smooth, newdata)
  fhat <- X %*% gamma  # This replaces the predict() call!

  # derive RBF coefficients
  B <- RBF_design(x = xnew, knots = knots)
  beta <- unname(coef(lm(fhat ~ -1 + B)))

  #### return formula representation ####
  # create table of coefficients
  d <- data.frame(
    term = term,
    range = "1",
    bfun = c("1",
             paste0("(", term, "-", a, ")/", b - a),
             paste0("abs((", term, "-", knots, ")/", b - a, ")^3")),
    coef = beta
  )

  # replace "--" by "+" in bfun
  d$bfun <- gsub(pattern = "--", replacement = "+", x = d$bfun)

  # create results as nested tibble
  result <- tibble(
    term = term,
    # type of smooth term
    type = "cr",
    # spline formula expressed in data frame as characters
    coeftab = list(as_tibble(d))
  )

  # attach term name to list columns
  names(result$coeftab) <- term

  return(result)
}
