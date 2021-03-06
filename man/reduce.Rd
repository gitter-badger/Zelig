% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{reduce}
\alias{reduce}
\title{Calculate the reduced dataset to be used in \code{\link{setx}}}
\usage{
reduce(dataset, s, formula, data, avg = avg)
}
\arguments{
\item{dataset}{Zelig object data, possibly split to deal with \code{by} argument}

\item{s}{list of variables and their tentative \code{setx} values}

\item{formula}{a simplified version of the Zelig object formula (typically with 1 on the lhs)}

\item{data}{Zelig object data}

\item{avg}{function of data transformations}
}
\value{
a list of all the model variables either at their central tendancy or their \code{setx} value
}
\description{
#' This method is used internally
}
\author{
Christine Choirat
}
\keyword{internal}
