% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/configure_ltreb_project.R
\name{configure_ltreb_project}
\alias{configure_ltreb_project}
\title{Configure LTREB project details for a EML project entity}
\usage{
configure_ltreb_project()
}
\value{
establishes in the R environment upon package load a EML::project
entity specific to the Sycamore Creek LTREB. If appropriate to include in a
dataset, 'ltrebProject' should be referenced with the project argument when
constructing a EML::dataset.
}
\description{
configure_ltreb_project establishes an EML::project with the
elements: (1) personnel, (2) project abstract, and (3) funding (grant
numbers).
}
\details{
configure_ltreb_project establishes an EML::project with the
elements: (1) personnel, (2) project abstract, and (3) funding (grant
numbers).
}
