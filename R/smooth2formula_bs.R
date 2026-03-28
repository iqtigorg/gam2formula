#' Derive closed formula for a B-spline smooth
#'
#' @param smooth A \code{"bs"} (B-spline) smooth.
#' @param mod The model object that the smooth forms part of.
#' @param ngrid The number of grid points on which to evaluate the smooth.
#'
#' @return A nested tibble with name of the term, type of the smooth (\code{"bs"}) and a closed formula representation of the smooth.
smooth2formula_bs <- function(smooth, mod, ngrid = 1e3){
  #### extract required quantities from the smooth ####
  # get term name
  term <- smooth$term
  # get spline coefficients (for QR-centered B-splines from mgcv)
  gamma <- coef(mod)[smooth$first.para:smooth$last.para]
  # get spline degree
  m <- smooth$p.order[1]
  # get knots
  knots <- smooth$knots
  # get number of knots
  nk <- length(knots)
  # get interior knots
  intknots <- knots[-c(1:(m + 1), (nk - m):nk)]
  # get interval boundaries
  a <- knots[m + 1]
  b <- knots[nk - m]

  #### check if knots were set to default ####
  default_knots <- smooth.construct(s(x, bs = "bs", m = m, k = smooth$bs.dim),
                                    data = tibble(x = model.frame(mod)[[term]]),
                                    knots = NULL)$knots
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
  fhat <- X %*% gamma

  # determine T-spline coefficients
  B <- T_spline_design(x = xnew, m = m, intknots = intknots, a = a, b = b)
  beta <- unname(coef(lm(fhat ~ -1 + B)))

  #### handle extrapolation beyond data range ####
  # left
  Al <- matrix(0, 2, length(beta)) # note: the coefficients of the line on the left agree with those in the interior of the data range
  Al[1, 1] <- 1
  Al[2, 2] <- 1
  betal <- as.vector(Al %*% beta)

  # right
  v2 <- c(0:m, m * ((b - intknots) / (b - a))^(m - 1)) # note: this is (b-a) times the first derivative of the vector of rescaled T-splines evaluated at b
  v1 <- T_spline_design(x = b, m = m, intknots = intknots, a = a, b = b) - v2 # coefficient of constant basis function on the right of the data range
  Ar <- rbind(v1, v2)
  betar <- as.vector(Ar %*% beta)

  #### return formula representation ####
  # create table of coefficients
  # left range
  d1 <- data.frame(
    term = term,
    range = paste0(term," < ", a),
    bfun = c("1", paste0("(", term, "-", a, ")/", b - a)),
    coef = betal
  )
  # inner range
  if(m == 1){
    bfun = c("1",
             paste0("(", term, "-", a, ")/", b - a),
             paste0("pmax((", term, "-", intknots, ")/", b - a, ",0)"))
  } else {
    bfun = c("1",
             paste0("(", term, "-", a, ")/", b - a),
             paste0("((", term, "-", a, ")/", b - a, ")^", 2:m),
             paste0("pmax((", term, "-", intknots, ")/", b - a, ",0)^", m))
  }

  d2 <- data.frame(
    term = term,
    range = paste0(term, " >= ", a, " & ", term, " <= ", b),
    bfun = bfun,
    coef = beta
  )
  # right range
  d3 <- data.frame(
    term = term,
    range = paste0(term, " > ", b),
    bfun = c("1", paste0("(", term, "-", a, ")/", b - a)),
    coef = betar
  )
  # merge
  d <- rbind(d1, d2, d3)

  # replace "--" by "+" in bfun
  d$bfun <- gsub(pattern = "--", replacement = "+", x = d$bfun)

  # create results as nested tibble
  result <- tibble(
    term = term,
    # type of smooth term
    type = "bs",
    # spline formula expressed in data frame as characters
    coeftab = list(as_tibble(d))
  )

  # attach term name to list columns
  names(result$coeftab) <- term

  return(result)
}
