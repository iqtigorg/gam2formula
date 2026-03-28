test_that("parsed write_latex() output gives same term-wise predictions as coefficient table", {
  # simulate
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "bs", m = c(3, 2), k = 23) + s(x2, bs = "cr", k = 11), data = dat)

  # get formula
  mod_formulas <- gam2formula(mod)

  # predictions based on coefficient table with new data in observed range
  # (for easier handling of latex parsing)
  newdata <- data.frame(x1 = runif(5, min(dat$x1), max(dat$x1)), x2 = runif(5, min(dat$x2), max(dat$x2)))
  predx1 <- predict(mod_formulas, "x1", newdata)
  predx2 <- predict(mod_formulas, "x2", newdata)

  # predictions based on parsed latex code
  mod_formulas_ltx_x1 <- write_latex(mod_formulas, "x1")
  mod_formulas_ltx_x2 <- write_latex(mod_formulas, "x2")
  parse_latex_table <- function(latex_string) {
    # parse stable string
    if(grepl("multicolumn", latex_string)){
      # if there are grouped rows (i.e., different ranges) in latex table,
      # then take middle group only (we check only case where new data is within range)
      sections <- strsplit(latex_string, "\\\\multicolumn")[[1]]
      lines <- strsplit(sections[[3]], "\n")[[1]]
      lines <- lines[grepl("&", lines)]
    } else{
      # otherwise simply go by column name directly
      lines <- strsplit(latex_string, "\n")[[1]]
      lines <- lines[grepl("&", lines) & !grepl("Basis function", lines)]
    }
    lines <- gsub("\\\\hspace\\{[^}]*\\}|\\\\\\\\", "", lines)
    # extract vectors
    parts <- strsplit(lines, "&")
    bfuns <- trimws(sapply(parts, "[", 1))
    coefs <- as.numeric(sapply(parts, "[", 2))
    # remove math mode
    bfuns <- gsub("^\\$|\\$$", "", bfuns)
    # latex to r
    bfuns <- gsub("\\\\text\\{([^}]*)\\}", "\\1", bfuns)
    bfuns <- gsub("\\\\max\\\\\\{([^,]+),([^}]+)\\\\\\}(\\^)?", "pmax(\\1,\\2)\\3", bfuns)
    bfuns <- gsub("\\^\\{([^}]+)\\}", "^\\1", bfuns)
    bfuns <- gsub("\\\\left\\|(.+?)\\\\right\\|", "abs(\\1)", bfuns)
    bfuns <- gsub("[\\\\{}]", "", bfuns)
    # build linear predictor
    paste(coefs, "*", bfuns, collapse = " + ")
  }

  predx1_ltx <- with(newdata, eval(parse(text = parse_latex_table(mod_formulas_ltx_x1))))
  predx2_ltx <- with(newdata, eval(parse(text = parse_latex_table(mod_formulas_ltx_x2))))

  expect_equal(c(predx1, predx2), c(predx1_ltx, predx2_ltx))
})
