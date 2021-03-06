# REQUIRE TEST Monte Carlo poisson ---------------------------------------------
test_that('REQUIRE TEST Monte Carlo poisson', {
    z <- zpoisson$new()
    test.poisson <- z$mcunit(minx = 0, plot = FALSE)
    expect_true(test.poisson)
})

# REQUIRE TEST poisson example -------------------------------------------------
test_that('REQUIRE TEST poisson example', {
    data(sanction)
    z.out <- zelig(num ~ target + coop, model = "poisson", data = sanction)
    x.out <- setx(z.out)
    s.out <- sim(z.out, x = x.out)
    expect_error(s.out$graph(), NA)
})
