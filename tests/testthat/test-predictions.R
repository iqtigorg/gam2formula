test_that("Predictions from derived formulas match predictions from mgcv", {
  dat <- gamSim(5, n = 1e2, verbose = FALSE)
  mod <- gam(y ~ factor(x0) + s(x1, bs = "bs", m = c(4, 1)) + s(x2, bs = "ps") + s(x3, bs = "cr", k = 18),
             data = dat)
  mod_formulas <- gam2formula(mod)
  newdata <- data.frame(x0 = factor(1),
                        x1 = runif(10, -1, 2),
                        x2 = runif(10, -1, 2),
                        x3 = runif(10, -1, 2))

  predx1 <- predict(mod_formulas, "x1", newdata)
  predx2 <- predict(mod_formulas, "x2", newdata)
  predx3 <- predict(mod_formulas, "x3", newdata)

  auto <- as.numeric(predict(mod, newdata))
  manual <- coef(mod)["(Intercept)"] + predx1 + predx2 + predx3

  expect_equal(auto, manual)
})
