# REQUIRE TEST Monte Carlo test ls ---------------------------------------------

test_that('REQUIRE TEST ls Monte Carlo', {
    z <- zls$new()
    test.ls <- z$mcunit(plot = FALSE)
    expect_true(test.ls)
})

# REQUIRE TEST ls with continuous covar -----------------------------------------

test_that('REQUIRE TEST ls continuous covar -- quickstart (Zelig 5 syntax)', {
    z5 <- zls$new()
    z5$zelig(Fertility ~ Education, data = swiss)

    # extract education coefficient parameter estimate and compare to reference
    expect_equivalent(round(as.numeric(z5$getcoef()[[1]][2]), 7), -0.8623503)
})


# REQUIRE TEST ls with by -------------------------------------------------------

test_that('REQUIRE TEST ls with by', {
    # Majority Catholic dummy
    swiss$maj_catholic <- cut(swiss$Catholic, breaks = c(0, 51, 100))

    z5 <- zls$new()
    z5$zelig(Fertility ~ Education, data = swiss, by = 'maj_catholic')
})

# gim method tests -------------------------------------------------------------

#test_that('REQUIRE TESTls gim method', {
    #z5$gim()
#})


# REQUIRE TEST for sim with ls models including factor levels ---------------------
test_that('REQUIRE TEST for sim with models including factor levels', {
    expect_is(iris$Species, 'factor')
    z.out <- zelig(Petal.Width ~ Petal.Length + Species, data = iris, 
                   model = "ls")
    x.out1 <- setx(z.out, Petal.Length = 1:10)
    sims1 <- sim(z.out, x.out1)
    expect_equal(length(sims1$sim.out$range), 10)
    
    x.out2 <- setx(z.out, Petal.Length = 1:10, fn = list(numeric = Median))
    sims2 <- sim(z.out, x.out2)
    expect_equal(length(sims2$sim.out$range), 10)
})

# REQUIRE TEST for set with ls models including factors set within zelig call --
test_that('REQUIRE TEST for set with ls models including factors set within zelig call', {
    data(macro)
    z1 <- zelig(unem ~ gdp + trade + capmob + as.factor(country), 
             model = "ls", data = macro)
    setUS1 <- setx(z1, country = "United States")
  
    macro$country <- as.factor(macro$country)
    z2 <- zelig(unem ~ gdp + trade + capmob + country, 
                model = "ls", data = macro)
    setUS2 <- setx(z2, country = "United States")
  
    expect_equal(setUS1$setx.out$x$mm[[1]][[16]], 1)
    expect_equal(setUS1$setx.out$x$mm[[1]][[16]], 
                 setUS2$setx.out$x$mm[[1]][[16]])
})
