test_that("gam2formula() runs without errors or warnings", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ factor(x0) + s(x1, bs = "bs", m = c(4, 1)) + s(x2, bs = "ps") + s(x3, bs = "cr", k = 18),
             data = dat)
  
  expect_no_warning(gam2formula(mod))
  expect_no_error(gam2formula(mod))
})

test_that("gam2formula() throws error under manual knot placement", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "bs", k = 6) + s(x2, bs = "bs", k = 6),
           data = dat, knots = list(x2 = seq(-1, 2, length.out = 10)))

  expect_error(gam2formula(mod), regexp = "x2")
})

test_that("gam2formula() throws error when discrete = TRUE", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- bam(y ~ s(x1, bs = "bs", k = 6) + s(x2, bs = "bs", k = 6),
           data = dat, knots = list(x2 = seq(-1, 2, length.out = 10)), discrete = TRUE)

  expect_error(gam2formula(mod), regexp = "discrete")
})

test_that("gam2formula() throws warning when 'by =' is used and excludes terms", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "bs") + s(x2, bs = "bs", by = x0), data = dat)

  expect_warning(gam2formula(mod), regexp = "by")
  expect_equal(nrow(suppressWarnings(gam2formula(mod))), 1)
})

test_that("gam2formula() throws error when no supported terms are included", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ s(x1, bs = "tp") + te(x1, x2), data = dat)

  expect_error(gam2formula(mod), regexp = "Supported types")
})

test_that("gam2formula() throws error on model with no smooth terms", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ x1 + x2, data = dat)

  expect_error(gam2formula(mod), regexp = "No smooth terms")
})
