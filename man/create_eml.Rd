% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_eml.R
\name{create_eml}
\alias{create_eml}
\title{create_eml}
\usage{
create_eml()
}
\value{
EML eml entity is returned.
}
\description{
create_eml generates a EML entity of type eml
}
\details{
A eml entity is created from objects defined in the user's R
  environment. The function loA project scope (default is LTER) indicates
  contact and project details specific to the research. The abstract and
  methods must be in markdown format - by default the package will look for
  these files (abstract.md, methods.md) in the project directory but files of
  different names or locadtions can be passed.
}
\note{
create_eml will look for most inputs used to construct a eml entity,
  such as access and dataset, in the working environment; these parameters
  are not passed directly to the function and must exist in the working
  environment.

Some parameters, such access, are loaded in the backgroud when the
  package is loaded and not called directly by the user.
}
