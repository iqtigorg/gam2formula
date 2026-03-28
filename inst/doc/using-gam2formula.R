## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE)

## ----warning = FALSE----------------------------------------------------------
library(mgcv)
library(gam2formula)

## ----generate-----------------------------------------------------------------
set.seed(2)
dat <- gamSim(1, n = 200, dist = "normal", scale = 2, verbose = FALSE)
mod <- gam(y ~ s(x0, bs = "cr") +
               s(x1, bs = "bs", m = c(4, 2)) +
               s(x2, bs = "ps") + 
               s(x3), data = dat)

## ----plot---------------------------------------------------------------------
plot(mod, pages = 1)

## ----gam2formula--------------------------------------------------------------
mod_formulas <- gam2formula(mod)
summary(mod_formulas)

## ----inspect1-----------------------------------------------------------------
print(mod_formulas, term = "x0")

## ----inspect2-----------------------------------------------------------------
print(mod_formulas, term = "x1")

## ----inspect3-----------------------------------------------------------------
print(mod_formulas, term = "x2")

## ----compare1-----------------------------------------------------------------
# generate new predictor data
x0_newmin <- min(dat$x0) - 0.2
x0_newmax <- max(dat$x0) + 0.2
x0_new <- seq(x0_newmin, x0_newmax, length.out = 30)

# compute the linear predictor from coefficient table for new data points
y <- predict(mod_formulas, term = "x0", newdata = data.frame(x0 = x0_new))

# plot comparison
plot(mod, select = 1, xlim = c(x0_newmin, x0_newmax))
points(x0_new, y, col = "dodgerblue", pch = 16)

## ----compare2-----------------------------------------------------------------
# generate new predictor data
x1_newmin <- min(dat$x1) - 0.2
x1_newmax <- max(dat$x1) + 0.2
x1_new <- seq(x1_newmin, x1_newmax, length.out = 30)

# compute the linear predictor from coefficient table for new data points
y <- predict(mod_formulas, term = "x1", newdata = data.frame(x1 = x1_new))

# plot comparison
plot(mod, select = 2, xlim = c(x1_newmin, x1_newmax))
points(x1_new, y, col = "olivedrab", pch = 16)

## ----compare3-----------------------------------------------------------------
# generate new predictor data
x2_newmin <- min(dat$x2) - 0.2
x2_newmax <- max(dat$x2) + 0.2
x2_new <- seq(x2_newmin, x2_newmax, length.out = 30)

# compute the linear predictor from coefficient table for new data points
y <- predict(mod_formulas, term = "x2", newdata = data.frame(x2 = x2_new))

# plot comparison
plot(mod, select = 3, xlim = c(x2_newmin, x2_newmax))
points(x2_new, y, col = "tomato", pch = 16)

## ----latexform1, results='asis'-----------------------------------------------
print(mod_formulas, term = "x0", format = "latex")

## ----latexform2, results = 'asis'---------------------------------------------
print(mod_formulas, term = "x1", format = "latex")

## ----latexform3, results = 'asis'---------------------------------------------
print(mod_formulas, term = "x2", format = "latex")

## ----fitbinary----------------------------------------------------------------
library(mlbench)
data(PimaIndiansDiabetes)
PimaIndiansDiabetes$diabetes <- as.numeric(PimaIndiansDiabetes$diabetes == "pos")
mod <- gam(diabetes ~ s(age, bs = "cr", k = 8) + s(glucose, bs = "cr", k = 8), 
         family = "binomial", data = PimaIndiansDiabetes)
plot(mod, pages = 1)

## ----printbinary, results = 'asis'--------------------------------------------
mod_formulas <- gam2formula(mod)
print(mod_formulas, term = "age", format = "latex")
print(mod_formulas, term = "glucose", format = "latex")

## ----predbinary---------------------------------------------------------------
newdata <- data.frame(age = c(22, 53), glucose = c(92, 131)) # new observations

linpred <- coef(mod)["(Intercept)"] + # global intercept
  predict(mod_formulas, "age", newdata) + # linear predictor term for age
  predict(mod_formulas, "glucose", newdata) # linear predictor term for glucose

plogis(linpred)

## ----predbinaryauto-----------------------------------------------------------
as.numeric(mgcv::predict.gam(mod, newdata, type = "response"))

## ----predbinaryexclude--------------------------------------------------------
 # get full linear predictor except s(age) from mgcv
linpred <- as.numeric(predict(mod, newdata, exclude = "s(age)")) +
  predict(mod_formulas, "age", newdata) # then add age term gam2formula

plogis(linpred)

