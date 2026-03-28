test_that("print() without term delegates to summary() and prints overview", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "bs") + s(x2, bs = "cr"), data = dat)
  mod_formulas <- gam2formula(mod)

  out <- capture.output(result <- print(mod_formulas))

  expect_true(any(grepl("gam2formula object with 2 derived formulas", out)))
  expect_true(any(grepl("x1, x2", out)))
  expect_true(any(grepl("Original call", out)))

  expect_s3_class(result, "gam2formula")
})


test_that("print() with format = 'latex' produces LaTeX table with coefficients", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "bs") + s(x2, bs = "cr"), data = dat)
  mod_formulas <- gam2formula(mod)

  out <- capture.output(print(mod_formulas, term = "x1", format = "latex"))
  expect_true(any(grepl("tabular", out)))
  expect_true(any(grepl("Coefficient", out)))
})

test_that("print() errors when format is given without term", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "bs"), data = dat)
  mod_formulas <- gam2formula(mod)

  expect_error(print(mod_formulas, format = "latex"), regexp = "No term")
})
