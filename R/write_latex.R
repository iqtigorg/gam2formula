#' Write LaTeX code for coefficient table of derived formulas
#'
#' @param x An object of class \code{gam2formula} as returned by \code{\link[=gam2formula]{gam2formula()}}.
#' @param term A string with the name of the predictor for which to write LaTeX code.
#'
#' @details
#' This function writes LaTeX code for derived formulas of B-spline, P-spline and cubic regression
#' spline smooths, relying on \code{kableExtra} for LaTeX code generation.
#'
#' @return A string with LaTeX syntax for the coefficient table created with \code{kableExtra::kable}.
#' By using \code{cat} on it, it gets parsed in the R console
#' for copy-and-pasting into a LaTeX compiler.
#'
write_latex <- function(x, term){

  # object structure verification
  stopifnot("gam2formula" %in% class(x))

  # get coeftable of requested term
  j <- x$coeftab[[term]]

  # format
  j_frmt <- tibble(
    range = paste0("For ", str_to_latex(j$range, term, application = "range")),
    bfun = str_to_latex(j$bfun, term, application = "bfun"),
    coef = as.character(j$coef)
  )

  # get indices for grouped rows
  idx <- table(factor(j_frmt$range, levels = unique(j_frmt$range)))

  # create kable
  j_kab <- kableExtra::kable(
    j_frmt[, names(j_frmt) != "range"],
    booktabs = TRUE,
    linesep  = "",
    escape = FALSE,
    format = "latex",
    col.names = c("Basis function", "Coefficient"),
    align = c("l", "r")
  )

  if(all(j$range == "1")){
    # formula without case distinction
    return(j_kab)
  } else {
    # formula with case distinction
    return(kableExtra::pack_rows(j_kab, escape = FALSE, index = idx))
  }
}

#' Convert a string with an extracted spline formula into LaTeX syntax
#'
#' @param s The string containing the formula to be converted.
#' @param term The name of the term to be displayed as text, supplied as a string.
#' @param application Whether basis function formula (\code{"bfun"}) or
#' range formula (\code{"range"}) is converted.
str_to_latex <- function(s, term, application) {

  if(application == "bfun"){
    # predictor name as text (only match after opening bracket)
    s <- gsub(paste0("\\(", term), paste0("\\(","\\\\\\text{", term, "}"), s)
    # handle exponents
    s <- gsub("\\^([0-9.]+)", "^{\\1}", s)
    # handle absolute values (allow one level of nesting of brackets)
    s <- gsub("abs\\(((?:[^()]|\\([^()]*\\))*)\\)", "\\\\left| \\1 \\\\right|", s, perl = TRUE)
    # handle pmax (allow one level of nesting of brackets)
    s <- gsub("pmax\\(((?:[^()]|\\([^()]*\\))*)\\)", "\\\\max\\\\{\\1\\\\}", s, perl = TRUE)

  }

  if(application == "range"){
    # predictor name as text
    s <- gsub(term, paste0("\\\\\\\\text{", term, "}"), s)
    # handle inequalities
    s <- gsub(">=", "\\\\\\\\geq", s)
    s <- gsub("<=", "\\\\\\\\leq", s)
    # handle "and"
    s <- gsub("&", "\\\\\\\\ \\\\\\\\text{and}\\\\\\\\", s)
    # bold the math manually
    s <- paste0("\\\\boldsymbol{", s, "}")
  }

  # wrap in math mode
  s <- paste0("$", s, "$")

  return(s)
}
