#' Estimating a Statistical Model
#'
#' The zelig command estimates a variety of statistical
#' models. Use \code{zelig} output with \code{setx} and \code{sim} to compute
#' quantities of interest, such as predicted probabilities, expected values, and
#' first differences, along with the associated measures of uncertainty
#' (standard errors and confidence intervals).
#'
#' This documentation describes the \code{zelig} Zelig 4 compatibility wrapper
#' function.
#'
#' @param formula a symbolic representation of the model to be
#'   estimated, in the form \code{y \~\, x1 + x2}, where \code{y} is the
#'   dependent variable and \code{x1} and \code{x2} are the explanatory
#'   variables, and \code{y}, \code{x1}, and \code{x2} are contained in the
#'   same dataset. (You may include more than two explanatory variables,
#'   of course.)  The \code{+} symbol means ``inclusion'' not
#'   ``addition.''  You may also include interaction terms and main
#'   effects in the form \code{x1*x2} without computing them in prior
#'   steps; \code{I(x1*x2)} to include only the interaction term and
#'   exclude the main effects; and quadratic terms in the form
#'   \code{I(x1^2)}
#' @param model the name of a statistical model.
#'   For a list of supported models visit:
#'   \url{http://docs.zeligproject.org/en/latest/}.
#' @param data the name of a data frame containing the variables
#'   referenced in the formula, or a list of multiply imputed data frames
#'   each having the same variable names and row numbers (created by
#'   \code{mi})
#' @param ... additional arguments passed to \code{zelig},
#'   depending on the model to be estimated
#' @param by a factor variable contained in \code{data}. Zelig will subset
#'   the data frame based on the levels in the \code{by} variable, and
#'   estimate a model for each subset. This a particularly powerful option
#'   which will allow you to save a considerable amount of effort. For
#'   example, to run the same model on all fifty states, you could type:
#'   \code{z.out <- zelig(y ~ x1 + x2, data = mydata, model = 'ls', by = 'state')}
#'   You may also use \code{by} to run models using MatchIt subclass
#' @param cite If is set to 'TRUE' (default), the model citation will be
#' @return Depending on the class of model selected, \code{zelig} will return
#'   an object with elements including \code{coefficients}, \code{residuals},
#'   and \code{formula} which may be summarized using
#'   \code{summary(z.out)} or individually extracted using, for example,
#'   \code{z.out\$coefficients}. See the specific models listed above
#'   for additional output values, or simply type \code{names(z.out)}.
#'
#' @name zelig
#' @author Matt Owen, Kosuke Imai, Olivia Lau, and Gary King
#' Maintainer: Christopher Gandrud
#' @keywords package
#' @export

zelig <- function(formula, model, data, ..., by = NULL, cite = TRUE) {
    # .Deprecated('\nz$new() \nz$zelig(...)') Check if required model argument is
    # specified
    if (missing(model))
        stop("Estimation model type not specified.\nSelect estimation model type with the model argument.",
            call. = FALSE)

    # Zelig Core
    zeligmodels <- system.file(file.path("JSON", "zelig5models.json"),
                               package = "Zelig")
    models <- jsonlite::fromJSON(txt = readLines(zeligmodels))$zelig5models
    # Zelig Choice
    zeligchoicemodels <- system.file(file.path("JSON", "zelig5choicemodels.json"),
                                     package = "ZeligChoice")
    if (zeligchoicemodels != "")
        models <- c(models, jsonlite::fromJSON(txt = readLines(zeligchoicemodels))$zelig5choicemodels)
    # Zelig Panel
    zeligpanelmodels <- system.file(file.path("JSON", "zelig5panelmodels.json"),
                                    package = "ZeligPanel")
    if (zeligpanelmodels != "")
        models <- c(models, jsonlite::fromJSON(txt = readLines(zeligpanelmodels))$zelig5panelmodels)
    # Zelig GAM
    zeligammodels <- system.file(file.path("JSON", "zelig5gammodels.json"),
                                 package = "ZeligGAM")
    if (zeligammodels != "")
        models <- c(models, jsonlite::fromJSON(txt = readLines(zeligammodels))$zelig5gammodels)
    # Zelig Multilevel
    zeligmixedmodels <- system.file(file.path("JSON", "zelig5mixedmodels.json"),
        package = "ZeligMultilevel")
    if (zeligmixedmodels != "")
        models <- c(models, jsonlite::fromJSON(txt = readLines(zeligmixedmodels))$zelig5mixedmodels)
    # Aggregating all available models
    models4 <- list()
    for (i in seq(models)) {
        models4[[models[[i]]$wrapper]] <- names(models)[i]
    }

    model.init <- sprintf("z%s$new()", models4[[model]])
    if (length(model.init) == 0)
        stop(sprintf("%s is not a supported model type.", model), call. = FALSE)
    z5 <- try(eval(parse(text = model.init)), silent = TRUE)
    if ("try-error" %in% class(z5))
        stop("Model '", model, "' not found")
    ## End: Zelig 5 models
    mf <- match.call()
    mf$model <- NULL
    mf$cite <- NULL
    mf[[1]] <- quote(z5$zelig)
    mf <- try(eval(mf, environment()), silent = TRUE)
    if ("try-error" %in% class(mf))
        z5$zelig(formula = formula, data = data, ..., by = by)
    if (cite)
        z5$cite()
    return(z5)
}

#' Setting Explanatory Variable Values
#'
#' The \code{setx} command uses the variables identified in
#' the \code{formula} generated by \code{zelig} and sets the values of
#' the explanatory variables to the selected values. Use \code{setx}
#' after \code{zelig} and before \code{sim} to simulate quantities of
#' interest.
#'
#' This documentation describes the \code{setx} Zelig 4 compatibility wrapper
#' function.
#'
#' @param obj output object from \code{zelig}
#' @param fn a list of functions to apply to the data frame
#' @param data a new data frame used to set the values of
#'   explanatory variables. If data = NULL (the default), the
#'   data frame called in zelig is used
#' @param cond   a logical value indicating whether unconditional
#'   (default) or conditional (choose \code{cond = TRUE}) prediction
#'   should be performed. If you choose \code{cond = TRUE}, \code{setx}
#'   will coerce \code{fn = NULL} and ignore the additional arguments in
#'   \code{\dots}. If \code{cond = TRUE} and \code{data = NULL},
#'   \code{setx} will prompt you for a data frame.
#' @param ... user-defined values of specific variables for overwriting the
#'   default values set by the function \code{fn}. For example, adding
#'   \code{var1 = mean(data\$var1)} or \code{x1 = 12} explicitly sets the value
#'   of \code{x1} to 12. In addition, you may specify one explanatory variable
#'   as a range of values, creating one observation for every unique value in
#'   the range of values
#' @return For unconditional prediction, \code{x.out} is a model matrix based
#'   on the specified values for the explanatory variables. For multiple
#'   analyses (i.e., when choosing the \code{by} option in \code{\link{zelig}},
#'   \code{setx} returns the selected values calculated over the entire
#'   data frame. If you wish to calculate values over just one subset of
#'   the data frame, the 5th subset for example, you may use:
#'   \code{x.out <- setx(z.out[[5]])}
#' @examples
#'
#' # Unconditional prediction:
#' data(turnout)
#' z.out <- zelig(vote ~ race + educate, model = 'logit', data = turnout)
#' x.out <- setx(z.out)
#' s.out <- sim(z.out, x = x.out)
#'
#' @author Matt Owen, Olivia Lau and Kosuke Imai
#' @seealso The full Zelig manual may be accessed online at
#'   \url{http://docs.zeligproject.org/en/latest/}
#' @keywords file
#' @export

setx <- function(obj, fn = NULL, data = NULL, cond = FALSE, ...) {
    # .Deprecated('\nz$new() \nz$zelig(...) \nz$setx() or z$setx1 or z$setrange')
    is_zelig(obj)

    x5 <- obj$copy()
    # This is the length of each argument in '...'s
    s <- list(...)
    if (length(s) > 0) {
        hold <- rep(1, length(s))
        for (i in 1:length(s)) {
            hold[i] <- length(s[i][[1]])
        }
    } else {
        hold <- 1
    }
    if (max(hold) > 1) {
        x5$setrange(...)
    } else {
        x5$setx(...)
    }
    return(x5)
}

#' Generic Method for Computing and Organizing Simulated Quantities of Interest
#'
#' Simulate quantities of interest from the estimated model
#' output from \code{zelig()} given specified values of explanatory
#' variables established in \code{setx()}. For classical \emph{maximum
#' likelihood} models, \code{sim()} uses asymptotic normal
#' approximation to the log-likelihood. For \emph{Bayesian models},
#' Zelig simulates quantities of interest from the posterior density,
#' whenever possible. For \emph{robust Bayesian models}, simulations
#' are drawn from the identified class of Bayesian posteriors.
#' Alternatively, you may generate quantities of interest using
#' bootstrapped parameters.
#'
#' This documentation describes the \code{sim} Zelig 4 compatibility wrapper
#' function.
#'
#' @param obj output object from \code{zelig}
#' @param x values of explanatory variables used for simulation,
#'   generated by \code{setx}. Not if ommitted, then \code{sim} will look for
#'   values in the reference class object
#' @param x1 optional values of explanatory variables (generated by a
#'   second call of \code{setx})
#'           particular computations of quantities of interest
#' @param y a parameter reserved for the computation of particular
#'          quantities of interest (average treatment effects). Few
#'          models currently support this parameter
#' @param num an integer specifying the number of simulations to compute
#' @param bootstrap currently unsupported
#' @param bootfn currently unsupported
#' @param cond.data currently unsupported
#' @param ... arguments reserved future versions of Zelig
#' @return The output stored in \code{s.out} varies by model. Use the
#'  \code{names} command to view the output stored in \code{s.out}.
#'  Common elements include:
#'  \item{x}{the \code{\link{setx}} values for the explanatory variables,
#'    used to calculate the quantities of interest (expected values,
#'    predicted values, etc.). }
#'  \item{x1}{the optional \code{\link{setx}} object used to simulate
#'    first differences, and other model-specific quantities of
#'    interest, such as risk-ratios.}
#'  \item{call}{the options selected for \code{\link{sim}}, used to
#'    replicate quantities of interest. }
#'  \item{zelig.call}{the original command and options for
#'    \code{\link{zelig}}, used to replicate analyses. }
#'  \item{num}{the number of simulations requested. }
#'  \item{par}{the parameters (coefficients, and additional
#'    model-specific parameters). You may wish to use the same set of
#'    simulated parameters to calculate quantities of interest rather
#'    than simulating another set.}
#'  \item{qi\$ev}{simulations of the expected values given the
#'    model and \code{x}. }
#'  \item{qi\$pr}{simulations of the predicted values given by the
#'    fitted values. }
#'  \item{qi\$fd}{simulations of the first differences (or risk
#'    difference for binary models) for the given \code{x} and \code{x1}.
#'    The difference is calculated by subtracting the expected values
#'    given \code{x} from the expected values given \code{x1}. (If do not
#'    specify \code{x1}, you will not get first differences or risk
#'    ratios.) }
#'  \item{qi\$rr}{simulations of the risk ratios for binary and
#'    multinomial models. See specific models for details.}
#'  \item{qi\$ate.ev}{simulations of the average expected
#'    treatment effect for the treatment group, using conditional
#'    prediction. Let \eqn{t_i} be a binary explanatory variable defining
#'    the treatment (\eqn{t_i=1}) and control (\eqn{t_i=0}) groups. Then the
#'    average expected treatment effect for the treatment group is
#'    \deqn{ \frac{1}{n}\sum_{i=1}^n [ \, Y_i(t_i=1) -
#'      E[Y_i(t_i=0)] \mid t_i=1 \,],}
#'    where \eqn{Y_i(t_i=1)} is the value of the dependent variable for
#'    observation \eqn{i} in the treatment group. Variation in the
#'    simulations are due to uncertainty in simulating \eqn{E[Y_i(t_i=0)]},
#'    the counterfactual expected value of \eqn{Y_i} for observations in the
#'    treatment group, under the assumption that everything stays the
#'    same except that the treatment indicator is switched to \eqn{t_i=0}. }
#'  \item{qi\$ate.pr}{simulations of the average predicted
#'    treatment effect for the treatment group, using conditional
#'    prediction. Let \eqn{t_i} be a binary explanatory variable defining
#'    the treatment (\eqn{t_i=1}) and control (\eqn{t_i=0}) groups. Then the
#'    average predicted treatment effect for the treatment group is
#'    \deqn{ \frac{1}{n}\sum_{i=1}^n [ \, Y_i(t_i=1) -
#'      \widehat{Y_i(t_i=0)} \mid t_i=1 \,],}
#'    where \eqn{Y_i(t_i=1)} is the value of the dependent variable for
#'    observation \eqn{i} in the treatment group. Variation in the
#'    simulations are due to uncertainty in simulating
#'    \eqn{\widehat{Y_i(t_i=0)}}, the counterfactual predicted value of
#'    \eqn{Y_i} for observations in the treatment group, under the
#'    assumption that everything stays the same except that the
#'    treatment indicator is switched to \eqn{t_i=0}.}
#'
#' @author Christopher Gandrud, Matt Owen, Olivia Lau and Kosuke Imai
#' @export

sim <- function(obj, x, x1, y = NULL, num = 1000, bootstrap = F,
    bootfn = NULL, cond.data = NULL, ...) {
    # .Deprecated('\nz$new() \n[...] \nz$sim(...)')
    is_zelig(obj)

    if (!missing(x)) s5 <- x$copy()
    if (!missing(x1)) {
        s15 <- x1$copy()
        if (!is.null(s15$setx.out$x)) {
            s5$setx.out$x1 <- s15$setx.out$x
            s5$bsetx1 <- TRUE
        }
        if (!is.null(s15$setx.out$range)) {
            s5$range1 <- s15$range
            s5$setx.out$range1 <- s15$setx.out$range
            s5$bsetrange1 <- TRUE
        }
    }
    if (missing(x)) s5 <- obj$copy()

    s5$sim(num = num)
    return(s5)
}

#' Extract the original fitted model object from a \code{zelig} estimation
#'
#' @param obj a zelig object with an estimated model
#'
#' @details Extracts the original fitted model object from a \code{zelig}
#'   estimation. This can be useful for passing output to non-Zelig
#'   post-estimation functions and packages such as texreg and stargazer
#'   for creating well-formatted presentation document tables.
#'
#' @examples
#' z5 <- zls$new()
#' z5$zelig(Fertility ~ Education, data = swiss)
#' from_zelig_model(z5)
#'
#' @author Christopher Gandrud
#' @export

from_zelig_model <- function(obj) {
    is_zelig(obj)

    f5 <- obj$copy()
    return(f5$from_zelig_model())
}
