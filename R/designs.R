#' Return the design matrix of the rescaled truncated power series basis.
#'
#' @param x A vector of x_i values.
#' @param m The degree of the spline.
#' @param intknots The vector of interior spline knots.
#' @param a Left boundary of spline interval.
#' @param b Right boundary of spline interval.
#'
#' @return The design matrix T=T_j(x_i).
T_spline_design <- function(x, m, intknots, a, b){

  n <- length(x)
  k <- length(intknots)
  d <- m+k+1

  Tmatrix  <- matrix(0,n,d)

  for(j in 1:(m+1)){
    Tmatrix[,j] <- ((x-a)/(b-a))^(j-1)
  }

  for(j in 1:k){
    Tmatrix[,j+m+1] <- pmax((x-intknots[j])/(b-a),0)^m
  }

  return(Tmatrix)

}

#' Return the design matrix of the rescaled cubic radial basis function basis.
#'
#' @param x A vector of x_i values.
#' @param knots The vector of spline knots.
#'
#' @return The design matrix B=B_j(x_i) with intercept, linear, and cubic RBF terms.
RBF_design <- function(x, knots){

  k <- length(knots) # number of knots

  a <- knots[1] # first knot
  b <- knots[k] # last knot

  n <- length(x)
  B <- cbind(rep(1, n), (x-a)/(b-a)) # linear part

  for(j in 1:k){
    B <- cbind(B, abs((x-knots[j])/(b-a))^3) # nonlinear part
  }

  return(B)
}
