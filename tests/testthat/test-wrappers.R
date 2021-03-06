# Zelig 4 ls wrapper working ---------------------------------------------------

test_that('ls wrapper continuous covar -- quickstart (Zelig 4 syntax)', {
    z4 <- zelig(Fertility ~ Education, data = swiss, model = 'ls', cite = FALSE)
  
    # extract education coefficient parameter estimate and compare to reference
    expect_equivalent(round(as.numeric(z4$getcoef()[[1]][2]), 7), -0.8623503)
})

# Test missing model argument error---------------------------------------------

test_that('missing model argument error', {
    expect_error(zelig(Fertility ~ Education, data = swiss),
               'Estimation model type not specified.\nSelect estimation model type with the model argument.'
  )
})

# Test non-supported model type error ------------------------------------------

test_that('non-supported model type error', {
    expect_error(zelig(Fertility ~ Education, data = swiss, model = 'TEST'),
                 'TEST is not a supported model type'
  )
})

# Test wrapper setx-------------------------------------------------------------

test_that('setx wrapper test x', {
    z4 <- zelig(Fertility ~ Education, data = swiss, model = 'ls')
  
    z4_set <- setx(z4)
    z4_set_vector <- round(as.vector(unlist(z4_set$setx.out)))
    expect_equivalent(z4_set_vector, c(1, 1, 11))
})

# FAIL TEST non-zelig objects --------------------------------------------------
test_that('setx and sim non-zelig object fail', {
    expect_error(setx('TEST'), 'Not a Zelig object.')
    expect_error(sim('TEST'), 'Not a Zelig object.')
})

# REQUIRE TEST sim wraper minimal working --------------------------------------
test_that('REQUIRE TEST sim wraper minimal working', {
    z5 <- zls$new()
    z5 <- zelig(Fertility ~ Education, data = swiss, model = 'ls')
    set_x <- setx(z5, Education = 5)
  
    zsimwrap <- sim(z5, x = set_x, num = 10)
    expect_equal(length(zsimwrap$getqi()), 10)
    
    z5$setx(Education = 5)
    zsimwrap <- sim(z5, num = 10)
    expect_equal(length(zsimwrap$getqi()), 10)
})

# REQUIRE TEST from_zelig_model returns expected fitted model object -----------------
test_that('REQUIRE TEST from_zelig_model returns expected fitted model object', {
    z5 <- zls$new()
    z5$zelig(Fertility ~ Education, data = swiss)
    expect_is(from_zelig_model(z5), class = 'lm')
})